class_name DetectorMando
extends Node
## Pieza (autoload «Mandos»): qué se está usando para jugar —teclado, mando de Xbox, de PlayStation, de Switch, Steam
## Deck o uno genérico— y si un mando se conecta o se desconecta en caliente. Se apoya en el addon «Input Helper» de
## Nathan Hoad (MIT, addons/input_helper/, autoload «InputHelper»): él mira cada evento y reconoce el mando por su nombre
## (los mapeos SDL que trae Godot dan los botones por posición). Aquí solo se traduce a nuestros tipos y se avisa con
## `mando_cambiado(tipo)`: Controles (textos) e IconosBotones (íconos) escuchan; la interfaz solo escucha.
## Además: en Switch, confirmar es el botón de la derecha y cancelar el de abajo (diseño de Nintendo) —ui_accept y
## ui_cancel se cambian de botón al detectarlo—, y vibrar() hace una vibración leve si Opciones la deja.
## Sin el addon (por ejemplo, en una prueba suelta), lee el nombre del mando con Input.get_joy_name.

signal mando_cambiado(tipo: StringName)

const TECLADO := &"teclado"
const XBOX := &"xbox"
const PLAYSTATION := &"playstation"
const SWITCH := &"switch"
const STEAM_DECK := &"steam_deck"
const GENERICO := &"generico"
## Nombre del dispositivo en Input Helper -> nuestro tipo.
const TIPOS := {
	"keyboard": TECLADO, "xbox": XBOX, "playstation": PLAYSTATION, "switch": SWITCH, "switch_left_joycon": SWITCH,
	"switch_right_joycon": SWITCH, "steamdeck": STEAM_DECK, "generic": GENERICO,
}
## Palabras del nombre del mando (Input.get_joy_name) por tipo, para cuando no está el addon.
const PALABRAS := {
	XBOX: ["xinput", "xbox"], PLAYSTATION: ["sony", "ps5", "ps4", "playstation", "dualsense", "dualshock"],
	STEAM_DECK: ["steam"], SWITCH: ["switch", "joy-con", "nintendo"],
}

## Lo que se usa ahora y el índice del mando (-1 con teclado).
var tipo: StringName = TECLADO
var indice := -1
## Mandos conectados ahora (índices).
var conectados: Array[int] = []


## El detector del árbol (el autoload «Mandos»), o null en una prueba sin él.
static func de(arbol: SceneTree) -> DetectorMando:
	return arbol.root.get_node_or_null("Mandos") as DetectorMando if arbol else null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mando_cambiado.connect(func(nuevo: StringName) -> void: Controles.al_cambiar_mando(nuevo))
	mando_cambiado.connect(func(nuevo: StringName) -> void: IconosBotones.al_cambiar_mando(nuevo))
	for i in Input.get_connected_joypads():
		conectados.append(i)
	var ayudante := get_node_or_null("/root/InputHelper")
	if ayudante:
		ayudante.device_changed.connect(_al_cambiar_dispositivo)
		ayudante.joypad_changed.connect(al_conectar)
	else:
		Input.joy_connection_changed.connect(al_conectar)


## Input Helper avisa que se cambió de dispositivo.
func _al_cambiar_dispositivo(dispositivo: String, indice_mando: int) -> void:
	cambiar(TIPOS.get(dispositivo, GENERICO), indice_mando)


## Tipo de un mando por su nombre (el de Input Helper si está; si no, por palabras).
func tipo_de_nombre(nombre: String) -> StringName:
	var ayudante := get_node_or_null("/root/InputHelper")
	if ayudante:
		return TIPOS.get(ayudante.get_simplified_device_name(nombre), GENERICO)
	var bajo := nombre.to_lower()
	for clave: StringName in PALABRAS:
		for palabra: String in PALABRAS[clave]:
			if palabra in bajo:
				return clave
	return GENERICO


## Cambia lo que se usa y avisa (solo si cambió).
func cambiar(nuevo: StringName, indice_mando := -1) -> void:
	if nuevo == tipo and indice_mando == indice:
		return
	tipo = nuevo
	indice = indice_mando if nuevo != TECLADO else -1
	_confirmar_segun_mando()
	mando_cambiado.emit(tipo)


## Un mando se conectó o se desconectó: si era el que se usaba, vuelve el teclado (los íconos no quedan colgados).
func al_conectar(indice_mando: int, conectado: bool) -> void:
	if conectado:
		if not conectados.has(indice_mando):
			conectados.append(indice_mando)
		return
	conectados.erase(indice_mando)
	if indice_mando == indice:
		cambiar(TECLADO, -1)


## ¿Se está jugando con un mando?
func usa_mando() -> bool:
	return tipo != TECLADO


## Vibración leve del mando en uso (golpes, derrotas, aterrizajes fuertes), si Opciones la deja.
func vibrar(debil: float, fuerte: float, segundos: float) -> void:
	if not Opciones.vibracion or indice < 0 or segundos <= 0.0:
		return
	Input.start_joy_vibration(indice, clampf(debil, 0.0, 1.0), clampf(fuerte, 0.0, 1.0), segundos)


## Diseño de Nintendo en Switch: confirmar con el botón de la derecha (JOY_BUTTON_B, que en Switch dice «A») y cancelar
## con el de abajo (JOY_BUTTON_A, que dice «B»). Godot nombra los botones por posición (como Xbox), así que en los
## demás mandos confirmar es el de abajo. Solo cambian ui_accept y ui_cancel (los menús); las acciones del juego no.
func _confirmar_segun_mando() -> void:
	var nintendo := tipo == SWITCH
	_poner_boton(&"ui_accept", JOY_BUTTON_B if nintendo else JOY_BUTTON_A)
	_poner_boton(&"ui_cancel", JOY_BUTTON_A if nintendo else JOY_BUTTON_B)


func _poner_boton(accion: StringName, boton: JoyButton) -> void:
	if not InputMap.has_action(accion):
		return
	for e: InputEvent in InputMap.action_get_events(accion):
		if e is InputEventJoypadButton and (e as InputEventJoypadButton).button_index in [JOY_BUTTON_A, JOY_BUTTON_B]:
			InputMap.action_erase_event(accion, e)
	var nuevo := InputEventJoypadButton.new()
	nuevo.button_index = boton
	nuevo.device = -1
	InputMap.action_add_event(accion, nuevo)
