class_name Dialogo
extends CanvasLayer
## Diálogo con retrato (pilar 5): los pensamientos de Felipe (sus 9 caras) y lo que dicen los otros personajes
## (Valeria, A.S.P.I.). El cuadro es la pieza CuadroDialogo (interfaz v2 «A + C»: caja oscura con la sombra del color
## del personaje, franja del nombre y fondo del retrato).
## - Una sola cola para todos: nadie contesta tarde ni se pisan (en el prototipo Felipe respondía a Valeria
##   cuando ella ya se había ido).
## - 2 líneas por página; si una frase no cabe (sobre todo con texto grande), se pagina: cada página se escribe letra a
##   letra y se cierra sola o se salta (Enter o LB).
## - No repite la misma frase seguida y descarta las que esperaron demasiado en la cola.
## - {acción} dentro del texto se cambia por el ícono del botón en uso (por ejemplo "{maullar} Servidumbre: abran.").
## - Va SIEMPRE arriba (zona B, bajo la salud), también con texto grande; solo si Felipe está tan arriba en la pantalla
##   que el cuadro lo taparía, sale abajo (hasta el borde de la zona segura).

signal dicho(quien: String, texto: String)

const ESCENA := "res://escenas/ui/cuadro_dialogo.tscn"
## Personajes: el ánimo es el número de su cara (ícono del kit `cara-dialogo-<quien>-<n>`).
## Felipe: 0 de reojo, 1 orejas planas, 2 sorprendido, 3 ojos cerrados, 4 sonrisa leve, 5 asqueado, 6 feliz,
## 7 presumido, 8 bufando. Valeria: 0 neutra, 1 enojada, 2 derretida, 3 grabando. A.S.P.I.: 0 normal, 1 alerta.
const PERSONAJES := {
	"felipe": {"caras": 9},
	"valeria": {"caras": 4},
	"aspi": {"caras": 2},
}
const VALERIA_NEUTRA := 0
const VALERIA_ENOJADA := 1
const VALERIA_DERRETIDA := 2
const VALERIA_GRABANDO := 3
## Líneas por página (normal y grande). Una frase del juego cabe en una página con texto normal (la prueba lo mide).
const MAX_LINEAS := 2
const MAX_COLA := 3
## Si los pies de Felipe quedan por encima de esta y en pantalla, el cuadro sale abajo.
const FELIPE_ABAJO_DESDE := 160.0

## Letras por segundo.
@export var velocidad_texto := 55.0
## Segundos que queda la página completa antes de seguir sola (más un poco por letra).
@export var espera_base := 1.3
@export var espera_por_letra := 0.035
## Una frase que espera en la cola más que esto se descarta (ya no viene al caso).
@export var caducidad_cola := 2.0

## Personaje al que el cuadro no debe tapar (Felipe). Sin él, el cuadro va arriba.
var seguir: Node2D
## Mientras devuelva true (hay un cartel en la zona C, la misma franja), las frases nuevas esperan en la cola sin
## envejecer. Lo pone Anuncios.
var esperar := Callable()
## Mientras devuelva true (una franja de fase del jefe, urgente, ocupa la zona C), ni las frases urgentes salen: van
## primeras en la cola. Lo pone Anuncios.
var esperar_urgente := Callable()
## Durante una pelea (PeleaJefe), lo que dice Felipe va a este globito sobre su cabeza (GloboDialogo) y no al cuadro
## de arriba, que tapaba la acción (crítica de Gemini, 2026-10-23). null = el cuadro de siempre.
var globo: GloboDialogo
var hablando := ""
var texto_actual := ""
## Páginas de la frase que se dice y cuál se ve.
var paginas: PackedStringArray = []
var pagina := 0
## Frases que se mostraron, en orden: [quien, texto] (para las pruebas y el resumen).
var historial: Array = []
var _cola: Array = []
var _caja: CuadroDialogo
var _texto: RichTextLabel
var _visibles := 0.0
var _largo := 0
var _espera := 0.0
var _reloj := 0.0
var _ultima := ""
var _animo := 0
var _en_presentacion := false


func _ready() -> void:
	layer = Capas.CAPA_DIALOGO
	add_to_group(PresentacionJefe.GRUPO_OCULTAR)
	process_mode = Node.PROCESS_MODE_ALWAYS
	_caja = (load(ESCENA) as PackedScene).instantiate()
	add_child(_caja)
	_texto = _caja.texto
	_caja.visible = false


## Pone una frase en la cola. `animo` es la cara del retrato (ver PERSONAJES). Urgente: corta lo que se dice.
## No repite la misma frase seguida. Devuelve false si se descartó.
func decir(quien: String, texto: String, animo := 0, urgente := false) -> bool:
	# Las frases llegan como claves de traducciones/textos.csv (FELIPE_..., VALERIA_...): aquí pasan a texto.
	texto = tr(texto)
	if _en_presentacion or texto == "" or texto == _ultima or (_caja.visible and texto == texto_actual):
		return false
	if quien == "felipe" and globo != null and is_instance_valid(globo):
		_ultima = texto
		historial.append([quien, texto])
		globo.decir(texto)
		dicho.emit(quien, texto)
		return true
	for pendiente: Array in _cola:
		if pendiente[1] == texto:
			return false
	if urgente and esperar_urgente.is_valid() and esperar_urgente.call():
		_cola.push_front([quien, texto, animo, _reloj])
		if _caja.visible:
			ceder()
	elif urgente or (not _caja.visible and not _debe_esperar()):
		_mostrar(quien, texto, animo)
	else:
		_cola.append([quien, texto, animo, _reloj])
		if _cola.size() > MAX_COLA:
			_cola.pop_front()
	return true


## Cierra lo que se esté diciendo y vacía la cola (por ejemplo, al cambiar de escena o empezar una cinemática).
func limpiar() -> void:
	_cola.clear()
	_caja.visible = false
	hablando = ""
	texto_actual = ""


## Hay una frase en pantalla.
func ocupado() -> bool:
	return _caja.visible


## Un cartel urgente pide la franja: la frase que se dice vuelve a la cola (primera) y el cuadro se esconde.
func ceder() -> void:
	if not _caja.visible:
		return
	_cola.push_front([hablando, texto_actual, _animo, _reloj])
	_ultima = ""
	_caja.visible = false
	hablando = ""
	texto_actual = ""


func _debe_esperar() -> bool:
	return esperar.is_valid() and esperar.call()


## La presentación de un jefe esconde el diálogo y lo que estaba en cola (M4); mientras dura, no se habla.
func al_presentar_jefe(presentando: bool) -> void:
	_en_presentacion = presentando
	if presentando:
		limpiar()


## Rectángulo del cuadro en pantalla (vacío si no se ve): para que los avisos no queden debajo (M3).
func rect_en_pantalla() -> Rect2:
	return _caja.rect_en_pantalla() if _caja.visible else Rect2()


## ¿El cuadro va abajo para no tapar a Felipe? Se decide al empezar cada frase.
func va_abajo() -> bool:
	if seguir == null or not is_instance_valid(seguir) or not seguir.is_inside_tree():
		return false
	var pies := seguir.get_viewport().get_canvas_transform() * seguir.global_position
	return pies.y <= FELIPE_ABAJO_DESDE


## Parte un texto en líneas del ancho del cuadro (con texto normal o grande). Cada {acción} cuenta como un ícono.
static func partir(texto: String, grande := false) -> PackedStringArray:
	var limpio := TranslationServer.translate(texto)
	var estilo := &"dialogo_texto_grande" if grande else &"dialogo_texto"
	var ancho := ancho_texto(grande)
	var lineas: PackedStringArray = []
	var actual := ""
	for palabra in limpio.split(" ", false):
		var prueba := palabra if actual == "" else actual + " " + palabra
		if actual != "" and _ancho_con_iconos(prueba, estilo) > ancho:
			lineas.append(actual)
			actual = palabra
		else:
			actual = prueba
	if actual != "":
		lineas.append(actual)
	return lineas


## Ancho del texto en el cuadro v2 (528 px menos la sangría tras la diagonal y el margen derecho).
static func ancho_texto(grande := false) -> float:
	var alto := 16.0 + MAX_LINEAS * float(CuadroDialogo.LINEA[2 if grande else 1])
	return CuadroDialogo.ANCHO_CAJA - KitUI.inclinacion(alto) - CuadroDialogo.SANGRIA_EXTRA - CuadroDialogo.MARGEN_DERECHO


static func _ancho_con_iconos(texto: String, estilo: StringName) -> float:
	for accion: String in Controles.ACCIONES:
		texto = texto.replace("{%s}" % accion, "MM")
	return Estilo.ancho(texto, estilo)


## Cuántas líneas ocupa la frase en el cuadro con texto normal (las frases deben caber en 1 o 2).
static func lineas_de(texto: String) -> int:
	return partir(texto).size()


func _mostrar(quien: String, texto: String, animo: int) -> void:
	hablando = quien
	texto_actual = texto
	_ultima = texto
	_animo = animo
	historial.append([quien, texto])
	var datos: Dictionary = PERSONAJES.get(quien, PERSONAJES["felipe"])
	var de := quien if PERSONAJES.has(quien) else "felipe"
	var cara := KitUI.textura("cara-dialogo-%s-%d" % [de, clampi(animo, 0, int(datos["caras"]) - 1)])
	_caja.armar(de, cara, tr("NOMBRE_" + quien) if PERSONAJES.has(quien) else quien.to_upper(), Opciones.texto_grande, va_abajo())
	_caja.visible = true
	# Páginas de 2 líneas.
	var lineas := partir(texto, Opciones.texto_grande)
	paginas = []
	for i in range(0, lineas.size(), MAX_LINEAS):
		paginas.append(" ".join(lineas.slice(i, i + MAX_LINEAS)))
	if paginas.is_empty():
		paginas.append(texto)
	_mostrar_pagina(0)
	dicho.emit(quien, texto)


func _mostrar_pagina(n: int) -> void:
	pagina = n
	_escribir(paginas[n])
	_visibles = 0.0
	_texto.visible_characters = 0
	_espera = espera_base + espera_por_letra * paginas[n].length()


## Escribe el texto cambiando cada {acción} por el ícono de su botón.
func _escribir(texto: String) -> void:
	_texto.clear()
	_largo = 0
	var lado := Estilo.letra(_caja.estilo_texto()) - 2
	var resto := texto
	while resto != "":
		var inicio := resto.find("{")
		var fin := resto.find("}", inicio)
		if inicio < 0 or fin < 0:
			_texto.add_text(resto)
			_largo += resto.length()
			break
		if inicio > 0:
			_texto.add_text(resto.substr(0, inicio))
			_largo += inicio
		var accion := resto.substr(inicio + 1, fin - inicio - 1)
		var icono := IconosBotones.textura(accion)
		if icono:
			_texto.add_image(icono, int(icono.get_size().x * lado / IconosBotones.LADO), lado)
			_largo += 1
		else:
			var etiqueta := "[%s]" % IconosBotones.texto(accion)
			_texto.add_text(etiqueta)
			_largo += etiqueta.length()
		resto = resto.substr(fin + 1)


## Enter / LB: primero completa el texto; si ya está completo, pasa a la página o a la frase siguiente.
func saltar() -> void:
	if not _caja.visible:
		return
	if _texto.visible_characters >= 0 and _texto.visible_characters < _largo:
		_texto.visible_characters = -1
		_visibles = _largo
	else:
		_seguir()


func _seguir() -> void:
	if pagina + 1 < paginas.size():
		_mostrar_pagina(pagina + 1)
	else:
		_cerrar()


func _cerrar() -> void:
	_caja.visible = false
	hablando = ""
	texto_actual = ""
	_siguiente()


func _siguiente() -> void:
	if _debe_esperar():
		return
	while not _cola.is_empty():
		var siguiente: Array = _cola.pop_front()
		if _reloj - float(siguiente[3]) > caducidad_cola:
			continue
		_mostrar(siguiente[0], siguiente[1], siguiente[2])
		return


func _process(delta: float) -> void:
	# Tiempo real (sin el congelado del Jugo).
	delta = delta / maxf(Engine.time_scale, 0.001)
	_reloj += delta
	if InputMap.has_action("saltar_dialogo") and Input.is_action_just_pressed("saltar_dialogo"):
		saltar()
	if not _caja.visible:
		if not _cola.is_empty():
			if _debe_esperar():
				# Mientras espera un cartel, lo que está en la cola no envejece.
				for pendiente: Array in _cola:
					pendiente[3] = float(pendiente[3]) + delta
			else:
				_siguiente()
		return
	if _visibles < _largo:
		_visibles += velocidad_texto * delta
		_texto.visible_characters = mini(int(_visibles), _largo)
		return
	_texto.visible_characters = -1
	_espera -= delta
	if _espera <= 0.0:
		_seguir()
