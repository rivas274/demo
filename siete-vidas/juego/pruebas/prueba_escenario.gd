extends SceneTree
## Prueba automática del escenario. Se ejecuta sin ventana:
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_escenario.gd
## Termina con código 0 si todo pasa y 1 si algo falla.

## Altura máxima con doble salto (~140 px) con margen, y distancia horizontal máxima entre muebles.
const SUBIDA_MAXIMA := 125.0
const HUECO_MAXIMO := 160.0

## Piezas que no hace falta alcanzar: las invisibles (piso, techo, paredes de cada habitación).
const SIN_ALCANZAR := ["invisible"]

var _fallos: Array[String] = []


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	var sala: Node2D = load("res://escenas/apartamento.tscn").instantiate()
	sala.mostrar_titulo = false
	sala.batalla_con_jefe = false
	root.add_child(sala)
	var felipe: Felipe = sala.get_node("Felipe")
	var fondo: Node = sala.get_node("Fondo")
	await _esperar(30)

	var capas: Array[Parallax2D] = []
	for hijo in fondo.get_children():
		if hijo is Parallax2D:
			capas.append(hijo)
	_comprobar(capas.size() >= 4, "El fondo tiene al menos 4 capas de parallax (%d)" % capas.size())
	var lejos := 1.0
	var cerca := 0.0
	for capa in capas:
		lejos = minf(lejos, capa.scroll_scale.x)
		cerca = maxf(cerca, capa.scroll_scale.x)
	_comprobar(lejos < 0.3 and cerca > 1.0, "Hay capas lejanas (más lentas) y de primer plano (más rápidas)")

	var antes := _posiciones_en_pantalla(sala, capas)
	# Arriba del librero del recibidor: la cámara cambia de habitación y sube.
	felipe.position = Vector2(1925, Sala.SUELO - 218)
	await _esperar(180)
	var despues := _posiciones_en_pantalla(sala, capas)
	var movimiento_juego: Vector2 = despues[0] - antes[0]
	_comprobar(absf(movimiento_juego.x) > 300.0 and absf(movimiento_juego.y) > 40.0, "La cámara se movió en horizontal y vertical (%.0f, %.0f)" % [movimiento_juego.x, movimiento_juego.y])
	for i in capas.size():
		var movimiento: Vector2 = despues[i + 1] - antes[i + 1]
		var proporcion := movimiento / movimiento_juego
		var esperado := capas[i].scroll_scale
		_comprobar(absf(proporcion.x - esperado.x) < 0.03 and absf(proporcion.y - esperado.y) < 0.03, "La capa %s se mueve a (%.2f, %.2f) de la cámara (esperado %.2f)" % [capas[i].name, proporcion.x, proporcion.y, esperado.x])

	_comprobar_alcanzables()

	for fallo in _fallos:
		printerr("FALLO: " + fallo)
	print("Resultado: %d fallos" % _fallos.size())
	quit(1 if _fallos.size() > 0 else 0)


## Posición en pantalla de la sala (capa del juego) y de cada capa de parallax.
func _posiciones_en_pantalla(sala: Node2D, capas: Array[Parallax2D]) -> Array[Vector2]:
	var posiciones: Array[Vector2] = [sala.get_global_transform_with_canvas().origin]
	for capa in capas:
		posiciones.append(capa.get_global_transform_with_canvas().origin)
	return posiciones


## Desde el piso, cada superficie donde Felipe puede pararse debe quedar a menos de un doble salto de otra ya alcanzada.
func _comprobar_alcanzables() -> void:
	var superficies: Array[Rect2] = []
	for pieza: Array in Sala.PIEZAS:
		if not pieza[3] in SIN_ALCANZAR:
			superficies.append(pieza[0])
	for i in Sala.ESCALONES:
		superficies.append(Rect2(Sala.ESCALERA_X + i * Sala.ANCHO_ESCALON, Sala.SUELO - Sala.SUBIDA_ESCALON * (i + 1), Sala.ANCHO_ESCALON, 8))
	# El piso de cada habitación (se llega por sus puertas).
	var alcanzadas: Array[Rect2] = []
	for habitacion: Array in Sala.HABITACIONES:
		var cuarto: Rect2 = habitacion[0]
		alcanzadas.append(Rect2(cuarto.position.x, Sala.SUELO, cuarto.size.x, 0))
	# Las cortinas que llegan al piso se suben trepando: su parte de arriba cuenta como alcanzada.
	for zona: Rect2 in Sala.TREPABLES:
		if zona.end.y >= Sala.SUELO:
			alcanzadas.append(Rect2(zona.position.x, zona.position.y, zona.size.x, 0))
	var hubo_cambio := true
	while hubo_cambio:
		hubo_cambio = false
		for superficie in superficies:
			if superficie in alcanzadas:
				continue
			for desde in alcanzadas:
				var subida := desde.position.y - superficie.position.y
				var hueco := maxf(0.0, maxf(superficie.position.x - desde.end.x, desde.position.x - superficie.end.x))
				var misma_habitacion := Sala.habitacion_de(superficie.get_center()) == Sala.habitacion_de(desde.get_center())
				if misma_habitacion and subida <= SUBIDA_MAXIMA and hueco <= HUECO_MAXIMO:
					alcanzadas.append(superficie)
					hubo_cambio = true
					break
	for pieza: Array in Sala.PIEZAS:
		if not pieza[3] in SIN_ALCANZAR:
			_comprobar(pieza[0] in alcanzadas, "Se puede llegar a: %s" % pieza[2])


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("OK    " if condicion else "FALLA ") + descripcion)
	if not condicion:
		_fallos.append(descripcion)
