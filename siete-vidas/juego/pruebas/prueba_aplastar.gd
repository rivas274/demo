extends SceneTree
## Prueba de «Aplastar» (pelea con A.S.P.I. v5): con A.S.P.I. vulnerable y al alcance, el botón de acción hace un salto
## dirigido que SIEMPRE cae sobre su tapa y la apaga, desde el piso y desde cada mueble del estudio (silla, escritorio,
## repisa de las macetas, repisa del gato, caja de los libros y librero bajo). También: le gana a lo que se puede tirar
## al lado, fuera de alcance no se ofrece, y sin estar vulnerable tampoco. Sin ventana:
##   godot --headless --path siete-vidas/juego --fixed-fps 60 --script res://pruebas/prueba_aplastar.gd
## Termina con código 0 si todo pasa y 1 si algo falla.

const MUEBLES := ["Silla del estudio", "Escritorio", "Repisa de las macetas", "Repisa del gato", "Caja de los libros", "Librero bajo"]

var _fallos: Array[String] = []
var sala: Nivel
var felipe: Felipe
var batalla: BatallaAspi
var aspi: Enemigo


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	sala = load("res://escenas/nivel_1.tscn").instantiate()
	sala.mostrar_titulo = false
	root.add_child(sala)
	felipe = sala.get_node("Felipe")
	batalla = sala.guion.batalla
	aspi = sala.guion.aspi
	felipe.vida.restante_invulnerable = 99999.0
	await _esperar(30)
	await _parar(Vector2(6990, Nivel1.SUELO), 10)
	await _esperar_que(func() -> bool: return batalla.fase != PeleaJefe.Fase.ESPERANDO, 120)
	batalla.saltar_entrada()
	await _esperar_que(func() -> bool: return batalla.fase == PeleaJefe.Fase.PELEA, 300)
	for nombre: String in ["embestida", "bola", "soplido"]:
		var conducta := batalla.conducta(nombre)
		if conducta:
			conducta.set("reloj_espera", 99999.0)
	(batalla.conducta("embestida") as AtaqueEmbestida).espera = PackedFloat32Array([99999.0])
	(batalla.conducta("bola") as AtaqueBolaPelo).espera = 99999.0
	var datos := batalla.reacciones.datos

	# Sin estar vulnerable no se ofrece; vulnerable pero lejos, tampoco.
	await _preparar(Vector2(7000, Nivel1.SUELO), 7300.0, false)
	_comprobar(felipe.objeto_cercano() != batalla.aplastar, "Sin estar vulnerable, «Aplastar» no se ofrece")
	await _preparar(Vector2(6990, Nivel1.SUELO), 7300.0, true)
	_comprobar(felipe.objeto_cercano() != batalla.aplastar, "Vulnerable pero a más de %.0f px en el piso, no se ofrece" % datos.alcance_piso)

	# Desde el piso.
	await _caso("el piso", Vector2(6990, Nivel1.SUELO), _x_libre(6990.0, datos.alcance_piso))
	# Desde cada mueble del estudio: A.S.P.I. en el piso al costado (o debajo), donde puede quedarse vulnerable.
	for nombre: String in MUEBLES:
		var mueble := Nivel1.rect_pieza(nombre)
		var pies := Vector2(roundf(mueble.get_center().x), mueble.position.y)
		await _caso(nombre.to_lower(), pies, _x_libre(pies.x, datos.alcance_mueble))

	# En corto (charco del apagón) también se ofrece.
	await _preparar(Vector2(6990, Nivel1.SUELO), _x_libre(6990.0, datos.alcance_piso), true, "charco")
	_comprobar(felipe.objeto_cercano() == batalla.aplastar, "En corto (charco del apagón) también se ofrece «Aplastar»")

	# Le gana a lo que se puede tirar: en el escritorio, junto al vaso.
	var vaso: Objeto = null
	for objeto in batalla.municion:
		if objeto.tipo in ["vaso", "taza"] and not objeto.tirable.roto:
			vaso = objeto
	if vaso:
		await _preparar(vaso.global_position + Vector2(-16, 0), _x_libre(vaso.global_position.x, datos.alcance_mueble), true)
		_comprobar(felipe.objeto_cercano() == batalla.aplastar and sala.travesuras.indicador.objeto == batalla.aplastar and sala.travesuras.indicador.verbo == "", "Le gana a lo que se puede tirar al lado (%s): el Indicador marca a A.S.P.I. y no repite la burbuja (el aviso amarillo dice «[E] ¡APLASTA!»)" % vaso.tipo)
	else:
		_comprobar(false, "No quedó un vaso ni una taza en el escritorio para probar la prioridad")

	print("Resultado: %d fallos" % _fallos.size())
	for fallo in _fallos:
		print("FALLÓ: " + fallo)
	quit(1 if _fallos.size() > 0 else 0)


## Una x del piso donde A.S.P.I. puede quedarse vulnerable (no la corre RemateAspi.piso_libre), a menos de `alcance`
## de `x` y lo más cerca posible de 90 px (ni encima ni en el borde del alcance).
func _x_libre(x: float, alcance: float) -> float:
	var mejor := INF
	var candidato := x - alcance + 10.0
	while candidato <= x + alcance - 10.0:
		var dentro := candidato >= aspi.patrulla.limite_izquierdo and candidato <= aspi.patrulla.limite_derecho
		if dentro and absf(batalla.remate.piso_libre(candidato) - candidato) < 0.5 and absf(absf(candidato - x) - 90.0) < absf(absf(mejor - x) - 90.0):
			mejor = candidato
		candidato += 5.0
	return mejor


## Deja a A.S.P.I. en `x_aspi` (vulnerable o no) y a Felipe parado en `pies`, con la pelea en la fase 1.
func _preparar(pies: Vector2, x_aspi: float, vulnerable: bool, motivo := "deposito") -> void:
	batalla.vencidas = 0
	batalla.llena = false
	batalla.reinicio = 0.0
	batalla.reacciones.despertando = 0.0
	batalla.reacciones.mareada = 0.0
	batalla.terminar_ataque()
	batalla.limpiar.limpiando = false
	batalla.manchas.clear()
	batalla.tipos_mancha.clear()
	batalla.nodos_mancha.clear()
	aspi.global_position = Vector2(x_aspi, Nivel1.SUELO)
	aspi.velocity = Vector2.ZERO
	aspi.patrulla.quieta = true
	await _parar(pies + Vector2(0, -2), 20)
	if vulnerable:
		batalla.quedar_vulnerable(motivo)
		await _esperar(25)


func _caso(donde: String, pies: Vector2, x_aspi: float) -> void:
	await _preparar(pies, x_aspi, true)
	var ofrece := felipe.objeto_cercano() == batalla.aplastar
	var antes := batalla.aplastar.aplastes
	var apagados := batalla.apagados
	var silencios := batalla.remate.congelados
	await _tocar("interactuar")
	await _esperar_que(func() -> bool: return batalla.aplastar.aplastes > antes, 90)
	var llegada := batalla.aplastar.ultima_llegada
	var tapa := aspi.datos.profundidad - BatallaAspi.ALTO_ARRIBA
	var encima := absf(llegada.x) <= 2.0 and absf(llegada.y - tapa) <= 2.0
	_comprobar(ofrece and encima and batalla.apagados == apagados + 1 and batalla.remate.congelados == silencios + 1, "Aplastar desde %s (A.S.P.I. a %.0f px): cae sobre su tapa (%s) y la apaga" % [donde, absf(aspi.global_position.x - pies.x), llegada])
	await _esperar_que(func() -> bool: return felipe.is_on_floor(), 120)
	await _esperar(10)
	_comprobar(felipe.get_collision_mask_value(Felipe.CAPA_ATRAVESABLE) and felipe.get_collision_mask_value(1), "Después de aplastar desde %s vuelve a chocar con el piso y los muebles" % donde)
	for montana in batalla.montanas.duplicate():
		montana.queue_free()


func _parar(donde: Vector2, cuadros: int) -> void:
	felipe.global_position = donde
	felipe.velocity = Vector2.ZERO
	await _esperar(cuadros)


func _tocar(accion: String) -> void:
	Input.action_press(accion)
	await physics_frame
	await physics_frame
	Input.action_release(accion)
	await physics_frame


func _esperar_que(condicion: Callable, maximo: int) -> void:
	for i in maximo:
		if condicion.call():
			return
		await physics_frame


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("OK    " if condicion else "FALLA ") + descripcion)
	if not condicion:
		_fallos.append(descripcion)
