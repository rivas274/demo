# PROTOTIPO: no es código del juego.
# Cuadros de cerca de Felipe animado sobre fondo gris claro, sin pixelar.
# Uso: xvfb-run -a godot --path siete-vidas/prototipos/sala-3d-pixel --rendering-driver opengl3 \
#   --script res://pruebas/felipe_anima_cuadros.gd -- <carpeta> [fps] [tam]
# Graba: quieto 1 s, 3 ciclos de caminar en el lugar y un salto (con su arco), y
# deja PNG numerados para armar el GIF.
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
	# Piso de referencia (línea fina) para ver que ninguna pata lo atraviesa.
	var piso := MeshInstance3D.new()
	var pm := BoxMesh.new()
	pm.size = Vector3(3, 0.004, 0.6)
	piso.mesh = pm
	piso.position = Vector3(0, -0.002, 0)
	var mp := StandardMaterial3D.new()
	mp.albedo_color = Color(0.68, 0.68, 0.7)
	piso.material_override = mp
	vp.add_child(piso)
	var f := Node3D.new()
	f.set_script(load("res://scripts/felipe_animado.gd"))
	f.set("usar_toon", false)
	vp.add_child(f)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 0.85
	cam.rotation_degrees.x = -12.0
	cam.position = Vector3(0, 0.36, 0) + cam.transform.basis.z * 4.0
	vp.add_child(cam)
	cam.current = true
	await process_frame
	var ap: AnimationPlayer = f.get("ap")
	ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	var giro: Node3D = f.get("giro")
	var guion := [["quieto", 1.0], ["caminar", 2.4], ["saltar", 1.2], ["quieto", 0.6]]
	var n := 0
	for paso in guion:
		ap.play(paso[0])
		ap.seek(0.0, true)
		var cuadros := int(paso[1] * fps)
		for i in cuadros:
			var t := float(i) / fps
			ap.seek(fmod(t, ap.current_animation_length) if paso[0] != "saltar" else t, true)
			giro.rotation.y = deg_to_rad(90.0 - 35.0)
			f.position.y = 0.0
			if paso[0] == "saltar":
				f.position.y = 0.18 * f.call("arco_salto", t).y
			for _k in 2:
				await process_frame
			vp.get_texture().get_image().save_png("%s/c%04d.png" % [dir, n])
			n += 1
	quit()
