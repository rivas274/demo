extends SceneTree
# uso: -- <glb> <salida_prefijo> <yaw0> <n_cuadros> <paso_grados> [tam]
func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var glb: String = a[0]
	var pref: String = a[1]
	var yaw0 := float(a[2])
	var n := int(a[3])
	var paso := float(a[4])
	var tam := 512 if a.size() < 6 else int(a[5])
	var vp := SubViewport.new()
	vp.size = Vector2i(tam, tam)
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
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = OS.get_environment("BLANCO") == ""
	mat.roughness = 0.85
	for m in modelo.find_children("*", "MeshInstance3D", true, false):
		(m as MeshInstance3D).material_override = mat
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.82, 0.82, 0.82)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1, 1, 1)
	env.ambient_light_energy = 0.4
	var we := WorldEnvironment.new(); we.environment = env; vp.add_child(we)
	var luz := DirectionalLight3D.new()
	luz.light_energy = 0.9
	luz.rotation_degrees = Vector3(-35, 15, 0)
	vp.add_child(luz)
	var luz2 := DirectionalLight3D.new()
	luz2.light_energy = 0.3
	luz2.rotation_degrees = Vector3(-25, 160, 0)
	vp.add_child(luz2)
	var luz3 := DirectionalLight3D.new()
	luz3.light_energy = 0.3
	luz3.rotation_degrees = Vector3(-20, -70, 0)
	vp.add_child(luz3)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 2.3 if a.size() < 7 else float(a[6])
	var cy := 0.05 if a.size() < 8 else float(a[7])
	var pitch := -12.0 if a.size() < 9 else float(a[8])
	cam.rotation_degrees = Vector3(pitch, 0, 0)
	cam.position = Vector3(0, cy, 0) + cam.transform.basis.z * 6.0
	vp.add_child(cam)
	cam.current = true
	for i in n:
		piv.rotation_degrees.y = yaw0 + paso * i
		await process_frame
		await process_frame
		await process_frame
		var img := vp.get_texture().get_image()
		img.save_png("%s_%02d.png" % [pref, i])
	quit()
