# PROTOTIPO: no es código del juego.
# Hoja de un ciclo de caminar de Felipe de perfil: 8 cuadros grandes con las 4 patas
# marcadas (punto en el hombro o la cadera, el codo o la rodilla y la mano o el pie;
# delanteras en rojo y naranja, traseras en azul y celeste; claro = lado de la cámara).
# Uso: xvfb-run -a godot --path siete-vidas/prototipos/sala-3d-pixel --rendering-driver opengl3 \
#   --script res://pruebas/felipe_ciclo_perfil.gd -- <carpeta>
extends SceneTree

const COLORES := {"dd": Color(1.0, 0.55, 0.1), "di": Color(0.8, 0.05, 0.05),
	"td": Color(0.3, 0.8, 1.0), "ti": Color(0.05, 0.2, 0.85)}


func _initialize() -> void:
	var dir: String = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(dir)
	var vp := SubViewport.new()
	vp.size = Vector2i(640, 520)
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.82, 0.82, 0.82)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color.WHITE
	env.ambient_light_energy = 0.45
	var we := WorldEnvironment.new()
	we.environment = env
	vp.add_child(we)
	var luz := DirectionalLight3D.new()
	luz.light_energy = 0.9
	luz.rotation_degrees = Vector3(-35, 30, 0)
	vp.add_child(luz)
	var piso := MeshInstance3D.new()
	var pm := BoxMesh.new()
	pm.size = Vector3(4, 0.004, 1)
	piso.mesh = pm
	piso.position.y = -0.002
	vp.add_child(piso)
	var f := Node3D.new()
	f.set_script(load("res://scripts/felipe_animado.gd"))
	f.set("usar_toon", false)
	vp.add_child(f)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 0.62
	cam.position = Vector3(0, 0.28, 4)
	vp.add_child(cam)
	cam.current = true
	await process_frame
	f.set_process(false)
	var giro: Node3D = f.get("giro")
	giro.rotation.y = deg_to_rad(90.0)
	var sk: Skeleton3D = f.get("sk")
	# Marcas que siguen a los huesos (se ven a través del cuerpo).
	for pata in COLORES:
		for i in [1, 2, 3]:
			var ba := BoneAttachment3D.new()
			ba.bone_name = pata + str(i)
			sk.add_child(ba)
			var bola := MeshInstance3D.new()
			var sm := SphereMesh.new()
			sm.radius = 0.035
			sm.height = 0.07
			bola.mesh = sm
			var mat := StandardMaterial3D.new()
			mat.albedo_color = COLORES[pata]
			mat.no_depth_test = true
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			mat.render_priority = 10
			bola.material_override = mat
			ba.add_child(bola)
	var ap: AnimationPlayer = f.get("ap")
	ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	ap.play("caminar")
	for i in 8:
		ap.seek(0.8 * i / 8.0, true)
		for _k in 3:
			await process_frame
		vp.get_texture().get_image().save_png("%s/p%d.png" % [dir, i])
	quit()
