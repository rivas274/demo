# PROTOTIPO: no es código del juego.
# Cuadros de cerca de Felipe (gato del pack de Quaternius adaptado) sin pixelar.
# Con FELIPE=felipe_meshy usa el Felipe de Meshy.
# Uso: xvfb-run -a godot --path siete-vidas/prototipos/sala-3d-pixel --rendering-driver opengl3 \
#   --script res://pruebas/felipe_pack_cuadros.gd -- <carpeta> [fps] [tam] [solo_pose]
# Guion: quieto en 3/4, caminar de perfil, caminar en 3/4, trote (caminar ×1,6), frena,
# salto y quieto. Felipe avanza de verdad sobre un piso con rayas cada 10 cm.
extends SceneTree


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var dir: String = a[0]
	var fps := 20 if a.size() < 2 else int(a[1])
	var tam := 520 if a.size() < 3 else int(a[2])
	DirAccess.make_dir_recursive_absolute(dir)
	var vp := SubViewport.new()
	vp.size = Vector2i(tam, tam)
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.82, 0.82, 0.82)
	var we := WorldEnvironment.new()
	we.environment = env
	vp.add_child(we)
	for l in [[0.85, Vector3(-35, 15, 0)], [0.3, Vector3(-25, 160, 0)], [0.25, Vector3(-20, -70, 0)]]:
		var luz := DirectionalLight3D.new()
		luz.light_energy = l[0]
		luz.rotation_degrees = l[1]
		vp.add_child(luz)
	var mp := StandardMaterial3D.new()
	mp.albedo_color = Color(0.74, 0.74, 0.76)
	var mr := StandardMaterial3D.new()
	mr.albedo_color = Color(0.6, 0.6, 0.63)
	var piso := MeshInstance3D.new()
	var pm := BoxMesh.new()
	pm.size = Vector3(12, 0.004, 1.0)
	piso.mesh = pm
	piso.position = Vector3(2, -0.002, 0)
	piso.material_override = mp
	vp.add_child(piso)
	for i in 120:
		var r := MeshInstance3D.new()
		var rm := BoxMesh.new()
		rm.size = Vector3(0.012, 0.002, 1.0)
		r.mesh = rm
		r.position = Vector3(-4.0 + i * 0.1, 0.001, 0)
		r.material_override = mr
		vp.add_child(r)
	var f := Node3D.new()
	var guion_felipe := OS.get_environment("FELIPE") if OS.get_environment("FELIPE") != "" else "felipe_pack"
	f.set_script(load("res://scripts/%s.gd" % guion_felipe))
	f.set("usar_toon", false)
	f.set("manual", true)
	if "giro_caminar" in f:
		f.set("giro_caminar", 0.0)  # de perfil puro en esta prueba
	vp.add_child(f)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 1.0 if OS.get_environment("FELIPE") != "felipe_meshy" else 0.75
	cam.rotation_degrees.x = -10.0
	vp.add_child(cam)
	cam.current = true
	await process_frame
	var v: float = f.call("velocidad_caminar")
	print("velocidad del paso: %.3f m/s" % v)
	var dt := 1.0 / fps
	if a.size() > 3:  # solo pose: 4 vistas de quieto (perfil, 3/4, frente, espalda)
		f.set("giro_3_4", 0.0)
		f.call("avanzar", 0.5)
		var giro: Node3D = f.get("giro")
		var k := 0
		for yaw in [0.0, -35.0, -90.0, 180.0]:
			f.set_process(false)
			f.set("manual", true)
			giro.rotation.y = deg_to_rad(yaw)
			cam.position = Vector3(0, 0.3, 0) + cam.transform.basis.z * 4.0
			await process_frame
			await process_frame
			vp.get_texture().get_image().save_png("%s/v%d.png" % [dir, k])
			k += 1
		quit()
		return
	# [animación, segundos, ritmo, perfil al caminar]
	var guion := [["quieto", 1.6, 1.0, true], ["caminar", 3.2, 1.0, true], ["caminar", 2.4, 1.0, false],
		["caminar", 2.0, 1.6, true], ["quieto", 1.2, 1.0, true], ["saltar", 1.3, 1.0, true], ["quieto", 1.2, 1.0, true]]
	var n := 0
	var x := -0.5
	var cam_x := x
	for paso in guion:
		f.set("perfil_al_caminar", paso[3])
		f.call("reproducir", paso[0], paso[2])
		if paso[0] == "saltar":
			var ap: AnimationPlayer = f.get("ap")
			ap.play("saltar", 0.15)
		var cuadros := int(paso[1] * fps)
		for i in cuadros:
			var t := float(i) / fps
			var y := 0.0
			if paso[0] == "caminar":
				var adelante := 1.0 if paso[3] else cos(deg_to_rad(35.0))
				x += v * paso[2] * dt * adelante
			elif paso[0] == "saltar":
				var arco: Vector2 = f.call("arco_salto", t)
				y = 0.16 * arco.y
				x += 0.25 * dt if t > 0.4 and t < 0.88 else 0.0
			var z := 0.0 if paso[3] or paso[0] != "caminar" else 0.0
			f.position = Vector3(x, y, z)
			f.call("avanzar", dt)
			cam_x = lerpf(cam_x, x, 0.4)
			cam.position = Vector3(cam_x, 0.3, 0) + cam.transform.basis.z * 4.0
			await process_frame
			await process_frame
			vp.get_texture().get_image().save_png("%s/c%04d.png" % [dir, n])
			n += 1
	quit()
