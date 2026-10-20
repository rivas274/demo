extends SceneTree
## Valida las reglas de diseño de niveles (siete-vidas/diseno/reglas-de-niveles.md) sobre los datos del nivel y su arte.
## Sin ventana:
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_reglas_nivel.gd
## Cada comprobación lleva el número de su regla o el hallazgo de la revisión (B3, B4, G1–G10, M1). Termina con código 0
## si todo pasa y 1 si algo falla.

## R2: los primeros píxeles de cada lección no tienen nada que haga daño.
const ENTRADA_SEGURA := 80.0
## R1: una idea a la vez.
const SEPARACION_LECCIONES := 150.0
## R3: líneas de 48 caracteres o menos (sin contar los botones).
const LARGO_LINEA := 48
## R6: el atajo termina cerca de un descanso.
const ATAJO_A_DESCANSO := 400.0
## R8: hueco mínimo para pasar agachado (30 cm), lado menor de lo interactuable y puertas.
const HUECO_AGACHADO := 36.0
const LADO_MINIMO := 24.0
const VANO_MINIMO := 100.0
## Salto de Felipe sin doble salto (~79 px): lo que no se alcanza con él es un lugar visto.
const SALTO := 79.0
## R11: calma entre dos zonas de daño (una pantalla).
const CALMA := 640.0
## R13 y R18: la habitación final es el alivio (no necesita con qué jugar ni travesura).
const ALIVIO := "balcon"
## B4/G2/G5/M1: tolerancia entre la colisión y el borde visible del arte.
const TOLERANCIA_ARTE := 2

var _fallos: Array[String] = []


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	var danos := _zonas_de_dano()
	var conexiones := _conexiones()
	var lecciones := Nivel1.LECCIONES

	# R1. Enseñar → probar → girar: cada mecánica que el nivel exige tiene su línea antes en la ruta, de a una.
	for exigida: Array in [
			["{interactuar}", Nivel1.ASPI[0], "tirar cosas (ensuciar en la pelea)"],
			["{agacharse}", Vector2(_pieza("Zapatero").get_center().x, Nivel1.SUELO), "agacharse (bajo el zapatero)"],
			["{zarpazo}", Nivel1.RATONES[1][0], "zarpazo (el ratón que cuida el pollo)"],
			["{saltar}", Vector2(Nivel1.CAJAS.get_center().x, Nivel1.SUELO), "subir muebles (librero y cajas de la mudanza)"],
			["{maullar}", Nivel1.PUERTAS[2][1], "maullar (puerta de la cocina)"]]:
		var ensenada := false
		for leccion: Array in lecciones:
			if exigida[0] in TranslationServer.translate(String(leccion[1])) and _antes_en_ruta(leccion[0].get_center(), exigida[1]):
				ensenada = true
		_comprobar(ensenada, "R1 Se enseña %s antes de exigirlo" % exigida[2])
	for i in lecciones.size():
		for j in range(i + 1, lecciones.size()):
			var a: Rect2 = lecciones[i][0]
			var b: Rect2 = lecciones[j][0]
			if Nivel1.habitacion_de(a.get_center()) == Nivel1.habitacion_de(b.get_center()):
				_comprobar(absf(a.position.x - b.position.x) >= SEPARACION_LECCIONES, "R1 Lecciones separadas: «%s» y «%s»" % [lecciones[i][1], lecciones[j][1]])
	_comprobar(not "AVISOS" in Nivel1.new().get_script().get_script_constant_map(), "M2 Sin avisos de texto abajo: enseñan el Indicador y las frases de Felipe")

	# R2. Enseñar sin peligro: la entrada de cada lección está libre de daño.
	for leccion: Array in lecciones:
		var entrada := Rect2(leccion[0].position, Vector2(ENTRADA_SEGURA, leccion[0].size.y))
		var libre := true
		for dano: Rect2 in danos:
			libre = libre and not entrada.intersects(dano)
		_comprobar(libre, "R2 Entrada segura en la lección «%s»" % leccion[1])

	# R3. Mostrar antes que decir: líneas de una frase corta.
	for leccion: Array in lecciones:
		var texto: String = leccion[1]
		var sin_teclas := RegEx.create_from_string("\\{[a-z_]+\\} ?").sub(texto, "", true)
		_comprobar(sin_teclas.length() <= LARGO_LINEA and not "\n" in texto, "R3 Línea corta: «%s» (%d)" % [texto, sin_teclas.length()])

	# R4. Meta a la vista: la salida está en la última habitación de la ruta (se muestra al empezar: prueba_nivel).
	_comprobar(Nivel1.orden_en_ruta(Vector2(Nivel1.SALIDA, Nivel1.SUELO)) == Nivel1.RUTA.size() - 1, "R4 La meta (balcón) es la última habitación de la ruta")

	# R5. Descanso cerca del peligro: en la misma habitación o en una contigua, y uno junto a la puerta del jefe.
	var cuartos_descanso := []
	for descanso: Rect2 in Nivel1.DESCANSOS:
		cuartos_descanso.append(Nivel1.habitacion_de(descanso.get_center()))
	for dano: Rect2 in danos:
		var cuarto := Nivel1.habitacion_de(dano.get_center())
		var cerca := cuarto in cuartos_descanso
		for vecino: String in conexiones.get(cuarto, []):
			cerca = cerca or vecino in cuartos_descanso
		_comprobar(cerca, "R5 Hay un descanso en %s o en una habitación contigua" % cuarto)
	var jefe := Nivel1.habitacion_de(Nivel1.ASPI[0])
	var antes_del_jefe := false
	for cuarto: String in cuartos_descanso:
		antes_del_jefe = antes_del_jefe or (cuarto in conexiones.get(jefe, []) and Nivel1.RUTA.find(cuarto) < Nivel1.RUTA.find(jefe))
	_comprobar(antes_del_jefe, "R5 Hay un descanso junto a la puerta del jefe")

	# R6. Atajos: el pestillo se abre solo desde la escalera y deja junto a la caja de arena.
	_comprobar(Nivel1.ATAJOS.size() >= 1, "R6 El nivel tiene al menos un atajo")
	for atajo: Array in Nivel1.ATAJOS:
		var junto := false
		for descanso: Rect2 in Nivel1.DESCANSOS:
			junto = junto or (Nivel1.habitacion_de(descanso.get_center()) == Nivel1.habitacion_de(atajo[1].get_center()) and _distancia(atajo[1], descanso) <= ATAJO_A_DESCANSO)
		_comprobar(junto, "R6 El atajo «%s» termina junto a un punto de descanso" % atajo[0])
	_comprobar(Nivel1.CAJAS.size.y > SALTO + 40.0, "R6 La pila de cajas no se salta desde el piso (%.0f px; el salto llega a ~%.0f)" % [Nivel1.CAJAS.size.y, SALTO])
	_comprobar(absf(ArteNivel.textura("cajas_pila").get_height() - Nivel1.CAJAS.size.y) <= 2.0 and absf(ArteNivel.textura("cajas_base").get_height() - CajasMudanza.ALTO_BASE) <= 2.0 and absf(ArteNivel.textura("cajas_pila").get_width() - Nivel1.CAJAS.size.x) <= 2.0, "B4 La colisión de las cajas calza con su arte a ±2 px (pila y base)")
	_comprobar(CajasMudanza.ALTO_BASE <= SALTO - 7.0, "R6 Tirada la caja de arriba, las dos que quedan se suben de un salto (%.0f px)" % CajasMudanza.ALTO_BASE)

	# R7. Verticalidad de gato y habitaciones unidas por puertas que van y vuelven.
	var escalera := Vector2.INF
	for datos: Array in Nivel1.PUERTAS:
		if datos[0] == Nivel1.PUERTA_ESCALERA:
			escalera = datos[1]
	_comprobar(escalera.x - 20.0 >= Nivel1.CAJAS.end.x and Nivel1.habitacion_de(escalera) == Nivel1.habitacion_de(Nivel1.CAJAS.get_center()), "R7 El pie de la escalera está detrás de las cajas (Felipe cabe entre ellas y el primer escalón)")
	_comprobar(Nivel1.PELDANOS.size() == 7 and Nivel1.PELDANOS[-1].y <= Nivel1.SUELO - 140.0, "R7 La escalera de fondo tiene 7 escalones que suben unos 150 px")
	var altas := 0
	for pieza: Array in Nivel1.PIEZAS:
		if pieza[3] != "invisible" and Nivel1.SUELO - pieza[0].position.y >= 150.0:
			altas += 1
	_comprobar(altas >= 3, "R7 Hay muebles altos que hacen de camino (%d)" % altas)
	var destinos := {}
	for datos: Array in Nivel1.PUERTAS:
		destinos[datos[0]] = datos[2]
	for nombre: String in destinos:
		_comprobar(destinos.get(destinos[nombre], "") == nombre, "R7 La puerta %s va y vuelve" % nombre)
	var visitadas := {Nivel1.RUTA[0]: true}
	var pendientes: Array = [Nivel1.RUTA[0]]
	while not pendientes.is_empty():
		for vecino: String in conexiones.get(pendientes.pop_back(), []):
			if not visitadas.has(vecino):
				visitadas[vecino] = true
				pendientes.append(vecino)
	_comprobar(visitadas.size() == Nivel1.HABITACIONES.size(), "R7 Desde la sala se llega por puertas a todas las habitaciones (%d)" % visitadas.size())
	for habitacion: Array in Nivel1.HABITACIONES:
		_comprobar((habitacion[0] as Rect2).size.x >= 640.0, "R7 La habitación %s no es más angosta que la pantalla (%.0f px)" % [habitacion[1], habitacion[0].size.x])

	# R8. Medidas reales y huecos legibles: bajo un mueble sólido o no hay hueco o se pasa agachado.
	for pieza: Array in Nivel1.PIEZAS:
		if pieza[1] or pieza[3] == "invisible":
			continue
		var hueco: float = Nivel1.SUELO - pieza[0].end.y
		_comprobar(hueco <= 0.5 or hueco >= HUECO_AGACHADO, "R8 Hueco bajo %s: %.0f px (0 o al menos %d)" % [pieza[2], hueco, HUECO_AGACHADO])

	# R8 y G8. Escala de gato: ratones a la mitad de Felipe y todo lo interactuable con lado MENOR ≥ 24 px (comida incluida).
	var raton := ArteNivel.textura("raton").get_size()
	_comprobar(raton.y >= 30.0, "R8 El ratón de cuerda mide la mitad de Felipe (%.0f px de alto)" % raton.y)
	var interactuables := ["vaso", "taza", "maceta", "llaves", "tazon", "pollo", "bolsita", "calcetin", "caja", "raton", "aspi", "rascador", "cajas_pila", "caja_arriba"]
	for tirable: Array in Nivel1.TIRABLES:
		if not tirable[1] in interactuables:
			interactuables.append(tirable[1])
	for comida: Array in Nivel1.COMIDA:
		if not comida[1] in interactuables:
			interactuables.append(comida[1])
	for nombre: String in interactuables:
		var tam := ArteNivel.textura(nombre).get_size()
		_comprobar(minf(tam.x, tam.y) >= LADO_MINIMO, "R8 %s se lee (%.0f × %.0f px, lado menor ≥ %d)" % [nombre, tam.x, tam.y, LADO_MINIMO])
	for recompensa: String in ["calcetin", "snack", "foto"]:
		var tam := Recogible.tamano_icono(recompensa)
		_comprobar(minf(tam.x, tam.y) >= LADO_MINIMO, "R8 La recompensa %s se lee (%.0f × %.0f px)" % [recompensa, tam.x, tam.y])
	# G7. Lo interactuable dibujado por código también se mide (su tamaño declarado): teclado, ropa, cajón.
	for datos: Array in Nivel1.DIBUJADOS_INTERACTUABLES:
		var tam: Vector2 = (datos[1] as Rect2).size
		_comprobar(minf(tam.x, tam.y) >= LADO_MINIMO, "R8 G7 %s (dibujado por código) se lee (%.0f × %.0f px)" % [datos[0], tam.x, tam.y])

	# B2 y R8. Puertas medidas en la imagen (no en la constante): gruesas y con un vano de 100 px o más.
	for nombre: String in ["puerta_abierta_v2", "puerta_cerrada_v2", "puerta_entornada", "puerta_balcon_v2", "puerta_balcon_abierta", "vano"]:
		var ancho := ArteNivel.textura(nombre).get_size().x
		_comprobar(ancho >= Puerta.ANCHO, "B2 La puerta %s mide %.0f px de ancho en la imagen" % [nombre, ancho])
	# G1 y G2 del plan de ambientes: un solo marco de puerta (140 × 248) en todos los estados y en el vano.
	for nombre: String in ["puerta_abierta_v2", "puerta_cerrada_v2", "puerta_entornada", "puerta_balcon_v2", "puerta_balcon_abierta", "vano"]:
		var tam := ArteNivel.textura(nombre).get_size()
		_comprobar(tam == Vector2(140, 248), "G1 La puerta %s tiene el marco de la casa (%.0f × %.0f)" % [nombre, tam.x, tam.y])
	for nombre: String in ["puerta_abierta_v2", "vano"]:
		var vano := _vano_de(ArteNivel.textura(nombre).get_image())
		_comprobar(vano >= VANO_MINIMO, "B2 El vano de %s, medido en la imagen, mide %d px (sin poste en el medio)" % [nombre, vano])

	# B4, G1–G5 y M1. Cada mueble pisable calza con el borde visible de su arte (±2 px).
	for pieza: Array in Nivel1.PIEZAS:
		if pieza[4] == "":
			continue
		_comprobar_arte(pieza[0], pieza[2], pieza[4])
	for datos: Array in Nivel1.ARTE:
		if datos[1].y == Nivel1.SUELO:
			var imagen: Image = ArteNivel.textura(datos[0]).get_image()
			_comprobar(_fila_opaca(imagen, imagen.get_height() - 1) > 0 and _fila_opaca(imagen, 0) > 0, "M1 %s no tiene margen transparente (se apoya en el piso)" % datos[0])
	var cola := _filas_sin_cuerpo(ArteNivel.textura("raton").get_image())
	_comprobar(absf(cola - (load(Nivel1.RUTA_RATON) as DatosEnemigo).apoyo) <= 1.0, "G1 El ratón se apoya por el cuerpo (cola de %d px; el juego la baja %.0f)" % [cola, (load(Nivel1.RUTA_RATON) as DatosEnemigo).apoyo])

	# B3 y G10. Rectángulo sagrado: nada se cruza con una puerta, la escalera ni la meta.
	var sagrados: Array = []
	for datos: Array in Nivel1.PUERTAS:
		if datos[0] != Nivel1.PUERTA_ESCALERA:
			sagrados.append([Nivel1.rect_sagrado(datos[1]), "la puerta %s" % datos[0]])
	sagrados.append([Nivel1.ESCALERA_RECT, "la escalera"])
	sagrados.append([Nivel1.rect_sagrado(Nivel1.BANO), "la puerta del baño"])
	for sagrado: Array in sagrados:
		var rect: Rect2 = (sagrado[0] as Rect2).grow(-0.5)
		for datos: Array in Nivel1.ARTE:
			# La escalera y lo suyo (el vano y la escoba apoyada en su armario) no cuentan contra sí misma.
			if datos[0] in ["escalera_peldanos", "vano"] or (datos[0] == "escoba" and sagrado[0] == Nivel1.ESCALERA_RECT):
				continue
			var tam := ArteNivel.textura(datos[0]).get_size()
			var dibujo := Rect2(datos[1] - Vector2(0, tam.y), tam)
			_comprobar(not dibujo.intersects(rect), "B3 %s no se cruza con %s" % [datos[0], sagrado[1]])
		for pieza: Array in Nivel1.PIEZAS:
			if pieza[3] == "invisible" or (pieza[4] == "escalera_peldanos" and sagrado[0] == Nivel1.ESCALERA_RECT):
				continue
			_comprobar(not (pieza[0] as Rect2).intersects(rect), "B3 %s no se cruza con %s" % [pieza[2], sagrado[1]])
		# A.S.P.I. pelea con las dos puertas del estudio cerradas (sin vuelta atrás): su arena no cuenta.
		for datos_raton: Array in Nivel1.RATONES:
			_comprobar(not _patrulla(datos_raton).grow(-0.5).intersects(rect), "G10 Ningún ratón patrulla en %s" % sagrado[1])
		for lugar: Vector2 in [Nivel1.VALERIA_SOFA, Nivel1.VALERIA_COCINA]:
			_comprobar(not rect.has_point(lugar - Vector2(0, 1)), "G10 Valeria no se para en %s" % sagrado[1])
		for descanso: Rect2 in Nivel1.DESCANSOS:
			_comprobar(not descanso.intersects(rect), "G10 El descanso no está en %s" % sagrado[1])

	# G5. Ningún ratón patrulla encima de la comida ni de lo que se tira (con su dibujo completo, no solo el centro).
	var ancho_raton := ArteNivel.textura("raton").get_width()
	var tapables: Array = []
	for comida: Array in Nivel1.COMIDA:
		tapables.append([comida[0], comida[1]])
	for tirable: Array in Nivel1.TIRABLES:
		tapables.append([tirable[0], tirable[1]])
	for datos_raton: Array in Nivel1.RATONES:
		var y: float = datos_raton[0].y
		var recorrido := Rect2(datos_raton[1] - ancho_raton / 2.0, y - 54.0, datos_raton[2] - datos_raton[1] + ancho_raton, 54.0)
		for tapable: Array in tapables:
			var tam := ArteNivel.textura(tapable[1]).get_size()
			var dibujo := Rect2(tapable[0] - Vector2(tam.x / 2.0, tam.y), tam)
			_comprobar(not recorrido.grow(-0.5).intersects(dibujo), "G5 El ratón de %s no tapa %s en %s" % [datos_raton[0], tapable[1], tapable[0]])

	# R9. Hitos: cada habitación tiene su propia pared.
	var estilos := {}
	for habitacion: Array in Nivel1.HABITACIONES:
		estilos[habitacion[2]] = true
	_comprobar(estilos.size() == Nivel1.HABITACIONES.size(), "R9 Cada habitación tiene una pared distinta")

	# R10. Exploración: al menos 3 calcetines, cada uno sobre algo donde pararse, y alguno lejos del piso.
	_comprobar(Nivel1.CALCETINES.size() >= 3, "R10 Hay al menos 3 calcetines")
	var alguno_alto := false
	for calcetin: Vector2 in Nivel1.CALCETINES:
		alguno_alto = alguno_alto or calcetin.y < Nivel1.SUELO - 150
		_comprobar(_hay_superficie(calcetin), "R10 El calcetín en %s está sobre algo" % calcetin)
	_comprobar(alguno_alto, "R10 Algún calcetín pide subir")

	# R11. Ritmo: entre dos zonas de daño fuertes de una misma habitación hay al menos una pantalla de calma.
	var fuertes: Array[Rect2] = []
	fuertes.append_array(Nivel1.PELIGROS)
	fuertes.append(_patrulla(Nivel1.ASPI))
	for i in fuertes.size():
		for j in range(i + 1, fuertes.size()):
			if Nivel1.habitacion_de(fuertes[i].get_center()) == Nivel1.habitacion_de(fuertes[j].get_center()):
				_comprobar(_distancia(fuertes[i], fuertes[j]) >= CALMA, "R11 Calma entre zonas de daño")
	_comprobar(Nivel1.RUTA[-1] == ALIVIO, "R11 El nivel cierra con el alivio (balcón)")

	# R12. El jefe es un examen: hay con qué ensuciar y algo de eso pide subir.
	var en_estudio := 0
	for tirable: Array in Nivel1.TIRABLES:
		if Nivel1.habitacion_de(tirable[0]) == jefe:
			en_estudio += 1
	var en_alto := Nivel1.TIRABLES.any(func(t: Array) -> bool: return Nivel1.habitacion_de(t[0]) == jefe and t[0].y < Nivel1.SUELO - 150.0)
	_comprobar(en_estudio >= 3, "R12 En el cuarto del jefe hay al menos 3 cosas para tirar (%d)" % en_estudio)
	_comprobar(en_alto, "R12 Algo para tirar pide subir (repisa)")

	# R13. Cada habitación tiene algo con qué jugar (salvo el alivio final).
	var cosas: Array[Vector2] = []
	cosas.append_array(Nivel1.CALCETINES)
	cosas.append(Nivel1.CAJA_CARTON)
	cosas.append(Nivel1.LASER[0])
	cosas.append(Nivel1.CAJAS.get_center())
	cosas.append(Nivel1.CAJON)
	for lista: Array in [Nivel1.RATONES, Nivel1.TIRABLES, Nivel1.COMIDA]:
		for cosa: Array in lista:
			cosas.append(cosa[0])
	for habitacion: Array in Nivel1.HABITACIONES:
		if habitacion[1] == ALIVIO:
			continue
		var hay := false
		for cosa in cosas:
			hay = hay or (habitacion[0] as Rect2).grow(1).has_point(cosa)
		_comprobar(hay, "R13 La habitación %s tiene algo con qué jugar" % habitacion[1])

	# R17. Un barrio que se descubre: lugares que se ven antes de alcanzarlos (y no se alcanzan), atajo y escenario.
	_comprobar(Nivel1.LUGARES_VISTOS.size() >= 1, "R17 Hay al menos un lugar visto para volver con una maña nueva")
	var alcanzables := _superficies_alcanzables()
	for lugar: Array in Nivel1.LUGARES_VISTOS:
		var rect: Rect2 = lugar[1]
		var se_alcanza := false
		for superficie: Rect2 in alcanzables:
			se_alcanza = se_alcanza or (superficie.position.x < rect.end.x and superficie.end.x > rect.position.x and absf(superficie.position.y - rect.end.y) < 12.0)
		_comprobar(not se_alcanza and lugar[2] != "", "R17 «%s» se ve pero no se alcanza todavía (se vuelve con %s)" % [lugar[0], lugar[2]])
		_comprobar(Nivel1.habitacion_de(rect.get_center()) != "", "R17 «%s» está dentro de un cuarto" % lugar[0])
	# G3. La caja de pizza está afuera: dentro del vidrio del pasillo y por encima de su borde de abajo; el alféizar
	# (que se pisa) queda bajo el vidrio y no la contiene.
	var alfeizar := _pieza("Alféizar")
	_comprobar(Nivel1.VIDRIO_PASILLO.encloses(Nivel1.PIZZA), "G3 La caja de pizza está detrás del vidrio del pasillo")
	_comprobar(alfeizar.position.y > Nivel1.VIDRIO_PASILLO.end.y and Nivel1.PIZZA.end.y < alfeizar.position.y - 20.0, "G3 El alféizar pisable queda bajo el vidrio y no contiene la caja")

	# R18. Una travesura de la Agenda con reacción por habitación (salvo el alivio).
	var con_travesura := {}
	for travesura: Dictionary in Agenda.NIVEL_1:
		var id: String = travesura["id"]
		var sitio: Array = Nivel1.AGENDA_SITIOS.get(id, [])
		_comprobar(not sitio.is_empty() and Nivel1.habitacion_de(sitio[0]) == travesura["cuarto"], "R18 La travesura «%s» pasa en %s" % [travesura["nombre"], travesura["cuarto"]])
		_comprobar(not sitio.is_empty() and String(sitio[1]) != "", "R18 La travesura «%s» tiene su reacción" % travesura["nombre"])
		con_travesura[travesura["cuarto"]] = true
	for habitacion: Array in Nivel1.HABITACIONES:
		if habitacion[1] != ALIVIO:
			_comprobar(con_travesura.has(habitacion[1]), "R18 La habitación %s tiene una travesura de la Agenda" % habitacion[1])

	# R19. Cada maña es llave y travesura: abre un camino y molesta a alguien.
	for mana: String in Nivel1.MANAS:
		var datos: Array = Nivel1.MANAS[mana]
		_comprobar(String(datos[0]) != "" and String(datos[1]) != "", "R19 %s abre «%s» y molesta a «%s»" % [mana, datos[0], datos[1]])

	# G7. En el nivel armado, todo lo que responde al botón de acción declara un tamaño de lado menor ≥ 24 px.
	var sala: Nivel = load("res://escenas/nivel_1.tscn").instantiate()
	sala.mostrar_titulo = false
	root.add_child(sala)
	await process_frame
	for nodo in sala.get_tree().get_nodes_in_group(Componentes.INTERACTUABLES):
		# Las puertas se miden en su imagen (B2, más arriba).
		if nodo is Felipe or nodo is Puerta:
			continue
		var rect := Rect2()
		if nodo.has_method("rect_indicador"):
			rect = nodo.call("rect_indicador")
		elif nodo.has_method("rect_dibujo"):
			rect = nodo.call("rect_dibujo")
		_comprobar(rect.has_area() and minf(rect.size.x, rect.size.y) >= LADO_MINIMO, "R8 G7 %s declara %.0f × %.0f px (lado menor ≥ %d)" % [nodo.name, rect.size.x, rect.size.y, LADO_MINIMO])
	# Puertas (el creador, 2026-10-19: "entras por una puerta cuadrada y al otro lado el marco es redondo"): las dos
	# caras de cada par tienen el mismo marco, el mismo estado y el mismo ancho, y ningún vano es un arco.
	for nombre: String in sala.puertas:
		var puerta: Puerta = sala.puertas[nombre]
		var par: Puerta = puerta.par
		_comprobar(par != null and par.par == puerta, "Puertas: %s tiene su otra cara" % nombre)
		if par == null:
			continue
		_comprobar(puerta.estilo == par.estilo, "Puertas: %s y %s usan el mismo marco («%s» y «%s»)" % [nombre, par.name, puerta.estilo, par.estilo])
		_comprobar(puerta.cerrada == par.cerrada and puerta.entornada == par.entornada, "Puertas: %s y %s empiezan en el mismo estado" % [nombre, par.name])
		var ancho := ArteNivel.textura(puerta.arte()).get_size().x
		var ancho_par := ArteNivel.textura(par.arte()).get_size().x
		_comprobar(ancho == ancho_par, "Puertas: %s y %s miden lo mismo de ancho (%.0f y %.0f px)" % [nombre, par.name, ancho, ancho_par])
	for nombre: String in ["puerta_abierta_v2", "vano"]:
		var imagen: Image = ArteNivel.textura(nombre).get_image()
		var arriba := _vano_en_fila(imagen, 22)
		var abajo := _vano_en_fila(imagen, imagen.get_height() - 10)
		_comprobar(arriba >= abajo - 2, "Puertas: el hueco de %s es cuadrado, no un arco (%d px arriba, %d abajo)" % [nombre, arriba, abajo])
	sala.queue_free()
	await process_frame

	for fallo in _fallos:
		printerr("FALLO: " + fallo)
	print("Resultado: %d fallos" % _fallos.size())
	quit(1 if _fallos.size() > 0 else 0)


## La colisión de la pieza coincide con un borde visible de su arte: en la mayoría de las columnas que cubre, a ±2 px
## de la fila de arriba de la pieza hay un borde (opaco con transparente encima, o la línea oscura del contorno).
func _comprobar_arte(rect: Rect2, nombre: String, imagen_nombre: String) -> void:
	var textura := ArteNivel.textura(imagen_nombre)
	var dibujos := Nivel1.rects_de_arte(imagen_nombre)
	var dibujo := Rect2()
	for candidato in dibujos:
		if candidato.grow(2).encloses(Rect2(rect.position.x, rect.position.y, rect.size.x, 1)):
			dibujo = candidato
	if imagen_nombre == "microondas":
		dibujos = [Rect2(Nivel1.MICROONDAS_X, Nivel1.SUELO - 109 - textura.get_height(), textura.get_width(), textura.get_height())]
		dibujo = dibujos[0]
	_comprobar(dibujo != Rect2(), "B4 %s está dentro de su arte (%s)" % [nombre, imagen_nombre])
	if dibujo == Rect2():
		return
	var espejo := false
	for datos: Array in Nivel1.ARTE + Nivel1.ARTE_EXTRA:
		if datos[0] == imagen_nombre and absf(datos[1].x - dibujo.position.x) < 0.5 and datos.size() > 2:
			espejo = datos[2]
	var imagen: Image = textura.get_image()
	var fila := int(roundf(rect.position.y - dibujo.position.y))
	var columnas := 0
	var con_borde := 0
	for x in range(int(rect.position.x), int(rect.end.x)):
		var columna := x - int(dibujo.position.x)
		if espejo:
			columna = imagen.get_width() - 1 - columna
		if columna < 0 or columna >= imagen.get_width():
			continue
		columnas += 1
		for dy in range(-TOLERANCIA_ARTE, TOLERANCIA_ARTE + 1):
			var y := fila + dy
			if y < 0 or y >= imagen.get_height():
				continue
			if _es_borde(imagen, columna, y):
				con_borde += 1
				break
	var parte := float(con_borde) / maxf(columnas, 1)
	_comprobar(parte >= 0.6, "B4 La colisión de %s calza con el borde de %s a ±%d px (%.0f %% de sus columnas)" % [nombre, imagen_nombre, TOLERANCIA_ARTE, parte * 100.0])


## Borde visible en (x, y): opaco con transparente encima, o la línea oscura del contorno (más oscura que lo que
## tiene 2 px arriba o abajo).
func _es_borde(imagen: Image, x: int, y: int) -> bool:
	var pixel := imagen.get_pixel(x, y)
	if pixel.a < 0.5:
		return false
	if y == 0 or imagen.get_pixel(x, y - 1).a < 0.5:
		return true
	var lum := pixel.get_luminance()
	var arriba := imagen.get_pixel(x, maxi(y - 2, 0))
	var abajo := imagen.get_pixel(x, mini(y + 2, imagen.get_height() - 1))
	return lum < 0.22 and ((arriba.a > 0.5 and arriba.get_luminance() - lum > 0.1) or (abajo.a > 0.5 and abajo.get_luminance() - lum > 0.1))


func _fila_opaca(imagen: Image, y: int) -> int:
	var n := 0
	for x in imagen.get_width():
		if imagen.get_pixel(x, y).a > 0.5:
			n += 1
	return n


## Filas de abajo con muy pocos pixeles (la cola del ratón, que cuelga bajo el cuerpo).
func _filas_sin_cuerpo(imagen: Image) -> int:
	var filas := 0
	for y in range(imagen.get_height() - 1, -1, -1):
		if _fila_opaca(imagen, y) > imagen.get_width() / 2:
			break
		filas += 1
	return filas


## Vano de una puerta medido en la imagen: de la primera a la última columna oscura (luminancia < 0,15) a media
## altura, sin contar los 4 px del contorno de afuera.
func _vano_de(imagen: Image) -> int:
	return _vano_en_fila(imagen, imagen.get_height() / 2)


## Ancho del hueco oscuro en una fila de la imagen (de la primera a la última columna oscura).
func _vano_en_fila(imagen: Image, y: int) -> int:
	var primera := -1
	var ultima := -1
	for x in range(4, imagen.get_width() - 4):
		var pixel := imagen.get_pixel(x, y)
		if pixel.a > 0.5 and pixel.get_luminance() < 0.15:
			if primera < 0:
				primera = x
			ultima = x
	return ultima - primera + 1 if primera >= 0 else 0


## Superficies donde Felipe puede pararse partiendo del piso, con saltos de ~79 px (sin doble salto ni trepar).
func _superficies_alcanzables() -> Array[Rect2]:
	var alcanzadas: Array[Rect2] = []
	for habitacion: Array in Nivel1.HABITACIONES:
		var cuarto: Rect2 = habitacion[0]
		alcanzadas.append(Rect2(cuarto.position.x, Nivel1.SUELO, cuarto.size.x, 0))
	var hubo_cambio := true
	while hubo_cambio:
		hubo_cambio = false
		for pieza: Array in Nivel1.PIEZAS:
			var superficie: Rect2 = pieza[0]
			if pieza[3] == "invisible" or superficie in alcanzadas:
				continue
			for desde in alcanzadas:
				var subida := desde.position.y - superficie.position.y
				var hueco := maxf(0.0, maxf(superficie.position.x - desde.end.x, desde.position.x - superficie.end.x))
				if Nivel1.habitacion_de(superficie.get_center()) == Nivel1.habitacion_de(desde.get_center() + Vector2(0, -1)) and subida <= SALTO - 7.0 and hueco <= 90.0:
					alcanzadas.append(superficie)
					hubo_cambio = true
					break
	return alcanzadas


## Habitación -> habitaciones a las que se llega por una puerta.
func _conexiones() -> Dictionary:
	var posicion := {}
	for datos: Array in Nivel1.PUERTAS:
		posicion[datos[0]] = datos[1]
	var conexiones := {}
	for datos: Array in Nivel1.PUERTAS:
		var desde := Nivel1.habitacion_de(datos[1])
		var hasta := Nivel1.habitacion_de(posicion.get(datos[2], Vector2.INF))
		if not conexiones.has(desde):
			conexiones[desde] = []
		if hasta != "" and not hasta in conexiones[desde]:
			conexiones[desde].append(hasta)
	return conexiones


## Zonas que quitan corazones: juguetes del piso, ratones y A.S.P.I.
func _zonas_de_dano() -> Array[Rect2]:
	var zonas: Array[Rect2] = []
	zonas.append_array(Nivel1.PELIGROS)
	for raton: Array in Nivel1.RATONES:
		zonas.append(_patrulla(raton))
	zonas.append(_patrulla(Nivel1.ASPI))
	return zonas


func _patrulla(datos: Array) -> Rect2:
	return Rect2(datos[1], datos[0].y - 40.0, datos[2] - datos[1], 40.0)


func _pieza(nombre: String) -> Rect2:
	for pieza: Array in Nivel1.PIEZAS:
		if pieza[2] == nombre:
			return pieza[0]
	return Rect2()


func _antes_en_ruta(a: Vector2, b: Vector2) -> bool:
	var orden_a := Nivel1.orden_en_ruta(a)
	var orden_b := Nivel1.orden_en_ruta(b)
	return orden_a < orden_b or (orden_a == orden_b and a.x <= b.x)


## Distancia en x más distancia en y entre los bordes de dos rectángulos.
func _distancia(a: Rect2, b: Rect2) -> float:
	var dx := maxf(0.0, maxf(a.position.x - b.end.x, b.position.x - a.end.x))
	var dy := maxf(0.0, maxf(a.position.y - b.end.y, b.position.y - a.end.y))
	return dx + dy


func _hay_superficie(punto: Vector2) -> bool:
	if absf(punto.y - Nivel1.SUELO) < 2.0:
		return true
	for pieza: Array in Nivel1.PIEZAS:
		var r: Rect2 = pieza[0]
		if absf(r.position.y - punto.y) < 2.0 and punto.x >= r.position.x and punto.x <= r.end.x:
			return true
	return false


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("OK    " if condicion else "FALLA ") + descripcion)
	if not condicion:
		_fallos.append(descripcion)
