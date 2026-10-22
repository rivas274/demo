# PROTOTIPO: no es código del juego.
# Diagnóstico de la sombra de la pata trasera de Felipe con rig: la misma pose de la
# caminata, de cerca y con el toon de la sala, en 4 variantes (con o sin sombras
# proyectadas, con o sin textura) para separar la causa.
# Uso: xvfb-run -a godot --path siete-vidas/prototipos/sala-3d-pixel \
#   --script res://pruebas/felipe_rig_sombra.gd -- <salida.png> [tiempos en s, separados por coma] [glb]
extends SceneTree


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var salida: String = a[0]
	var tiempos := [0.0, 0.25, 0.4, 0.7] if a.size() < 2 else Array(a[1].split(",")).map(func(x): return float(x))
	var glb: String = a[2] if a.size() > 2 else ""
	var tam := 300
	var variantes := [["toon + sombras", true, true], ["toon sin sombras", false, true],
		["sin textura + sombras", true, false], ["sin textura ni sombras", false, false]]
	var img := Image.create(tam * variantes.size(), tam * tiempos.size(), false, Image.FORMAT_RGB8)
	for vi in variantes.size():
		var v: Array = variantes[vi]
		var vp := SubViewport.new()
		vp.size = Vector2i(tam, tam)
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		vp.own_world_3d = true
		root.add_child(vp)
		var env := Environment.new()
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0.82, 0.82, 0.82)
		var we := WorldEnvironment.new()
		we.environment = env
		vp.add_child(we)
		# La luz del sol de la sala (sala.gd): de frente-arriba, algo de lado.
		var luz := DirectionalLight3D.new()
		luz.light_energy = 1.0
		luz.shadow_enabled = v[1]
		luz.rotation_degrees = Vector3(-50, 25, 0)
		vp.add_child(luz)
		var f := Node3D.new()
		f.set_script(load("res://scripts/felipe_rig.gd"))
		f.set("rutina", false)
		f.set("resorte_cola", false)
		if glb != "":
			f.set("ruta", glb)
		vp.add_child(f)
		var cam := Camera3D.new()
		cam.projection = Camera3D.PROJECTION_ORTHOGONAL
		cam.size = 0.3
		vp.add_child(cam)
		cam.current = true
		await process_frame
		f.set_process(false)
		f.rotation.y = deg_to_rad(90.0)
		f.position = Vector3.ZERO
		if not v[2]:
			for mi in f.find_children("*", "MeshInstance3D", true, false):
				var m: ShaderMaterial = (mi as MeshInstance3D).material_override
				m.set_shader_parameter("usar_textura", false)
		cam.position = Vector3(-0.07, 0.12, 3.0)
		var ap: AnimationPlayer = f.get("ap")
		ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
		ap.play("caminar")
		for ti in tiempos.size():
			ap.seek(tiempos[ti], true)
			f.call("animar", 0.0001)
			for k in 3:
				await process_frame
			var im := vp.get_texture().get_image()
			im.convert(Image.FORMAT_RGB8)
			img.blit_rect(im, Rect2i(0, 0, tam, tam), Vector2i(tam * vi, tam * ti))
		print(v[0])
	img.save_png(salida)
	quit()
