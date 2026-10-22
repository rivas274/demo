# PROTOTIPO: no es código del juego.
# Pregunta: ¿se ve mejor la sala en 3D renderizado como pixel art?
# Fecha: 2026-10-21
# Arma la tubería: escena 3D -> SubViewport chico -> bordes -> paleta -> pantalla 1280x720
# con escala entera (pixel de render de x2, x3 o x4 pixeles de pantalla).
# Teclas: 1 paleta, 2 bordes, 3 escalones de luz, 4 tamaño de pixel, Tab guion/manual, F1 ayuda.
# Argumentos (después de --): --con-paleta, --pixel=2|3|4, --maniqui (Valeria maniquí de la v2),
# --felipe-anima (solo Felipe de Meshy con la caminata del gato de Quaternius: camina, salta al sofá y vuelve).
extends Node

## Escala del juego: Valeria 1,65 m = 200 px de 640x360, Felipe 67 px. El encuadre
## (2,975 m de alto) no cambia con el tamaño del pixel: los personajes miden lo mismo.
const PX_POR_METRO := 121.0
const ALTO_CUADRO_M := 360.0 / PX_POR_METRO
const PANTALLA := Vector2i(1280, 720)
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
@export var paleta_activa := false
## Tamaño del pixel de render en pixeles de pantalla 1280x720 (2 = 640x360 de render).
@export var tam_pixel := 3
@export var contorno_activo := true
@export var escalones_activos := true
@export var limites_camara := Vector2(-1.2, 1.9)

var vista: SubViewport
var pantalla: TextureRect
var camara: Camera3D
var valeria: Node3D
var felipe: Sprite3D
var felipe_3d: Node3D
var felipe_ia: Node3D
var felipe_animado: Node3D
var bordes: ShaderMaterial
var ayuda: Label
var _cam_x := 0.0


func _ready() -> void:
	if "--valeria-mixamo" in OS.get_cmdline_user_args():
		set_process(false)  # Valeria Meshy + Mixamo: escena propia (valeria_mixamo.tscn).
		get_tree().change_scene_to_file.call_deferred("res://valeria_mixamo.tscn")
		return
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--pixel="):
			tam_pixel = int(arg.get_slice("=", 1))
	vista = SubViewport.new()
	vista.msaa_3d = Viewport.MSAA_DISABLED
	vista.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
	vista.use_taa = false
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
	if not "--maniqui" in OS.get_cmdline_user_args():
		# v3: Valeria hecha por IA desde su imagen, con esqueleto automático.
		valeria.set("malla_ia", "res://assets/valeria_ia/valeria_hunyuan.glb")
		valeria.set("alto_m", 1.75)  # con el moño
		valeria.set("z_sentada", -0.6)  # piernas más cortas: se sienta más adelante
	vista.add_child(valeria)
	var solo_felipe := "--felipe-anima" in OS.get_cmdline_user_args()
	if solo_felipe:
		valeria.visible = false
		valeria.process_mode = Node.PROCESS_MODE_DISABLED
		felipe_animado = Node3D.new()
		felipe_animado.name = "FelipeAnimado"
		felipe_animado.set_script(load("res://scripts/felipe_meshy.gd"))
		felipe_animado.set("version", 8)  # v8: piezas del creador (FELIPE_VERSION=7 o FELIPE_PIEZAS=0 para comparar)
		felipe_animado.set("escala", 1.3)  # pedido del creador: 30 % más grande
		vista.add_child(felipe_animado)
		var guion := Node.new()
		guion.name = "GuionFelipe"
		guion.set_script(load("res://scripts/guion_felipe_animado.gd"))
		guion.set("felipe", felipe_animado)
		add_child(guion)

	if not solo_felipe:
		_felipes_comparar(sala)
	_armar_camara()


func _felipes_comparar(sala: Node3D) -> void:
	felipe = Sprite3D.new()
	felipe.name = "Felipe"
	felipe.set_script(load("res://scripts/felipe_sprite.gd"))
	felipe.position = Vector3(2.2, 0.0, 0.45)
	felipe.set("puntos", [2.2] as Array[float])
	vista.add_child(felipe)

	# Felipe de primitivas, quieto a un lado para comparar.
	felipe_3d = _modelo_3d("Felipe3D", "", Vector3(2.75, 0.0, 0.45), true)
	# Felipe hecho por IA desde su imagen: el que camina y salta al sofá.
	felipe_ia = _modelo_3d("FelipeIA", "res://assets/felipe_ia/felipe_hunyuan.glb", Vector3.ZERO, false)
	felipe_ia.set("x_sofa", sala.get("punto_sofa").x + 0.68)
	valeria.connect("empieza_vuelta", func() -> void: felipe_ia.set("_t", 0.0))


func _armar_camara() -> void:
	camara = Camera3D.new()
	camara.projection = Camera3D.PROJECTION_ORTHOGONAL
	camara.size = ALTO_CUADRO_M
	camara.near = 0.1
	camara.far = 40.0
	camara.rotation_degrees.x = -inclinacion_grados
	vista.add_child(camara)
	# Post-proceso de bordes: un quad pegado a la cámara que cubre la pantalla.
	var quad := MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(1, 1)
	quad.mesh = qm
	quad.extra_cull_margin = 16384.0
	quad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	bordes = ShaderMaterial.new()
	bordes.shader = load("res://shaders/bordes.gdshader")
	quad.material_override = bordes
	quad.position = Vector3(0, 0, -1)
	camara.add_child(quad)
	_cam_x = clampf(_objetivo().position.x, limites_camara.x, limites_camara.y)
	_colocar_camara()

	pantalla = TextureRect.new()
	pantalla.texture = vista.get_texture()
	pantalla.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pantalla.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pantalla.stretch_mode = TextureRect.STRETCH_SCALE
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
	ayuda.text = "1 paleta  2 bordes  3 escalones  4 pixel x2/x3/x4  Tab guion/manual (flechas)"
	ayuda.position = Vector2(8, 690)
	ayuda.add_theme_font_size_override("font_size", 16)
	ayuda.visible = false
	add_child(ayuda)
	if "--con-paleta" in OS.get_cmdline_user_args():
		paleta_activa = true
	_cambiar_pixel(tam_pixel)
	_aplicar()


func _process(delta: float) -> void:
	var meta := clampf(_objetivo().position.x, limites_camara.x, limites_camara.y)
	_cam_x = lerpf(_cam_x, meta, clampf(delta * 2.5, 0.0, 1.0))
	_colocar_camara()


## La cámara sigue a Valeria, o a Felipe en el modo --felipe-anima.
func _objetivo() -> Node3D:
	return felipe_animado if felipe_animado else valeria


func _cambiar_pixel(k: int) -> void:
	tam_pixel = k
	vista.size = Vector2i(ceili(PANTALLA.x / float(k)), PANTALLA.y / k)
	pantalla.size = Vector2(vista.size * k)
	pantalla.position = Vector2.ZERO


func _modelo_3d(nombre: String, ruta: String, pos: Vector3, quieto: bool, alto: float = 67.0 / 121.0) -> Node3D:
	var n := Node3D.new()
	n.name = nombre
	n.set_script(load("res://scripts/felipe_3d.gd"))
	n.set("modelo_ia", ruta)
	n.set("solo_quieto", quieto)
	n.set("alto_ia", alto)
	n.position = pos
	vista.add_child(n)
	return n


## La cámara solo se mueve en x y en múltiplos exactos de un pixel de render: nada tiembla.
func _colocar_camara() -> void:
	var px_m := float(vista.size.y) / ALTO_CUADRO_M
	var x := roundf(_cam_x * px_m) / px_m
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
		KEY_4:
			_cambiar_pixel(2 + (tam_pixel - 1) % 3)
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
	bordes.set_shader_parameter("activo", contorno_activo)
