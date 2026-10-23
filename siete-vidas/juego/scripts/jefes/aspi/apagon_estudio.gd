class_name ApagonEstudio
extends Node2D
## El apagón de la fase 3 de A.S.P.I. («Cortocircuito y apagón», maqueta de Gemini, 2026-10-23): el cuarto queda en
## penumbra azulada (CanvasModulate: el del cuarto si ya hay uno, el de LuzCuarto, o uno propio) y alumbran solo
## la luz roja de emergencia de A.S.P.I. (late), su LED verde, la luz de la luna por la ventana y un brillo frío
## alrededor de Felipe (sus ojos de gato: siempre se ve dónde está). Lo que hay que leer (avisos, charcos, bolas) va sin
## sombrear. La penumbra no es negra: los muebles se siguen viendo (pilar: no es un juego que castiga).
## Luces con la textura en escalones de la casa (`assets/luz/luz_escalones.png`), sin halo suave (lección 26).

## Color del cuarto a oscuras. Al cortarse, la luz parpadea 3 veces con ritmo (v4, Gemini: en vez del destello blanco):
## tramos de oscuro y luz que se alargan, y queda a oscuras.
const OSCURO := Color(0.36, 0.38, 0.54)
const RITMO: Array[float] = [0.12, 0.08, 0.14, 0.08, 0.18, 0.08]
## Charcos (v4, iluminación selectiva): un brillo celeste chico sobre cada uno.
const CHARCO := ["Charco", Color(0.55, 0.85, 1.0), 0.55, 0.3]
const CUARTO := "estudio"
const TEXTURA := "res://assets/luz/luz_escalones.png"
## Luces: [nombre, color, energía, escala de la textura].
const EMERGENCIA := ["Emergencia de A.S.P.I.", Color(1.0, 0.18, 0.12), 1.3, 0.75]
const LED := ["LED de A.S.P.I.", Color(0.4, 1.0, 0.5), 0.6, 0.18]
const OJOS := ["Ojos de Felipe", Color(0.75, 0.88, 1.0), 0.75, 0.45]
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
var _luces_charco: Array[PointLight2D] = []
var _textura: Texture2D
## Dónde están los charcos ahora (x, ancho); lo da la pelea.
var charcos: Callable


func _init(de_nivel: Nivel, de_jefe: Node2D, de_felipe: Node2D) -> void:
	name = "Apagón del estudio"
	nivel = de_nivel
	jefe = de_jefe
	felipe = de_felipe


func _ready() -> void:
	_textura = load(TEXTURA) if ResourceLoader.exists(TEXTURA) else null
	for datos: Array in [EMERGENCIA, LED, OJOS, LUNA]:
		_luces[datos[0]] = _luz(datos)
	(_luces[LUNA[0]] as PointLight2D).global_position = VENTANA


func _luz(datos: Array) -> PointLight2D:
	var luz := PointLight2D.new()
	luz.name = datos[0]
	luz.texture = _textura
	luz.color = datos[1]
	luz.energy = datos[2]
	luz.texture_scale = datos[3]
	luz.blend_mode = Light2D.BLEND_MODE_ADD
	luz.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	luz.enabled = false
	add_child(luz)
	return luz


## Se corta la luz: parpadea con RITMO y queda en penumbra.
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
	for luz in _luces_charco:
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
	_alumbrar_charcos()
	if _ambiente == null or not is_instance_valid(_ambiente):
		return
	if nivel.habitacion != CUARTO:
		# Fuera del estudio (Felipe perdió una vida) el resto de la casa tiene luz.
		_ambiente.color = _color_normal()
		return
	# Al cortarse, la luz parpadea tres veces con ritmo antes de quedar a oscuras.
	_ambiente.color = _color_normal() if parpadeando() and _tramo() % 2 == 1 else OSCURO


## ¿Todavía en los parpadeos de la entrada?
func parpadeando() -> bool:
	return activo and _tramo() < RITMO.size()


## En qué tramo del RITMO va (pares: oscuro; impares: luz).
func _tramo() -> int:
	var t := 0.0
	for i in RITMO.size():
		t += RITMO[i]
		if _reloj < t:
			return i
	return RITMO.size()


## Cuántos charcos están alumbrados ahora (para las pruebas).
func charcos_alumbrados() -> int:
	return _luces_charco.filter(func(luz: PointLight2D) -> bool: return luz.enabled).size()


## Una luz celeste chica sobre cada charco (se leen a oscuras: son la clave de la fase).
func _alumbrar_charcos() -> void:
	var lista: Array[Vector2] = charcos.call() if charcos.is_valid() else []
	while _luces_charco.size() < lista.size():
		_luces_charco.append(_luz(CHARCO))
	for i in _luces_charco.size():
		var luz := _luces_charco[i]
		luz.enabled = i < lista.size()
		if luz.enabled:
			luz.global_position = Vector2(lista[i].x, nivel.datos.suelo - 6.0)


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
