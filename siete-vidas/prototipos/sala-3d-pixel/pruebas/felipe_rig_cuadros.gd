# PROTOTIPO: no es código del juego.
# Cuadros de cerca de Felipe con rig de Blender (felipe_rig.glb), de perfil y en 3/4 lado a
# lado, con el toon de la sala y la capa del resorte de la cola. Tramos: caminar (avanzando
# sobre un piso con rayas cada 10 cm), la cola de cerca caminando y quieta, saltar (con el
# arco del código), arañar (entrada, bucle y salida) y pedir (entrada y bucle).
# Uso: xvfb-run -a godot --path siete-vidas/prototipos/sala-3d-pixel \
#   --script res://pruebas/felipe_rig_cuadros.gd -- <carpeta> [fps=15] [tam=300]
# Escribe c0000.png... y tramos.txt (cuadro inicial y nombre de cada tramo).
extends SceneTree


func _vista(tam: int) -> Array:
	var vp := SubViewport.new()
	vp.size = Vector2i(tam, tam)
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
	# Pared para arañar: un respaldo vertical que se muestra solo en ese tramo.
	var pared := MeshInstance3D.new()
	var pw := BoxMesh.new()
	pw.size = Vector3(0.5, 0.6, 0.05)
	pared.mesh = pw
	var mw := StandardMaterial3D.new()
	mw.albedo_color = Color(0.75, 0.45, 0.32)
	pared.material_override = mw
	pared.visible = false
	vp.add_child(pared)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	vp.add_child(cam)
	cam.current = true
	return [vp, cam, pared]


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var dir: String = a[0]
	var fps := 15 if a.size() < 2 else int(a[1])
	var tam := 300 if a.size() < 3 else int(a[2])
	DirAccess.make_dir_recursive_absolute(dir)
	var vistas := [_vista(tam), _vista(tam)]
	var felipes: Array[Node3D] = []
	for i in 2:
		var f := Node3D.new()
		f.set_script(load("res://scripts/felipe_rig.gd"))
		f.set("rutina", false)
		(vistas[i][0] as SubViewport).add_child(f)
		felipes.append(f)
	await process_frame
	for f in felipes:
		f.set_process(false)
	var ciclo: float = felipes[0].call("duracion", "caminar")
	# [título, [[animación, veces], ...], giro perfil, giro 3/4, encuadre]
	# encuadre: "cuerpo", "cola" o "alto" (arañar: más alto).
	var tramos := [
		["caminar", [["caminar", 2.0]], 90.0, 40.0, "cuerpo"],
		["cola de cerca: caminar", [["caminar", 2.0]], 90.0, 140.0, "cola"],
		["cola de cerca: quieto", [["quieto", 0.75]], 90.0, 140.0, "cola"],
		["saltar", [["quieto", 0.1], ["saltar", 1.0], ["quieto", 0.1]], 90.0, 40.0, "cuerpo"],
		["arañar", [["aranar_entrada", 1.0], ["aranar", 2.0], ["aranar_salida", 1.0]], 90.0, 130.0, "alto"],
		["pedir", [["pedir_entrada", 1.0], ["pedir", 1.5]], 90.0, 40.0, "cuerpo"],
	]
	var log := FileAccess.open(dir + "/tramos.txt", FileAccess.WRITE)
	var n := 0
	for tr in tramos:
		log.store_line("%d\t%s" % [n, tr[0]])
		for i in 2:
			var f := felipes[i]
			f.position = Vector3.ZERO
			f.rotation.y = deg_to_rad(tr[2 + i])
			f.set("_pos_antes", f.global_position)
			f.set("_vel_antes", Vector3.ZERO)
			var pared: MeshInstance3D = vistas[i][2]
			pared.visible = tr[0] == "arañar"
			var adelante := Vector3(sin(f.rotation.y), 0, cos(f.rotation.y))
			pared.position = adelante * 0.30 + Vector3(0, 0.3, 0)
			pared.rotation.y = f.rotation.y
		for paso in tr[1]:
			var nombre: String = paso[0]
			var dur: float = felipes[0].call("duracion", nombre) * paso[1]
			for f in felipes:
				f.call("reproducir", nombre)
			var desde: Array[Vector3] = [felipes[0].position, felipes[1].position]
			var cuadros := int(round(dur * fps))
			for k in cuadros:
				var t := (k + 1) / float(fps)
				for i in 2:
					var f := felipes[i]
					var adelante := Vector3(sin(f.rotation.y), 0, cos(f.rotation.y))
					if nombre == "caminar":
						f.position += adelante * float(f.call("velocidad")) / fps
					elif nombre == "saltar":
						f.position = f.call("arco_salto", desde[i], desde[i] + adelante * 0.35, t)
					f.call("animar", 1.0 / fps)
					var cam: Camera3D = vistas[i][1]
					cam.rotation_degrees = Vector3(-10.0, 0.0, 0)
					var centro := Vector3(f.position.x, 0.36, f.position.z)
					cam.size = 1.0
					if tr[4] == "cola":
						centro = f.position - adelante * 0.16 + Vector3(0, 0.47, 0)
						cam.size = 0.62
					elif tr[4] == "alto":
						centro = Vector3(f.position.x, 0.42, f.position.z)
						cam.size = 1.05
					cam.position = centro + cam.transform.basis.z * 4.0
				await process_frame
				await process_frame
				var img := Image.create(tam * 2, tam, false, Image.FORMAT_RGB8)
				for i in 2:
					var im := (vistas[i][0] as SubViewport).get_texture().get_image()
					im.convert(Image.FORMAT_RGB8)
					img.blit_rect(im, Rect2i(0, 0, tam, tam), Vector2i(tam * i, 0))
				img.save_png("%s/c%04d.png" % [dir, n])
				n += 1
	log.store_line("%d\tfin" % n)
	print("cuadros: ", n)
	quit()
