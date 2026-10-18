extends SceneTree
## Valida las reglas de diseño de niveles (siete-vidas/diseno/reglas-de-niveles.md) sobre los datos del nivel. Sin ventana:
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_reglas_nivel.gd
## Cada comprobación lleva el número de su regla. Termina con código 0 si todo pasa y 1 si algo falla.

## R2: los primeros píxeles de cada aviso no tienen nada que haga daño.
const ENTRADA_SEGURA := 80.0
## R1: un aviso a la vez.
const SEPARACION_AVISOS := 150.0
## R3: avisos de una línea.
const LARGO_AVISO := 48
## R6: el atajo termina cerca de un descanso.
const ATAJO_A_DESCANSO := 400.0
## R8: hueco mínimo para pasar agachado (30 cm).
const HUECO_AGACHADO := 36.0
## R11: calma entre dos zonas de daño (una pantalla).
const CALMA := 640.0
## R13: la habitación final es el alivio (no necesita con qué jugar).
const ALIVIO := "balcon"

var _fallos: Array[String] = []


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	var danos := _zonas_de_dano()
	var conexiones := _conexiones()

	# R1. Enseñar → probar → girar: cada mecánica que el nivel exige tiene su aviso antes en la ruta, y los avisos van de a uno.
	var avisos := Sala.AVISOS
	var aparador: Rect2 = _pieza("Aparador")
	for exigida: Array in [
			["{interactuar}", Sala.ENCHUFES[0], "tirar y desenchufar (pelea)"],
			["{agacharse}", Vector2(aparador.get_center().x, Sala.SUELO), "agacharse (bajo el aparador)"],
			["{zarpazo}", Sala.RATONES[1][0], "zarpazo (ratones de la cocina)"],
			["{saltar}", Vector2(Sala.REJA.get_center().x, Sala.SUELO), "doble salto (librero y reja)"],
			["{mover_arriba}", Sala.TREPABLES[0].get_center(), "trepar"]]:
		var ensenada := false
		for aviso: Array in avisos:
			if exigida[0] in aviso[1] and _antes_en_ruta(aviso[0].get_center(), exigida[1]):
				ensenada = true
		_comprobar(ensenada, "R1 Se enseña %s antes de exigirlo" % exigida[2])
	for i in avisos.size():
		for j in range(i + 1, avisos.size()):
			var a: Rect2 = avisos[i][0]
			var b: Rect2 = avisos[j][0]
			if Sala.habitacion_de(a.get_center()) == Sala.habitacion_de(b.get_center()):
				_comprobar(absf(a.position.x - b.position.x) >= SEPARACION_AVISOS, "R1 Avisos separados: «%s» y «%s»" % [avisos[i][1], avisos[j][1]])

	# R2. Enseñar sin peligro: la entrada de cada aviso está libre de daño.
	for aviso: Array in avisos:
		var entrada := Rect2(aviso[0].position, Vector2(ENTRADA_SEGURA, aviso[0].size.y))
		var libre := true
		for dano: Rect2 in danos:
			libre = libre and not entrada.intersects(dano)
		_comprobar(libre, "R2 Entrada segura en el aviso «%s»" % aviso[1])

	# R3. Mostrar antes que decir: avisos de una línea.
	for aviso: Array in avisos:
		var texto: String = aviso[1]
		var sin_teclas := RegEx.create_from_string("\\{[a-z_]+\\}").sub(texto, "X", true)
		_comprobar(sin_teclas.length() <= LARGO_AVISO and not "\n" in texto, "R3 Aviso de una línea: «%s»" % texto)

	# R4. Meta a la vista: la salida está en la última habitación de la ruta (se muestra al empezar: prueba_nivel).
	_comprobar(Sala.orden_en_ruta(Vector2(Sala.SALIDA, Sala.SUELO)) == Sala.RUTA.size() - 1, "R4 La meta (balcón) es la última habitación de la ruta")

	# R5. Descanso cerca del peligro: en la misma habitación o en una contigua, y uno junto a la puerta del jefe.
	var cuartos_descanso := []
	for descanso: Rect2 in Sala.DESCANSOS:
		cuartos_descanso.append(Sala.habitacion_de(descanso.get_center()))
	for dano: Rect2 in danos:
		var cuarto := Sala.habitacion_de(dano.get_center())
		var cerca := cuarto in cuartos_descanso
		for vecino: String in conexiones.get(cuarto, []):
			cerca = cerca or vecino in cuartos_descanso
		_comprobar(cerca, "R5 Hay un descanso en %s o en una habitación contigua" % cuarto)
	var jefe := Sala.habitacion_de(Sala.ASPI[0])
	var antes_del_jefe := false
	for cuarto: String in cuartos_descanso:
		antes_del_jefe = antes_del_jefe or (cuarto in conexiones.get(jefe, []) and Sala.RUTA.find(cuarto) < Sala.RUTA.find(jefe))
	_comprobar(antes_del_jefe, "R5 Hay un descanso junto a la puerta del jefe")

	# R6. Atajos: la reja se abre solo desde la escalera y deja junto a la caja de arena.
	var junto := false
	for descanso: Rect2 in Sala.DESCANSOS:
		junto = junto or (Sala.habitacion_de(descanso.get_center()) == Sala.habitacion_de(Sala.REJA.get_center()) and _distancia(Sala.REJA, descanso) <= ATAJO_A_DESCANSO)
	_comprobar(junto, "R6 El atajo (la reja) termina junto a un punto de descanso")
	_comprobar(Sala.REJA.size.y > 140.0, "R6 La reja no se salta desde el piso (%.0f px, doble salto ~140)" % Sala.REJA.size.y)

	# R7. Verticalidad de gato y habitaciones unidas por puertas que van y vuelven.
	var tope := Vector2(Sala.ESCALERA_X + Sala.ESCALONES * Sala.ANCHO_ESCALON, Sala.SUELO - Sala.SUBIDA_ESCALON * Sala.ESCALONES)
	var puerta_arriba := Vector2.INF
	for datos: Array in Sala.PUERTAS:
		if datos[1].y < Sala.SUELO - 1.0:
			puerta_arriba = datos[1]
	_comprobar(absf(puerta_arriba.y - tope.y) < 2.0, "R7 La escalera llega a la puerta del piso de arriba")
	var altas := 0
	for pieza: Array in Sala.PIEZAS:
		if pieza[3] != "invisible" and Sala.SUELO - pieza[0].position.y >= 150.0:
			altas += 1
	_comprobar(altas >= 3 and Sala.TREPABLES.size() >= 1, "R7 Hay muebles altos para trepar (%d) y algo que trepar" % altas)
	var destinos := {}
	for datos: Array in Sala.PUERTAS:
		destinos[datos[0]] = datos[2]
	for nombre: String in destinos:
		_comprobar(destinos.get(destinos[nombre], "") == nombre, "R7 La puerta %s va y vuelve" % nombre)
	var visitadas := {Sala.RUTA[0]: true}
	var pendientes: Array = [Sala.RUTA[0]]
	while not pendientes.is_empty():
		for vecino: String in conexiones.get(pendientes.pop_back(), []):
			if not visitadas.has(vecino):
				visitadas[vecino] = true
				pendientes.append(vecino)
	_comprobar(visitadas.size() == Sala.HABITACIONES.size(), "R7 Desde la sala se llega por puertas a todas las habitaciones (%d)" % visitadas.size())

	# R8. Medidas reales y huecos legibles: bajo un mueble sólido o no hay hueco o se pasa agachado.
	for pieza: Array in Sala.PIEZAS:
		if pieza[1] or pieza[3] == "invisible":
			continue
		var hueco: float = Sala.SUELO - pieza[0].end.y
		_comprobar(hueco <= 0.5 or hueco >= HUECO_AGACHADO, "R8 Hueco bajo %s: %.0f px (0 o al menos %d)" % [pieza[2], hueco, HUECO_AGACHADO])

	# R9. Hitos: cada habitación tiene su propia pared.
	var estilos := {}
	for habitacion: Array in Sala.HABITACIONES:
		estilos[habitacion[2]] = true
	_comprobar(estilos.size() == Sala.HABITACIONES.size(), "R9 Cada habitación tiene una pared distinta")

	# R10. Exploración: al menos 3 calcetines, cada uno sobre algo donde pararse, y alguno lejos del piso.
	_comprobar(Sala.CALCETINES.size() >= 3, "R10 Hay al menos 3 calcetines")
	var alguno_alto := false
	for calcetin: Vector2 in Sala.CALCETINES:
		alguno_alto = alguno_alto or calcetin.y < Sala.SUELO - 150
		_comprobar(_hay_superficie(calcetin), "R10 El calcetín en %s está sobre algo" % calcetin)
	_comprobar(alguno_alto, "R10 Algún calcetín pide subir")

	# R11. Ritmo: entre dos zonas de daño fuertes de una misma habitación hay al menos una pantalla de calma.
	var fuertes: Array[Rect2] = []
	fuertes.append_array(Sala.PELIGROS)
	fuertes.append(_patrulla(Sala.ASPI))
	for i in fuertes.size():
		for j in range(i + 1, fuertes.size()):
			if Sala.habitacion_de(fuertes[i].get_center()) == Sala.habitacion_de(fuertes[j].get_center()):
				_comprobar(_distancia(fuertes[i], fuertes[j]) >= CALMA, "R11 Calma entre zonas de daño")

	# R12. El jefe es un examen: hay con qué ensuciar y enchufes a distintas alturas (pide subir).
	var en_estudio := 0
	for tirable: Array in Sala.TIRABLES:
		if Sala.habitacion_de(tirable[0]) == jefe:
			en_estudio += 1
	var alturas := {}
	for enchufe: Vector2 in Sala.ENCHUFES:
		alturas[int(enchufe.y)] = true
	_comprobar(en_estudio >= 3, "R12 En el cuarto del jefe hay al menos 3 cosas para tirar (%d)" % en_estudio)
	_comprobar(alturas.size() >= 3 and Sala.ENCHUFES.any(func(e: Vector2) -> bool: return e.y < Sala.SUELO - 200.0), "R12 Los enchufes están a distintas alturas y uno pide trepar")

	# R13. Cada habitación tiene algo con qué jugar (salvo el alivio final).
	var cosas: Array[Vector2] = []
	cosas.append_array(Sala.CALCETINES)
	cosas.append_array(Sala.ENCHUFES)
	cosas.append(Sala.CAJA_CARTON)
	cosas.append(Sala.LASER[0])
	cosas.append(Sala.REJA.get_center())
	for lista: Array in [Sala.RATONES, Sala.TIRABLES, Sala.COMIDA]:
		for cosa: Array in lista:
			cosas.append(cosa[0])
	for habitacion: Array in Sala.HABITACIONES:
		if habitacion[1] == ALIVIO:
			continue
		var hay := false
		for cosa in cosas:
			hay = hay or (habitacion[0] as Rect2).grow(1).has_point(cosa)
		_comprobar(hay, "R13 La habitación %s tiene algo con qué jugar" % habitacion[1])

	for fallo in _fallos:
		printerr("FALLO: " + fallo)
	print("Resultado: %d fallos" % _fallos.size())
	quit(1 if _fallos.size() > 0 else 0)


## Habitación -> habitaciones a las que se llega por una puerta.
func _conexiones() -> Dictionary:
	var posicion := {}
	for datos: Array in Sala.PUERTAS:
		posicion[datos[0]] = datos[1]
	var conexiones := {}
	for datos: Array in Sala.PUERTAS:
		var desde := Sala.habitacion_de(datos[1])
		var hasta := Sala.habitacion_de(posicion.get(datos[2], Vector2.INF))
		if not conexiones.has(desde):
			conexiones[desde] = []
		if hasta != "" and not hasta in conexiones[desde]:
			conexiones[desde].append(hasta)
	return conexiones


## Zonas que quitan corazones: juguetes del piso, ratones y A.S.P.I.
func _zonas_de_dano() -> Array[Rect2]:
	var zonas: Array[Rect2] = []
	zonas.append_array(Sala.PELIGROS)
	for raton: Array in Sala.RATONES:
		zonas.append(_patrulla(raton))
	zonas.append(_patrulla(Sala.ASPI))
	return zonas


func _patrulla(datos: Array) -> Rect2:
	return Rect2(datos[1], datos[0].y - 40.0, datos[2] - datos[1], 40.0)


func _pieza(nombre: String) -> Rect2:
	for pieza: Array in Sala.PIEZAS:
		if pieza[2] == nombre:
			return pieza[0]
	return Rect2()


func _antes_en_ruta(a: Vector2, b: Vector2) -> bool:
	var orden_a := Sala.orden_en_ruta(a)
	var orden_b := Sala.orden_en_ruta(b)
	return orden_a < orden_b or (orden_a == orden_b and a.x <= b.x)


## Distancia en x más distancia en y entre los bordes de dos rectángulos.
func _distancia(a: Rect2, b: Rect2) -> float:
	var dx := maxf(0.0, maxf(a.position.x - b.end.x, b.position.x - a.end.x))
	var dy := maxf(0.0, maxf(a.position.y - b.end.y, b.position.y - a.end.y))
	return dx + dy


func _hay_superficie(punto: Vector2) -> bool:
	if absf(punto.y - Sala.SUELO) < 2.0:
		return true
	for pieza: Array in Sala.PIEZAS:
		var r: Rect2 = pieza[0]
		if absf(r.position.y - punto.y) < 2.0 and punto.x >= r.position.x and punto.x <= r.end.x:
			return true
	return false


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("OK    " if condicion else "FALLA ") + descripcion)
	if not condicion:
		_fallos.append(descripcion)
