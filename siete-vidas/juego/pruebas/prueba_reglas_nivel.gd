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
## R5: distancia máxima (en x más y) entre cualquier daño y un punto de descanso.
const DISTANCIA_DESCANSO := 700.0
## R6: el atajo termina cerca de un descanso.
const ATAJO_A_DESCANSO := 200.0
## R8: hueco mínimo para pasar agachado (30 cm).
const HUECO_AGACHADO := 36.0
## R11: calma entre dos zonas de daño (una pantalla).
const CALMA := 640.0

var _fallos: Array[String] = []


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	var danos := _zonas_de_dano()

	# R1. Enseñar → probar → girar: cada mecánica que el nivel exige tiene su aviso antes en la ruta, y los avisos van de a uno.
	var avisos := Sala.AVISOS
	for exigida: Array in [["{interactuar}", Sala.ASPI[0], "tirar (para aturdir a A.S.P.I.)"], ["{zarpazo}", Sala.ASPI[0], "zarpazo"],
			["{agacharse}", Vector2(Sala.PIEZAS[13][0].get_center().x, Sala.SUELO - 1), "agacharse (bajo el aparador)"],
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
			if a.position.y == b.position.y:
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

	# R4. Meta a la vista: la salida está en el nivel y del lado contrario al inicio.
	_comprobar(Sala.SALIDA > Sala.ANCHO * 0.75, "R4 La meta (balcón) está al final del recorrido")

	# R5. Descanso cerca del peligro.
	for dano: Rect2 in danos:
		var cerca := INF
		for descanso: Rect2 in Sala.DESCANSOS:
			cerca = minf(cerca, _distancia(dano, descanso))
		_comprobar(cerca <= DISTANCIA_DESCANSO, "R5 Hay un descanso a %.0f px de la zona de daño en %s" % [cerca, dano.position])
	var ultimo_descanso := -1
	for descanso: Rect2 in Sala.DESCANSOS:
		ultimo_descanso = maxi(ultimo_descanso, Sala.orden_en_ruta(descanso.get_center()))
	_comprobar(ultimo_descanso >= 0 and ultimo_descanso < Sala.orden_en_ruta(Sala.ASPI[0]), "R5 Hay un descanso antes del jefe")

	# R6. Atajos: la puerta del dormitorio se abre solo desde el lado lejano y deja junto a un descanso.
	var puerta := Sala.PUERTA_DORMITORIO
	var junto := false
	for descanso: Rect2 in Sala.DESCANSOS:
		junto = junto or _distancia(puerta, descanso) <= ATAJO_A_DESCANSO
	_comprobar(junto, "R6 El atajo termina junto a un punto de descanso")
	var tope_escalera := Vector2(Sala.ESCALERA_X + Sala.ESCALONES * Sala.ANCHO_ESCALON, Sala.SUELO - 32.0 * Sala.ESCALONES)
	_comprobar(absf(tope_escalera.x - puerta.position.x) <= 40.0 and absf(tope_escalera.y - Sala.PISO_ALTO) <= 32.0, "R6 La escalera llega a la puerta del atajo")

	# R7. Verticalidad de gato: dos pisos y algo que trepar (que todo se alcance lo valida prueba_escenario).
	var en_piso_alto := 0
	for pieza: Array in Sala.PIEZAS:
		if pieza[0].end.y <= Sala.PISO_ALTO and pieza[3] != "invisible":
			en_piso_alto += 1
	_comprobar(en_piso_alto >= 3 and Sala.TREPABLES.size() >= 1, "R7 Hay segundo piso con recorrido (%d piezas) y algo que trepar" % en_piso_alto)

	# R8. Medidas reales y huecos legibles: bajo un mueble sólido o no hay hueco o se pasa agachado.
	for pieza: Array in Sala.PIEZAS:
		if pieza[1] or pieza[3] in ["invisible", "muro", "entrepiso", "puerta"]:
			continue
		var piso := Sala.SUELO if pieza[0].end.y > Sala.TECHO_BAJO else Sala.PISO_ALTO
		var hueco: float = piso - pieza[0].end.y
		_comprobar(hueco <= 0.5 or hueco >= HUECO_AGACHADO, "R8 Hueco bajo %s: %.0f px (0 o al menos %d)" % [pieza[2], hueco, HUECO_AGACHADO])

	# R9. Hitos: cada habitación tiene su propia pared.
	var estilos := {}
	for habitacion: Array in Sala.HABITACIONES:
		estilos[habitacion[1]] = true
	_comprobar(estilos.size() == Sala.HABITACIONES.size(), "R9 Cada habitación tiene una pared distinta")

	# R10. Exploración: al menos 3 calcetines, cada uno sobre algo donde pararse, y alguno lejos del piso.
	_comprobar(Sala.CALCETINES.size() >= 3, "R10 Hay al menos 3 calcetines")
	var alguno_alto := false
	for calcetin: Vector2 in Sala.CALCETINES:
		alguno_alto = alguno_alto or (calcetin.y < Sala.SUELO - 150 and calcetin.y != Sala.PISO_ALTO)
		_comprobar(_hay_superficie(calcetin), "R10 El calcetín en %s está sobre algo" % calcetin)
	_comprobar(alguno_alto, "R10 Algún calcetín pide subir")

	# R11. Ritmo: entre dos zonas de daño de un mismo piso hay al menos una pantalla de calma (los ratones son práctica).
	var fuertes: Array[Rect2] = []
	fuertes.append_array(Sala.PELIGROS)
	fuertes.append(_patrulla(Sala.ASPI))
	for i in fuertes.size():
		for j in range(i + 1, fuertes.size()):
			if Sala.orden_en_ruta(fuertes[i].get_center()) == Sala.orden_en_ruta(fuertes[j].get_center()):
				_comprobar(_distancia(fuertes[i], fuertes[j]) >= CALMA, "R11 Calma entre zonas de daño")

	# R12. El jefe es un examen: A.S.P.I. pide aturdir (tirar) y zarpazo, ambos enseñados antes.
	var aspi := Aspi.new(Sala.ASPI[1], Sala.ASPI[2])
	_comprobar(aspi.golpes_para_apagar >= 2, "R12 A.S.P.I. pide más de un zarpazo")
	aspi.free()
	var sala: Sala = load("res://escenas/apartamento.tscn").instantiate()
	sala.mostrar_titulo = false
	root.add_child(sala)
	await physics_frame
	var jefa: Aspi = sala.get_node("ASPI") if sala.has_node("ASPI") else null
	if jefa == null:
		for hijo in sala.get_children():
			if hijo is Aspi and not hijo is Raton:
				jefa = hijo
	_comprobar(jefa != null and jefa.necesita_aturdir, "R12 A.S.P.I. hay que aturdirla tirándole algo")

	# R13. Cada habitación tiene algo con qué jugar.
	var cosas: Array[Vector2] = []
	cosas.append_array(Sala.CALCETINES)
	cosas.append(Sala.CAJA_CARTON)
	cosas.append(Sala.LASER[0])
	for lista: Array in [Sala.RATONES, Sala.TIRABLES, Sala.COMIDA]:
		for cosa: Array in lista:
			cosas.append(cosa[0])
	for habitacion: Array in Sala.HABITACIONES:
		var hay := false
		for cosa in cosas:
			hay = hay or (habitacion[0] as Rect2).grow(1).has_point(cosa)
		_comprobar(hay, "R13 La habitación %s tiene algo con qué jugar" % habitacion[1])

	for fallo in _fallos:
		printerr("FALLO: " + fallo)
	print("Resultado: %d fallos" % _fallos.size())
	quit(1 if _fallos.size() > 0 else 0)


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
