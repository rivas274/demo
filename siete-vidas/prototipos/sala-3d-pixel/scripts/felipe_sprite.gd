# PROTOTIPO: no es código del juego.
# Pregunta: ¿se ve mejor la sala en 3D renderizado como pixel art?
# Fecha: 2026-10-21
# Felipe tal cual está en el juego (sus hojas 2D) puesto como Sprite3D en la sala 3D.
# Escala de siempre: cuadro de 106 px a 0.72 => 67 px de alto en 640x360.
extends Sprite3D

const PX_POR_METRO := 121.0
const ESCALA_SPRITE := 0.72
const HOJAS := {
	"quieto": [preload("res://assets/felipe/felipe-idle-sheet.png"), 8.0],
	"caminar": [preload("res://assets/felipe/felipe-caminar-largo-sheet.png"), 10.0],
}

## 120 px/s del juego pasados a metros.
@export var velocidad := 120.0 / PX_POR_METRO
@export var puntos: Array[float] = [-1.1, 1.7]
@export var pausa := 3.5

var _anim := ""
var _cuadro_t := 0.0
var _destino := 0
var _espera := 0.0


func _ready() -> void:
	pixel_size = ESCALA_SPRITE / PX_POR_METRO
	hframes = 8
	texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	shaded = false
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	centered = true
	# Los pies del cuadro de 106 px quedan cerca del borde de abajo.
	offset = Vector2(0, 52)
	_poner("quieto")


func _process(delta: float) -> void:
	_cuadro_t += delta * float(HOJAS[_anim][1])
	frame = int(_cuadro_t) % 8
	if _espera > 0.0:
		_espera -= delta
		return
	var x := puntos[_destino]
	var d := x - position.x
	if absf(d) < 0.02:
		_destino = (_destino + 1) % puntos.size()
		_espera = pausa
		_poner("quieto")
		return
	flip_h = d < 0.0
	position.x += signf(d) * minf(absf(d), velocidad * delta)
	_poner("caminar")


func _poner(nombre: String) -> void:
	if _anim == nombre:
		return
	_anim = nombre
	texture = HOJAS[nombre][0]
	_cuadro_t = 0.0
