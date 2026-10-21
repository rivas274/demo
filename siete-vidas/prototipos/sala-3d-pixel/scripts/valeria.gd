# PROTOTIPO: no es código del juego.
# Pregunta: ¿se ve mejor la sala en 3D renderizado como pixel art?
# Fecha: 2026-10-21
# Valeria en 3D: maniquí CC0 de Quaternius recoloreado por hueso, con moño.
# Guion en bucle: entra caminando, se sienta en el sofá, se queda, se para y se va.
# Modo manual (Tab): flechas izquierda/derecha caminan, abajo se sienta, arriba se para.
extends Node3D

const RUTA := "res://assets/quaternius/AnimationLibrary_Godot_Standard.glb"
const SUDADERA := Color("3f6f68")
const PANTALON := Color("3d3a40")
const PIEL := Color("d9a07a")
const PELO := Color("5a3220")
const ZAPATOS := Color("e8dccb")

@export var alto_m := 1.65
@export var velocidad := 1.05
@export var x_fuera := 4.6
@export var tiempo_sentada := 5.0
@export var tiempo_giro := 0.35
@export var mezcla := 0.2
## Cuánto más atrás (hacia el sofá) queda la cadera al sentarse; se compensa al pararse.
@export var z_camino := -0.15

var manual := false
var x_sofa := 0.4
var z_sentada := -0.72

var _modelo: Node3D
var _ap: AnimationPlayer
var _fase := "esperar"
var _t := 0.0
var _rumbo := -PI * 0.5
var _rumbo_desde := 0.0
var _rumbo_hasta := 0.0


func _ready() -> void:
	_modelo = (load(RUTA) as PackedScene).instantiate() as Node3D
	add_child(_modelo)
	var mi := _modelo.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
	var sk := _modelo.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	_ap = _modelo.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	_modelo.scale = Vector3.ONE * (alto_m / mi.mesh.get_aabb().size.y)
	_recolorear(mi, sk)
	_pelo(sk)
	position = Vector3(x_fuera, 0.0, z_camino)
	_ap.play("Idle")
	_cambiar("entrar")


func _process(delta: float) -> void:
	_t += delta
	if manual:
		_manual(delta)
	else:
		_guion(delta)
	rotation.y = _rumbo


func _guion(delta: float) -> void:
	match _fase:
		"entrar":
			if _caminar_hacia(x_sofa, delta):
				_girar_a(0.0, "sentarse")
		"girar":
			_girar(delta)
		"sentarse":
			# Se echa hacia atrás hasta el cojín mientras baja.
			position.z = lerpf(z_camino, z_sentada, clampf(_t / 0.8, 0.0, 1.0))
			if _t >= _ap.current_animation_length - 0.05:
				_ap.play("Sitting_Idle", mezcla)
				_cambiar("sentada")
		"sentada":
			if _t >= tiempo_sentada:
				_ap.play("Sitting_Exit", 0.1)
				_cambiar("pararse")
		"pararse":
			position.z = lerpf(z_sentada, z_camino, clampf((_t - 0.2) / 0.7, 0.0, 1.0))
			if _t >= _ap.current_animation_length - 0.05:
				_ap.play("Idle", mezcla)
				_girar_a(PI * 0.5, "salir")
		"salir":
			if _caminar_hacia(x_fuera, delta):
				_ap.play("Idle", mezcla)
				_cambiar("esperar")
		"esperar":
			if _t >= 1.0:
				position.x = x_fuera
				_cambiar("entrar")


func _manual(delta: float) -> void:
	var eje := Input.get_axis("ui_left", "ui_right")
	if _fase in ["sentada", "sentarse", "pararse"]:
		if _fase == "sentarse" or _fase == "pararse":
			_guion(delta)
		elif Input.is_action_just_pressed("ui_up"):
			_ap.play("Sitting_Exit", 0.1)
			_cambiar("pararse")
		return
	if _fase == "girar":
		_girar(delta)
		return
	if eje != 0.0:
		_rumbo = PI * 0.5 * signf(eje)
		position.x += eje * velocidad * delta
		if _ap.current_animation != "Walk":
			_ap.play("Walk", mezcla)
	elif _ap.current_animation != "Idle":
		_ap.play("Idle", mezcla)
	if Input.is_action_just_pressed("ui_down") and absf(position.x - x_sofa) < 0.5:
		position.x = x_sofa
		_girar_a(0.0, "sentarse")


## Devuelve true al llegar.
func _caminar_hacia(x: float, delta: float) -> bool:
	var d := x - position.x
	if absf(d) < 0.02:
		position.x = x
		return true
	_rumbo = PI * 0.5 * signf(d)
	if _ap.current_animation != "Walk":
		_ap.play("Walk", mezcla)
	position.x += signf(d) * minf(absf(d), velocidad * delta)
	return false


var _despues_de_girar := ""


func _girar_a(rumbo: float, siguiente: String) -> void:
	_rumbo_desde = _rumbo
	_rumbo_hasta = rumbo
	_despues_de_girar = siguiente
	if _ap.current_animation == "Walk":
		_ap.play("Idle", mezcla)
	_cambiar("girar")


func _girar(_delta: float) -> void:
	var k := clampf(_t / tiempo_giro, 0.0, 1.0)
	_rumbo = lerp_angle(_rumbo_desde, _rumbo_hasta, k)
	if k >= 1.0:
		if _despues_de_girar == "sentarse":
			_ap.play("Sitting_Enter", mezcla)
		_cambiar(_despues_de_girar)


func _cambiar(fase: String) -> void:
	_fase = fase
	_t = 0.0


## Pinta cada vértice según el hueso que más lo mueve: sudadera, pantalón, piel, zapatos.
func _recolorear(mi: MeshInstance3D, sk: Skeleton3D) -> void:
	var nueva := ArrayMesh.new()
	for s in mi.mesh.get_surface_count():
		var arr := mi.mesh.surface_get_arrays(s)
		var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		var huesos: PackedInt32Array = arr[Mesh.ARRAY_BONES]
		var pesos: PackedFloat32Array = arr[Mesh.ARRAY_WEIGHTS]
		var por := huesos.size() / verts.size()
		var colores := PackedColorArray()
		colores.resize(verts.size())
		for i in verts.size():
			var mejor := 0
			for j in por:
				if pesos[i * por + j] > pesos[i * por + mejor]:
					mejor = j
			var b := huesos[i * por + mejor]
			var nombre := mi.skin.get_bind_name(b) if mi.skin else &""
			if nombre == &"" and mi.skin:
				nombre = sk.get_bone_name(mi.skin.get_bind_bone(b))
			colores[i] = _color_de_hueso(String(nombre))
		arr[Mesh.ARRAY_COLOR] = colores
		var banderas := Mesh.ARRAY_FLAG_USE_8_BONE_WEIGHTS if por == 8 else 0
		nueva.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr, [], {}, banderas)
	mi.mesh = nueva
	var mat := Toon.material(Color.WHITE)
	mat.set_shader_parameter("usar_color_vertice", true)
	mat.next_pass = Toon.material_contorno()
	mi.material_override = mat


func _color_de_hueso(n: String) -> Color:
	if "head" in n or "neck" in n or "hand" in n or "f_" in n or "thumb" in n:
		return PIEL
	if "foot" in n or "toe" in n:
		return ZAPATOS
	if "thigh" in n or "shin" in n or "hips" in n:
		return PANTALON
	return SUDADERA


## Pelo castaño con moño, pegado al hueso de la cabeza.
func _pelo(sk: Skeleton3D) -> void:
	var i := sk.find_bone("DEF-head")
	var anexo := BoneAttachment3D.new()
	anexo.bone_name = "DEF-head"
	sk.add_child(anexo)
	var reposo := sk.get_bone_global_rest(i)
	var pelo := Node3D.new()
	anexo.add_child(pelo)
	pelo.transform = reposo.affine_inverse() * Transform3D(Basis(), reposo.origin + Vector3(0, 0.12, 0))
	var mat := Toon.material(PELO)
	mat.next_pass = Toon.material_contorno()
	_esfera(pelo, 0.112, Vector3(0, 0.05, -0.045), Vector3(1.0, 0.85, 0.95), mat)
	_esfera(pelo, 0.075, Vector3(0, 0.15, -0.07), Vector3.ONE, mat)
	# Ojos: dos puntitos oscuros (a esta escala son 2 px).
	var ojo := Toon.material(Color("2a1810"))
	for lado in [-1.0, 1.0]:
		var o := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.022, 0.03, 0.02)
		o.mesh = bm
		o.material_override = ojo
		o.position = Vector3(0.038 * lado, 0.0, 0.095)
		pelo.add_child(o)


func _esfera(padre: Node3D, r: float, pos: Vector3, esc: Vector3, mat: Material) -> void:
	var m := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2.0
	sm.radial_segments = 16
	sm.rings = 8
	m.mesh = sm
	m.position = pos
	m.scale = esc
	m.material_override = mat
	padre.add_child(m)
