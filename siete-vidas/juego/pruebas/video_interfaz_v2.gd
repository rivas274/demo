extends SceneTree
## Video corto (unos 75 s) de la interfaz v2 y la salud de 9 huellas, para el creador: la sala con un diálogo de
## Valeria y otro de Felipe, un cartel y un logro, un golpe, la pausa con el bolsillo y la Ficha, la pelea con A.S.P.I.
## (barra del jefe con fases, daño reciente, aviso de oportunidad, globito) y un desmayo con los 9 gatitos fantasma y
## «Siesta táctica.». Se graba con el modo de película de Godot:
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --resolution 640x360 --write-movie <carpeta>/c.png --fixed-fps 30 --script res://pruebas/video_interfaz_v2.gd
##   ffmpeg -framerate 30 -i <carpeta>/c%08d.png -i <carpeta>/c.wav -vf scale=1280:720:flags=neighbor -c:v libx264 -pix_fmt yuv420p -crf 20 -c:a aac interfaz-v2.mp4

var sala: Nivel
var guion: GuionNivel1
var felipe: Felipe


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	Opciones.reducir_movimiento = false
	Opciones.texto_grande = false
	Opciones.golpes = Opciones.Golpes.NORMAL
	sala = load("res://escenas/nivel_1.tscn").instantiate()
	guion = sala.guion
	sala.mostrar_titulo = false
	guion.peligros_activos = false
	root.add_child(sala)
	felipe = sala.get_node("Felipe")
	var t := sala.travesuras
	await _segundos(1.0)
	# La sala: camina hasta el sofá; Valeria habla arriba.
	t.dialogo.limpiar()
	await _caminar(1.0, 1.6)
	t.dialogo.decir("valeria", "¿Quién dejó abierta la puerta del balcón? Felipe, si fuiste tú, hoy no hay atún para nadie.", Dialogo.VALERIA_ENOJADA, true)
	await _segundos(4.5)
	t.dialogo.decir("felipe", "Su Majestad no rompió nada. El vaso decidió saltar solo.", 7, true)
	await _segundos(4.0)
	t.dialogo.limpiar()
	# Un cartel de travesura y su logro (de a uno).
	t.hud.cartel("UI_TRAVESURA_CUMPLIDA", "AGENDA_ROBAR_EL_ALMUERZO_DE", false)
	await _segundos(3.0)
	sala.desbloquear_logro("LOGRO_COLECCIONISTA_DE_CALCETINES")
	await _segundos(3.0)
	# Un golpe: la huella destella, rebota y queda vacía; la cara hace una mueca.
	felipe.vida.restante_invulnerable = 0.0
	felipe.recibir_dano(2, felipe.global_position.x + 20.0)
	await _segundos(2.0)
	felipe.vida.restante_invulnerable = 0.0
	felipe.recibir_dano(2, felipe.global_position.x - 20.0)
	await _segundos(2.0)
	# La pausa: el bolsillo dice «7 de 9» y la Ficha, los kilos.
	sala.pantallas.modo = Pantallas.Modo.PAUSA
	await _cuadros_reales(30 * 3)
	sala.pantallas.menu_pausa.get_node("Bolsillo").grab_focus()
	await _cuadros_reales(30)
	sala.pantallas.menu_pausa.get_node("Ficha").grab_focus()
	await _cuadros_reales(30)
	sala.pantallas.menu_pausa.get_node("Opciones").grab_focus()
	await _cuadros_reales(15)
	sala.pantallas.pausa.visible = false
	sala.pantallas.opciones.abrir()
	await _cuadros_reales(30 * 2)
	sala.pantallas.opciones.cerrar()
	sala.pantallas.modo = Pantallas.Modo.JUGANDO
	await _segundos(0.5)
	# Texto grande, un momento.
	Opciones.texto_grande = true
	t.dialogo.decir("felipe", "Tengo nueve. Las uso cuando quiero.", 7, true)
	await _segundos(3.5)
	t.dialogo.limpiar()
	Opciones.texto_grande = false
	await _pelea()
	quit()


## La pelea: la entrada, la barra con fases, golpes de verdad, un apagado y el desmayo con su siesta táctica.
func _pelea() -> void:
	var batalla := guion.batalla
	var aspi := guion.aspi
	sala.travesuras.dialogo.limpiar()
	# Pasa por el cojín junto a la puerta del estudio: ahí reaparece si se desmaya (y le llena las huellas).
	felipe.global_position = Vector2(Nivel1.DESCANSOS[1].get_center().x, Nivel1.SUELO)
	felipe.velocity = Vector2.ZERO
	await _segundos(1.2)
	felipe.global_position = Vector2(6842, Nivel1.SUELO)
	felipe.velocity = Vector2.ZERO
	await _segundos(0.6)
	await _caminar(1.0, 1.4)
	await _esperar_que(func() -> bool: return batalla.fase == PeleaJefe.Fase.PELEA, 60 * 12)
	await _segundos(1.0)
	felipe.vida.restante_invulnerable = 0.0
	# Se queda cerca de ella: las embestidas y el roce le quitan huellas.
	for i in 3:
		await _caminar(1.0 if felipe.global_position.x < aspi.global_position.x else -1.0, 0.8)
		await _segundos(1.6)
	sala.travesuras.dialogo.decir("felipe", "¿Eso es todo?", 7)
	await _segundos(2.0)
	# Un apagado: llena, el aviso limón con flecha, y Felipe le cae encima.
	batalla.quedar_vulnerable("deposito")
	await _segundos(2.5)
	felipe.global_position = aspi.global_position + Vector2(-70, 0)
	felipe.velocity = Vector2.ZERO
	await _segundos(0.3)
	Input.action_press("interactuar")
	await _segundos(0.2)
	Input.action_release("interactuar")
	await _esperar_que(func() -> bool: return not batalla.llena, 60 * 6)
	await _segundos(3.0)
	# El desmayo: con la última huella, un golpe; suben los 9 gatitos fantasma y vuelve con todo lleno.
	felipe.medias = 2
	await _segundos(0.3)
	felipe.vida.restante_invulnerable = 0.0
	felipe.recibir_dano(2, felipe.global_position.x + 20.0)
	await _segundos(4.5)
	await _caminar(1.0, 1.0)
	await _segundos(2.0)


func _caminar(direccion: float, segundos: float) -> void:
	var accion := "mover_derecha" if direccion > 0.0 else "mover_izquierda"
	Input.action_press(accion)
	await _segundos(segundos)
	Input.action_release(accion)


## Con --fixed-fps 30, cada cuadro dibujado es 1/30 s del juego.
func _segundos(s: float) -> void:
	for i in int(s * 30.0):
		await process_frame


func _cuadros_reales(n: int) -> void:
	for i in n:
		await process_frame


func _esperar_que(condicion: Callable, maximo: int) -> void:
	for i in maximo:
		if condicion.call():
			return
		await physics_frame
