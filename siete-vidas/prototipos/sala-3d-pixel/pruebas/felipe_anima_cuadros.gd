# PROTOTIPO: no es código del juego.
# Cuadros de cerca de Felipe animado sobre fondo gris claro, sin pixelar.
# Uso: xvfb-run -a godot --path siete-vidas/prototipos/sala-3d-pixel --rendering-driver opengl3 \
#   --script res://pruebas/felipe_anima_cuadros.gd -- <carpeta> [fps] [tam]
# Graba: quieto, 3 ciclos de caminar de perfil, 3 en 3/4 (avanzando de verdad sobre un
# piso con rayas, para ver que la pata apoyada no resbala), un salto y quieto.
extends SceneTree


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var dir: String = a[0]
	var fps := 20 if a.size() < 2 else int(a[1])
	var tam := 480 if a.size() < 3 else int(a[2])
	DirAccess.make_dir_recursive_absolute(dir)
	var vp := SubViewport.new()
	vp.size = Vector2i(tam, tam)
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.82, 0.82, 0.82)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color.WHITE
	env.ambient_light_energy = 0.4
	var we := WorldEnvironment.new()
	we.environment = env
	vp.add_child(we)
	for l in [[0.9, Vector3(-35, 15, 0)], [0.3, Vector3(-25, 160, 0)], [0.3, Vector3(-20, -70, 0)]]:
		var luz := DirectionalLight3D.new()
		luz.light_energy = l[0]
		luz.rotation_degrees = l[1]
		vp.add_child(luz)
	# Piso gris con rayas cada 10 cm: la pata apoyada no debe moverse respecto de ellas.
	var mp := StandardMaterial3D.new()
	mp.albedo_color = Color(0.74, 0.74, 0.76)
	var mr := StandardMaterial3D.new()
	mr.albedo_color = Color(0.6, 0.6, 0.63)
	var piso := MeshInstance3D.new()
	var pm := BoxMesh.new()
	pm.size = Vector3(8, 0.004, 1.0)
	piso.mesh = pm
	piso.position = Vector3(0, -0.002, 0)
	piso.material_override = mp
	vp.add_child(piso)
	for i in 80:
		var r := MeshInstance3D.new()
		var rm := BoxMesh.new()
		rm.size = Vector3(0.012, 0.002, 1.0)
		r.mesh = rm
		r.position = Vector3(-4.0 + i * 0.1, 0.001, 0)
		r.material_override = mr
		vp.add_child(r)
	var f := Node3D.new()
	f.set_script(load("res://scripts/felipe_animado.gd"))
	f.set("usar_toon", false)
	vp.add_child(f)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 0.8
	cam.rotation_degrees.x = -12.0
	var cam_base := Vector3(0, 0.32, 0) + cam.transform.basis.z * 4.0
	vp.add_child(cam)
	cam.current = true
	await process_frame
	f.set_process(false)  # el giro lo pone este guion
	var ap: AnimationPlayer = f.get("ap")
	ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	var giro: Node3D = f.get("giro")
	var v: float = f.call("velocidad_caminar")
	var ciclo := 0.8
	# [animación, segundos, giro del modelo en grados]
	var guion := [["quieto", 0.8, 55.0], ["caminar", ciclo * 3, 90.0], ["caminar", ciclo * 3, 55.0],
		["saltar", 1.2, 55.0], ["quieto", 0.8, 55.0]]
	var n := 0
	for paso in guion:
		ap.play(paso[0])
		giro.rotation.y = deg_to_rad(paso[2])
		var adelante := Vector3(sin(giro.rotation.y), 0, cos(giro.rotation.y))
		var inicio := Vector3(-0.25, 0, 0) if paso[0] == "caminar" else Vector3.ZERO
		if paso[0] == "caminar" and paso[2] != 90.0:
			inicio = -adelante * 0.25
		var cuadros := int(paso[1] * fps)
		for i in cuadros:
			var t := float(i) / fps
			ap.seek(t if paso[0] == "saltar" else fmod(t, ap.current_animation_length), true)
			var pos := inicio
			if paso[0] == "caminar":
				pos = inicio + adelante * v * t
			elif paso[0] == "saltar":
				pos.y = 0.18 * f.call("arco_salto", t).y
			f.position = pos
			cam.position = cam_base + Vector3(pos.x, 0, pos.z) * 0.5
			for _k in 2:
				await process_frame
			vp.get_texture().get_image().save_png("%s/c%04d.png" % [dir, n])
			n += 1
	quit()
