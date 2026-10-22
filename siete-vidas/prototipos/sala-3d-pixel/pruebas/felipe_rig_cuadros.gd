# PROTOTIPO: no es código del juego.
# Cuadros de cerca de Felipe con rig de Blender (felipe_rig.glb), de perfil y en 3/4 lado a
# lado: 2 ciclos de caminar avanzando sobre un piso con rayas cada 10 cm (la pata apoyada
# no debe correrse respecto de ellas) y luego "quieto" (3 s).
# Uso: xvfb-run -a godot --path siete-vidas/prototipos/sala-3d-pixel \
#   --script res://pruebas/felipe_rig_cuadros.gd -- <carpeta> [fps=24] [tam=360] [toon=1]
extends SceneTree


func _vista(tam: int, giro_cam: float) -> Array:
	var vp := SubViewport.new()
	vp.size = Vector2i(tam, tam)
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.own_world_3d = true
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
	var luz := DirectionalLight3D.new()
	luz.light_energy = 1.0
	luz.shadow_enabled = true
	luz.rotation_degrees = Vector3(-50, 25, 0)
	vp.add_child(luz)
	var mp := StandardMaterial3D.new()
	mp.albedo_color = Color(0.74, 0.74, 0.76)
	var mr := StandardMaterial3D.new()
	mr.albedo_color = Color(0.58, 0.58, 0.62)
	var piso := MeshInstance3D.new()
	var pm := BoxMesh.new()
	pm.size = Vector3(10, 0.004, 3.0)
	piso.mesh = pm
	piso.position = Vector3(0, -0.002, 0)
	piso.material_override = mp
	vp.add_child(piso)
	for i in 100:
		var r := MeshInstance3D.new()
		var rm := BoxMesh.new()
		rm.size = Vector3(0.012, 0.002, 3.0)
		r.mesh = rm
		r.position = Vector3(-5.0 + i * 0.1, 0.001, 0)
		r.material_override = mr
		vp.add_child(r)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 1.0
	cam.rotation_degrees = Vector3(-10.0, giro_cam, 0)
	vp.add_child(cam)
	cam.current = true
	return [vp, cam]


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var dir: String = a[0]
	var fps := 24 if a.size() < 2 else int(a[1])
	var tam := 360 if a.size() < 3 else int(a[2])
	var toon := a.size() < 4 or a[3] == "1"
	DirAccess.make_dir_recursive_absolute(dir)
	var vistas := [_vista(tam, 0.0), _vista(tam, 0.0)]
	var felipes: Array[Node3D] = []
	for i in 2:
		var f := Node3D.new()
		f.set_script(load("res://scripts/felipe_rig.gd"))
		f.set("usar_toon", toon)
		(vistas[i][0] as SubViewport).add_child(f)
		felipes.append(f)
	await process_frame
	var v: float = felipes[0].call("velocidad_caminar") / cos(deg_to_rad(20.0))  # avance real
	print("velocidad (escala 1,3): %.3f m/s" % v)
	var ciclo := 22.0 / 24.0
	# [animación, segundos, giro de Felipe (grados): perfil 90, 3/4 hacia la cámara 40]
	var guion := [["caminar", ciclo * 2, 90.0, 40.0], ["quieto", 3.0, 90.0, 40.0]]
	var n := 0
	for i in 2:
		felipes[i].set_process(false)  # el guion lo pone este script
		var ap: AnimationPlayer = felipes[i].get("ap")
		ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	for paso in guion:
		var cuadros := int(round(paso[1] * fps))
		for i in 2:
			var ap: AnimationPlayer = felipes[i].get("ap")
			ap.play(paso[0])
			ap.seek(0.0, true)
			felipes[i].rotation.y = deg_to_rad(paso[2 + i])
		for k in cuadros:
			for i in 2:
				var f := felipes[i]
				var ap: AnimationPlayer = f.get("ap")
				if k > 0:
					ap.advance(1.0 / fps)
				if paso[0] == "caminar":
					var adelante := Vector3(sin(f.rotation.y), 0, cos(f.rotation.y))
					f.position += adelante * v * (1.0 / fps if k > 0 else 0.0)
				var cam: Camera3D = vistas[i][1]
				var base := Vector3(f.position.x, 0.36, f.position.z)
				cam.rotation_degrees = Vector3(-10.0, 0.0, 0)
				cam.position = base + cam.transform.basis.z * 4.0
			await process_frame
			await process_frame
			var img := Image.create(tam * 2, tam, false, Image.FORMAT_RGB8)
			for i in 2:
				var im := (vistas[i][0] as SubViewport).get_texture().get_image()
				im.convert(Image.FORMAT_RGB8)
				img.blit_rect(im, Rect2i(0, 0, tam, tam), Vector2i(tam * i, 0))
			img.save_png("%s/c%04d.png" % [dir, n])
			n += 1
	print("cuadros: ", n)
	quit()
