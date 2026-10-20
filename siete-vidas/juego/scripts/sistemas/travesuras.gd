class_name Travesuras
extends Node
## Junta los sistemas reutilizables de un nivel y los conecta entre sí y con Felipe:
## Agenda de Su Majestad (datos), Recompensas (nido, galería, bolsillo), Libreta (Tab), Hud (contadores y carteles),
## Dialogo (retratos, una sola cola), Jugo (congelado, palabras, sacudida, destello) e Indicador (contorno y burbuja).
## El nivel solo crea uno con su agenda, llama cumplir(id, donde) cuando pasa una travesura y conecta sus objetos
## (conectar_rascador, conectar_aranable). Al final del nivel, mostrar_resumen().

## Se cumplió una travesura de la agenda (después de entregar o soltar su recompensa).
signal travesura_cumplida(id: String)
signal resumen_cerrado

var felipe: Felipe
var agenda: Agenda
var recompensas: Recompensas
var libreta: Libreta
var hud: Hud
var dialogo: Dialogo
var jugo: Jugo
var indicador: Indicador
## La cola única de anuncios (carteles, logros, franjas de fase): G5 de la revisión 3.
var anuncios: Anuncios
var frases := Frases.new()
## Perdones de Valeria en el día (los suma el nivel con contar_perdon(); salen en el resumen).
var perdones := 0
## id de travesura -> dónde soltar su recompensa (lo pasa cumplir()).
var _donde := {}


func _init(de: Felipe = null, lista_agenda: Array = Agenda.NIVEL_1) -> void:
	name = "Travesuras"
	felipe = de
	agenda = Agenda.new(lista_agenda)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	recompensas = Recompensas.new(felipe)
	jugo = Jugo.new()
	jugo.name = "Jugo"
	add_child(jugo)
	anuncios = Anuncios.new()
	anuncios.felipe = felipe
	add_child(anuncios)
	hud = Hud.new()
	hud.name = "Hud"
	hud.agenda = agenda
	hud.recompensas = recompensas
	add_child(hud)
	dialogo = Dialogo.new()
	dialogo.name = "Dialogo"
	dialogo.seguir = felipe
	add_child(dialogo)
	hud.anuncios = anuncios
	anuncios.dialogo = dialogo
	libreta = Libreta.new()
	libreta.name = "Libreta"
	libreta.agenda = agenda
	add_child(libreta)
	indicador = Indicador.new()
	indicador.felipe = felipe
	indicador.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(indicador)
	indicador.primera_vez.connect(func(_objeto: Node2D, frase: String) -> void: dialogo.decir("felipe", frase, 0))
	agenda.cumplida.connect(_al_cumplir)
	recompensas.cambio.connect(hud.golpear)
	recompensas.bolsillo_lleno.connect(func() -> void: decir_felipe("bolsillo_lleno"))
	recompensas.ranura_ganada.connect(_al_ganar_ranura)
	if felipe:
		jugo.camara = felipe.get_node_or_null("Camara")
		jugo.evitar = felipe
		felipe.impacto.connect(_al_impacto)
		felipe.maullo.connect(_al_maullar)
		felipe.aranazo.connect(_al_aranar)
		felipe.snack_comido.connect(_al_comer_snack)
		felipe.sin_snacks.connect(func() -> void: decir_felipe("sin_snacks", true))
		felipe.snacks_cambiados.connect(func(_n: int) -> void: hud.golpear("snack"))


## El nivel avisa que pasó una travesura. `donde`: dónde aparece la recompensa (sobre algo pisable) para que
## Felipe la recoja al pasar; sin `donde`, se entrega directo. Devuelve true si con esto se cumplió.
func cumplir(id: String, donde := Vector2.INF) -> bool:
	if donde != Vector2.INF:
		_donde[id] = donde
	return agenda.avanzar(id)


func _al_cumplir(t: Dictionary) -> void:
	var id := String(t["id"])
	var secreta := bool(t.get("secreta", false))
	var recompensa: Dictionary = t.get("recompensa", {})
	hud.cartel(tr("UI_TRAVESURA_SECRETA") if secreta else tr("UI_TRAVESURA_CUMPLIDA"), String(t["nombre"]), String(recompensa.get("texto", "")), secreta, altura_cartel())
	var frase: Array = t.get("frase", [])
	if frase.size() >= 2:
		dialogo.decir("felipe", String(frase[0]), int(frase[1]))
	var tipo := String(recompensa.get("tipo", ""))
	if _donde.has(id) and tipo in ["calcetin", "snack", "foto"]:
		var donde: Vector2 = _donde[id]
		# Nunca sobre la cara de Felipe (M2): si sale pegada a él, sale a su lado y en un arco corto hacia afuera.
		var lado := 0.0
		if felipe and donde.distance_to(felipe.global_position + Vector2(0, -30)) < 60.0:
			lado = signf(donde.x - felipe.global_position.x)
			if lado == 0.0:
				lado = -felipe.mirando
			donde.x = felipe.global_position.x + lado * 44.0
		for i in int(recompensa.get("cantidad", 1)):
			# La foto es papel: sale apenas hacia arriba y cae flotando (si saltara alto, se iría a otro mueble).
			var impulso := Vector2(randf_range(-40.0, 40.0), -60.0 if tipo == "foto" else -160.0)
			if lado != 0.0:
				impulso = Vector2(lado * randf_range(20.0, 50.0), -110.0)
			soltar(tipo, donde, impulso)
	else:
		recompensas.dar(recompensa)
	travesura_cumplida.emit(id)
	if agenda.completa():
		decir_felipe("agenda_completa")


## Suelta una recompensa en el mundo (sale disparada y Felipe la recoge al pasar).
func soltar(tipo: String, donde: Vector2, impulso := Vector2(0, -160)) -> Recogible:
	var objeto := Recogible.new(tipo, impulso)
	var mundo := felipe.get_parent() if felipe else get_parent()
	mundo.add_child(objeto)
	objeto.global_position = donde
	objeto.recogido.connect(_al_recoger)
	return objeto


func _al_recoger(objeto: Recogible) -> void:
	var entro := recompensas.dar({"tipo": objeto.tipo, "cantidad": 1})
	if entro > 0:
		decir_felipe("recoger_" + objeto.tipo)


func _al_ganar_ranura(_total: int) -> void:
	decir_felipe("ranura", true)
	if felipe:
		jugo.palabra_en_mundo("¡RANURA DE MAÑA!", felipe.global_position + Vector2(0, -90), Color(0.7, 1.0, 0.7), 16)


func contar_perdon() -> void:
	perdones += 1


## Conecta un rascador: frases de Felipe y Valeria y jugo según haya público y premio.
func conectar_rascador(rascador: Rascador) -> void:
	rascador.funcion.connect(_al_actuar)


## Conecta algo arañable: al romperse (el plástico del sofá) avanza la travesura `id_agenda`, y la recompensa
## sale en `donde`.
func conectar_aranable(objeto: Aranable, id_agenda := "", donde := Vector2.INF) -> void:
	if id_agenda != "":
		objeto.roto.connect(func(_o: Aranable) -> void: cumplir(id_agenda, donde))


func _al_actuar(rascador: Rascador, con_publico: bool, premio: bool, _testigo: Node) -> void:
	var arriba := rascador.global_position + Vector2(0, -Rascador.ALTO - 16)
	jugo.palabra_en_mundo("¡GARRAS AFILADAS!", arriba, Color(0.7, 0.95, 1.0), 13, 0.9 if con_publico else 0.2)
	if not con_publico:
		decir_felipe("rascador_solo", true)
		return
	if premio:
		contar_perdon()
		jugo.palabra_en_mundo("¡OVACIÓN!", arriba + Vector2(0, -24), Color(1.0, 0.55, 0.75), 22)
		jugo.destello(0.35, Color(1, 1, 1))
		decir_valeria("rascador", true)
		decir_felipe("rascador_publico")
	else:
		decir_valeria("rascador_bis", true)
		decir_felipe("rascador_bis")


func _al_impacto(tipo: String) -> void:
	# La receta de jugo de cada acción (datos/jugo/<tipo>.tres): pausa de impacto, sacudida y frase. Zarpazo,
	# manotazo y arañazo: dos o tres cuadros de congelado al pegar la pata (hallazgo B5).
	var frase := RecetaJugo.impacto_de(tipo, jugo)
	if frase != "":
		decir_felipe(frase, true)


func _al_maullar(boca: Vector2) -> void:
	jugo.palabra_en_mundo("¡MIAU!", boca + Vector2(felipe.mirando * 14.0, -18.0), Color(1.0, 0.95, 0.6), 16)
	if not dialogo.ocupado() and randf() < 0.5:
		decir_felipe("maullar")


func _al_aranar(_objetivo: Node2D, critico: bool) -> void:
	if not critico or felipe == null:
		return
	jugo.congelar(0.09)
	jugo.sacudir(0.2, 0.8)
	jugo.destello(0.3)
	jugo.palabra_en_mundo("¡CRÍTICO!", felipe.global_position + Vector2(felipe.mirando * 30.0, -80.0), Color(1.0, 0.4, 0.3), 22)
	decir_felipe("aranar_critico", true)


func _al_comer_snack() -> void:
	if felipe:
		jugo.palabra_en_mundo("¡ÑAM!", felipe.global_position + Vector2(0, -80), Color(1.0, 0.8, 0.5), 15)
	decir_felipe("snack")


## Felipe dice una frase del evento (sin repetir la anterior).
func decir_felipe(evento: String, urgente := false) -> void:
	var frase := frases.elegir("felipe", evento)
	if not frase.is_empty():
		dialogo.decir("felipe", String(frase[0]), int(frase[1]), urgente)


func decir_valeria(evento: String, urgente := false) -> void:
	var frase := frases.elegir("valeria", evento)
	if not frase.is_empty():
		dialogo.decir("valeria", String(frase[0]), int(frase[1]), urgente)


## Resumen del día tipo Balatro (al terminar el nivel). Pausa el juego hasta que se cierra.
func mostrar_resumen(frase_final: Array = []) -> ResumenDia:
	libreta.cerrar()
	libreta.habilitada = false
	var frase := frase_final if not frase_final.is_empty() else (Frases.FELIPE["agenda_completa"][0] if agenda.completa() else ["Mañana, más. Hoy ya hice demasiado.", 0])
	var resumen := ResumenDia.new()
	resumen.mostrar(ResumenDia.filas_de(agenda, recompensas, perdones), frase)
	resumen.cerrado.connect(func() -> void:
		libreta.habilitada = true
		resumen_cerrado.emit())
	add_child(resumen)
	return resumen


## Muestra u oculta la interfaz del juego (HUD, diálogo, palabras y carteles) mientras hay una pantalla encima (G7).
func mostrar_interfaz(visible_ahora: bool) -> void:
	for capa: CanvasLayer in [hud, dialogo, jugo]:
		if capa:
			capa.visible = visible_ahora


## Altura del cartel que no tapa a Felipe (sus 67 px sobre los pies) ni al cuadro de diálogo.
func altura_cartel() -> float:
	if felipe == null:
		return Hud.Y_CARTEL
	var pies := _en_pantalla(felipe.global_position).y
	var felipe_ocupa := Vector2(pies - 72.0, pies)
	var dialogo_ocupa := Vector2(dialogo.lugar(), dialogo.lugar() + 56.0)
	for y: float in Hud.ALTURAS_CARTEL:
		var cartel := Vector2(y, y + Hud.ALTO_CARTEL)
		if not _se_cruzan(cartel, felipe_ocupa) and not _se_cruzan(cartel, dialogo_ocupa):
			return y
	return Hud.Y_CARTEL


func _se_cruzan(a: Vector2, b: Vector2) -> bool:
	return a.x < b.y and b.x < a.y


func _en_pantalla(posicion: Vector2) -> Vector2:
	var vista := get_viewport()
	return vista.get_canvas_transform() * posicion if vista else posicion
