# PROTOTIPO: no es código del juego.
# Pregunta: ¿se siente bien controlar a Felipe 3D (con rig) en una sala jugable: caminar, saltar
# a los muebles, arañar, tirar cosas y pedirle a Valeria?
# Fecha: 2026-10-23
# Escena jugable.tscn: la misma sala de principal.gd (pixel x3, bordes, luz toon) con
# colisiones, una mesa alta (75 cm), vaso, taza y pelota con física, Felipe controlable y
# Valeria con rutina y reacciones. Interfaz mínima: controles (H los oculta), globos de texto y
# el indicador de E sobre lo que Felipe tiene más cerca.
# Argumentos (después de --): --bot (juega solo; ver bot_jugable.gd), --sin-valeria, --pixel=N.
extends "res://scripts/principal.gd"

const COLOR_MESA := Color("905535")
const COLOR_VASO := Color("d9e4dc")
const COLOR_TAZA := Color("3f6f68")
const COLOR_PELOTA := Color("c27046")
const COLOR_GOLOSINA := Color("7c4127")
## Mesa alta (de comedor): 75 cm, a la derecha del sofá. Desde el piso no se alcanza (salto de
## ~66 cm); desde el cojín del sofá sí.
const MESA_X := Vector2(1.42, 1.98)
const MESA_Z := Vector2(-1.1, -0.62)
const MESA_ALTO := 0.75
const TECLAS := "A/D o ←/→  caminar\nW/S o ↑/↓  fondo / frente\nEspacio  saltar (soltar = salto corto)\nE  acción (arañar, tirar, pedir)\nQ  pedir / maullar\nQuieto 9 s: se sienta y juega\nH  ocultar esta ayuda"

@export var con_valeria := true
@export var limites := Vector2(-1.0, 1.7)

var gato: CharacterBody3D
var sala: Node3D
var pelota: RigidBody3D
var vaso: RigidBody3D
var taza: RigidBody3D
var sofa_aranable: Node3D
var _golosinas: Array[Node3D] = []
var _globos: Array[Dictionary] = []
var _capa_ui: Control
var _indicador: Label
var _controles: Label


func _ready() -> void:
	add_to_group("jugable")
	_acciones_entrada()
	var args := OS.get_cmdline_user_args()
	if "--sin-valeria" in args:
		con_valeria = false
	for arg in args:
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

	sala = Node3D.new()
	sala.name = "Sala"
	sala.set_script(load("res://scripts/sala.gd"))
	vista.add_child(sala)
	_colisiones()
	_mesa_alta()
	_objetos()

	gato = CharacterBody3D.new()
	gato.name = "Felipe"
	gato.set_script(load("res://scripts/jugable/felipe_jugable.gd"))
	gato.set("juego", self)
	gato.position = Vector3(-1.6, 0.0, -0.15)
	vista.add_child(gato)

	if con_valeria:
		valeria = Node3D.new()
		valeria.name = "Valeria"
		valeria.set_script(load("res://scripts/jugable/valeria_jugable.gd"))
		valeria.set("x_sofa", sala.get("punto_sofa").x)
		valeria.set("felipe", gato)
		valeria.set("juego", self)
		vista.add_child(valeria)
		vaso.caido.connect(valeria.al_caer)
		taza.caido.connect(valeria.al_caer)
	_armar_camara()
	_cam_x = clampf(gato.position.x, limites.x, limites.y)
	_interfaz()
	if "--bot" in args:
		var bot := Node.new()
		bot.name = "Bot"
		bot.set_script(load("res://scripts/jugable/bot_jugable.gd"))
		bot.set("juego", self)
		add_child(bot)


## Teclas como el juego 2D, más W/S para la profundidad; también mando.
func _acciones_entrada() -> void:
	var mapa := {
		"mover_izq": [KEY_A, KEY_LEFT, JOY_BUTTON_DPAD_LEFT, [JOY_AXIS_LEFT_X, -1.0]],
		"mover_der": [KEY_D, KEY_RIGHT, JOY_BUTTON_DPAD_RIGHT, [JOY_AXIS_LEFT_X, 1.0]],
		"mover_arriba": [KEY_W, KEY_UP, JOY_BUTTON_DPAD_UP, [JOY_AXIS_LEFT_Y, -1.0]],
		"mover_abajo": [KEY_S, KEY_DOWN, JOY_BUTTON_DPAD_DOWN, [JOY_AXIS_LEFT_Y, 1.0]],
		"saltar": [KEY_SPACE, JOY_BUTTON_A],
		"accion": [KEY_E, JOY_BUTTON_Y],
		"pedir": [KEY_Q, JOY_BUTTON_B],
		"ayuda": [KEY_H, JOY_BUTTON_BACK],
	}
	for accion: String in mapa:
		if InputMap.has_action(accion):
			continue
		InputMap.add_action(accion, 0.3)
		for i in mapa[accion].size():
			var tecla = mapa[accion][i]
			var ev: InputEvent
			if tecla is Array:
				var eje := InputEventJoypadMotion.new()
				eje.axis = tecla[0]
				eje.axis_value = tecla[1]
				ev = eje
			elif int(tecla) > 25:
				var k := InputEventKey.new()
				k.physical_keycode = tecla
				ev = k
			else:
				var b := InputEventJoypadButton.new()
				b.button_index = tecla
				ev = b
			InputMap.action_add_event(accion, ev)


# --- Colisiones ------------------------------------------------------------------

func _estatico(forma: Shape3D, pos: Vector3, padre: Node3D = null) -> StaticBody3D:
	var cuerpo := StaticBody3D.new()
	cuerpo.collision_layer = 1
	cuerpo.collision_mask = 0
	var cs := CollisionShape3D.new()
	cs.shape = forma
	cuerpo.add_child(cs)
	(padre if padre else vista).add_child(cuerpo)
	cuerpo.position = pos
	return cuerpo


func _caja_forma(tam: Vector3) -> BoxShape3D:
	var b := BoxShape3D.new()
	b.size = tam
	return b


func _colisiones() -> void:
	# Piso, pared del fondo, paredes de los lados y una pared invisible al frente.
	_estatico(_caja_forma(Vector3(12, 0.2, 2.6)), Vector3(0, -0.1, 0.1))
	_estatico(_caja_forma(Vector3(12, 3.5, 0.2)), Vector3(0, 1.75, -1.3))
	_estatico(_caja_forma(Vector3(0.2, 3.5, 2.6)), Vector3(-3.45, 1.75, 0.1))
	_estatico(_caja_forma(Vector3(0.2, 3.5, 2.6)), Vector3(4.4, 1.75, 0.1))
	_estatico(_caja_forma(Vector3(12, 3.5, 0.2)), Vector3(0, 1.75, 0.68))
	# Muebles de Kenney: el sofá con su malla exacta (cojín, brazos y respaldo); el resto,
	# cascos convexos (sólidos, sin meterse en los estantes).
	for hijo in sala.get_children():
		if hijo is MeshInstance3D or not (hijo is Node3D) or hijo is Light3D:
			continue
		var nombre := String(hijo.name)
		if nombre.begins_with("rug") or nombre.begins_with("plantSmall") or nombre == "books":
			continue
		var exacta := nombre.begins_with("loungeSofa")
		for mi: MeshInstance3D in hijo.find_children("*", "MeshInstance3D", true, false):
			if mi.global_position.y > 0.6 and not nombre.begins_with("Lampara"):
				continue  # plantas de la ventana
			var cuerpo := StaticBody3D.new()
			cuerpo.collision_layer = 1
			cuerpo.collision_mask = 0
			var cs := CollisionShape3D.new()
			cs.shape = mi.mesh.create_trimesh_shape() if exacta else mi.mesh.create_convex_shape(true, true)
			cuerpo.add_child(cs)
			mi.add_child(cuerpo)
	sofa_aranable = Node3D.new()
	sofa_aranable.name = "SofaAranable"
	sofa_aranable.set_script(load("res://scripts/jugable/aranable.gd"))
	vista.add_child(sofa_aranable)


func _mesa_alta() -> void:
	var cx := (MESA_X.x + MESA_X.y) * 0.5
	var cz := (MESA_Z.x + MESA_Z.y) * 0.5
	var ancho := MESA_X.y - MESA_X.x
	var fondo := MESA_Z.y - MESA_Z.x
	var grosor := 0.04
	var tapa := Vector3(ancho, grosor, fondo)
	var pos_tapa := Vector3(cx, MESA_ALTO - grosor * 0.5, cz)
	Toon.caja(sala, tapa, pos_tapa, COLOR_MESA)
	_estatico(_caja_forma(tapa), pos_tapa)
	var pata := Vector3(0.05, MESA_ALTO - grosor, 0.05)
	for sx in [-1, 1]:
		for sz in [-1, 1]:
			var p := Vector3(cx + sx * (ancho * 0.5 - 0.04), (MESA_ALTO - grosor) * 0.5, cz + sz * (fondo * 0.5 - 0.04))
			Toon.caja(sala, pata, p, Color("572c1d"))
			_estatico(_caja_forma(pata), p)


func _objetos() -> void:
	var Tirable := load("res://scripts/jugable/tirable.gd")
	vaso = RigidBody3D.new()
	vaso.name = "Vaso"
	vaso.set_script(Tirable)
	vaso.set("color", COLOR_VASO)
	vaso.position = Vector3(-0.66, 0.55 + 0.12, -0.77)
	vista.add_child(vaso)
	taza = RigidBody3D.new()
	taza.name = "Taza"
	taza.set_script(Tirable)
	taza.set("rompible", false)
	taza.set("alto", 0.17)
	taza.set("radio", 0.085)
	taza.set("color", COLOR_TAZA)
	taza.position = Vector3(1.86, MESA_ALTO + 0.085, -0.8)
	vista.add_child(taza)
	pelota = RigidBody3D.new()
	pelota.name = "Pelota"
	pelota.mass = 0.15
	pelota.collision_layer = 8
	pelota.collision_mask = 1 | 2 | 8
	pelota.linear_damp = 0.8
	pelota.angular_damp = 1.5
	var pm := PhysicsMaterial.new()
	pm.bounce = 0.35
	pm.friction = 0.8
	pelota.physics_material_override = pm
	var cs := CollisionShape3D.new()
	var esfera := SphereShape3D.new()
	esfera.radius = 0.11
	cs.shape = esfera
	pelota.add_child(cs)
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.11
	sm.height = 0.22
	sm.radial_segments = 12
	sm.rings = 6
	mi.mesh = sm
	mi.material_override = Toon.material(COLOR_PELOTA)
	pelota.add_child(mi)
	# Franja para que se vea rodar.
	var franja := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.1
	tm.outer_radius = 0.115
	tm.rings = 12
	tm.ring_segments = 4
	franja.mesh = tm
	franja.material_override = Toon.material(Color("ffe2b0"))
	pelota.add_child(franja)
	pelota.position = Vector3(-2.7, 0.11, 0.25)
	vista.add_child(pelota)


## Valeria le da un snack: aparece en el piso y Felipe se lo come al pasar encima.
func dar_golosina(p: Vector3) -> void:
	var g := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.12, 0.05, 0.1)
	g.mesh = bm
	g.material_override = Toon.material(COLOR_GOLOSINA)
	vista.add_child(g)
	g.position = Vector3(p.x, p.y + 0.025, p.z)
	_golosinas.append(g)


func pelusa(p: Vector3, n: Vector3) -> void:
	var part := CPUParticles3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3.ONE * 0.025
	part.mesh = bm
	part.material_override = Toon.material(Color("ede8de"))
	part.amount = 10
	part.one_shot = true
	part.explosiveness = 0.9
	part.lifetime = 0.9
	part.direction = n
	part.spread = 60.0
	part.initial_velocity_min = 0.4
	part.initial_velocity_max = 0.9
	part.gravity = Vector3(0, -2.5, 0)
	vista.add_child(part)
	part.global_position = p
	part.emitting = true
	get_tree().create_timer(1.5).timeout.connect(part.queue_free)


# --- Interfaz ---------------------------------------------------------------------

func _interfaz() -> void:
	_capa_ui = Control.new()
	_capa_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	_capa_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_capa_ui)
	_controles = Label.new()
	_controles.text = TECLAS
	_controles.position = Vector2(14, 10)
	_estilo(_controles, 17)
	_capa_ui.add_child(_controles)
	_indicador = Label.new()
	_estilo(_indicador, 20)
	_indicador.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_indicador.add_theme_color_override("font_color", Color("ffe2b0"))
	_capa_ui.add_child(_indicador)


func _estilo(l: Label, tam: int) -> void:
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", Color("fff1d0"))
	l.add_theme_color_override("font_outline_color", Color("29140f"))
	l.add_theme_constant_override("outline_size", 6)


## Globo de texto sobre un personaje (en pantalla, nítido).
func decir(nodo: Node3D, texto: String, segundos := 1.5, alto := 1.0) -> void:
	for g in _globos:
		if g["nodo"] == nodo:
			(g["label"] as Label).queue_free()
	_globos = _globos.filter(func(g: Dictionary) -> bool: return g["nodo"] != nodo)
	var l := Label.new()
	l.text = texto
	_estilo(l, 20)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_capa_ui.add_child(l)
	_globos.append({"label": l, "nodo": nodo, "alto": alto, "hasta": Time.get_ticks_msec() / 1000.0 + segundos, "t": 0.0, "dur": segundos})


func _en_pantalla(p: Vector3) -> Vector2:
	return camara.unproject_position(p) * float(tam_pixel)


func _process(delta: float) -> void:
	# Cámara: sigue a Felipe con suavizado, dentro de los límites; en pasos de 1 pixel de render.
	var meta := clampf(gato.global_position.x, limites.x, limites.y)
	_cam_x = lerpf(_cam_x, meta, clampf(delta * 3.0, 0.0, 1.0))
	_colocar_camara()
	# Globos.
	for g in _globos.duplicate():
		g["t"] += delta
		var l := g["label"] as Label
		if g["t"] >= g["dur"] or not is_instance_valid(g["nodo"]):
			l.queue_free()
			_globos.erase(g)
			continue
		var p := _en_pantalla((g["nodo"] as Node3D).global_position + Vector3.UP * float(g["alto"]))
		l.reset_size()
		l.position = (p - Vector2(l.size.x * 0.5, l.size.y + 4.0 * minf(g["t"] * 8.0, 1.0) * 2.0)).round()
	# Indicador de E: lo más cercano que Felipe puede usar.
	var mejor: Node = null
	var mejor_d := INF
	var verbo := ""
	if gato.call("en_suelo_firme"):
		for n in get_tree().get_nodes_in_group("interactuable"):
			var v: String = n.call("verbo", gato)
			if v == "":
				continue
			var punto: Vector3 = n.call("punto_para", gato) if n.has_method("punto_para") else n.call("punto")
			var d := (punto - gato.global_position).length()
			if d < mejor_d:
				mejor_d = d
				mejor = n
				verbo = v
	gato.set("objetivo", mejor)
	_indicador.visible = mejor != null
	if mejor:
		var punto: Vector3 = mejor.call("punto_para", gato) if mejor.has_method("punto_para") else mejor.call("punto")
		var tecla := "Q/E" if verbo == "Pedir" else "E"
		_indicador.text = "%s  %s\n▼" % [tecla, verbo]
		_indicador.reset_size()
		var bote := sin(Time.get_ticks_msec() / 160.0) * 3.0
		_indicador.position = (_en_pantalla(punto) - Vector2(_indicador.size.x * 0.5, _indicador.size.y - 6.0 + bote)).round()
	# Golosinas: Felipe se las come al pasar.
	for g in _golosinas.duplicate():
		var d: Vector3 = g.global_position - gato.global_position
		if Vector2(d.x, d.z).length() < 0.3 and absf(d.y) < 0.2:
			decir(gato, "¡Ñam! +1", 1.2, 0.8)
			g.queue_free()
			_golosinas.erase(g)


func _objetivo() -> Node3D:
	return gato


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ayuda"):
		_controles.visible = not _controles.visible
		return
	if e is InputEventKey and e.pressed and (e as InputEventKey).keycode in [KEY_1, KEY_2, KEY_3, KEY_4]:
		super(e)
