# PROTOTIPO: no es código del juego.
# Pregunta: ¿se siente bien controlar a Felipe 3D (con rig) en una sala jugable: caminar, saltar
# a los muebles, arañar, tirar cosas y pedirle a Valeria?
# Fecha: 2026-10-23
# Escena jugable.tscn: la misma sala de principal.gd (pixel x3, bordes, luz toon) jugada como
# el juego 2D (2,5D de desplazamiento lateral): Felipe se mueve solo en X e Y, en un plano fijo
# (Z_PLANO). Los muebles son plataformas de un sentido (se atraviesan desde abajo; S + Espacio
# para bajar), como en el juego 2D; cada una dice a qué profundidad se dibuja Felipe cuando
# está encima (sobre el cojín se ve sobre el cojín). Vaso, taza y pelota tienen física con el
# eje Z bloqueado. Valeria camina por un carril apenas detrás de Felipe (no chocan: Felipe pasa
# delante, como las capas del 2D). Mesa alta de 75 cm, vaso, taza, pelota y Valeria con rutina
# y reacciones. Interfaz mínima: controles (H los oculta), globos de texto y
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
## Plano de juego de Felipe (z fija) y carril de Valeria, apenas detrás.
const Z_PLANO := 0.15
const Z_VALERIA := -0.15
## Capas de física: 1 piso y paredes, 2 Felipe, 8 objetos sueltos, 32 plataformas de un sentido
## (solo Felipe; se apagan cuando él está debajo o bajando), 64 las mismas plataformas, siempre
## sólidas, para los objetos.
const CAPA_PLATAFORMA_FELIPE := 32
const CAPA_PLATAFORMA_OBJETOS := 64
## Plataformas: [nombre, x desde, x hasta, alto (m), z donde se dibuja Felipe encima].
const PLATAFORMAS := [
	["cojin_sofa", -0.38, 1.18, 0.43, -0.55],
	["brazo_izq_sofa", -0.505, -0.38, 0.68, -0.72],
	["brazo_der_sofa", 1.18, 1.305, 0.68, -0.72],
	["respaldo_sofa", -0.38, 1.18, 0.85, -1.04],
	["mesita", -1.33, -0.57, 0.55, -0.8],
	["mesa_alta", 1.42, 1.98, 0.75, -0.86],
	["librero", 2.05, 2.95, 0.9, -1.0],
]
const TECLAS := "A/D o ←/→  caminar\nEspacio  saltar (soltar = salto corto)\nS + Espacio  bajar de un mueble\nE  acción (arañar, tirar, pedir)\nQ  pedir / maullar\nQuieto 9 s: se sienta y juega\nH  ocultar esta ayuda"

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
## [{cuerpo, forma, x0, x1, alto, z}] de las plataformas de un sentido.
var plataformas: Array[Dictionary] = []
var _cam_y := 0.0


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
	gato.position = Vector3(-1.6, 0.0, Z_PLANO)
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
	# Piso y paredes de los lados (sólidos para todos).
	_estatico(_caja_forma(Vector3(12, 0.2, 2.6)), Vector3(0, -0.1, 0.1))
	_estatico(_caja_forma(Vector3(0.2, 3.5, 2.6)), Vector3(-3.45, 1.75, 0.1))
	_estatico(_caja_forma(Vector3(0.2, 3.5, 2.6)), Vector3(4.4, 1.75, 0.1))
	# La lámpara de la mesita es un estorbo sólido sobre la mesita (no en el piso).
	_estatico(_caja_forma(Vector3(0.24, 0.47, 2.6)), Vector3(-0.95, 0.795, 0.1))
	for p in PLATAFORMAS:
		var ancho: float = p[2] - p[1]
		var centro := Vector3((p[1] + p[2]) * 0.5, float(p[3]) - 0.03, 0.1)
		# Para Felipe: de un sentido. Para los objetos: siempre sólida.
		var cf := _estatico(_caja_forma(Vector3(ancho, 0.06, 2.6)), centro)
		cf.collision_layer = CAPA_PLATAFORMA_FELIPE
		var co := _estatico(_caja_forma(Vector3(ancho, 0.06, 2.6)), centro)
		co.collision_layer = CAPA_PLATAFORMA_OBJETOS
		plataformas.append({"nombre": p[0], "forma": cf.get_child(0), "x0": p[1], "x1": p[2], "alto": p[3], "z": p[4]})
	sofa_aranable = Node3D.new()
	sofa_aranable.name = "SofaAranable"
	sofa_aranable.set_script(load("res://scripts/jugable/aranable.gd"))
	vista.add_child(sofa_aranable)


## Plataformas de un sentido (como one_way_collision del 2D): para Felipe solo existen las que
## quedan bajo sus pies mientras no sube ni está bajando con S + Espacio.
func ajustar_plataformas(f: CharacterBody3D, bajando: bool) -> void:
	var pies := f.global_position.y
	var sube := f.velocity.y > 0.01
	for p in plataformas:
		var apagada: bool = sube or bajando or pies < float(p["alto"]) - 0.035
		(p["forma"] as CollisionShape3D).disabled = apagada


## La plataforma bajo Felipe (la más alta que no esté por encima de sus pies), o {} si es el piso.
func plataforma_bajo(f: Node3D, margen := 0.03) -> Dictionary:
	var mejor := {}
	var x := f.global_position.x
	var pies := f.global_position.y
	for p in plataformas:
		if x < float(p["x0"]) - 0.12 or x > float(p["x1"]) + 0.12:
			continue
		if float(p["alto"]) <= pies + margen and (mejor.is_empty() or float(p["alto"]) > float(mejor["alto"])):
			mejor = p
	return mejor


## Profundidad a la que se dibuja Felipe: la del mueble bajo él; en el piso, su plano.
func z_visual(f: Node3D) -> float:
	var p := plataforma_bajo(f)
	if p.is_empty():
		return Z_PLANO
	var z: float = p["z"]
	# Sobre el cojín junto a Valeria sentada va delante de ella (como en el juego 2D).
	if p["nombre"] == "cojin_sofa" and valeria and valeria.get("_sentada") and absf(f.global_position.x - float(valeria.get("x_sofa"))) < 0.45:
		z = -0.28
	return z


func _mesa_alta() -> void:
	var cx := (MESA_X.x + MESA_X.y) * 0.5
	var cz := (MESA_Z.x + MESA_Z.y) * 0.5
	var ancho := MESA_X.y - MESA_X.x
	var fondo := MESA_Z.y - MESA_Z.x
	var grosor := 0.04
	Toon.caja(sala, Vector3(ancho, grosor, fondo), Vector3(cx, MESA_ALTO - grosor * 0.5, cz), COLOR_MESA)
	var pata := Vector3(0.05, MESA_ALTO - grosor, 0.05)
	for sx in [-1, 1]:
		for sz in [-1, 1]:
			var p := Vector3(cx + sx * (ancho * 0.5 - 0.04), (MESA_ALTO - grosor) * 0.5, cz + sz * (fondo * 0.5 - 0.04))
			Toon.caja(sala, pata, p, Color("572c1d"))


func _objetos() -> void:
	var Tirable := load("res://scripts/jugable/tirable.gd")
	vaso = RigidBody3D.new()
	vaso.name = "Vaso"
	vaso.set_script(Tirable)
	vaso.set("color", COLOR_VASO)
	vaso.set("lado_caida", -1.0)
	vaso.position = Vector3(-1.22, 0.55 + 0.12, -0.8)
	vista.add_child(vaso)
	taza = RigidBody3D.new()
	taza.name = "Taza"
	taza.set_script(Tirable)
	taza.set("rompible", false)
	taza.set("alto", 0.17)
	taza.set("radio", 0.085)
	taza.set("color", COLOR_TAZA)
	taza.set("lado_caida", -1.0)
	taza.position = Vector3(1.55, MESA_ALTO + 0.085, -0.86)
	vista.add_child(taza)
	pelota = RigidBody3D.new()
	pelota.name = "Pelota"
	pelota.mass = 0.15
	pelota.collision_layer = 8
	pelota.collision_mask = 1 | 2 | 8 | CAPA_PLATAFORMA_OBJETOS
	pelota.axis_lock_linear_z = true
	pelota.axis_lock_angular_x = true
	pelota.axis_lock_angular_y = true
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
	pelota.position = Vector3(-2.7, 0.11, Z_PLANO)
	vista.add_child(pelota)


## Valeria le da un snack: aparece en el piso y Felipe se lo come al pasar encima.
func dar_golosina(p: Vector3) -> void:
	var g := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.12, 0.05, 0.1)
	g.mesh = bm
	g.material_override = Toon.material(COLOR_GOLOSINA)
	vista.add_child(g)
	g.position = Vector3(p.x, p.y + 0.025, Z_PLANO)
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
	# Un poco en Y: sube con Felipe en los muebles y saltos (hasta 0,3 m).
	_cam_y = lerpf(_cam_y, clampf(gato.global_position.y * 0.35, 0.0, 0.3), clampf(delta * 2.0, 0.0, 1.0))
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
		if absf(d.x) < 0.3 and absf(d.y) < 0.2:
			decir(gato, "¡Ñam! +1", 1.2, 0.8)
			g.queue_free()
			_golosinas.erase(g)


## Como principal.gd, pero también en Y, siempre en pasos de 1 pixel de render.
func _colocar_camara() -> void:
	var px_m := float(vista.size.y) / ALTO_CUADRO_M
	var x := roundf(_cam_x * px_m) / px_m
	var y := roundf((1.22 + _cam_y) * px_m) / px_m
	var dist := 12.0
	var a := deg_to_rad(inclinacion_grados)
	camara.position = Vector3(x, y + dist * sin(a), dist * cos(a))


func _objetivo() -> Node3D:
	return gato


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ayuda"):
		_controles.visible = not _controles.visible
		return
	if e is InputEventKey and e.pressed and (e as InputEventKey).keycode in [KEY_1, KEY_2, KEY_3, KEY_4]:
		super(e)
