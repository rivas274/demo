# PROTOTIPO: no es código del juego.
# Diagnóstico de los brazos de Valeria Mixamo: renderiza de cerca, de frente y de perfil,
# idle, walking y texting en tres versiones: (a) GLB tal cual, (b) pistas copiadas como en
# la rutina, (c) el FBX de caminar directo.
# Uso: xvfb-run godot --path . -s pruebas/valeria_brazos.gd -- <carpeta_salida>
extends SceneTree

const Carga := preload("res://scripts/mixamo_carga.gd")
const M := "res://assets/meshy_prueba/valeria/mixamo/"
const CLIPS := {"idle": 2.0, "walking": 0.3, "texting": 6.0}

var _salida := ""
var _vista: SubViewport
var _cam: Camera3D
var _cola: Array = []
var _actual: Dictionary = {}
var _espera := 0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	_salida = args[0] if args.size() > 0 and not args[0].begins_with("--") else "user://"
	_vista = SubViewport.new()
	_vista.size = Vector2i(300, 400)
	_vista.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_vista)
	var amb := Environment.new()
	amb.background_mode = Environment.BG_COLOR
	amb.background_color = Color(0.85, 0.9, 0.92)
	amb.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	amb.ambient_light_color = Color(0.6, 0.6, 0.6)
	var we := WorldEnvironment.new()
	we.environment = amb
	_vista.add_child(we)
	var sol := DirectionalLight3D.new()
	_vista.add_child(sol)
	sol.look_at_from_position(Vector3.ZERO, Vector3(-0.4, -0.7, -1.0), Vector3.UP)
	_cam = Camera3D.new()
	_cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	_cam.size = 1.9
	_vista.add_child(_cam)
	for v in ["a", "b", "c", "d"]:
		for clip: String in CLIPS:
			if v == "c" and clip != "walking":
				continue
			for vista in ["frente", "perfil"]:
				_cola.append({"v": v, "clip": clip, "vista": vista})


func _modelo(v: String, clip: String) -> Node3D:
	var raiz: Node3D
	if v == "d":
		return _modelo_fbx(clip)
	if v == "c":
		raiz = Carga.cargar(M + "valeria_walking.fbx")
	else:
		raiz = Carga.cargar(M + "valeria_animada.glb")
	_vista.add_child(raiz)
	var ap := Carga.primero(raiz, "AnimationPlayer") as AnimationPlayer
	var t: float = CLIPS[clip]
	if v == "b":
		var sk := Carga.primero(raiz, "Skeleton3D") as Skeleton3D
		var a := Carga.copiar(ap.get_animation(clip), String(raiz.get_path_to(sk)), sk, true)
		ap.stop()
		ap.queue_free()
		var nuevo := AnimationPlayer.new()
		raiz.add_child(nuevo)
		nuevo.root_node = nuevo.get_path_to(raiz)
		var lib := AnimationLibrary.new()
		lib.add_animation("x", a)
		nuevo.add_animation_library("", lib)
		nuevo.play("x")
		nuevo.seek(t, true)
	else:
		var nombre: String = clip if v == "a" else String(ap.get_animation_list()[0])
		if v == "c":
			for n in ap.get_animation_list():
				if String(n).begins_with("mixamo"):
					nombre = n
		ap.play(nombre)
		ap.seek(t, true)
	return raiz


## (d) Como la rutina con los FBX: malla del FBX de caminar + pistas del FBX de cada clip.
const FBX := {"idle": "valeria_breathing_idle.fbx", "walking": "valeria_walking.fbx", "texting": "valeria_texting.fbx"}


func _modelo_fbx(clip: String) -> Node3D:
	var raiz := Carga.cargar(M + "valeria_walking.fbx")
	_vista.add_child(raiz)
	var sk := Carga.primero(raiz, "Skeleton3D") as Skeleton3D
	var fuente := Carga.cargar(M + FBX[clip])
	var a := Carga.copiar(Carga.animacion(fuente), String(raiz.get_path_to(sk)), sk, true)
	fuente.free()
	var viejo := Carga.primero(raiz, "AnimationPlayer") as AnimationPlayer
	viejo.stop()
	viejo.queue_free()
	var ap := AnimationPlayer.new()
	raiz.add_child(ap)
	ap.root_node = ap.get_path_to(raiz)
	var lib := AnimationLibrary.new()
	lib.add_animation("x", a)
	ap.add_animation_library("", lib)
	ap.play("x")
	ap.seek(CLIPS[clip], true)
	return raiz


func _process(_d: float) -> bool:
	if _espera > 0:
		_espera -= 1
		if _espera == 0:
			var img := _vista.get_texture().get_image()
			img.save_png(_salida.path_join("%s_%s_%s.png" % [_actual["v"], _actual["clip"], _actual["vista"]]))
			(_actual["nodo"] as Node).queue_free()
		return false
	if _cola.is_empty():
		return true
	_actual = _cola.pop_front()
	var n := _modelo(_actual["v"], _actual["clip"])
	_actual["nodo"] = n
	# Centra la cámara en la cadera.
	var sk := Carga.primero(n, "Skeleton3D") as Skeleton3D
	sk.force_update_all_bone_transforms()
	var c := (sk.global_transform * sk.get_bone_global_pose(Carga.hueso(sk, "Hips"))).origin
	var centro := Vector3(c.x, 0.82, c.z)
	if _actual["vista"] == "frente":
		_cam.look_at_from_position(centro + Vector3(0, 0, 5), centro, Vector3.UP)
	else:
		_cam.look_at_from_position(centro + Vector3(5, 0, 0), centro, Vector3.UP)
	if _ver_huesos:
		_marcar_huesos(sk)
	_espera = 4
	return false


var _ver_huesos := "--huesos" in OS.get_cmdline_user_args()


## Puntos rojos (sin profundidad) en hombro, codo, muñeca y dedos para ver dónde quedan.
func _marcar_huesos(sk: Skeleton3D) -> void:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.no_depth_test = true
	mat.albedo_color = Color.RED
	for n in ["LeftArm", "LeftForeArm", "LeftHand", "RightArm", "RightForeArm", "RightHand", "LeftShoulder", "RightShoulder"]:
		var b := BoneAttachment3D.new()
		b.bone_name = sk.get_bone_name(Carga.hueso(sk, n))
		sk.add_child(b)
		var m := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.018
		sm.height = 0.036
		m.mesh = sm
		m.material_override = mat
		b.add_child(m)
		m.top_level = false
