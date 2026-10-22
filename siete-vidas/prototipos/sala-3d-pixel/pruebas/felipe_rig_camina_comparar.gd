# PROTOTIPO: no es código del juego.
# Compara dos caminatas de Felipe con rig (por ejemplo, la v1 de 0,92 s y la v2 de 0,67 s):
# arriba la anterior y abajo la nueva, de perfil y en 3/4, avanzando sobre un piso con
# rayas cada 10 cm (la pata apoyada no debe correrse respecto de ellas), con el toon.
# Uso: xvfb-run -a godot --path siete-vidas/prototipos/sala-3d-pixel \
#   --script res://pruebas/felipe_rig_camina_comparar.gd -- <carpeta> <glb anterior> <vel. anterior m/s> [s=3] [fps=15]
extends SceneTree

const TAM := 280


func _vista() -> Array:
	var vp := SubViewport.new()
	vp.size = Vector2i(TAM, TAM)
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.own_world_3d = true
	root.add_child(vp)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.82, 0.82, 0.82)
	var we := WorldEnvironment.new()
	we.environment = env
	vp.add_child(we)
	var luz := DirectionalLight3D.new()
	luz.shadow_enabled = true
	luz.rotation_degrees = Vector3(-50, 25, 0)
	vp.add_child(luz)
	var mp := StandardMaterial3D.new()
	mp.albedo_color = Color(0.74, 0.74, 0.76)
	var mr := StandardMaterial3D.new()
	mr.albedo_color = Color(0.58, 0.58, 0.62)
	var piso := MeshInstance3D.new()
	var pm := BoxMesh.new()
	pm.size = Vector3(12, 0.004, 6.0)
	piso.mesh = pm
	piso.position = Vector3(0, -0.002, 0)
	piso.material_override = mp
	vp.add_child(piso)
	for i in 120:
		var r := MeshInstance3D.new()
		var rm := BoxMesh.new()
		rm.size = Vector3(0.012, 0.002, 6.0)
		r.mesh = rm
		r.position = Vector3(-6.0 + i * 0.1, 0.001, 0)
		r.material_override = mr
		vp.add_child(r)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 0.95
	vp.add_child(cam)
	cam.current = true
	return [vp, cam]


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var dir: String = a[0]
	var glb_antes: String = a[1]
	var vel_antes := float(a[2])
	var segundos := 3.0 if a.size() < 4 else float(a[3])
	var fps := 15 if a.size() < 5 else int(a[4])
	DirAccess.make_dir_recursive_absolute(dir)
	# [glb, velocidad, giro]: arriba la anterior, abajo la nueva; perfil y 3/4.
	var casos := [[glb_antes, vel_antes, 90.0], [glb_antes, vel_antes, 40.0], ["", 0.0, 90.0], ["", 0.0, 40.0]]
	var vistas := []
	var felipes: Array[Node3D] = []
	for c in casos:
		var v := _vista()
		vistas.append(v)
		var f := Node3D.new()
		f.set_script(load("res://scripts/felipe_rig.gd"))
		f.set("rutina", false)
		if c[0] != "":
			f.set("ruta", c[0])
			f.set("velocidad_m_s", c[1])
		(v[0] as SubViewport).add_child(f)
		felipes.append(f)
	await process_frame
	for i in 4:
		var f := felipes[i]
		f.set_process(false)
		f.rotation.y = deg_to_rad(casos[i][2])
		f.set("_pos_antes", f.global_position)
		f.call("reproducir", "caminar")
	for k in int(segundos * fps):
		for i in 4:
			var f := felipes[i]
			var adelante := Vector3(sin(f.rotation.y), 0, cos(f.rotation.y))
			f.position += adelante * float(f.call("velocidad")) / fps
			f.call("animar", 1.0 / fps)
			var cam: Camera3D = vistas[i][1]
			cam.rotation_degrees = Vector3(-10.0, 0.0, 0)
			cam.position = Vector3(f.position.x, 0.36, f.position.z) + cam.transform.basis.z * 4.0
		await process_frame
		await process_frame
		var img := Image.create(TAM * 2, TAM * 2, false, Image.FORMAT_RGB8)
		for i in 4:
			var im := (vistas[i][0] as SubViewport).get_texture().get_image()
			im.convert(Image.FORMAT_RGB8)
			img.blit_rect(im, Rect2i(0, 0, TAM, TAM), Vector2i(TAM * (i % 2), TAM * (i / 2)))
		img.save_png("%s/c%04d.png" % [dir, k])
	print("cuadros: ", int(segundos * fps))
	quit()
