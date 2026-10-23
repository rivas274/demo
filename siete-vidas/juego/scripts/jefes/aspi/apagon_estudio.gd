class_name ApagonEstudio
extends Node2D
## El apagón de la fase 3 de A.S.P.I. («Cortocircuito y apagón», maqueta de Gemini, 2026-10-23): el cuarto queda en
## penumbra azulada (CanvasModulate: el del cuarto si ya hay uno, el de LuzCuarto, o uno propio) y alumbran solo
## la luz roja de emergencia de A.S.P.I. (late), su LED verde, la luz de la luna por la ventana y un brillo frío
## alrededor de Felipe (sus ojos de gato: siempre se ve dónde está). Lo que hay que leer (avisos, charcos, bolas) va sin
## sombrear. La penumbra no es negra: los muebles se siguen viendo (pilar: no es un juego que castiga).
## Luces con la textura en escalones de la casa (`assets/luz/luz_escalones.png`), sin halo suave (lección 26).

## Color del cuarto a oscuras y cuánto dura el parpadeo al cortarse la luz.
const OSCURO := Color(0.36, 0.38, 0.54)
const PARPADEO := 0.6
const CUARTO := "estudio"
const TEXTURA := "res://assets/luz/luz_escalones.png"
## Luces: [nombre, color, energía, escala de la textura].
const EMERGENCIA := ["Emergencia de A.S.P.I.", Color(1.0, 0.18, 0.12), 1.3, 0.75]
const LED := ["LED de A.S.P.I.", Color(0.4, 1.0, 0.5), 0.6, 0.18]
const OJOS := ["Ojos de Felipe", Color(0.7, 0.85, 1.0), 0.45, 0.38]
const LUNA := ["Luna de la ventana", Color(0.55, 0.65, 1.0), 0.5, 0.9]
## Centro de la ventana del estudio (luz de la luna), en el mundo.
const VENTANA := Vector2(7120, 280)

var activo := false
var nivel: Nivel
var jefe: Node2D
var felipe: Node2D
var _ambiente: CanvasModulate
var _propio := false
var _reloj := 0.0
var _luces := {}


func _init(de_nivel: Nivel, de_jefe: Node2D, de_felipe: Node2D) -> void:
	name = "Apagón del estudio"
	nivel = de_nivel
	jefe = de_jefe
	felipe = de_felipe


func _ready() -> void:
	var textura: Texture2D = load(TEXTURA) if ResourceLoader.exists(TEXTURA) else null
	for datos: Array in [EMERGENCIA, LED, OJOS, LUNA]:
		var luz := PointLight2D.new()
		luz.name = datos[0]
		luz.texture = textura
		luz.color = datos[1]
		luz.energy = datos[2]
		luz.texture_scale = datos[3]
		luz.blend_mode = Light2D.BLEND_MODE_ADD
		luz.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		luz.enabled = false
		add_child(luz)
		_luces[datos[0]] = luz
	(_luces[LUNA[0]] as PointLight2D).global_position = VENTANA


## Se corta la luz: parpadea PARPADEO s y queda en penumbra.
func apagar() -> void:
	_ambiente = _buscar_ambiente()
	activo = true
	_reloj = 0.0
	for luz: PointLight2D in _luces.values():
		luz.enabled = true


## Vuelve la luz de golpe (al apagar a A.S.P.I. por última vez).
func encender() -> void:
	activo = false
	for luz: PointLight2D in _luces.values():
		luz.enabled = false
	if _ambiente and is_instance_valid(_ambiente):
		_ambiente.color = _color_normal()


func _process(delta: float) -> void:
	if not activo:
		return
	_reloj += delta
	if is_instance_valid(jefe):
		(_luces[EMERGENCIA[0]] as PointLight2D).global_position = jefe.global_position + Vector2(0, -20)
		(_luces[LED[0]] as PointLight2D).global_position = jefe.global_position + Vector2(10, -12)
		# Luz de emergencia que late (rojo intenso y medio), con pasos enteros: sin degradado suave.
		(_luces[EMERGENCIA[0]] as PointLight2D).energy = EMERGENCIA[2] * (1.0 if int(_reloj * 3.0) % 2 == 0 else 0.6)
	if is_instance_valid(felipe):
		(_luces[OJOS[0]] as PointLight2D).global_position = felipe.global_position + Vector2(0, -30)
	if _ambiente == null or not is_instance_valid(_ambiente):
		return
	if nivel.habitacion != CUARTO:
		# Fuera del estudio (Felipe perdió una vida) el resto de la casa tiene luz.
		_ambiente.color = _color_normal()
		return
	# Al cortarse, la luz parpadea tres veces antes de quedar a oscuras.
	if _reloj < PARPADEO and int(_reloj * 10.0) % 2 == 0:
		_ambiente.color = _color_normal()
	else:
		_ambiente.color = OSCURO


## El ambiente del cuarto: el de LuzCuarto si existe; si no, uno propio (blanco fuera del apagón).
func _buscar_ambiente() -> CanvasModulate:
	if _ambiente and is_instance_valid(_ambiente):
		return _ambiente
	for nodo in nivel.find_children("*", "CanvasModulate", true, false):
		return nodo as CanvasModulate
	var propio := CanvasModulate.new()
	propio.name = "Ambiente del apagón"
	add_child(propio)
	_propio = true
	return propio


func _color_normal() -> Color:
	return Nivel1.AMBIENTE_CUARTOS.get(nivel.habitacion, Color.WHITE)
