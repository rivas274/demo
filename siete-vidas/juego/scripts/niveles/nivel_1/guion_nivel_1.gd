class_name GuionNivel1
extends GuionNivel
## Guion del nivel 1 ("La Gran Fuga" v4, siete-vidas/diseno/nivel-01-gran-fuga.md): lo que pasa en esta casa y en
## ninguna otra. Pone a Valeria, A.S.P.I., los objetos y las travesuras (los datos están en Nivel1) y responde a lo que
## pasa: el vaso que cae, el plástico del sofá, el popo táctico, el láser, el teclado, el cajón, el baño, el goteo de la
## cocina y la caja de la mudanza (R18: cada travesura tiene su reacción). Escucha las señales del Nivel (cambio de
## cuarto, puerta cerrada, escalera) y de sus piezas. Las escenas de Valeria por la casa van en ValeriaPorLaCasa, el
## final del balcón en FinalBalcon y el dibujo en ArteNivel1 y DecoradoNivel1.

## Entrar al estudio arranca la pelea de jefe (la prueba de mecánicas la apaga para probar a A.S.P.I. sola).
@export var batalla_con_jefe := true
## Las piezas de juguete hacen daño (la prueba de movimiento las apaga; en la v4 no hay).
@export var peligros_activos := true
## PRUEBA de luz y efectos en la sala (LuzCuarto, scripts/niveles/nivel_1/luz_cuarto.gd): false la quita entera.
@export var luz_activa := true

var batalla: BatallaAspi
var aspi: Enemigo
var valeria: Valeria
var ensayo: EnsayoAspi
var cajas: CajasMudanza
var sofa: Aranable
var rascador: Rascador
var tirables: Array[Objeto] = []
## Puerta del baño y cuánto lleva Felipe quieto cerca de ella; goteos.
var bano: Puerta
## Las escenas de Valeria por la casa, el final del balcón y el dibujo del nivel.
var valeria_por_la_casa: ValeriaPorLaCasa
var balcon: FinalBalcon
var arte: ArteNivel1
var decorado: DecoradoNivel1
## Estado de las travesuras que se ve en el dibujo.
var sofa_roto := false
var teclado_pisado := false
var cajon_abierto := false
var ropa_firmada := false
## Calcetines que vuelan del cajón: (x, y, fase).
var calcetines_volando: Array[Vector3] = []

var _visitados := {}
var _tiempo_popo := 0.0
var _tiempo_laser := 0.0
var _laser: Laser
var _espera_papel := 0.0
var _quieto_bano := 0.0
var _goteo_bano := 0.0
var _goteo_cocina := 0.0

## Atajos al nivel (el código de las travesuras se lee igual que cuando estaba en él).
var felipe: Felipe:
	get:
		return nivel.felipe
var travesuras: Travesuras:
	get:
		return nivel.travesuras
var habitacion: String:
	get:
		return nivel.habitacion
var puertas: Dictionary:
	get:
		return nivel.puertas


func _init() -> void:
	name = "Guion"


func datos_del_nivel() -> DatosNivel:
	return Nivel1.datos()


func crear_fondo() -> void:
	arte = ArteNivel1.new(nivel, self)
	decorado = DecoradoNivel1.new(nivel, self)
	valeria_por_la_casa = ValeriaPorLaCasa.new(self)
	add_child(valeria_por_la_casa)
	balcon = FinalBalcon.new(self)
	add_child(balcon)
	arte.crear_fondo()


func preparar() -> void:
	nivel.habitacion_cambiada.connect(_al_entrar_a)
	nivel.puerta_cerrada_probada.connect(func(puerta: Puerta) -> void:
		_decir("balcon_cerrado" if puerta.name == Nivel1.PUERTA_BALCON else "cocina_cerrada", true))
	nivel.escalera_bajada.connect(func() -> void:
		if not cajas.tirada_ya:
			_decir("cajas_arriba", true))
	travesuras.recompensas.camino_abierto.connect(_abrir_camino)
	travesuras.recompensas.cambio.connect(_al_cambiar_recompensas)
	_crear_puertas_del_nivel()
	_crear_objetos()
	_crear_valeria()
	_crear_aspi()


func al_terminar_de_armar() -> void:
	if luz_activa:
		nivel.add_child(LuzCuarto.new(nivel, valeria))


func cada_cuadro(delta: float) -> void:
	_actualizar_popo(delta)
	_actualizar_laser(delta)
	_actualizar_teclado(delta)
	balcon.cada_cuadro(delta)
	_actualizar_frases_de_lugar()
	_actualizar_bano(delta)
	_actualizar_goteo_cocina(delta)
	arte.cada_cuadro(delta)


## ¿Hay una escena de Valeria en curso o esperando?
func valeria_en_escena() -> bool:
	return valeria_por_la_casa.en_escena


func sonar(nombre: String, tono := 1.0) -> void:
	nivel.sonar(nombre, tono)


func desbloquear_logro(titulo: String) -> void:
	nivel.desbloquear_logro(titulo)


func pieza(nombre: String) -> StaticBody2D:
	return nivel.pieza(nombre)


## Felipe dice una frase de Frases.FELIPE (cada evento con `una_vez` sale solo la primera vez).
func _decir(evento: String, urgente := false, una_vez := true) -> void:
	nivel.decir(evento, urgente, una_vez)


## Lo propio del nivel junto a las puertas: la del baño (lugar insinuado) y la entornada del dormitorio.
func _crear_puertas_del_nivel() -> void:
	# Puerta del baño: cerrada siempre; «Probar» la hace temblar y Felipe dice su frase (no lleva a ningún cuarto).
	bano = Puerta.new("Puerta del baño", Nivel1.BANO, "", Nivel1.BANO.y - Nivel1.TECHO)
	bano.cerrada = true
	bano.bano = true
	bano.cruzada.connect(_probar_bano)
	nivel.add_child(bano)
	# La puerta entornada del dormitorio se abre arañándola (R19: arañar es llave).
	var entornada := Aranable.new("Puerta entornada", 70.0, 200.0)
	entornada.position = (puertas[Nivel1.PUERTA_DORMITORIO] as Puerta).position
	entornada.aranazos_para_romper = 1
	entornada.verbo_indicador = "Arañar"
	var cara_dormitorio: Puerta = puertas[Nivel1.PUERTA_DORMITORIO]
	entornada.arte = cara_dormitorio.arte_indicador
	entornada.roto.connect(func(_o: Aranable) -> void:
		for cara: Puerta in [puertas[Nivel1.PUERTA_DORMITORIO], (puertas[Nivel1.PUERTA_DORMITORIO] as Puerta).par]:
			cara.entornada = false
			cara.queue_redraw()
		_decir("puerta_abierta")
		sonar("caja"))
	nivel.add_child(entornada)


## Objetos, travesuras y piezas del nivel, en el orden de dibujo de siempre.
func _crear_objetos() -> void:
	cajas = CajasMudanza.new(Nivel1.CAJAS, Nivel1.PELDANO_CAJAS)
	cajas.tirada.connect(_al_tirar_cajas)
	cajas.empujada.connect(func() -> void: _decir("cajas", true))
	nivel.add_child(cajas)
	for comida: Array in Nivel1.COMIDA:
		var objeto := Comida.crear(load(Nivel1.DATOS_OBJETO % comida[1]))
		objeto.position = comida[0]
		objeto.comido.connect(_al_comer)
		nivel.add_child(objeto)
	for tirable: Array in Nivel1.TIRABLES:
		var objeto := Objeto.crear(load(Nivel1.DATOS_OBJETO % tirable[1]), Nivel1.SUELO, tirable[2] if tirable.size() > 2 else 0.0)
		objeto.position = tirable[0]
		objeto.tirable.caido.connect(_al_caer_tirable.bind(objeto))
		nivel.add_child(objeto)
		tirables.append(objeto)
	for datos: Array in Nivel1.RATONES:
		var raton := Enemigo.desde_escena(Nivel1.ESCENA_RATON, datos[1], datos[2])
		raton.position = datos[0]
		nivel.add_child(raton)
	# La caja de cartón suelta un snack al romperla (su pieza SueltaRecompensa).
	var caja := CajaCarton.crear()
	caja.position = Nivel1.CAJA_CARTON
	nivel.add_child(caja)
	_laser = Laser.new(Nivel1.LASER[1], Nivel1.LASER[2])
	_laser.position = Nivel1.LASER[0]
	nivel.add_child(_laser)
	# Calcetín 2: arriba del refrigerador (exploración, no es de la agenda).
	var calcetin := travesuras.soltar("calcetin", Nivel1.CALCETIN_REFRIGERADOR, Vector2.ZERO)
	calcetin.quieto = true
	# Rascador (teatro para Valeria) y sofá con plástico.
	rascador = Rascador.new()
	rascador.position = Vector2(Nivel1.RASCADOR_X, Nivel1.SUELO)
	rascador.z_index = Capas.MUEBLES
	nivel.add_child(rascador)
	travesuras.conectar_rascador(rascador)
	sofa = Aranable.new("Sofa arañable", Nivel1.SOFA_ARANABLE[1], Nivel1.SOFA_ARANABLE[2])
	sofa.position = Nivel1.SOFA_ARANABLE[0]
	sofa.arte = func() -> Dictionary:
		var nombre := arte.sofa_dibujado if arte.sofa_dibujado != "" else "sofa_plastico"
		return ArteNivel.arte_en(nivel, nombre, Nivel1.ARTE_EXTRA[0][1].x + ArteNivel.textura(nombre).get_width() / 2.0, Nivel1.SUELO)
	sofa.aranado.connect(_al_aranar_sofa)
	nivel.add_child(sofa)
	travesuras.conectar_aranable(sofa, "sofa", Nivel1.AGENDA_SITIOS["sofa"][0] + Vector2(0, -20))
	sofa.roto.connect(_romper_plastico)
	# Cajón de los calcetines (cómoda) y ropa doblada (cama).
	var cajon := Interactivo.new("Cajon", "Saquear", Nivel1.RECT_CAJON)
	cajon.position = Nivel1.CAJON
	# El contorno sigue la cómoda entera (el cajón es parte de su arte).
	cajon.arte = func() -> Dictionary: return ArteNivel.arte_en(nivel, "comoda", 6230.0 + ArteNivel.textura("comoda").get_width() / 2.0, Nivel1.SUELO)
	cajon.al_usar = func(f: Felipe) -> void: f.dar_manotazo(_abrir_cajon.bind(cajon))
	nivel.add_child(cajon)
	# La ropa se desordena (Felipe se acicala encima): un verbo distinto del sofá («Firmar») y de la puerta («Arañar»), M7.
	var ropa := Interactivo.new("Ropa doblada", "Desordenar", Nivel1.RECT_ROPA)
	ropa.position = Nivel1.ROPA
	ropa.al_usar = func(f: Felipe) -> void:
		f.acicalarse()
		ropa_firmada = true
		ropa.queue_redraw()
		_decir("ropa", true)
	ropa.dibujo = decorado.dibujar_ropa
	ropa.arte = func() -> Dictionary:
		var arte_ropa := ArteNivel.arte_en(ropa, "ropa_pelos" if ropa_firmada else "ropa_limpia", 0.0, Nivel1.ROPA_HUNDIDA)
		arte_ropa["z"] = Capas.MARCAS  # sobre la cama (si fuera detrás, la cama lo taparía)
		return arte_ropa
	# Detrás de Felipe: se acicala encima de la ropa, no detrás de la pila.
	ropa.z_index = Capas.MUEBLES
	nivel.add_child(ropa)
	# La puerta de la cocina oye los maullidos de este lado (Valeria está adentro): su pieza OyeMaullido.
	var oido := OyeMaullido.new()
	oido.name = "Oido de la puerta"
	oido.alcance_x = 140.0
	oido.position = Vector2(0, -40)
	oido.oyo.connect(_maullido_en_la_puerta_de_la_cocina)
	(puertas[Nivel1.PUERTA_COCINA] as Puerta).add_child(oido)
	# Fachada, decorado, ambiente, grifo, sombras en vivo y nido: el arte, en este punto del orden de dibujo.
	arte.crear_decorado()


func _crear_valeria() -> void:
	valeria = Valeria.new()
	valeria.travesuras = travesuras
	for datos: Array in Nivel1.PUERTAS:
		valeria.puertas_x.append(datos[1].x)
	nivel.add_child(valeria)
	valeria.poner(Nivel1.VALERIA_SOFA, "sala", 1.0, Valeria.Actividad.SENTADA)
	valeria.fijar_casa()
	valeria.perdono.connect(_al_perdonar)
	# Su sombra de contacto solo de pie o caminando (sentada la tapa el sofá; fuera no está).
	var sombra_valeria := SombraContacto.new(58.0, 0.4)
	sombra_valeria.mostrar = func() -> bool: return not valeria.actividad in [Valeria.Actividad.SENTADA, Valeria.Actividad.FUERA]
	valeria.add_child(sombra_valeria)
	travesuras.anuncios.testigos.append(valeria)
	# Si Valeria va a salir a reaccionar en el cuarto de Felipe, el cartel espera a que salga (G5).
	travesuras.anuncios.reaccion_en_curso = func() -> bool: return valeria_por_la_casa.en_escena and habitacion == "recibidor" and valeria_por_la_casa.actual in ["bolsas", "maullido"] and not (valeria.cuarto == "recibidor" and valeria.visible)


func _crear_aspi() -> void:
	aspi = Enemigo.desde_escena(Nivel1.ESCENA_ASPI, Nivel1.ASPI[1], Nivel1.ASPI[2])
	aspi.position = Nivel1.ASPI[0]
	# La jefa: los zarpazos rebotan si no está aturdida (algo le cayó encima).
	aspi.recibe_golpes.solo_aturdido = true
	aspi.vida.murio.connect(_abrir_balcon)
	nivel.add_child(aspi)
	travesuras.anuncios.testigos.append(aspi)
	if batalla_con_jefe:
		batalla = BatallaAspi.new(aspi, felipe, nivel)
		nivel.add_child(batalla)
		batalla.presentacion.anuncios = travesuras.anuncios
		for objeto in tirables:
			if Nivel1.habitacion_de(objeto.position) == "estudio":
				batalla.agregar_municion(objeto)
	# Ensayo sin riesgo en el pasillo: A.S.P.I. sale a limpiar lo que Felipe tira (R1, R12).
	ensayo = EnsayoAspi.new(nivel, Vector2((puertas["pasillo>estudio"] as Puerta).position.x, Nivel1.SUELO))
	nivel.add_child(ensayo)
	# Detrás de la puerta del estudio, el pasamanos y lo demás encima.
	arte.crear_pasamanos()


## Lo que pasa al entrar a un cuarto: Valeria cuenta la visita, se va a la cocina, se pone audífonos...
func _al_entrar_a(cuarto: String) -> void:
	var primera := not _visitados.has(cuarto)
	_visitados[cuarto] = true
	if valeria and valeria.cuarto == cuarto:
		valeria.visita += 1
	if cuarto == "recibidor" and primera and valeria.cuarto == "sala":
		valeria_por_la_casa.escena("a_la_cocina")
	elif cuarto == "pasillo" and primera:
		valeria.audifonos = true
		travesuras.decir_valeria("audifonos", true)
		_decir("robot")
	elif cuarto == "cocina" and primera:
		valeria.visita += 1


# --- Travesuras y reacciones (R18) ---------------------------------------------------------------------------------

## Algo cayó: el vaso de la sala hace saltar a Valeria; las llaves, que se asome; en el pasillo sale A.S.P.I.
func _al_caer_tirable(donde: Vector2, objeto: Objeto) -> void:
	var cuarto := Nivel1.habitacion_de(donde)
	match objeto.tipo:
		"vaso":
			if cuarto == "sala":
				travesuras.jugo.congelar(0.08)
				# Sobre la mesa de donde cayó (no a la altura del mueble), en un celeste fuerte con contorno (M1).
				travesuras.jugo.palabra_en_mundo("¡GRAVEDAD: 1 · VASO: 0!", Vector2(donde.x, Nivel1.SUELO - 120), Color(0.45, 0.85, 1.0), 15)
				if valeria.cuarto == "sala":
					valeria.reganar(felipe, "rotura", "vaso")
			elif cuarto == "pasillo":
				ensayo.empezar(donde.x)
			_decir("tirar", false, false)
		"llaves":
			travesuras.jugo.palabra_en_mundo("¡CLINK CRÍTICO!", donde + Vector2(0, -50), Color(1.0, 0.9, 0.4), 16)
			travesuras.jugo.sacudir(0.12, 0.5)
			if valeria.cuarto == "cocina" and not valeria.audifonos:
				travesuras.decir_valeria("llaves", true)


## La caja de arriba de la mudanza, tirada desde el peldaño: rueda al piso con jugo y abre el atajo de vuelta (R6).
func _al_tirar_cajas() -> void:
	travesuras.jugo.congelar(0.06)
	await get_tree().create_timer(CajasMudanza.SEGUNDOS_CAIDA, false).timeout
	var donde := Nivel1.CAJAS.position + Vector2(CajasMudanza.CAIDA_X, Nivel1.CAJAS.size.y)
	travesuras.jugo.palabra_en_mundo("¡PUM! · MUDANZA: 0", Vector2(donde.x + 20.0, Nivel1.SUELO - 150.0), Color(1.0, 0.75, 0.4), 15)
	travesuras.jugo.sacudir(0.15, 0.6)
	sonar("caja")
	sonar("golpe", 0.8)
	travesuras.anuncios.marcar_chiste(Rect2(donde.x - 50.0, Nivel1.SUELO - 140.0, 140.0, 140.0), 1.5)
	desbloquear_logro("Atajo de Gato")
	# El mundo reacciona (pilar 5): el ¡PUM! se oye en toda la casa, aunque Valeria tenga audífonos. Ella contesta
	# primero, desde donde esté (con audífonos se saca uno: su frase es de la reunión); después Felipe, sin culpa.
	if valeria.actividad != Valeria.Actividad.FUERA:
		if valeria.audifonos:
			valeria.sacar_audifono(3.0)
			travesuras.decir_valeria("cajas_audifonos", true)
		else:
			travesuras.decir_valeria("cajas", true)
		await nivel.esperar_dialogo(5.0)
	_decir("cajas_tiradas", true)


func _al_perdonar(motivo: String) -> void:
	if motivo == "rotura":
		# "Romper algo y que me perdone igual": el snack sale a los pies de Felipe.
		travesuras.cumplir("perdon", felipe.global_position + Vector2(0, -24))


## Arañar el sofá delante de Valeria: a los dos arañazos lo deja frente al rascador (y el plástico aguanta).
func _al_aranar_sofa(objeto: Aranable, critico: bool) -> void:
	if objeto.esta_roto or critico:
		return
	if valeria.ve(Vector2(felipe.global_position.x, Nivel1.SUELO - 20)) and objeto.aranazos >= 2:
		objeto.aranazos = 0
		valeria.llevar_al_rascador(felipe, Nivel1.RASCADOR_X - 46.0)


func _romper_plastico(_objeto: Aranable) -> void:
	sofa_roto = true
	travesuras.jugo.palabra_en_mundo("¡PLÁSTICO: 0!", Nivel1.SOFA_ARANABLE[0] + Vector2(0, -120), Color(1.0, 0.6, 0.4), 18)
	for nombre: String in Nivel1.SOFA_ARANADO:
		pieza(nombre).position.y = Nivel1.SOFA_ARANADO[nombre]
	if valeria.cuarto == "sala":
		travesuras.decir_valeria("sofa_roto", true)
	travesuras.anuncios.marcar_chiste(Rect2(240, Nivel1.SUELO - 130, 240, 130), 1.5)
	# El sofá se redibuja sin plástico ni etiqueta (G4) y los jirones del plástico salen volando.
	arte.redibujar_muebles()
	arte.soltar_jirones(Nivel1.SOFA_ARANABLE[0])


func _al_comer(comida: Comida) -> void:
	if comida.tipo == "tazon":
		_decir("tazon", true)
	elif comida.tipo == "pollo":
		var en_su_cara := valeria.ve(comida.global_position)
		# Los snacks caen en el mesón, al lado del microondas: no sobre la cara de Felipe (M2).
		travesuras.cumplir("almuerzo", Vector2(Nivel1.POLLO.x - 70.0, Nivel1.SUELO - 120.0))
		if en_su_cara:
			travesuras.jugo.palabra_en_mundo("¡EN SU CARA!", comida.global_position + Vector2(0, -70), Color(1.0, 0.4, 0.5), 20)
			valeria.reganar(felipe, "almuerzo", "almuerzo")
		elif valeria.cuarto == "cocina":
			travesuras.decir_valeria("almuerzo", true)


## Popo táctico: agachado sobre la caja de arena recién limpiada (travesura secreta, con censura irónica).
func _actualizar_popo(delta: float) -> void:
	var caja: Rect2 = Nivel1.DESCANSOS[0]
	if travesuras.agenda.esta_cumplida("popo") or not (felipe.agachado and felipe.is_on_floor() and caja.has_point(felipe.global_position)):
		_tiempo_popo = 0.0
		return
	_tiempo_popo += delta
	if _tiempo_popo >= Nivel1.TIEMPO_POPO:
		_tiempo_popo = 0.0
		_censura_ironica()
		# La recompensa es una foto vergonzosa (G6): la que Valeria tenía lista para subir se le cae del bolsillo
		# al ver la arena. Las tres secretas dan fotos; la galería completa da «Galería Viral».
		travesuras.cumplir("popo", Nivel1.FOTO_POPO)
		if valeria.cuarto == "cocina" and not valeria.audifonos:
			valeria_por_la_casa.escena("bolsas")


func _censura_ironica() -> void:
	travesuras.anuncios.marcar_chiste(Rect2(felipe.global_position + Vector2(-40, -110), Vector2(80, 110)), 2.0)
	travesuras.jugo.palabra_en_mundo("CONTENIDO SENSIBLE", felipe.global_position + Vector2(0, -70), Color(1.0, 1.0, 1.0), 14)
	var pegatina := Node2D.new()
	pegatina.name = "Censura"
	pegatina.z_index = Capas.CENSURA
	pegatina.global_position = felipe.global_position + Vector2(0, -20)
	pegatina.draw.connect(func() -> void:
		# Pegatina de pescadito y un aviso que muestra... una papa.
		pegatina.draw_rect(Rect2(-22, -20, 44, 24), Color(0.2, 0.55, 0.85))
		pegatina.draw_colored_polygon(PackedVector2Array([Vector2(-12, -8), Vector2(6, -14), Vector2(12, -8), Vector2(6, -2)]), Color(1.0, 0.65, 0.35))
		pegatina.draw_colored_polygon(PackedVector2Array([Vector2(12, -8), Vector2(18, -13), Vector2(18, -3)]), Color(1.0, 0.55, 0.3))
		pegatina.draw_circle(Vector2(-14, -40), 9.0, Color(0.72, 0.55, 0.32)))
	nivel.add_child(pegatina)
	var irse := pegatina.create_tween()
	irse.tween_interval(1.4)
	irse.tween_property(pegatina, "modulate:a", 0.0, 0.3)
	irse.tween_callback(pegatina.queue_free)


## Ignorar el láser: 5 s quieto en el pasillo con el punto rojo cerca, sin perseguirlo (secreta).
func _actualizar_laser(delta: float) -> void:
	if travesuras.agenda.esta_cumplida("laser") or habitacion != "pasillo" or _laser == null:
		_tiempo_laser = 0.0
		return
	var quieto := felipe.is_on_floor() and absf(felipe.velocity.x) < 1.0 and not felipe.en_escalera()
	if quieto and absf(_laser.global_position.x - felipe.global_position.x) < 260.0 and felipe.global_position.y > Nivel1.SUELO - 4.0:
		_tiempo_laser += delta
	else:
		_tiempo_laser = 0.0
	if _tiempo_laser >= Nivel1.TIEMPO_IGNORAR_LASER:
		_laser.apagar()
		travesuras.jugo.palabra_en_mundo("*se apaga de vergüenza*", _laser.global_position + Vector2(0, -24), Color(1.0, 0.5, 0.5), 11)
		# La foto vergonzosa se cae del cajón de la consola.
		travesuras.cumplir("laser", Vector2(4710, Nivel1.SUELO - 97))


## Frases que salen una vez al ver algo: la pizza del lugar visto (desde el alféizar) y el láser (la primera vez).
func _actualizar_frases_de_lugar() -> void:
	if not felipe.is_on_floor():
		return
	var pies := felipe.global_position
	var alfeizar: Rect2 = Nivel1.rect_pieza("Alféizar")
	if absf(pies.y - alfeizar.position.y) < 3.0 and pies.x > alfeizar.position.x and pies.x < alfeizar.end.x:
		_decir("pizza", true)
	if habitacion == "pasillo" and _laser and not _laser.apagado and absf(_laser.global_position.x - pies.x) < 200.0 and pies.y > Nivel1.SUELO - 4.0:
		_decir("laser_visto")


## La puerta del baño (2.4.1): al acercarse la primera vez, su frase; si después se queda quieto cerca 2 s, la manilla
## da un destello, Felipe la mira de reojo y dice la segunda. El goteo solo se oye a BANO_GOTEO px o menos.
func _actualizar_bano(delta: float) -> void:
	if habitacion != "pasillo" or bano == null:
		_quieto_bano = 0.0
		return
	var pies := felipe.global_position
	var distancia := absf(pies.x - Nivel1.BANO.x)
	var en_el_piso := felipe.is_on_floor() and pies.y > Nivel1.SUELO - 4.0
	_goteo_bano += delta
	if _goteo_bano >= 2.6:
		_goteo_bano = 0.0
		if distancia <= Nivel1.BANO_GOTEO:
			sonar("goteo", 0.8)
	if en_el_piso and distancia <= Nivel1.BANO_FRASE and not nivel.cruce_en_curso():
		_decir("bano", true)
	if not nivel.ya_dijo("bano") or nivel.ya_dijo("bano_manija"):
		return
	if en_el_piso and distancia <= Nivel1.BANO_MANIJA and absf(felipe.velocity.x) < 1.0:
		_quieto_bano += delta
	else:
		_quieto_bano = 0.0
	if _quieto_bano >= 2.0:
		bano.destellar()
		if distancia > 1.0:
			felipe.mirando = signf(Nivel1.BANO.x - pies.x)
			felipe.sprite.flip_h = felipe.mirando < 0.0
		_decir("bano_manija", true)


## Probar la puerta del baño: la hoja tiembla 1 px y no cede.
func _probar_bano(_puerta: Puerta) -> void:
	bano.temblar()
	sonar("golpe", 1.4)
	_decir("bano", true)


## Goteo de la llave de la cocina (C-5): una gota cada 3 s con su «plic» (anticipa el del baño).
func _actualizar_goteo_cocina(delta: float) -> void:
	_goteo_cocina += delta
	if _goteo_cocina >= 3.0:
		_goteo_cocina = 0.0
		if habitacion == "cocina":
			sonar("goteo")


## Pisar el teclado de Valeria: "jjjjjjjjjj" (secreta). En la pelea, los apuntes del escritorio vuelan: manchas extra.
func _actualizar_teclado(delta: float) -> void:
	_espera_papel = maxf(0.0, _espera_papel - delta)
	var encima := felipe.is_on_floor() and Nivel1.TECLADO.grow_individual(0, 6, 0, 6).has_point(felipe.global_position)
	if not encima:
		return
	if not teclado_pisado:
		teclado_pisado = true
		arte.decorado.queue_redraw()
		travesuras.jugo.palabra_en_mundo("jjjjjjjjjj", Vector2(7190, Nivel1.SUELO - 150), Color(0.7, 0.9, 1.0), 14)
		# La pantalla con «jjjjjj» es el chiste: el cartel no la tapa (G5).
		travesuras.anuncios.marcar_chiste(Rect2(7110, Nivel1.SUELO - 160, 110, 70), 3.0)
		travesuras.cumplir("teclado", Vector2(7146, Nivel1.SUELO - 120))
	if batalla and batalla.fase == BatallaAspi.Fase.PELEA and _espera_papel <= 0.0:
		_espera_papel = 4.0
		var papel := Vector2(7097 + randf_range(-40, 60), Nivel1.SUELO)
		travesuras.jugo.palabra_en_mundo("¡FIUU!", Vector2(7097, Nivel1.SUELO - 110), Color(1, 1, 1), 11)
		batalla.agregar_mancha(papel, "papel")


func _abrir_cajon(cajon: Interactivo) -> void:
	cajon_abierto = true
	travesuras.anuncios.marcar_chiste(Rect2(Nivel1.CAJON.x - 60, Nivel1.CAJON.y - 110, 160, 120), 1.8)
	cajon.marcar_usado()
	sonar("caja")
	for i in 7:
		calcetines_volando.append(Vector3(Nivel1.CAJON.x + randf_range(-20, 40), Nivel1.CAJON.y, randf_range(0.0, 1.0)))
	var vuelo := create_tween()
	vuelo.tween_interval(1.6)
	vuelo.tween_callback(func() -> void:
		calcetines_volando.clear()
		arte.decorado.queue_redraw())
	travesuras.cumplir("cajon", Vector2(6272, Nivel1.SUELO - 140))
	arte.decorado.queue_redraw()


# --- La cocina y lo que abre caminos -------------------------------------------------------------------------------

## Maullar del otro lado de la puerta de la cocina: Valeria la abre (R19: maullar es llave).
func _maullido_en_la_puerta_de_la_cocina(_felipe_que_maulla: Felipe) -> void:
	var puerta: Puerta = puertas[Nivel1.PUERTA_COCINA]
	if not puerta.cerrada or valeria.cuarto != "cocina" or valeria.audifonos:
		return
	valeria_por_la_casa.escena("maullido")


func abrir_cocina() -> void:
	var puerta: Puerta = puertas[Nivel1.PUERTA_COCINA]
	puerta.cerrada = false
	puerta.sombra_detras = false
	puerta.queue_redraw()
	(puertas["cocina<recibidor"] as Puerta).cerrada = false
	(puertas["cocina<recibidor"] as Puerta).queue_redraw()


## Recompensa de camino: el balcón (A.S.P.I. desenchufada).
func _abrir_camino(id: String) -> void:
	match id:
		"balcon":
			_abrir_balcon()


func _al_cambiar_recompensas(tipo: String) -> void:
	if tipo == "calcetin":
		arte.nido.queue_redraw()
		if nivel.calcetines >= Nivel1.TOTAL_CALCETINES:
			desbloquear_logro("Coleccionista de Calcetines")
	elif tipo == "foto" and travesuras.recompensas.fotos >= Nivel1.TOTAL_FOTOS:
		desbloquear_logro("Galería Viral")


func _abrir_balcon() -> void:
	var puerta: Puerta = puertas.get(Nivel1.PUERTA_BALCON)
	if puerta and puerta.cerrada:
		for cara: Puerta in [puerta, puerta.par]:
			cara.cerrada = false
			cara.queue_redraw()
	desbloquear_logro("Desenchufada")
