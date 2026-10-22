# PROTOTIPO: no es código del juego.
# Pregunta: ¿se ve vivo Felipe de Meshy con una retopología, un esqueleto y una caminata
# hechos en Blender como lo haría un artista (y no armados por código)?
# Fecha: 2026-10-22
# - Modelo: assets/meshy_prueba/felipe_rig/felipe_rig.glb (malla en cuadriláteros, textura
#   horneada, piel con pesos de calor y 2 animaciones: "caminar" y "quieto").
#   Se arma con los scripts de assets/meshy_prueba/felipe_rig/scripts/ (Blender 5.2 como módulo).
# - La caminata es "en el lugar": el nodo avanza a la velocidad del paso que trae
#   felipe_rig.json, así la pata apoyada no resbala.
# - Rutina: quieto, camina a la derecha, quieto, se da vuelta y camina a la izquierda, en bucle.
# Se abre con: godot --path . -- --felipe-rig
extends Node3D

const RUTA := "res://assets/meshy_prueba/felipe_rig/felipe_rig.glb"
const RUTA_INFO := "res://assets/meshy_prueba/felipe_rig/felipe_rig.json"
const MEZCLA := 0.25
const GIRO_S := 0.45

## 1,3: el tamaño que pidió el creador para el Felipe 3D (30 % más grande).
@export var escala := 1.3
@export var usar_toon := true
## Al caminar se gira un poco hacia la cámara para que se vea la cara (como felipe_meshy.gd).
@export var giro_caminar := 20.0
## Mirando a la cámara en 3/4 cuando está quieto.
@export var giro_quieto := 40.0
@export var x_izquierda := -0.9
@export var x_derecha := 0.9
@export var z_piso := 0.3
@export var quieto_s := 3.0

var ap: AnimationPlayer
var modelo: Node3D
var mira_derecha := true
var velocidad := 0.187  # m/s a escala 1; se lee de felipe_rig.json
var _estado := "quieto"
var _t := 0.0
var _giro_desde := 0.0
var _giro_hasta := 0.0
var _t_giro := 1.0


func _ready() -> void:
	_leer_info()
	var doc := GLTFDocument.new()
	var estado := GLTFState.new()
	if doc.append_from_file(RUTA, estado) != OK:
		push_error("felipe_rig: no se pudo cargar " + RUTA)
		return
	modelo = doc.generate_scene(estado)
	modelo.scale = Vector3.ONE * escala
	add_child(modelo)
	ap = modelo.find_children("*", "AnimationPlayer", true, false)[0]
	for nombre in ["caminar", "quieto"]:
		ap.get_animation(nombre).loop_mode = Animation.LOOP_LINEAR
	if usar_toon:
		for mi in modelo.find_children("*", "MeshInstance3D", true, false):
			var m := mi as MeshInstance3D
			var src := m.mesh.surface_get_material(0) as BaseMaterial3D
			var mt := Toon.material(Color.WHITE)
			mt.set_shader_parameter("usar_textura", true)
			mt.set_shader_parameter("textura", src.albedo_texture if src else null)
			m.material_override = mt
	position = Vector3(x_izquierda, 0, z_piso)
	_girar_a(_angulo(), true)
	ap.play("quieto")


func _leer_info() -> void:
	var f := FileAccess.open(RUTA_INFO, FileAccess.READ)
	if f == null:
		return
	var d = JSON.parse_string(f.get_as_text())
	if d is Dictionary and d.has("velocidad_caminar_m_s"):
		velocidad = float(d["velocidad_caminar_m_s"])


## Velocidad de avance en x (m/s) con la escala y el giro hacia la cámara.
func velocidad_caminar() -> float:
	return velocidad * escala * cos(deg_to_rad(giro_caminar))


## El modelo mira a +Z; girar 90° lo hace mirar a +X. Se gira hacia la cámara (+Z).
func _angulo() -> float:
	var g := giro_caminar if _estado == "caminar" else giro_quieto
	return deg_to_rad((90.0 - g) if mira_derecha else (-90.0 + g))


func _girar_a(ang: float, ya: bool = false) -> void:
	_giro_desde = rotation.y
	_giro_hasta = ang
	_t_giro = 1.0 if ya else 0.0
	if ya:
		rotation.y = ang


func _process(delta: float) -> void:
	if ap == null:
		return
	_t += delta
	if _t_giro < 1.0:
		_t_giro = minf(1.0, _t_giro + delta / GIRO_S)
		rotation.y = lerp_angle(_giro_desde, _giro_hasta, smoothstep(0.0, 1.0, _t_giro))
	match _estado:
		"quieto":
			if _t >= quieto_s:
				_estado = "caminar"
				_t = 0.0
				_girar_a(_angulo())
				ap.play("caminar", MEZCLA)
		"caminar":
			var dir := 1.0 if mira_derecha else -1.0
			position.x += dir * velocidad_caminar() * delta
			var meta := x_derecha if mira_derecha else x_izquierda
			if (position.x - meta) * dir >= 0.0:
				position.x = meta
				mira_derecha = not mira_derecha
				_estado = "quieto"
				_t = 0.0
				_girar_a(_angulo())
				ap.play("quieto", MEZCLA)
