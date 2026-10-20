class_name SiluetaTapada
extends Node2D
## Pieza «silueta tapada» (plan de estabilización 2026-10-20, decisión 1): cuando un humano (Valeria, 200 px, más
## cerca de la cámara) tapa a Felipe, se dibuja el CONTORNO de Felipe de 1 px en un color claro del tema, solo en la
## parte tapada. Es la técnica de oclusión de muchos juegos 2D: Felipe queda detrás (profundidad) y el jugador nunca
## lo pierde.
##
## Cómo funciona: la pieza es hija del que tapa, que se dibuja con `clip_children` (sus hijos solo se ven dentro de
## su silueta opaca). La pieza copia cada cuadro el sprite de Felipe (hoja, cuadro, giro, escala y lugar) y lo dibuja
## con un shader que deja solo el borde. Si Felipe no está detrás (otra capa más alta, invisible), no dibuja.
##   var silueta := SiluetaTapada.new()
##   valeria.add_child(silueta)
##   silueta.seguir(felipe.sprite)

const COLOR := &"silueta_tapada"
## Grosor del borde en pixeles de la hoja: la hoja se dibuja a 0,72, así 1,4 pixeles de hoja ≈ 1 px de pantalla.
const GROSOR := 1.4

const SHADER := """
shader_type canvas_item;
render_mode unshaded;
uniform vec4 color : source_color;
uniform float grosor = 1.4;
void fragment() {
	float a = texture(TEXTURE, UV).a;
	vec2 p = TEXTURE_PIXEL_SIZE * grosor;
	float v = min(min(texture(TEXTURE, UV + vec2(p.x, 0.0)).a, texture(TEXTURE, UV - vec2(p.x, 0.0)).a),
			min(texture(TEXTURE, UV + vec2(0.0, p.y)).a, texture(TEXTURE, UV - vec2(0.0, p.y)).a));
	v = min(v, min(min(texture(TEXTURE, UV + p).a, texture(TEXTURE, UV - p).a),
			min(texture(TEXTURE, UV + vec2(p.x, -p.y)).a, texture(TEXTURE, UV + vec2(-p.x, p.y)).a)));
	float borde = step(0.5, a) * (1.0 - step(0.5, v));
	COLOR = vec4(color.rgb, color.a * borde);
}
"""

var _origen: AnimatedSprite2D
var _copia := Sprite2D.new()


func _ready() -> void:
	name = "SiluetaTapada"
	var padre := get_parent() as CanvasItem
	if padre != null:
		padre.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	var material := ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = SHADER
	material.shader = shader
	material.set_shader_parameter("color", Estilo.color(COLOR))
	material.set_shader_parameter("grosor", GROSOR)
	_copia.material = material
	_copia.visible = false
	add_child(_copia)


## Sigue al sprite que puede quedar tapado (el de Felipe).
func seguir(sprite: AnimatedSprite2D) -> void:
	_origen = sprite


## ¿Está dibujando el contorno ahora? (las pruebas lo leen).
func dibujando() -> bool:
	return _copia.visible


func _process(_delta: float) -> void:
	var padre := get_parent() as CanvasItem
	var ver := _origen != null and is_instance_valid(_origen) and _origen.is_visible_in_tree() \
			and padre != null and padre.is_visible_in_tree() \
			and Capas.z_efectivo(_origen) < Capas.z_efectivo(padre)
	_copia.visible = ver
	if not ver:
		return
	_copia.texture = _origen.sprite_frames.get_frame_texture(_origen.animation, _origen.frame)
	_copia.centered = _origen.centered
	_copia.offset = _origen.offset
	_copia.flip_h = _origen.flip_h
	_copia.flip_v = _origen.flip_v
	_copia.global_transform = _origen.global_transform
	_copia.modulate.a = _origen.modulate.a
