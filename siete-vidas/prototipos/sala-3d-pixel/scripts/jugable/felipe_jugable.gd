# PROTOTIPO: no es código del juego.
# Pregunta: ¿se siente bien controlar a Felipe 3D (con rig) en una sala jugable: caminar, saltar
# a los muebles, arañar, tirar cosas y pedirle a Valeria?
# Fecha: 2026-10-23
# Felipe jugable: CharacterBody3D con la sensación de juego del 2D (aceleración, margen al salir
# del borde, salto recordado, corte del salto, caída más pesada) en metros (121 px = 1 m).
# El dibujo es scripts/felipe_rig.gd (rig de Blender, cola con resorte y mirada) como hijo; este
# script solo elige el clip, su velocidad y hacia dónde mira.
extends CharacterBody3D

enum Estado { SUELO, PREPARA, AIRE, ATERRIZA, ARANANDO, MANOTAZO, PIDIENDO, OCIO_IR, OCIO }

const PX_M := 121.0
const ACCIONES := ["mover_izq", "mover_der", "mover_arriba", "mover_abajo", "saltar", "accion", "pedir"]
## Caja de colisión (m): largo en x, alto, ancho en z. Felipe mide 0,72 m a escala 1,3.
const CAJA := Vector3(0.5, 0.48, 0.3)

## Tope al caminar (m/s). El clip "caminar" se mide en felipe_rig.json (0,29 m/s a escala 1 =
## 0,38 m/s a 1,3); a más velocidad el clip se acelera en la misma proporción: las patas no patinan.
@export var velocidad_max := 0.6
## Hacia el fondo y el frente se camina más lento (como en un beat 'em up).
@export var factor_profundidad := 0.75
## Tiempo en llegar al tope y en frenar (en el 2D: 120/1200 = 0,1 s y 120/1450 = 0,083 s).
@export var t_acelerar := 0.1
@export var t_frenar := 0.083
## Valores del salto del juego 2D pasados a metros: ~0,66 m de alto.
@export var gravedad := 1410.0 / PX_M
@export var gravedad_cayendo := 2400.0 / PX_M
@export var velocidad_salto := 475.0 / PX_M
@export var caida_maxima := 740.0 / PX_M
@export var corte_salto := 0.45
@export var margen_salto := 0.12
@export var salto_recordado := 0.15
## Anticipación antes del despegue (s). El clip trae 0,5 s; se recorta para que responda.
@export var anticipacion := 0.1
## Al saltar pegado al frente de un mueble, el salto se corre hacia el fondo para caer encima.
@export var ayuda_profundidad := true
@export var espera_ocio := 8.5
## Cuánto mira al jugador sentado antes de jugar con la pelota (s).
@export var mira_antes_de_jugar := 1.5
## Empuje sobre la pelota (y otros cuerpos sueltos) al caminar contra ella.
@export var empuje := 1.3
@export var giro_caminar := 20.0

var juego: Node
var rig: Node3D
var ap: AnimationPlayer
var estado := Estado.SUELO
var objetivo: Node = null  # lo que usaría con E (lo muestra el indicador)

var _t := 0.0
var _coyote := 0.0
var _recordado := 0.0
var _cortado := false
var _z_meta := NAN
var _y_meta := 0.0
var _yaw := deg_to_rad(70.0)
var _ocio_t := 0.0
var _empuje := Vector3.ZERO
var _fase := ""
var _fase_t := 0.0
var _obj_accion: Node = null
var _ocio_meta := Vector3.ZERO
var _ocio_yaw := 0.0
var _ocio_bloqueo := 0.0
var _pos_clip_antes := 0.0
var _contacto_lado := 1.0
var _zarpazos_hechos: Array[float] = []
var _marcas: Array[Node3D] = []
var _caer_max_y := 0.0
## Para la prueba: la altura máxima de los pies en el último salto.
var altura_max := 0.0


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1 | 4 | 8
	floor_snap_length = 0.06
	floor_max_angle = deg_to_rad(50.0)
	var forma := CollisionShape3D.new()
	var caja := BoxShape3D.new()
	caja.size = CAJA
	forma.shape = caja
	forma.position.y = CAJA.y * 0.5
	add_child(forma)
	rig = Node3D.new()
	rig.name = "FelipeRig"
	rig.set_script(load("res://scripts/felipe_rig.gd"))
	rig.set("rutina", false)
	add_child(rig)
	ap = rig.get("ap")
	for bucle in ["sentado_mira", "sentado_pelota"]:
		if ap and ap.has_animation(bucle):
			ap.get_animation(bucle).loop_mode = Animation.LOOP_LINEAR
	rig.rotation.y = _yaw


func info() -> Dictionary:
	return rig.get("info")


## Velocidad del paso del clip "caminar" a la escala de Felipe (m/s).
func velocidad_paso() -> float:
	return rig.call("velocidad")


func tiene(clip: String) -> bool:
	return ap != null and ap.has_animation(clip)


func _tocar(clip: String, mezcla := 0.2, velocidad := 1.0, desde := -1.0) -> void:
	if not tiene(clip):
		return
	if ap.current_animation != clip or desde >= 0.0:
		ap.play(clip, mezcla)
		if desde >= 0.0:
			ap.seek(desde, true)
	ap.speed_scale = velocidad


func empujon(v: Vector3) -> void:
	_empuje = v


func en_suelo_firme() -> bool:
	return estado in [Estado.SUELO, Estado.ATERRIZA] and is_on_floor()


func _alguna_tecla() -> bool:
	for a in ACCIONES:
		if Input.is_action_pressed(a):
			return true
	return false


func _entrada() -> Vector2:
	return Vector2(Input.get_axis("mover_izq", "mover_der"), Input.get_axis("mover_arriba", "mover_abajo"))


# ------------------------------------------------------------------ física

func _physics_process(delta: float) -> void:
	if ap == null:
		return
	_t += delta
	if Input.is_action_just_pressed("saltar"):
		_recordado = salto_recordado
	else:
		_recordado = maxf(0.0, _recordado - delta)
	if is_on_floor():
		_coyote = margen_salto
	else:
		_coyote = maxf(0.0, _coyote - delta)

	var dir := _entrada()
	match estado:
		Estado.SUELO, Estado.ATERRIZA:
			_suelo(delta, dir)
		Estado.PREPARA:
			_frenar(delta)
			if _t >= anticipacion:
				_despegar()
		Estado.AIRE:
			_aire(delta, dir)
		Estado.ARANANDO, Estado.MANOTAZO, Estado.PIDIENDO:
			_frenar(delta)
			_accion(delta)
		Estado.OCIO_IR:
			_ocio_ir(delta)
		Estado.OCIO:
			_frenar(delta)
			_ocio(delta)

	if estado != Estado.AIRE:
		velocity.y = maxf(velocity.y - gravedad_cayendo * delta, -caida_maxima) if not is_on_floor() else minf(velocity.y, 0.0)
	var empuje_v := _empuje
	_empuje = _empuje.lerp(Vector3.ZERO, clampf(delta * 6.0, 0.0, 1.0))
	velocity += empuje_v
	move_and_slide()
	velocity -= empuje_v
	_empujar_cuerpos()
	altura_max = maxf(altura_max, global_position.y)
	_girar(delta)


func _horizontal() -> Vector3:
	return Vector3(velocity.x, 0.0, velocity.z)


func _acelerar(delta: float, dir: Vector2) -> void:
	var meta := Vector3(dir.x, 0.0, dir.y * factor_profundidad) * velocidad_max
	if meta.length() > velocidad_max:
		meta = meta.normalized() * velocidad_max
	var h := _horizontal()
	var a := velocidad_max / (t_acelerar if meta.length() > 0.01 else t_frenar)
	h = h.move_toward(meta, a * delta)
	velocity.x = h.x
	velocity.z = h.z


func _frenar(delta: float) -> void:
	_acelerar(delta, Vector2.ZERO)


func _suelo(delta: float, dir: Vector2) -> void:
	_acelerar(delta, dir)
	var en_piso := is_on_floor()
	# Salto (también con margen al salir del borde y salto recordado).
	if _recordado > 0.0 and (en_piso or _coyote > 0.0):
		_recordado = 0.0
		if en_piso:
			_cambiar(Estado.PREPARA)
		else:
			_despegar()
		return
	if not en_piso and _coyote <= 0.0:
		_cambiar(Estado.AIRE)
		return
	if Input.is_action_just_pressed("accion") and objetivo:
		_usar(objetivo)
		return
	if Input.is_action_just_pressed("pedir"):
		_pedir_o_maullar()
		return
	# Clip: caminar al ritmo de la velocidad o quieto.
	var v := _horizontal().length()
	if estado == Estado.ATERRIZA:
		if _t > 0.32 or (_t > 0.1 and v > 0.08):
			estado = Estado.SUELO
		else:
			return
	if v > 0.04:
		_tocar("caminar", 0.2, clampf(v / velocidad_paso(), 0.35, 3.0))
	else:
		_tocar("quieto", 0.25)
	# Quieto largo.
	if _alguna_tecla() or v > 0.03:
		_ocio_t = 0.0
	else:
		_ocio_t += delta
		if _ocio_t >= espera_ocio:
			_ocio_t = 0.0
			_empezar_ocio()


func _despegar() -> void:
	estado = Estado.AIRE
	_t = 0.0
	velocity.y = velocidad_salto
	_cortado = false
	altura_max = global_position.y
	if not Input.is_action_pressed("saltar"):
		velocity.y *= corte_salto
		_cortado = true
	var j: Dictionary = info()["saltar"]
	if ap.current_animation != "saltar":
		_tocar("saltar", 0.1, 1.0, float(j["despegue_s"]))
	_z_meta = _buscar_plataforma() if ayuda_profundidad and absf(_entrada().y) < 0.1 else NAN


## Si Felipe salta pegado al frente de un mueble alcanzable, devuelve la z donde caer encima.
func _buscar_plataforma() -> float:
	var espacio := get_world_3d().direct_space_state
	var pie := global_position.y
	var alto := velocidad_salto * velocidad_salto / (2.0 * gravedad)
	var atras := global_position.z - CAJA.z * 0.5
	for k in [0.03, 0.1, 0.16]:
		var z: float = atras - k
		var q := PhysicsRayQueryParameters3D.create(Vector3(global_position.x, pie + alto + 0.1, z),
			Vector3(global_position.x, pie + 0.05, z), 1)
		var r := espacio.intersect_ray(q)
		if r and r.normal.y > 0.7 and r.position.y > pie + 0.12 and r.position.y < pie + alto - 0.02:
			_y_meta = r.position.y
			return z - CAJA.z * 0.5 - 0.06
	return NAN


func _aire(delta: float, dir: Vector2) -> void:
	_acelerar(delta, dir)
	if not is_nan(_z_meta) and absf(dir.y) < 0.1 and global_position.y > _y_meta + 0.02:
		velocity.z = clampf((_z_meta - global_position.z) / 0.12, -1.6, 1.6)
	if velocity.y > 0.0:
		if not _cortado and not Input.is_action_pressed("saltar"):
			velocity.y *= corte_salto
			_cortado = true
		velocity.y -= gravedad * delta
	else:
		velocity.y = maxf(velocity.y - gravedad_cayendo * delta, -caida_maxima)
	# El clip "saltar" se recorre según la física: sube hasta la mitad del vuelo en la cima y
	# llega a las patas adelante cuando cae.
	var j: Dictionary = info()["saltar"]
	var t0: float = j["despegue_s"]
	var t1: float = j["aterrizaje_s"]
	var f := 0.5 * (1.0 - velocity.y / velocidad_salto) if velocity.y > 0.0 else 0.5 + 0.45 * clampf(-velocity.y / 3.0, 0.0, 1.0)
	var meta := t0 + f * (t1 - t0)
	if ap.current_animation != "saltar":
		_tocar("saltar", 0.15, 0.0, meta)
	ap.speed_scale = clampf((meta - ap.current_animation_position) / maxf(delta, 0.001), 0.0, 4.0)
	if is_on_floor() and velocity.y <= 0.0:
		_aterrizar()


func _aterrizar() -> void:
	_z_meta = NAN
	if _recordado > 0.0:
		_recordado = 0.0
		_cambiar(Estado.PREPARA)
		return
	_cambiar(Estado.ATERRIZA)


func _cambiar(e: Estado) -> void:
	estado = e
	_t = 0.0
	match e:
		Estado.PREPARA:
			var j: Dictionary = info()["saltar"]
			_tocar("saltar", 0.1, 1.0, maxf(0.0, float(j["despegue_s"]) - anticipacion))
		Estado.ATERRIZA:
			_tocar("saltar", 0.06, 1.3, float(info()["saltar"]["aterrizaje_s"]))
		Estado.AIRE:
			var j: Dictionary = info()["saltar"]
			_tocar("saltar", 0.15, 0.0, float(j["despegue_s"]) + 0.6 * (float(j["aterrizaje_s"]) - float(j["despegue_s"])))


func _empujar_cuerpos() -> void:
	var h := _horizontal()
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		var o := c.get_collider()
		if o is RigidBody3D and not (o as RigidBody3D).freeze:
			var cuerpo := o as RigidBody3D
			var d := -c.get_normal()
			d.y = 0.0
			if d.length() < 0.1:
				continue
			d = d.normalized()
			var meta := maxf(h.length(), 0.25) * empuje
			var falta := meta - cuerpo.linear_velocity.dot(d)
			if falta > 0.0:
				cuerpo.apply_central_impulse(d * falta * cuerpo.mass)


# ------------------------------------------------------------------ giro

func _girar(delta: float) -> void:
	var h := _horizontal()
	if estado in [Estado.SUELO, Estado.AIRE, Estado.ATERRIZA, Estado.OCIO_IR] and h.length() > 0.05:
		# Mira hacia donde camina, girado un poco hacia la cámara para que se vea la cara.
		var d := Vector3(h.x, 0.0, h.z + absf(h.x) * tan(deg_to_rad(giro_caminar)))
		_yaw = atan2(d.x, d.z)
	rig.rotation.y = lerp_angle(rig.rotation.y, _yaw, clampf(delta * 10.0, 0.0, 1.0))


func mirar_hacia(p: Vector3, hacia_camara := 0.0) -> void:
	var d := p - global_position
	d.y = 0.0
	if d.length() < 0.01:
		return
	d = d.normalized()
	d.z += absf(d.x) * tan(deg_to_rad(hacia_camara))
	_yaw = atan2(d.x, d.z)


func adelante() -> Vector3:
	return Vector3(sin(rig.rotation.y), 0.0, cos(rig.rotation.y))


# ------------------------------------------------------------------ acciones

func _usar(obj: Node) -> void:
	var verbo: String = obj.call("verbo", self)
	if "--bot-log" in OS.get_cmdline_user_args():
		print("  [felipe] %s %s en %s" % [verbo, obj.name, str(global_position)])
	match verbo:
		"Arañar":
			_obj_accion = obj
			var lado := signf(sin(rig.rotation.y))
			_yaw = atan2(0.35 * (lado if lado != 0.0 else 1.0), -1.0)
			_empezar_accion(Estado.ARANANDO)
		"Tirar":
			_obj_accion = obj
			mirar_hacia((obj as Node3D).global_position)
			_empezar_accion(Estado.MANOTAZO)
		"Pedir":
			_pedir_o_maullar()


func _pedir_o_maullar() -> void:
	var valeria: Node = juego.get("valeria") if juego else null
	_obj_accion = null
	if valeria and valeria.has_method("verbo") and valeria.call("verbo", self) == "Pedir":
		_obj_accion = valeria
		mirar_hacia((valeria as Node3D).global_position, 25.0)
	_empezar_accion(Estado.PIDIENDO)


func _empezar_accion(e: Estado) -> void:
	estado = e
	_t = 0.0
	_fase_t = 0.0
	_zarpazos_hechos.clear()
	_ocio_t = 0.0
	match e:
		Estado.ARANANDO, Estado.MANOTAZO:
			_fase = "entrada"
			_tocar("aranar_entrada", 0.2)
		Estado.PIDIENDO:
			_fase = "entrada"
			_tocar("pedir_entrada", 0.2)


func _accion(delta: float) -> void:
	_fase_t += delta
	var dur := func(c: String) -> float: return ap.get_animation(c).length if tiene(c) else 0.5
	match estado:
		Estado.ARANANDO, Estado.MANOTAZO:
			var vueltas := 2 if estado == Estado.ARANANDO else 1
			match _fase:
				"entrada":
					if _fase_t >= dur.call("aranar_entrada") - 0.02:
						_fase = "aranar"
						_fase_t = 0.0
						_tocar("aranar", 0.08, 1.0, 0.0)
				"aranar":
					var zarpazos: Array = info().get("aranar", {}).get("zarpazos_s", [0.125, 0.4583])
					var ciclo: float = dur.call("aranar")
					for v in vueltas:
						for z in zarpazos:
							var tz: float = v * ciclo + float(z)
							if _fase_t >= tz and not (tz in _zarpazos_hechos):
								_zarpazos_hechos.append(tz)
								_zarpazo()
					if _fase_t >= ciclo * vueltas - 0.02:
						_fase = "salida"
						_fase_t = 0.0
						_tocar("aranar_salida", 0.1, 1.0, 0.0)
				"salida":
					if _fase_t >= dur.call("aranar_salida") - 0.02:
						_terminar_accion()
		Estado.PIDIENDO:
			var pide := _obj_accion != null
			match _fase:
				"entrada":
					if _fase_t >= dur.call("pedir_entrada") - 0.02:
						_fase = "pedir"
						_fase_t = 0.0
						_tocar("pedir", 0.1, 1.0, 0.0)
						if pide:
							juego.call("decir", self, "Mrrau... (snack)", 1.6, 0.8)
							_obj_accion.call("pedido", self)
						else:
							juego.call("decir", self, "¡MIAU!", 1.0, 0.8)
				"pedir":
					if _fase_t >= (dur.call("pedir") if pide else 0.5):
						_fase = "salida"
						_fase_t = 0.0
						if tiene("pedir_entrada"):
							ap.play_backwards("pedir_entrada", 0.15)
							ap.speed_scale = 1.3
				"salida":
					if _fase_t >= dur.call("pedir_entrada") / 1.3 - 0.02:
						_terminar_accion()


func _terminar_accion() -> void:
	_obj_accion = null
	estado = Estado.SUELO
	_t = 1.0
	_tocar("quieto", 0.25)


## Cada bajada de garras: en el arañazo deja marcas y pelusa; en el manotazo tira el objeto
## (cuando la pata llega, no al apretar).
func _zarpazo() -> void:
	if estado == Estado.MANOTAZO:
		if _zarpazos_hechos.size() == 1 and is_instance_valid(_obj_accion):
			var d := (_obj_accion as Node3D).global_position - global_position
			# El manotazo lo manda hacia el frente (al piso libre), un poco hacia donde pegó.
			_obj_accion.call("golpear", Vector3(clampf(d.x, -0.5, 0.5), 0.0, 0.8).normalized())
		return
	# Arañar: rayo hacia el mueble a la altura de las garras.
	var origen := global_position + Vector3.UP * 0.36
	var q := PhysicsRayQueryParameters3D.create(origen, origen + adelante() * 0.7, 1)
	var r := get_world_3d().direct_space_state.intersect_ray(q)
	if r.is_empty():
		return
	var n: Vector3 = r.normal
	var p: Vector3 = r.position + n * 0.006
	_marca(p, n)
	if juego:
		juego.call("pelusa", p, n)


func _marca(p: Vector3, n: Vector3) -> void:
	var raiz := Node3D.new()
	get_parent().add_child(raiz)
	raiz.global_position = p
	var arriba := Vector3.UP if absf(n.dot(Vector3.UP)) < 0.9 else Vector3.FORWARD
	raiz.look_at(p - n, arriba)
	raiz.rotate_object_local(Vector3.FORWARD, randf_range(-0.25, 0.25))
	for i in 3:
		var m := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.014, randf_range(0.08, 0.11), 0.004)
		m.mesh = bm
		m.material_override = Toon.material(Color("572c1d"))
		m.position = Vector3((i - 1) * 0.03, randf_range(-0.01, 0.01), 0.0)
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		raiz.add_child(m)
	_marcas.append(raiz)
	if _marcas.size() > 24:
		_marcas.pop_front().queue_free()


# ------------------------------------------------------------------ quieto largo

func _empezar_ocio() -> void:
	if not tiene("sentarse"):
		# Clips de sentarse aún no disponibles: queda en "quieto" (con la mirada ocasional del rig).
		return
	var pelota: RigidBody3D = juego.get("pelota") if juego else null
	var contactos: Array = info().get("sentado_pelota", {}).get("contactos", [])
	if pelota and contactos.size() > 0:
		var d := pelota.global_position - global_position
		var alto_ok := absf(pelota.global_position.y - global_position.y - 0.11) < 0.08
		if alto_ok and Vector2(d.x, d.z).length() < 1.6 and pelota.linear_velocity.length() < 0.15:
			var lado := 1.0 if d.x >= 0.0 else -1.0
			_ocio_yaw = deg_to_rad(50.0) * lado
			var pie := _pie_contacto()
			var b := Basis(Vector3.UP, _ocio_yaw)
			_ocio_meta = pelota.global_position - b * Vector3(pie.x, 0.0, pie.z + 0.1)
			_ocio_meta.y = global_position.y
			_ocio_meta.z = clampf(_ocio_meta.z, -0.2, 0.45)
			_ocio_bloqueo = 0.0
			estado = Estado.OCIO_IR
			_t = 0.0
			return
	_sentarse()


func _pie_contacto() -> Vector3:
	var contactos: Array = info().get("sentado_pelota", {}).get("contactos", [])
	if contactos.is_empty():
		return Vector3(0.0, 0.0, 0.3)
	var p: Array = contactos[0]["pie_m"]
	return Vector3(p[0], p[1], p[2]) * float(rig.get("escala"))


func _ocio_ir(delta: float) -> void:
	if _alguna_tecla():
		_terminar_accion()
		return
	var d := _ocio_meta - global_position
	d.y = 0.0
	if d.length() < 0.03 or _ocio_bloqueo > 2.5:
		velocity.x = 0.0
		velocity.z = 0.0
		_yaw = _ocio_yaw
		_sentarse()
		return
	var v := minf(velocidad_paso() * 1.2, d.length() / maxf(delta, 0.001))
	var h := d.normalized() * v
	velocity.x = h.x
	velocity.z = h.z
	if get_real_velocity().length() < 0.02 and _t > 0.3:
		_ocio_bloqueo += delta
	_tocar("caminar", 0.2, clampf(v / velocidad_paso(), 0.35, 3.0))


func _sentarse() -> void:
	estado = Estado.OCIO
	_fase = "sentarse"
	_fase_t = 0.0
	_tocar("sentarse", 0.25, 1.0, 0.0)


func _ocio(delta: float) -> void:
	_fase_t += delta
	if _fase != "levantarse" and _fase != "sentarse" and _alguna_tecla():
		_fase = "levantarse"
		_fase_t = 0.0
		_tocar("levantarse", 0.15, 1.4, 0.0)
		return
	match _fase:
		"sentarse":
			if _fase_t >= ap.get_animation("sentarse").length - 0.02:
				if _alguna_tecla():
					_fase = "levantarse"
					_fase_t = 0.0
					_tocar("levantarse", 0.15, 1.4, 0.0)
				else:
					_fase = "mira"
					_fase_t = 0.0
					_tocar("sentado_mira", 0.2, 1.0, 0.0)
		"mira":
			if _fase_t >= mira_antes_de_jugar and _pelota_cerca() and tiene("sentado_pelota"):
				_fase = "pelota"
				_fase_t = 0.0
				_pos_clip_antes = 0.0
				_tocar("sentado_pelota", 0.25, 1.0, 0.0)
		"pelota":
			var pos := ap.current_animation_position
			for c in info().get("sentado_pelota", {}).get("contactos", []):
				var tc: float = c["t_s"]
				var cruzo := (_pos_clip_antes < tc and pos >= tc) or (pos < _pos_clip_antes and (tc > _pos_clip_antes or tc <= pos))
				if cruzo:
					_tocar_pelota()
			_pos_clip_antes = pos
			if not _pelota_cerca(0.5) and _fase_t > 2.0:
				_fase = "mira"
				_fase_t = 0.0
				_tocar("sentado_mira", 0.3, 1.0, 0.0)
		"levantarse":
			if _fase_t >= ap.get_animation("levantarse").length / 1.4 - 0.02:
				_terminar_accion()


func _pata_mundo() -> Vector3:
	return rig.global_transform * _pie_contacto()


func _pelota_cerca(max_d := 0.35) -> bool:
	var pelota: RigidBody3D = juego.get("pelota") if juego else null
	if pelota == null:
		return false
	var d := pelota.global_position - _pata_mundo()
	d.y = 0.0
	return d.length() < max_d


## En cada contacto de la pata (marcas de felipe_rig.json) la pelota recibe un toque: hacia un
## lado y al siguiente hacia el otro, así se queda jugando cerca.
func _tocar_pelota() -> void:
	var pelota: RigidBody3D = juego.get("pelota") if juego else null
	if pelota == null or not _pelota_cerca(0.4):
		return
	var izquierda := rig.global_transform.basis.x.normalized()
	var frente := adelante()
	_contacto_lado = -_contacto_lado
	var v := izquierda * 0.38 * _contacto_lado + frente * 0.06 + Vector3.UP * 0.25
	pelota.apply_central_impulse(v * pelota.mass)
