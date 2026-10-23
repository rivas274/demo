# PROTOTIPO: no es código del juego.
# Quieto largo de Felipe con rig: se sienta, mira al jugador, juega con una pelota y se levanta.
# La pelota no está en el modelo: se mueve por código con los contactos de felipe_rig.json
# ("sentado_pelota": tiempo y posición de la punta de la pata en el modelo, a escala 1).
# Uso: xvfb-run -a godot --path siete-vidas/prototipos/sala-3d-pixel \
#   --script res://pruebas/felipe_rig_pelota.gd -- <carpeta> [fps=24] [tam=480]
extends SceneTree

const RADIO := 0.035
const DUR_RODAR := 0.55   # s que la pelota va y vuelve tras cada manotazo


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var dir: String = a[0]
	var fps := 24 if a.size() < 2 else int(a[1])
	var tam := 480 if a.size() < 3 else int(a[2])
	DirAccess.make_dir_recursive_absolute(dir)
	var vp := SubViewport.new()
	vp.size = Vector2i(tam, tam)
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.82, 0.8, 0.78)
	var we := WorldEnvironment.new()
	we.environment = env
	vp.add_child(we)
	var luz := DirectionalLight3D.new()
	luz.shadow_enabled = true
	luz.rotation_degrees = Vector3(-50, 25, 0)
	vp.add_child(luz)
	var piso := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(6, 6)
	piso.mesh = pm
	var mp := StandardMaterial3D.new()
	mp.albedo_color = Color(0.72, 0.62, 0.52)
	piso.material_override = mp
	vp.add_child(piso)
	var f := Node3D.new()
	f.set_script(load("res://scripts/felipe_rig.gd"))
	f.set("rutina", false)
	vp.add_child(f)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 1.0
	vp.add_child(cam)
	cam.current = true
	cam.rotation_degrees = Vector3(-14, 0, 0)
	cam.position = Vector3(0.14, 0.34, 0.1) + cam.transform.basis.z * 4.0
	# Pelota roja de juguete.
	var bola := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = RADIO
	sm.height = RADIO * 2
	bola.mesh = sm
	var mb := Toon.material(Color("c8463a"))
	bola.material_override = mb
	vp.add_child(bola)
	await process_frame
	f.set_process(false)
	f.rotation.y = deg_to_rad(65.0)   # casi de perfil, algo hacia la cámara: se ve el manotazo
	var info: Dictionary = f.get("info")
	var esc: float = f.get("escala")
	var contactos: Array = info["sentado_pelota"]["contactos"]
	var puntos: Array[Vector3] = []
	for c in contactos:
		var p: Array = c["pie_m"]
		var loc := Vector3(p[0], 0, p[2]) * esc
		var w := f.global_transform * loc
		w.y = RADIO
		puntos.append(w)
	var adelante := f.global_transform.basis.z.normalized()
	# La pelota espera un poco delante de la punta de la pata (la pata baja y le pega).
	for i in puntos.size():
		puntos[i] += adelante * (RADIO * 1.4)
	bola.position = puntos[0]
	var dur_pel: float = f.call("duracion", "sentado_pelota")
	# [animación, veces]
	var guion := [["quieto", 0.5], ["sentarse", 1.0], ["sentado_mira", 1.0], ["sentado_pelota", 3.0],
		["sentado_mira", 0.5], ["levantarse", 1.0], ["quieto", 0.3]]
	var n := 0
	var t_bola := -10.0
	var desde := bola.position
	var hacia := bola.position
	var ic := 0
	for paso in guion:
		var nombre: String = paso[0]
		f.call("reproducir", nombre)
		var dur: float = f.call("duracion", nombre) * paso[1]
		var cuadros := int(round(dur * fps))
		for k in cuadros:
			var t := (k + 1) / float(fps)
			f.call("animar", 1.0 / fps)
			if nombre == "sentado_pelota":
				var tl := fmod(t, dur_pel)
				for i in contactos.size():
					var tc: float = contactos[i]["t_s"]
					if tl >= tc and tl - 1.0 / fps < tc:
						# Manotazo: la pelota sale hacia adelante y al costado y vuelve sola.
						ic = i
						t_bola = 0.0
						desde = puntos[i]
						hacia = puntos[(i + 1) % puntos.size()]
			if t_bola >= 0.0:
				t_bola += 1.0 / fps
				var u := clampf(t_bola / DUR_RODAR, 0.0, 1.0)
				var lado := f.global_transform.basis.x.normalized() * (0.05 if ic == 0 else -0.04)
				var salida := (adelante * 0.11 + lado) * sin(PI * u) * (1.0 - 0.3 * u)
				var nueva := desde.lerp(hacia, u) + salida
				var paso_v := nueva - bola.position
				bola.position = nueva
				# Rueda: gira según lo que avanza.
				if paso_v.length() > 1e-5:
					var eje := Vector3.UP.cross(paso_v.normalized())
					bola.rotate(eje, paso_v.length() / RADIO)
				if u >= 1.0:
					t_bola = -10.0
			await process_frame
			await process_frame
			var im := vp.get_texture().get_image()
			im.convert(Image.FORMAT_RGB8)
			im.save_png("%s/c%04d.png" % [dir, n])
			n += 1
	print("cuadros: ", n)
	quit()
