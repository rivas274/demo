extends SceneTree
## Capturas reales del juego con la interfaz v2 («A + C») y la salud de 9 huellas, para compararlas con la lámina
## aprobada (siete-vidas/diseno/revisiones/capturas/interfaz-rediseno/kit-v2.png): exploración con diálogo, pelea con
## la barra del jefe, el aviso de oportunidad y el globito, cartel de travesura, logro, pausa con el bolsillo y la
## Ficha, texto grande, pocas huellas, desmayo (los 9 gatitos fantasma), opciones, libreta y resumen del día.
## Necesita pantalla; en la nube, con xvfb-run:
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/capturas_interfaz_v2.gd -- <carpeta>

var _carpeta := "user://capturas_v2"
var sala: Nivel
var guion: GuionNivel1
var felipe: Felipe


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_carpeta = args[0]
	DirAccess.make_dir_recursive_absolute(_carpeta)
	_correr.call_deferred()


func _correr() -> void:
	Opciones.reducir_movimiento = false
	Opciones.texto_grande = false
	sala = load("res://escenas/nivel_1.tscn").instantiate()
	guion = sala.guion
	sala.mostrar_titulo = false
	guion.peligros_activos = false
	root.add_child(sala)
	felipe = sala.get_node("Felipe")
	var t := sala.travesuras
	await _esperar(60)
	# 1. Exploración: la salud (6 y media de 9) y Valeria habla arriba.
	t.dialogo.limpiar()
	await _poner_en(Vector2(300, Nivel1.SUELO))
	felipe.medias = 13
	await _esperar(30)
	t.dialogo.decir("valeria", "¿Quién dejó abierta la puerta del balcón? Felipe, si fuiste tú, hoy no hay atún para nadie.", Dialogo.VALERIA_ENOJADA, true)
	await _esperar(150)
	await _capturar("01-exploracion-dialogo")
	# 1b. Felipe habla (sombra ámbar).
	t.dialogo.limpiar()
	t.dialogo.decir("felipe", "Su Majestad no rompió nada. El vaso decidió saltar solo.", 7, true)
	await _esperar(90)
	await _capturar("01b-dialogo-felipe")
	t.dialogo.limpiar()
	# 2. Un golpe: la huella destella y rebota (cara con mueca).
	felipe.vida.restante_invulnerable = 0.0
	felipe.recibir_dano(2, felipe.global_position.x + 20.0)
	await _cuadros(5)
	await _capturar("02-golpe-huella")
	await _esperar(80)
	# 3. Cartel de travesura y después el logro (de a uno, en la zona C).
	t.dialogo.limpiar()
	t.hud.cartel("UI_TRAVESURA_CUMPLIDA", "AGENDA_ROBAR_EL_ALMUERZO_DE", false)
	await _esperar_que(func() -> bool: return t.anuncios.actual.get("tipo", "") == "cartel", 200)
	await _esperar(20)
	await _capturar("03-cartel")
	await _esperar_que(func() -> bool: return t.anuncios.actual.is_empty(), 300)
	sala.desbloquear_logro("LOGRO_COLECCIONISTA_DE_CALCETINES")
	await _esperar_que(func() -> bool: return t.anuncios.actual.get("tipo", "") == "logro", 300)
	await _esperar(20)
	await _capturar("04-logro")
	await _esperar_que(func() -> bool: return t.anuncios.actual.is_empty(), 300)
	# 5. Pocas huellas: laten y «Esto es un empate técnico.».
	t.dialogo.limpiar()
	felipe.medias = 8
	await _esperar(2)
	felipe.vida.restante_invulnerable = 0.0
	felipe.recibir_dano(2, felipe.global_position.x + 20.0)
	await _esperar(70)
	await _capturar("05-pocas-huellas")
	# 6. Pausa: lista, bolsillo y Ficha.
	t.dialogo.limpiar()
	await _esperar(90)
	sala.pantallas.modo = Pantallas.Modo.PAUSA
	await _cuadros(30)
	await _capturar("06-pausa")
	# 7. Opciones (accesibilidad primero).
	sala.pantallas.pausa.visible = false
	sala.pantallas.opciones.abrir()
	await _cuadros(10)
	await _capturar("07-opciones")
	sala.pantallas.opciones.cerrar()
	sala.pantallas.modo = Pantallas.Modo.JUGANDO
	await _cuadros(5)
	# 8. Texto grande: huellas, diálogo de Felipe (paginado si hace falta) y el logro, al doble.
	Opciones.texto_grande = true
	felipe.medias = 13
	await _esperar(10)
	t.dialogo.decir("felipe", "Su Majestad no rompió nada. El vaso decidió saltar solo.", 7, true)
	await _esperar(120)
	await _capturar("08-texto-grande")
	t.dialogo.limpiar()
	sala.desbloquear_logro("LOGRO_GALERIA_VIRAL")
	await _esperar_que(func() -> bool: return t.anuncios.actual.get("tipo", "") == "logro", 300)
	await _esperar(20)
	await _capturar("08b-texto-grande-logro")
	await _esperar_que(func() -> bool: return t.anuncios.actual.is_empty(), 300)
	Opciones.texto_grande = false
	# 9. Desmayo: las 9 huellas suben como gatitos fantasma.
	t.dialogo.limpiar()
	felipe.medias = 2
	await _esperar(2)
	felipe.vida.restante_invulnerable = 0.0
	felipe.recibir_dano(2, felipe.global_position.x + 20.0)
	await _esperar(30)
	await _capturar("09-desmayo-fantasmas")
	await _esperar(25)
	await _capturar("09b-desmayo-se-miran")
	await _esperar_que(func() -> bool: return felipe.estado != Felipe.Estado.DESMAYADO, 200)
	await _esperar(40)
	await _capturar("10-siesta-tactica")
	# 11. Libreta y resumen.
	t.dialogo.limpiar()
	await _esperar(60)
	t.cumplir("laser")
	await _esperar(5)
	t.libreta.abrir()
	await _cuadros(10)
	await _capturar("11-libreta")
	t.libreta.cerrar()
	await _esperar(10)
	var resumen := t.mostrar_resumen()
	for i in 300:
		await process_frame
	await _capturar("12-resumen")
	resumen.cerrar()
	await _esperar(10)
	await _pelea()
	quit()


## La pelea: barra del jefe (A2), el aviso de oportunidad con borde limón y flecha, y el globito de Felipe.
func _pelea() -> void:
	var batalla := guion.batalla
	var aspi := guion.aspi
	sala.travesuras.dialogo.limpiar()
	felipe.vida.restante_invulnerable = 99999.0
	await _poner_en(Vector2(6842, Nivel1.SUELO))
	await _poner_en(Vector2(6990, Nivel1.SUELO))
	await _esperar_que(func() -> bool: return batalla.fase != PeleaJefe.Fase.ESPERANDO, 120)
	batalla.saltar_entrada()
	await _esperar_que(func() -> bool: return batalla.fase == PeleaJefe.Fase.PELEA, 300)
	for nombre: String in ["embestida", "bola"]:
		batalla.conducta(nombre).set("reloj_espera", 9999.0)
	(batalla.conducta("embestida") as AtaqueEmbestida).espera = PackedFloat32Array([9999.0])
	(batalla.conducta("bola") as AtaqueBolaPelo).espera = 9999.0
	felipe.vida.restante_invulnerable = 0.0
	felipe.medias = 8
	await _poner_en(Vector2(7060, Nivel1.SUELO))
	await _esperar_que(func() -> bool: return not batalla.presentacion.cartel_visible(), 400)
	await _esperar(30)
	sala.travesuras.dialogo.decir("felipe", "¿Eso es todo?", 7)
	await _esperar(20)
	await _capturar("13-pelea-barra-globito")
	# Golpe al jefe: la barra baja con la capa de daño reciente (la pelea cuenta las fases vencidas).
	batalla.vencidas += 1
	await _esperar(6)
	await _capturar("14-pelea-dano-reciente")
	await _esperar(60)
	await _poner_en(Vector2(6930, Nivel1.SUELO))
	batalla.quedar_vulnerable("deposito")
	await _esperar(40)
	await _capturar("15-pelea-aviso-oportunidad")


func _poner_en(posicion: Vector2) -> void:
	felipe.global_position = posicion
	felipe.velocity = Vector2.ZERO
	await _esperar(20)


func _esperar_que(condicion: Callable, maximo: int) -> void:
	for i in maximo:
		if condicion.call():
			return
		await physics_frame


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame


func _cuadros(cuadros: int) -> void:
	for i in cuadros:
		await process_frame


func _capturar(nombre: String) -> void:
	await process_frame
	await process_frame
	var imagen := root.get_texture().get_image()
	imagen.save_png("%s/%s.png" % [_carpeta, nombre])
	print("captura ", nombre)
