# PROTOTIPO: no es código del juego.
# Pregunta: ¿se ve mejor la sala en 3D renderizado como pixel art?
# Fecha: 2026-10-22
# La misma sala de principal.gd (cámara, pixel x3, bordes, teclas) pero solo con la Valeria
# de Meshy + Mixamo (scripts/valeria_mixamo.gd), sin los Felipes de comparación.
# Se abre con la escena valeria_mixamo.tscn o con `-- --valeria-mixamo`.
extends "res://scripts/principal.gd"


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--pixel="):
			tam_pixel = int(arg.get_slice("=", 1))
	vista = SubViewport.new()
	vista.msaa_3d = Viewport.MSAA_DISABLED
	vista.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
	vista.use_taa = false
	vista.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vista.positional_shadow_atlas_size = 2048
	add_child(vista)

	var mundo := WorldEnvironment.new()
	var amb := Environment.new()
	amb.background_mode = Environment.BG_COLOR
	amb.background_color = Color("210c0a")
	amb.ambient_light_source = Environment.AMBIENT_SOURCE_DISABLED
	amb.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	mundo.environment = amb
	vista.add_child(mundo)

	var sala := Node3D.new()
	sala.name = "Sala"
	sala.set_script(load("res://scripts/sala.gd"))
	vista.add_child(sala)

	valeria = Node3D.new()
	valeria.name = "ValeriaMixamo"
	valeria.set_script(load("res://scripts/valeria_mixamo.gd"))
	valeria.set("x_sofa", sala.get("punto_sofa").x)
	vista.add_child(valeria)
	_armar_camara()
