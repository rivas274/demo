# PROTOTIPO: no es código del juego.
# Pregunta: ¿se siente bien controlar a Felipe 3D (con rig) en una sala jugable: caminar, saltar
# a los muebles, arañar, tirar cosas y pedirle a Valeria?
# Fecha: 2026-10-23
# Valeria de la sala jugable. Reusa la carga de valeria_mixamo.gd (Meshy + Mixamo, toon, medidas
# de la caminata, la sentada y el agarre) y cambia la rutina por una cola de pasos que se puede
# interrumpir:
# - rutina: celular junto al librero, sofá, recoger la pelota y lanzársela a Felipe, ventana;
# - si Felipe tira algo: "¡FELIPE!", voltea, camina, lo recoge (clip recoger);
# - si Felipe le pide cerca: se agacha y le da un snack (sentada, se lo tira sin pararse);
# - esquiva a Felipe al caminar y, si él no se mueve, lo empuja suave.
extends "res://scripts/valeria_mixamo.gd"

const CAPA_VALERIA := 4

var felipe: CharacterBody3D
var juego: Node
var cuerpo: AnimatableBody3D
var _forma_pie: CollisionShape3D
var _forma_sentada: CollisionShape3D
var _cola: Array[Dictionary] = []
var _p: Dictionary = {}
var _act := 0
var _sentada := false
var _reaccionando := false
var _espera_pedido := 0.0
var _dijo_permiso := 0.0
var _llevando: RigidBody3D
var _agarro := false
var _bloqueo := 0.0
@export var rapidez_giro := 7.0


func _ready() -> void:
	z_camino = 0.22
	_cargar()
	_aplicar_toon()
	if _animado:
		_medir()
	_crear_cuerpo()
	add_to_group("interactuable")
	position = Vector3(3.0, 0.0, z_camino)
	_rumbo = -PI * 0.5
	rotation.y = _rumbo
	_siguiente()


func _crear_cuerpo() -> void:
	cuerpo = AnimatableBody3D.new()
	cuerpo.sync_to_physics = false
	cuerpo.collision_layer = CAPA_VALERIA
	cuerpo.collision_mask = 0
	_forma_pie = CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.2
	cap.height = 1.6
	_forma_pie.shape = cap
	_forma_pie.position.y = 0.8
	cuerpo.add_child(_forma_pie)
	_forma_sentada = CollisionShape3D.new()
	var caja := BoxShape3D.new()
	caja.size = Vector3(0.42, 0.8, 0.5)
	_forma_sentada.shape = caja
	_forma_sentada.disabled = true
	cuerpo.add_child(_forma_sentada)
	add_child(cuerpo)


func _sentar_cuerpo(si: bool) -> void:
	_sentada = si
	_forma_pie.disabled = si
	_forma_sentada.disabled = not si
	if si:
		_forma_sentada.global_position = Vector3(x_sofa, y_asiento + 0.42, -0.72)


# --- Lo que Felipe puede hacer con ella ---------------------------------------

func verbo(f: Node3D) -> String:
	var d := f.global_position - global_position
	if Vector2(d.x, d.z).length() <= 1.0 and absf(d.y) < 0.7:
		return "Pedir"
	return ""


func punto() -> Vector3:
	return global_position + Vector3.UP * (0.95 if _sentada else 1.2)


func pedido(f: Node3D) -> void:
	if _espera_pedido > 0.0:
		_decir("Ya comiste, gordo.")
		return
	if _reaccionando:
		_decir("¡Ahora no, Felipe!")
		return
	_espera_pedido = 8.0
	if _sentada:
		_decir("Ay, ya. Toma.")
		var donde := f.global_position + Vector3(0.0, 0.0, 0.25)
		juego.call("dar_golosina", Vector3(donde.x, f.global_position.y, donde.z))
		return
	_soltar_carga()
	var dar := func() -> void:
		var mano := _anexo_mano().global_position
		var hacia := (f.global_position - mano)
		hacia.y = 0.0
		var p := mano + hacia.limit_length(0.25)
		juego.call("dar_golosina", Vector3(p.x, 0.0, clampf(p.z, -0.3, 0.5)))
	_interrumpir([
		{"t": "mirar_a", "n": f},
		{"t": "decir", "txt": "¿Qué quieres, mi rey?"},
		{"t": "recoger", "agarre": dar},
		{"t": "decir", "txt": "Toma. No le digas a nadie."},
	])


## Felipe tiró algo: lo va a recoger.
func al_caer(obj: Node3D, pos: Vector3) -> void:
	if "--bot-log" in OS.get_cmdline_user_args():
		print("  [valeria] cayó %s en %s (reaccionando=%s)" % [obj.name, str(pos), _reaccionando])
	var pasos: Array[Dictionary] = []
	if not _reaccionando:
		_soltar_carga()
		if _sentada:
			pasos.append({"t": "levantarse"})
		pasos.append({"t": "decir", "txt": "¡FELIPE!"})
	pasos.append({"t": "mirar_a", "p": pos})
	pasos.append({"t": "ir", "p": _parada_cerca(pos)})
	pasos.append({"t": "mirar_a", "p": pos})
	pasos.append({"t": "recoger", "agarre": func() -> void: obj.call("recoger")})
	pasos.append({"t": "decir", "txt": "Gato malo..."})
	pasos.append({"t": "llamar", "f": func() -> void: _reaccionando = false})
	if _reaccionando:
		# Ya estaba recogiendo otra cosa: esta va después.
		_cola.append_array(pasos)
		return
	_reaccionando = true
	_interrumpir(pasos)


func _parada_cerca(pos: Vector3) -> Vector3:
	var lado := 1.0 if global_position.x >= pos.x else -1.0
	# Si Felipe está al lado de la cosa, se para del otro lado.
	if felipe and absf(felipe.global_position.x - pos.x) < 0.7:
		lado = 1.0 if pos.x >= felipe.global_position.x else -1.0
	return Vector3(pos.x + lado * 0.42, 0.0, clampf(pos.z + 0.1, -0.1, 0.45))


func _interrumpir(pasos: Array[Dictionary]) -> void:
	_cola = pasos
	_siguiente()


func _decir(txt: String) -> void:
	if juego:
		juego.call("decir", self, txt, 1.8, 1.25 if _sentada else 1.95)


# --- Rutina ----------------------------------------------------------------------

func _actividad(i: int) -> Array[Dictionary]:
	var zc := z_camino
	match i:
		0:
			return [{"t": "ir", "p": Vector3(2.3, 0.0, zc)}, {"t": "mirar", "yaw": deg_to_rad(-30.0)},
				{"t": "anim", "a": "celular", "s": 4.5}]
		1:
			return [{"t": "ir", "p": Vector3(x_sofa, 0.0, zc)}, {"t": "mirar", "yaw": 0.0},
				{"t": "sentarse"}, {"t": "decir", "txt": "Memes de gatos..."},
				{"t": "anim", "a": "sentada", "s": 7.0}, {"t": "levantarse"}]
		2:
			var pelota: RigidBody3D = juego.get("pelota") if juego else null
			if pelota == null or felipe == null:
				return []
			var bp := pelota.global_position
			var lejos := (bp - felipe.global_position).length() > 0.9
			var ocupado: bool = felipe.get("estado") in [7, 8]  # OCIO_IR, OCIO
			if bp.y > 0.2 or not lejos or ocupado:
				return []
			return [{"t": "ir", "p": _parada_cerca(bp)}, {"t": "mirar_a", "n": pelota},
				{"t": "recoger", "agarre": func() -> void: _tomar(pelota)},
				{"t": "decir", "txt": "¡Atrápala, Felipe!"},
				{"t": "llamar", "f": _lanzar}]
		_:
			return [{"t": "ir", "p": Vector3(-1.5, 0.0, zc)}, {"t": "mirar", "yaw": PI},
				{"t": "esperar", "s": 2.5}]


func _siguiente() -> void:
	var vueltas := 0
	while _cola.is_empty() and vueltas < 5:
		_cola = _actividad(_act)
		_act = (_act + 1) % 4
		vueltas += 1
	_p = _cola.pop_front()
	if "--bot-log" in OS.get_cmdline_user_args():
		print("  [valeria] %s en %s" % [_p.get("t"), str(position)], " ", _p.get("txt", _p.get("a", "")))
	_t = 0.0
	_desde = position
	_rumbo_desde = _rumbo
	_agarro = false
	_ap.speed_scale = 1.0
	match _p["t"]:
		"ir":
			if _sentada:
				_cola.push_front(_p)
				_p = {"t": "levantarse"}
				_tocar("quieto", mezcla_corte)
			else:
				_tocar("caminar", mezcla)
		"mirar", "mirar_a", "esperar":
			if not _sentada:
				_tocar("quieto", mezcla)
		"anim":
			_tocar(_p["a"], mezcla)
		"sentarse":
			_tocar("sentada", mezcla_corte)
			_sentar_cuerpo(true)
		"levantarse":
			_tocar("quieto", mezcla_corte)
		"recoger":
			_tocar("recoger", mezcla)


func _process(delta: float) -> void:
	_t += delta
	_espera_pedido = maxf(0.0, _espera_pedido - delta)
	_dijo_permiso = maxf(0.0, _dijo_permiso - delta)
	var listo := false
	match _p.get("t", ""):
		"ir":
			listo = _ir(delta)
		"mirar", "mirar_a":
			var meta: float = _p.get("yaw", _rumbo)
			if _p["t"] == "mirar_a":
				var objetivo: Vector3 = (_p["n"] as Node3D).global_position if _p.has("n") else _p["p"]
				var d := objetivo - position
				meta = atan2(d.x, d.z)
			_rumbo = lerp_angle(_rumbo, meta, clampf(delta * rapidez_giro, 0.0, 1.0))
			listo = absf(angle_difference(_rumbo, meta)) < 0.06 or _t > 0.8
		"anim", "esperar":
			listo = _t >= float(_p["s"])
		"sentarse", "levantarse":
			var dur := mezcla_corte
			var meta := _pos_sentada if _p["t"] == "sentarse" else Vector3(x_sofa, 0.0, z_camino)
			if _p["t"] == "levantarse" and not _sentada:
				meta = position
			var k := smoothstep(0.0, 1.0, clampf(_t / dur, 0.0, 1.0))
			position = _desde.lerp(meta, k)
			if _p["t"] == "sentarse":
				_rumbo = lerp_angle(_rumbo_desde, 0.0, k)
			if _t >= dur:
				listo = true
				if _p["t"] == "levantarse":
					_sentar_cuerpo(false)
		"recoger":
			if not _agarro and _t >= _t_agarre:
				_agarro = true
				if _p.has("agarre"):
					(_p["agarre"] as Callable).call()
			listo = _t >= _t_fin_recoger
		"decir":
			_decir(_p["txt"])
			listo = true
		"llamar":
			(_p["f"] as Callable).call()
			listo = true
		_:
			listo = true
	rotation.y = _rumbo
	if listo:
		_siguiente()


## Camina hacia el punto; esquiva a Felipe y, si él no se corre, lo empuja suave.
func _ir(delta: float) -> bool:
	var meta: Vector3 = _p["p"]
	var d := meta - position
	d.y = 0.0
	if d.length() < 0.03:
		position = Vector3(meta.x, 0.0, meta.z)
		return true
	var dir := d.normalized()
	var vel := _velocidad
	if felipe and felipe.global_position.y < 0.25:
		var desvio := _desvio(dir, d.length())
		if desvio.is_finite():
			dir = desvio
			_bloqueo = 0.0
		else:
			# No hay por dónde pasar: espera un poco y luego avanza despacio empujándolo suave.
			_bloqueo += delta
			vel = 0.0 if _bloqueo < 0.8 else 0.3
			if _dijo_permiso <= 0.0:
				_dijo_permiso = 6.0
				_decir("Permiso, Su Majestad.")
			if vel > 0.0:
				var a := felipe.global_position - position
				a.y = 0.0
				var lado := dir.cross(Vector3.UP).normalized()
				lado = lado if lado.dot(a) > 0.0 else -lado
				felipe.call("empujon", (lado * 0.7 + dir * 0.5).normalized() * 0.45)
	var paso := minf(vel * delta, d.length())
	position += dir * paso
	position.z = clampf(position.z, -0.15, 0.5)
	_rumbo = lerp_angle(_rumbo, atan2(dir.x, dir.z), clampf(delta * rapidez_giro, 0.0, 1.0))
	_ap.speed_scale = maxf(vel, 0.05) / maxf(_velocidad, 0.01)
	return false


## Si Felipe está en el camino, devuelve la dirección para rodearlo a 0,62 m por el lado que
## quede dentro del piso libre (z de -0,15 a 0,5). Vector3(INF...) si no hay por dónde.
func _desvio(dir: Vector3, largo: float) -> Vector3:
	var a := felipe.global_position - position
	a.y = 0.0
	var proy := a.dot(dir)
	var lateral := (a - dir * proy).length()
	if proy < -0.05 or proy > largo + 0.3 or lateral > 0.58:
		return dir
	var lado := dir.cross(Vector3.UP).normalized()
	var mejor := Vector3.INF
	var mejor_d := INF
	for s: float in [1.0, -1.0]:
		var w := felipe.global_position + lado * s * 0.62
		w.y = 0.0
		if w.z < -0.15 or w.z > 0.5:
			continue
		var dw := (w - position).length()
		if dw < mejor_d:
			mejor_d = dw
			mejor = w
	if not mejor.is_finite():
		return Vector3.INF
	var hacia := mejor - position
	hacia.y = 0.0
	if hacia.length() < 0.05:
		return dir
	return (hacia.normalized() + dir * 0.3).normalized()


# --- La pelota ----------------------------------------------------------------

func _tomar(pelota: RigidBody3D) -> void:
	_llevando = pelota
	pelota.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	pelota.freeze = true
	pelota.reparent(_anexo_mano(), true)


func _lanzar() -> void:
	if _llevando == null:
		return
	var pelota := _llevando
	_soltar_carga()
	if felipe:
		var hacia := felipe.global_position - pelota.global_position
		hacia.y = 0.0
		hacia = hacia.normalized() * clampf(hacia.length() * 1.2, 0.6, 1.6)
		pelota.linear_velocity = hacia + Vector3.UP * 1.0


func _soltar_carga() -> void:
	if _llevando == null:
		return
	var pelota := _llevando
	_llevando = null
	pelota.reparent(get_parent(), true)
	pelota.rotation = Vector3.ZERO
	pelota.freeze = false
	pelota.sleeping = false
