class_name Dialogo
extends CanvasLayer
## Cuadro de diálogo abajo, con retrato (pilar 5): los pensamientos de Felipe (sus 9 caras de
## felipe-retratos.png) y lo que dicen los otros personajes (Valeria, A.S.P.I.).
## - Una sola cola para todos: nadie contesta tarde ni se pisan (en el prototipo Felipe respondía a Valeria
##   cuando ella ya se había ido).
## - Frases de 1 o 2 líneas; se escriben letra a letra, se cierran solas y se saltan (Enter o LB).
## - No repite la misma frase seguida y descarta las que esperaron demasiado en la cola.
## - {acción} dentro del texto se cambia por el ícono del botón en uso (por ejemplo "{maullar} Servidumbre: abran.").
## - Nunca tapa a Felipe: con la cámara del juego, en el piso queda abajo de la pantalla, así que el cuadro sale
##   arriba (bajo el HUD); si Felipe está arriba (librero, repisa), sale abajo.

signal dicho(quien: String, texto: String)

const ESCENA := "res://escenas/ui/cuadro_dialogo.tscn"
const RETRATOS_FELIPE := "res://assets/felipe/felipe-retratos.png"
## Hoja de Valeria y A.S.P.I. (Gemini, tanda 3B; la recorta herramientas/preparar_retratos.py): 3 x 2 cuadros.
## Si falta, se usa el retrato provisional dibujado por código (RetratoValeria).
const RETRATOS_OTROS := "res://assets/personajes/retratos-valeria-aspi.png"
## Personajes: nombre en pantalla, hoja, columnas y cuadro de la hoja para cada ánimo.
## Felipe (3 x 3): 0 de reojo, 1 orejas planas, 2 sorprendido, 3 ojos cerrados, 4 sonrisa leve, 5 asqueado,
## 6 feliz, 7 presumido, 8 bufando. Valeria: 0 neutra, 1 enojada, 2 derretida, 3 grabando. A.S.P.I.: 0 normal, 1 alerta.
const PERSONAJES := {
	"felipe": {"nombre": "FELIPE", "hoja": RETRATOS_FELIPE, "columnas": 3, "cuadros": [0, 1, 2, 3, 4, 5, 6, 7, 8]},
	"valeria": {"nombre": "VALERIA", "hoja": RETRATOS_OTROS, "columnas": 3, "cuadros": [0, 1, 2, 3]},
	"aspi": {"nombre": "A.S.P.I.", "hoja": RETRATOS_OTROS, "columnas": 3, "cuadros": [4, 5]},
}
const VALERIA_NEUTRA := 0
const VALERIA_ENOJADA := 1
const VALERIA_DERRETIDA := 2
const VALERIA_GRABANDO := 3
## Ancho del texto: con letra de 14 px caben unas 70 letras por línea; más de 2 líneas no se aceptan.
const ANCHO_TEXTO := 548.0
const TAM_LETRA := 14
const MAX_LINEAS := 2
const MAX_COLA := 3
## Posición del cuadro arriba (bajo el HUD) y abajo; y de la pantalla desde la que Felipe "está abajo".
const Y_ARRIBA := 44.0
const Y_ABAJO := 300.0
const FELIPE_ABAJO_DESDE := 190.0

## Letras por segundo.
@export var velocidad_texto := 55.0
## Segundos que queda la frase completa antes de cerrarse sola (más un poco por letra).
@export var espera_base := 1.3
@export var espera_por_letra := 0.035
## Una frase que espera en la cola más que esto se descarta (ya no viene al caso).
@export var caducidad_cola := 2.0

## Personaje al que el cuadro no debe tapar (Felipe). Sin él, el cuadro va arriba.
var seguir: Node2D
var hablando := ""
var texto_actual := ""
## Frases que se mostraron, en orden: [quien, texto] (para las pruebas y el resumen).
var historial: Array = []
var _cola: Array = []
var _caja: Panel
var _nombre: Label
var _texto: RichTextLabel
var _retrato: TextureRect
var _retrato_codigo: RetratoValeria
var _visibles := 0.0
var _largo := 0
var _espera := 0.0
var _reloj := 0.0
var _ultima := ""
var _hojas := {}
var _en_presentacion := false


func _ready() -> void:
	layer = Capas.CAPA_DIALOGO
	add_to_group(PresentacionJefe.GRUPO_OCULTAR)
	process_mode = Node.PROCESS_MODE_ALWAYS
	# El cuadro (panel, marco, retrato, nombre y texto) se arma en el editor: escenas/ui/cuadro_dialogo.tscn; su
	# aspecto sale del tema (variaciones CuadroDialogo, NombreDialogo y TextoDialogo).
	_caja = (load(ESCENA) as PackedScene).instantiate()
	add_child(_caja)
	_retrato = _caja.get_node("%Retrato")
	_retrato_codigo = _caja.get_node("%RetratoCodigo")
	_nombre = _caja.get_node("%Nombre")
	_texto = _caja.get_node("%Texto")
	_caja.visible = false


## Pone una frase en la cola. `animo` es el cuadro del retrato (ver PERSONAJES). Urgente: corta lo que se dice.
## No repite la misma frase seguida. Devuelve false si se descartó.
func decir(quien: String, texto: String, animo := 0, urgente := false) -> bool:
	if _en_presentacion or texto == "" or texto == _ultima or (_caja.visible and texto == texto_actual):
		return false
	for pendiente: Array in _cola:
		if pendiente[1] == texto:
			return false
	if urgente or not _caja.visible:
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


## La presentación de un jefe esconde el diálogo y lo que estaba en cola (M4); mientras dura, no se habla.
func al_presentar_jefe(presentando: bool) -> void:
	_en_presentacion = presentando
	if presentando:
		limpiar()


## Rectángulo del cuadro en pantalla (vacío si no se ve): para que los avisos no queden debajo (M3).
func rect_en_pantalla() -> Rect2:
	return Rect2(_caja.position, _caja.size) if _caja.visible else Rect2()


## Dónde va el cuadro (y en pantalla) para no tapar a Felipe. Se decide al empezar cada frase.
func lugar() -> float:
	if seguir == null or not is_instance_valid(seguir) or not seguir.is_inside_tree():
		return Y_ARRIBA
	var pies := seguir.get_viewport().get_canvas_transform() * seguir.global_position
	return Y_ARRIBA if pies.y > FELIPE_ABAJO_DESDE else Y_ABAJO


## Cuántas líneas ocupa la frase en el cuadro (las frases deben caber en 1 o 2).
static func lineas_de(texto: String) -> int:
	var limpio := texto
	for accion: String in Controles.ACCIONES:
		limpio = limpio.replace("{%s}" % accion, "MM")
	var parrafo := TextParagraph.new()
	parrafo.add_string(limpio, Estilo.fuente(), TAM_LETRA)
	parrafo.width = ANCHO_TEXTO
	parrafo.break_flags = TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE
	return parrafo.get_line_count()


func _mostrar(quien: String, texto: String, animo: int) -> void:
	hablando = quien
	texto_actual = texto
	_ultima = texto
	historial.append([quien, texto])
	_caja.visible = true
	# Las frases pasan por la traducción (hoy en español; mañana, una clave por frase en traducciones/).
	_escribir(tr(texto))
	_visibles = 0.0
	_texto.visible_characters = 0
	_espera = espera_base + espera_por_letra * texto.length()
	var datos: Dictionary = PERSONAJES.get(quien, PERSONAJES["felipe"])
	_nombre.text = tr("NOMBRE_" + quien) if PERSONAJES.has(quien) else String(datos["nombre"])
	var hoja := _hoja(String(datos["hoja"]))
	var cuadros: Array = datos["cuadros"]
	_retrato.visible = hoja != null
	_retrato_codigo.visible = hoja == null
	if hoja:
		var cuadro: int = cuadros[clampi(animo, 0, cuadros.size() - 1)]
		var columnas: int = datos["columnas"]
		var lado := hoja.get_width() / float(columnas)
		var cara := AtlasTexture.new()
		cara.atlas = hoja
		cara.region = Rect2((cuadro % columnas) * lado, (cuadro / columnas) * lado, lado, lado)
		_retrato.texture = cara
	else:
		_retrato_codigo.personaje = quien
		_retrato_codigo.animo = animo
		_retrato_codigo.queue_redraw()
	_caja.position.y = lugar()
	# Pequeño golpe al aparecer.
	_caja.pivot_offset = Vector2(30, 28)
	_caja.scale = Vector2(1.0, 0.7)
	create_tween().tween_property(_caja, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	dicho.emit(quien, texto)


## Escribe el texto cambiando cada {acción} por el ícono de su botón.
func _escribir(texto: String) -> void:
	_texto.clear()
	_largo = 0
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
			_texto.add_image(icono, int(icono.get_size().x * 14.0 / IconosBotones.LADO), 14)
			_largo += 1
		else:
			var etiqueta := "[%s]" % IconosBotones.texto(accion)
			_texto.add_text(etiqueta)
			_largo += etiqueta.length()
		resto = resto.substr(fin + 1)


func _hoja(ruta: String) -> Texture2D:
	if not _hojas.has(ruta):
		_hojas[ruta] = load(ruta) if ResourceLoader.exists(ruta) else null
	return _hojas[ruta]


## Enter / LB: primero completa el texto; si ya está completo, pasa a la siguiente frase.
func saltar() -> void:
	if not _caja.visible:
		return
	if _texto.visible_characters >= 0 and _texto.visible_characters < _largo:
		_texto.visible_characters = -1
		_visibles = _largo
	else:
		_cerrar()


func _cerrar() -> void:
	_caja.visible = false
	hablando = ""
	texto_actual = ""
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
		return
	if _visibles < _largo:
		_visibles += velocidad_texto * delta
		_texto.visible_characters = mini(int(_visibles), _largo)
		return
	_texto.visible_characters = -1
	_espera -= delta
	if _espera <= 0.0:
		_cerrar()
