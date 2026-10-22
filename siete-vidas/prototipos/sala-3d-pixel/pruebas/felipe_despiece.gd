# PROTOTIPO: no es código del juego.
# Despiece de Felipe v8: cada pieza de un color, de perfil y de frente con el mismo
# encuadre que las plantillas del creador (para superponer sus marcas), y abierto.
# Uso: DESPIECE=0 xvfb-run -a godot --path siete-vidas/prototipos/sala-3d-pixel \
#   --rendering-driver opengl3 --script res://pruebas/felipe_despiece.gd -- <carpeta>
extends SceneTree


func _initialize() -> void:
	var dir: String = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(dir)
	var vp := SubViewport.new()
	vp.size = Vector2i(1024, 1024)
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.85, 0.85, 0.85)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color.WHITE
	env.ambient_light_energy = 0.6
	var we := WorldEnvironment.new()
	we.environment = env
	vp.add_child(we)
	var luz := DirectionalLight3D.new()
	luz.light_energy = 0.6
	luz.rotation_degrees = Vector3(-35, 25, 0)
	vp.add_child(luz)
	var f := Node3D.new()
	f.set_script(load("res://scripts/felipe_meshy.gd"))
	f.set("usar_toon", false)
	f.set("manual", true)
	f.set("version", 8)
	vp.add_child(f)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	vp.add_child(cam)
	cam.current = true
	await process_frame
	f.set_process(false)
	var giro: Node3D = f.get("giro")
	var sk: Skeleton3D = f.get("sk")
	sk.reset_bone_poses()
	if OS.get_environment("ANIM_T") != "":
		var ap: AnimationPlayer = f.get("ap")
		ap.play("caminar")
		ap.seek(float(OS.get_environment("ANIM_T")), true)
		f.call("_capas", 0.0)
	# Encuadre: el mismo tamaño relativo que vistas.gd (1,15 × el lado mayor).
	var m: float = f.get("metros_por_unidad") * 2.7
	cam.size = 1.15 * 1.89942 * m
	var centro := Vector3(0, 1.615 * 0.5 * m, 0)
	for vista in [["perfil", 0.0], ["frente", -90.0]]:
		giro.rotation_degrees.y = vista[1]
		cam.position = centro + Vector3(0, 0, 4)
		for _k in 3:
			await process_frame
		vp.get_texture().get_image().save_png("%s/%s.png" % [dir, vista[0]])
	quit()
