extends SceneTree
# Render ortografico de perfil, frente y arriba, sin perspectiva, para dibujar encima.
func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var glb: String = a[0]
	var pref: String = a[1]
	var vp := SubViewport.new()
	vp.size = Vector2i(1024, 1024)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.msaa_3d = Viewport.MSAA_4X
	vp.own_world_3d = true
	root.add_child(vp)
	var doc := GLTFDocument.new()
	var st := GLTFState.new()
	if doc.append_from_file(glb, st) != OK:
		push_error("no carga"); quit(1); return
	var modelo: Node3D = doc.generate_scene(st)
	var piv := Node3D.new()
	vp.add_child(piv)
	piv.add_child(modelo)
	await process_frame
	var aabb := AABB()
	var primero := true
	for m in modelo.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		var b := mi.global_transform * mi.get_aabb()
		aabb = b if primero else aabb.merge(b)
		primero = false
	modelo.position = -aabb.get_center()
	var lado: float = max(aabb.size.x, max(aabb.size.y, aabb.size.z)) * 1.15
	print("AABB ", aabb)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.85, 0.85, 0.85)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1, 1, 1)
	env.ambient_light_energy = 0.7
	var we := WorldEnvironment.new(); we.environment = env; vp.add_child(we)
	var luz := DirectionalLight3D.new()
	luz.light_energy = 0.7
	luz.rotation_degrees = Vector3(-35, 25, 0)
	vp.add_child(luz)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = lado
	vp.add_child(cam)
	cam.current = true
	var vistas := {"perfil": [Vector3(0, 0, 0), 90.0], "frente": [Vector3(0, 0, 0), 0.0], "arriba": [Vector3(-90, 0, 0), 0.0]}
	for nombre in vistas:
		var rot: Vector3 = vistas[nombre][0]
		piv.rotation_degrees = Vector3(0, vistas[nombre][1], 0)
		cam.rotation_degrees = rot
		cam.position = cam.transform.basis.z * 10.0
		for i in 4:
			await process_frame
		vp.get_texture().get_image().save_png("%s_%s.png" % [pref, nombre])
	quit()
