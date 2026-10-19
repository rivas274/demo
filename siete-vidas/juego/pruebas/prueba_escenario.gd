extends SceneTree
## Prueba automática del escenario. Se ejecuta sin ventana:
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_escenario.gd
## Termina con código 0 si todo pasa y 1 si algo falla.

## Sin doble salto ni trepar (nivel 1): el salto llega a ~79 px; con margen, 72 de subida y 90 de distancia entre muebles.
## Los escalones del camino obligatorio son de 60 px o menos (los mide prueba_reglas_nivel y el bot).
const SUBIDA_MAXIMA := 72.0
const HUECO_MAXIMO := 90.0

## Piezas que no hace falta alcanzar: las invisibles (piso, techo, paredes) y los lugares vistos (se vuelve con una
## maña nueva: R17).
const SIN_ALCANZAR := ["invisible", "lugar_visto"]

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
	felipe.position = Vector2(2214, Sala.SUELO - 218)
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
	_comprobar_sin_trampas()

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
	# El piso de cada habitación (se llega por sus puertas).
	var alcanzadas: Array[Rect2] = []
	for habitacion: Array in Sala.HABITACIONES:
		var cuarto: Rect2 = habitacion[0]
		alcanzadas.append(Rect2(cuarto.position.x, Sala.SUELO, cuarto.size.x, 0))
	# En el nivel 1 no se trepa nada (Felipe.puede_trepar apagado).
	_comprobar(Sala.TREPABLES.is_empty(), "No hay nada que trepar en el nivel 1 (se gana con Afilar Garras)")
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
			_comprobar(pieza[0] in alcanzadas, "Se puede llegar sin doble salto a: %s" % pieza[2])
		elif pieza[3] == "lugar_visto":
			_comprobar(not pieza[0] in alcanzadas, "El lugar visto %s no se alcanza todavía" % pieza[2])


## Ningún hueco atrapa a Felipe: desde toda superficie a la que se llega desde una puerta se puede volver a esa puerta
## (sin doble salto ni trepar). La reja no cuenta como pared: desde adentro se abre (atajo) y desde afuera se salta.
func _comprobar_sin_trampas() -> void:
	var superficies: Array[Rect2] = []
	for habitacion: Array in Sala.HABITACIONES:
		var cuarto: Rect2 = habitacion[0]
		var cortes: Array[Vector2] = []
		for pieza: Array in Sala.PIEZAS:
			var r: Rect2 = pieza[0]
			if pieza[1] or pieza[3] == "invisible" or not cuarto.grow(1).intersects(r):
				continue
			if Sala.SUELO - r.end.y < 36.0:
				cortes.append(Vector2(r.position.x, r.end.x))
		cortes.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
		var x := cuarto.position.x
		for corte in cortes:
			if corte.x - x >= 40.0:
				superficies.append(Rect2(x, Sala.SUELO, corte.x - x, 0))
			x = maxf(x, corte.y)
		if cuarto.end.x - x >= 40.0:
			superficies.append(Rect2(x, Sala.SUELO, cuarto.end.x - x, 0))
	for pieza: Array in Sala.PIEZAS:
		if not pieza[3] in SIN_ALCANZAR:
			superficies.append(Rect2(pieza[0].position, Vector2(pieza[0].size.x, 0)))
	var vecinos := {}
	for i in superficies.size():
		vecinos[i] = []
		for j in superficies.size():
			if i == j or Sala.habitacion_de(superficies[i].position + Vector2(1, -1)) != Sala.habitacion_de(superficies[j].position + Vector2(1, -1)):
				continue
			var a := superficies[i]
			var b := superficies[j]
			var hueco := maxf(0.0, maxf(b.position.x - a.end.x, a.position.x - b.end.x))
			var subida := a.position.y - b.position.y
			if (subida <= SUBIDA_MAXIMA and subida > 0.5 and hueco <= HUECO_MAXIMO) or (subida <= 0.5 and hueco <= HUECO_MAXIMO):
				vecinos[i].append(j)
	for datos: Array in Sala.PUERTAS:
		var puerta: Vector2 = datos[1]
		var inicio := -1
		for i in superficies.size():
			var r := superficies[i]
			if absf(r.position.y - puerta.y) < 1.0 and puerta.x >= r.position.x and puerta.x <= r.end.x:
				inicio = i
		_comprobar(inicio >= 0, "La puerta %s está sobre un piso" % datos[0])
		if inicio < 0:
			continue
		var ida := _alcanzables_desde(inicio, vecinos)
		var atrapado := ""
		for i: int in ida:
			if not inicio in _alcanzables_desde(i, vecinos):
				atrapado = "%s" % superficies[i]
		_comprobar(atrapado == "", "Desde la puerta %s nada atrapa a Felipe %s" % [datos[0], atrapado])


func _alcanzables_desde(inicio: int, vecinos: Dictionary) -> Array:
	var vistos := {inicio: true}
	var pendientes := [inicio]
	while not pendientes.is_empty():
		for j: int in vecinos[pendientes.pop_back()]:
			if not vistos.has(j):
				vistos[j] = true
				pendientes.append(j)
	return vistos.keys()


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("OK    " if condicion else "FALLA ") + descripcion)
	if not condicion:
		_fallos.append(descripcion)
