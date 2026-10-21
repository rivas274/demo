# PROTOTIPO: no es código del juego.
# Pregunta: ¿se ve mejor la sala en 3D renderizado como pixel art?
# Fecha: 2026-10-21
# Arma la tubería: escena 3D -> SubViewport 640x360 -> paleta -> pantalla con escala entera.
# Teclas: 1 paleta, 2 contorno, 3 escalones de luz, Tab guion/manual, F1 ayuda.
extends Node

const PX_POR_METRO := 121.0  # Valeria 1,65 m = 200 px, como en el juego.
const PALETA := [
	"d6b088", "c79c74", "e9c9a0",
	# Madera, pared y sombras (de la sala del juego).
	"210c0a", "3e1b10", "572c1d", "7c4127", "905535", "a15e35", "b66a42", "ae7857",
	"be926c", "d9a06e", "f0c38f", "ffe2b0", "5e3c2b", "6e5641",
	# Sofá y alfombra.
	"a55534", "d98b5e", "e8a878", "c27046",
	# Lámpara y cielo.
	"ffd28a", "f0a868", "fff1d0",
	# Valeria: sudadera, pantalón, piel, pelo, zapatos.
	"1f3b3a", "2c524e", "3f6f68", "5d8f86", "2a282e", "3d3a40", "57535a",
	"9c6448", "c3845f", "d9a07a", "f0c09a", "5a3220", "3a1e14", "e8dccb",
	# Sombras frías (violeta).
	"2b2238", "3d3150", "56486a", "6f6585", "8a6f80",
	# Plantas.
	"3f5a2a", "6e8a3a", "93a95a",
	# Felipe (sacados de su hoja).
	"ede8de", "dacbbf", "c1afa4", "ac9188", "8d7f73", "7c6f67", "605350", "4d4143", "31262f",
]

@export var inclinacion_grados := 18.0
@export var paleta_activa := true
@export var contorno_activo := true
@export var escalones_activos := true
@export var limites_camara := Vector2(-1.4, 1.9)

var vista: SubViewport
var pantalla: TextureRect
var camara: Camera3D
var valeria: Node3D
var felipe: Sprite3D
var ayuda: Label
var _cam_x := 0.0


func _ready() -> void:
	vista = SubViewport.new()
	vista.size = Vector2i(640, 360)
	vista.msaa_3d = Viewport.MSAA_DISABLED
	vista.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vista.positional_shadow_atlas_size = 2048
	add_child(vista)

	var mundo := WorldEnvironment.new()
	var amb := Environment.new()
	amb.background_mode = Environment.BG_COLOR
	amb.background_color = Color("210c0a")
	amb.ambient_light_source = Environment.AMBIENT_SOURCE_DISABLED
	amb.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	mundo.environment = amb
	vista.add_child(mundo)

	var sala := Node3D.new()
	sala.name = "Sala"
	sala.set_script(load("res://scripts/sala.gd"))
	vista.add_child(sala)

	valeria = Node3D.new()
	valeria.name = "Valeria"
	valeria.set_script(load("res://scripts/valeria.gd"))
	valeria.set("x_sofa", sala.get("punto_sofa").x)
	vista.add_child(valeria)

	felipe = Sprite3D.new()
	felipe.name = "Felipe"
	felipe.set_script(load("res://scripts/felipe_3d.gd"))
	felipe.position = Vector3(-1.1, 0.0, 0.55)
	vista.add_child(felipe)

	camara = Camera3D.new()
	camara.projection = Camera3D.PROJECTION_ORTHOGONAL
	camara.size = 360.0 / PX_POR_METRO
	camara.near = 0.1
	camara.far = 40.0
	camara.rotation_degrees.x = -inclinacion_grados
	vista.add_child(camara)
	_cam_x = clampf(valeria.position.x, limites_camara.x, limites_camara.y)
	_colocar_camara()

	pantalla = TextureRect.new()
	pantalla.texture = vista.get_texture()
	pantalla.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/paleta.gdshader")
	var colores := PackedVector3Array()
	for h in PALETA:
		var c := Color(h)
		colores.append(Vector3(c.r, c.g, c.b))
	mat.set_shader_parameter("paleta", colores)
	mat.set_shader_parameter("cantidad", colores.size())
	pantalla.material = mat
	add_child(pantalla)

	ayuda = Label.new()
	ayuda.text = "1 paleta  2 contorno  3 escalones  Tab guion/manual  (flechas)"
	ayuda.position = Vector2(4, 344)
	ayuda.add_theme_font_size_override("font_size", 8)
	ayuda.visible = false
	add_child(ayuda)
	_aplicar()


func _process(delta: float) -> void:
	var meta := clampf(valeria.position.x, limites_camara.x, limites_camara.y)
	_cam_x = lerpf(_cam_x, meta, clampf(delta * 2.5, 0.0, 1.0))
	_colocar_camara()


## La cámara solo se mueve en x y en múltiplos exactos de un píxel: nada tiembla.
func _colocar_camara() -> void:
	var x := roundf(_cam_x * PX_POR_METRO) / PX_POR_METRO
	var y_centro := 1.22
	var dist := 12.0
	var a := deg_to_rad(inclinacion_grados)
	camara.position = Vector3(x, y_centro + dist * sin(a), dist * cos(a))


func _unhandled_input(e: InputEvent) -> void:
	if not (e is InputEventKey and e.pressed and not e.echo):
		return
	match (e as InputEventKey).keycode:
		KEY_1:
			paleta_activa = not paleta_activa
		KEY_2:
			contorno_activo = not contorno_activo
		KEY_3:
			escalones_activos = not escalones_activos
		KEY_TAB:
			valeria.set("manual", not valeria.get("manual"))
		KEY_F1:
			ayuda.visible = not ayuda.visible
	_aplicar()


func _aplicar() -> void:
	(pantalla.material as ShaderMaterial).set_shader_parameter("activa", paleta_activa)
	for m in Toon.materiales:
		m.set_shader_parameter("escalones", escalones_activos)
		if m.next_pass:
			(m.next_pass as ShaderMaterial).set_shader_parameter("grosor_px", 1.0 if contorno_activo else 0.0)
	for c in Toon.contornos:
		c.visible = contorno_activo
