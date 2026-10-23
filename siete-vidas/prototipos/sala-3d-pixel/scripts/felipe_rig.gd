# PROTOTIPO: no es código del juego.
# Pregunta: ¿se ve vivo Felipe de Meshy con una retopología, un esqueleto y animaciones
# hechos en Blender como lo haría un artista (y no armados por código)?
# Fecha: 2026-10-22
# - Modelo: assets/meshy_prueba/felipe_rig/felipe_rig.glb (malla en cuadriláteros, textura
#   horneada, piel con pesos de calor y animaciones caminar, quieto, aranar_entrada, aranar,
#   aranar_salida, pedir_entrada, pedir y saltar). Se arma con los scripts de
#   assets/meshy_prueba/felipe_rig/scripts/ (Blender 5.2 como módulo).
# - Todo va "en el lugar": el nodo avanza a la velocidad del paso y el arco del salto lo
#   hace este código entre las marcas de despegue y aterrizaje de felipe_rig.json.
# - Capa aditiva de la cola: un resorte amortiguado por hueso, encima del clip, que reacciona
#   a la aceleración y a los giros del nodo (al arrancar se atrasa, al frenar sigue de largo
#   y rebota, al despegar va abajo y al aterrizar da un latigazo).
# - Rutina (en la sala): camina, salta al cojín del sofá, araña el respaldo, baja de un
#   salto, camina hasta donde estaría Valeria y le pide comida; vuelve a empezar.
# Se abre con: godot --path . -- --felipe-rig
extends Node3D

const RUTA := "res://assets/meshy_prueba/felipe_rig/felipe_rig.glb"
const RUTA_INFO := "res://assets/meshy_prueba/felipe_rig/felipe_rig.json"
const MEZCLA := 0.2
const BUCLES := ["caminar", "quieto", "aranar", "pedir", "sentado_mira", "sentado_pelota"]
const COLA := ["tail.001", "tail.002", "tail.003", "tail.004", "tail.005"]
## Resorte de la cola por hueso: frecuencia (Hz, la punta más lenta = más retraso),
## ganancia (grados por m/s²) y amortiguación. Tope de ±25°.
const COLA_HZ := [2.6, 2.3, 2.0, 1.75, 1.5]
const COLA_GANANCIA := [0.6, 1.1, 1.7, 2.3, 2.9]
const COLA_AMORT := 0.32
const COLA_TOPE := 25.0
## Alto del arco del salto sobre el punto más alto (m, a escala 1,3).
const ALTO_ARCO := 0.12

## 1,3: el tamaño que pidió el creador para el Felipe 3D (30 % más grande).
@export var escala := 1.3
@export var usar_toon := true
## Al caminar se gira un poco hacia la cámara para que se vea la cara.
@export var giro_caminar := 20.0
@export var rutina := true
## Otro GLB (por ejemplo, la versión anterior para comparar).
@export var ruta := RUTA
## Si es mayor que 0, reemplaza la velocidad del paso de felipe_rig.json (para comparar un GLB viejo).
@export var velocidad_m_s := 0.0
@export var resorte_cola := true
## Contorno de dibujo (técnica estándar toon / cel shading):
## - casco invertido (segunda pasada, caras traseras empujadas en pantalla), en píxeles de render;
## - umbrales del post-proceso de bordes de la sala (profundidad en m y normales), que dibujan la
##   línea interior donde la pata se superpone al cuerpo.
## v5: el post-proceso global de la sala vuelve a sus valores de siempre (los umbrales bajos de
## la v4 ensuciaban la imagen a ×3); a Felipe solo se le agrega su casco de 1 px. Con
## -- --contorno=px y -- --bordes=prof,normal se prueban otras combinaciones.
@export var contorno_px := 0.0  # v5: sin casco (sus caras traseras asomaban como puntos oscuros en el pecho y la cara)
var _bordes_cmd := false
## v6: capa de cabeza (técnica estándar de vista lateral: el personaje "muestra la cara").
## giro_cabeza: grados máximos que la cabeza gira hacia la cámara; alza_cabeza: grados que el
## cuello sube al caminar (la caminata la lleva baja y, con la cámara alta, se veía sobre todo
## la coronilla); escala_cabeza: escala uniforme del hueso de la cabeza.
## Se prueban con -- --giro=g --alza=g --escala-cabeza=k --glb=ruta.
@export var giro_cabeza := 12.0   # v6.1: al caminar, giro sutil (solo evita ver la coronilla)
## v6.1: mirada a cámara solo como gesto: en quieto, cada 4 a 8 s (al azar) mira 1 a 2 s; al
## pedir mira a la persona. De espaldas o dándose vuelta, la cabeza sigue al cuerpo.
@export var giro_gesto := 35.0
@export var giro_pedir := 25.0
var _rng := RandomNumberGenerator.new()
var _prox_gesto := 5.0
var _gesto_t := 0.0
var _gesto_dur := 0.0
@export var alza_cabeza := 12.0
@export var escala_cabeza := 1.0
var _cab_idx := -1
var _cuello_idx := -1
var _giro_cab := 0.0
var _anda := 0.0
var umbral_profundidad := 0.12
var umbral_normal := 0.45
const COLOR_CONTORNO := Color("2b140e")

var ap: AnimationPlayer
var sk: Skeleton3D
var modelo: Node3D
var info := {"velocidad_caminar_m_s": 0.187, "saltar": {"despegue_s": 0.5, "aterrizaje_s": 1.0}}
var _cola_idx: Array[int] = []
var _cola_ang: Array[Vector2] = []   # (atrás/adelante, de lado) en grados, por hueso
var _cola_vel: Array[Vector2] = []
var _pos_antes := Vector3.ZERO
var _vel_antes := Vector3.ZERO
var _giro_antes := 0.0
var _acel := Vector3.ZERO
# Rutina: lista de pasos y estado del paso actual.
var _pasos: Array = []
var _i := -1
var _t := 0.0
var _desde := Vector3.ZERO
var _giro_desde := 0.0


func _ready() -> void:
	_leer_info()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--glb="):
			ruta = arg.get_slice("=", 1)
	var doc := GLTFDocument.new()
	var estado := GLTFState.new()
	if FileAccess.file_exists(ruta) and doc.append_from_file(ruta, estado) == OK:
		modelo = doc.generate_scene(estado)
	elif ResourceLoader.exists(ruta):
		# En un ejecutable exportado el .glb original no viaja: se usa la escena importada.
		modelo = (load(ruta) as PackedScene).instantiate()
	else:
		push_error("felipe_rig: no se pudo cargar " + ruta)
		return
	modelo.scale = Vector3.ONE * escala
	add_child(modelo)
	ap = modelo.find_children("*", "AnimationPlayer", true, false)[0]
	ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	sk = modelo.find_children("*", "Skeleton3D", true, false)[0]
	for nombre in ap.get_animation_list():
		ap.get_animation(nombre).loop_mode = Animation.LOOP_LINEAR if nombre in BUCLES else Animation.LOOP_NONE
	_cab_idx = sk.find_bone("spine.006")
	_cuello_idx = sk.find_bone("spine.004")
	for h in COLA:
		_cola_idx.append(sk.find_bone(h))
		_cola_ang.append(Vector2.ZERO)
		_cola_vel.append(Vector2.ZERO)
	if usar_toon:
		for mi in modelo.find_children("*", "MeshInstance3D", true, false):
			var m := mi as MeshInstance3D
			var src := m.mesh.surface_get_material(0) as BaseMaterial3D
			var mt := Toon.material(Color.WHITE)
			mt.set_shader_parameter("usar_textura", true)
			mt.set_shader_parameter("textura", src.albedo_texture if src else null)
			m.material_override = mt
			if contorno_px > 0.0:
				var casco := ShaderMaterial.new()
				casco.shader = Toon.SHADER_CONTORNO
				casco.set_shader_parameter("color", COLOR_CONTORNO)
				casco.set_shader_parameter("grosor_px", contorno_px)
				mt.next_pass = casco
	_ajustar_bordes.call_deferred()
	_rng.seed = 7
	ap.play("quieto")
	if rutina:
		_armar_rutina()
	_pos_antes = global_position
	_giro_antes = rotation.y


## Lee las opciones de contorno de la línea de comandos y las aplica después de que la sala
## arma su post-proceso (principal.gd fija el casco a 1 px al empezar).
func _ajustar_bordes() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--giro="):
			giro_cabeza = float(arg.get_slice("=", 1))
		elif arg.begins_with("--alza="):
			alza_cabeza = float(arg.get_slice("=", 1))
		elif arg.begins_with("--escala-cabeza="):
			escala_cabeza = float(arg.get_slice("=", 1))
		elif arg.begins_with("--contorno="):
			contorno_px = float(arg.get_slice("=", 1))
		elif arg.begins_with("--bordes="):
			var v := arg.get_slice("=", 1).split(",")
			umbral_profundidad = float(v[0])
			umbral_normal = float(v[1])
			_bordes_cmd = true
	for mi in find_children("*", "MeshInstance3D", true, false):
		var mt := (mi as MeshInstance3D).material_override as ShaderMaterial
		if mt and mt.next_pass:
			(mt.next_pass as ShaderMaterial).set_shader_parameter("grosor_px", contorno_px)
	var principal := get_parent().get_parent() if get_parent() else null
	var bordes = principal.get("bordes") if principal else null
	if bordes is ShaderMaterial and _bordes_cmd:
		bordes.set_shader_parameter("umbral_profundidad", umbral_profundidad)
		bordes.set_shader_parameter("umbral_normal", umbral_normal)


func _leer_info() -> void:
	var f := FileAccess.open(RUTA_INFO, FileAccess.READ)
	if f == null:
		return
	var d = JSON.parse_string(f.get_as_text())
	if d is Dictionary:
		info = d


func velocidad() -> float:
	var v := velocidad_m_s if velocidad_m_s > 0.0 else float(info["velocidad_caminar_m_s"])
	return v * escala


func duracion(nombre: String) -> float:
	return ap.get_animation(nombre).length


func reproducir(nombre: String, atras := false) -> void:
	if atras:
		ap.play_backwards(nombre, MEZCLA)
	else:
		ap.play(nombre, MEZCLA)


## Posición del salto en el tiempo t (s desde que empieza la animación "saltar"): quieto
## hasta el despegue, arco parabólico hasta el aterrizaje y luego en el destino.
func arco_salto(desde: Vector3, hasta: Vector3, t: float) -> Vector3:
	var t0: float = info["saltar"]["despegue_s"]
	var t1: float = info["saltar"]["aterrizaje_s"]
	var u := clampf((t - t0) / (t1 - t0), 0.0, 1.0)
	var p := desde.lerp(hasta, u)
	var cima := maxf(desde.y, hasta.y) + ALTO_ARCO
	# Parábola que pasa por desde.y, cima y hasta.y.
	var a := desde.y
	var b := hasta.y
	var h := cima
	var m := (sqrt(h - a)) / (sqrt(h - a) + sqrt(h - b))
	var y := a + (h - a) * (1.0 - pow((u - m) / m, 2)) if u <= m else b + (h - b) * (1.0 - pow((u - m) / (1.0 - m), 2))
	p.y = y if u > 0.0 and u < 1.0 else p.y
	return p


## Avanza la animación y aplica la capa de la cola. Las pruebas lo llaman cuadro a cuadro.
func animar(delta: float) -> void:
	if ap == null or delta <= 0.0:
		return
	ap.advance(delta)
	var pos := global_position
	var vel := (pos - _pos_antes) / delta
	var acel := (vel - _vel_antes) / delta
	_acel = _acel.lerp(acel, clampf(delta * 20.0, 0.0, 1.0))
	var giro_vel := wrapf(rotation.y - _giro_antes, -PI, PI) / delta
	_pos_antes = pos
	_vel_antes = vel
	_giro_antes = rotation.y
	_cabeza(delta, giro_vel)
	if resorte_cola:
		_cola(delta, giro_vel)


## Capa de cabeza (v6.1): sube el cuello al caminar y gira la cabeza, con suavizado:
## - de espaldas a la cámara (más de ~60° pasada la vista de perfil) o dándose vuelta: 0;
## - caminando: hacia la cámara como mucho giro_cabeza (sutil, mira hacia donde va);
## - quieto: mirada ocasional a la cámara (gesto de 1 a 2 s cada 4 a 8 s);
## - pidiendo: mira a la persona (hacia la cámara, giro_pedir).
func _cabeza(delta: float, giro_vel: float = 0.0) -> void:
	if _cab_idx < 0:
		return
	var anim := ap.current_animation
	var anda := 1.0 if anim == "caminar" else 0.0
	_anda = lerpf(_anda, anda, clampf(delta * 6.0, 0.0, 1.0))
	var cam := get_viewport().get_camera_3d()
	var hacia := 0.0      # ángulo (°) de la cámara respecto del frente de Felipe
	if cam:
		var a_cam := sk.global_transform.affine_inverse() * cam.global_position
		var d := a_cam - sk.get_bone_global_pose(_cab_idx).origin
		hacia = rad_to_deg(atan2(d.x, d.z))
	# Gesto ocasional en quieto.
	if anim == "quieto":
		_prox_gesto -= delta
		if _prox_gesto <= 0.0 and _gesto_t <= 0.0:
			_gesto_dur = _rng.randf_range(1.0, 2.0)
			_gesto_t = _gesto_dur
			_prox_gesto = _rng.randf_range(4.0, 8.0) + _gesto_dur
	else:
		_prox_gesto = maxf(_prox_gesto, 2.0)
	_gesto_t = maxf(0.0, _gesto_t - delta)
	var tope := 0.0
	if anim == "caminar":
		tope = giro_cabeza
	elif anim.begins_with("pedir") or anim == "sentado_mira":
		tope = giro_pedir   # mira a la persona / al jugador
	elif anim == "quieto" and _gesto_t > 0.0:
		tope = giro_gesto
	# De espaldas: nada (se desvanece de 100° a 130° de la cámara); dándose vuelta: nada.
	var de_frente := 1.0 - smoothstep(100.0, 130.0, absf(hacia))
	var quieto_giro := 1.0 - smoothstep(0.5, 1.5, absf(giro_vel))
	var meta := clampf(hacia, -tope, tope) * de_frente * quieto_giro
	_giro_cab = lerpf(_giro_cab, meta, clampf(delta * 3.5, 0.0, 1.0))
	if _cuello_idx >= 0 and alza_cabeza != 0.0:
		_girar_hueso(_cuello_idx, Basis(Vector3.RIGHT, deg_to_rad(-alza_cabeza * _anda)))
	_girar_hueso(_cab_idx, Basis(Vector3.UP, deg_to_rad(_giro_cab)))
	if escala_cabeza != 1.0:
		sk.set_bone_pose_scale(_cab_idx, Vector3.ONE * escala_cabeza)


## Gira un hueso en el espacio del esqueleto alrededor de su cabeza (capa aditiva).
func _girar_hueso(b: int, giro: Basis) -> void:
	var padre := sk.get_bone_parent(b)
	var gp := sk.get_bone_global_pose(b)
	var pp := sk.get_bone_global_pose(padre) if padre >= 0 else Transform3D()
	sk.set_bone_pose_rotation(b, (pp.basis.inverse() * (giro * gp.basis)).get_rotation_quaternion())


func _cola(delta: float, giro_vel: float) -> void:
	# Aceleración en el marco de Felipe: z adelante, y arriba.
	var local := global_transform.basis.inverse() * _acel
	for i in COLA.size():
		var w: float = TAU * COLA_HZ[i]
		var g: float = COLA_GANANCIA[i]
		# x + = adelante, y + = a su izquierda. Al acelerar adelante (o hacia arriba) la cola
		# se atrasa (o baja); al girar a la izquierda el cuerpo rota y la cola queda atrás,
		# hacia su izquierda.
		var objetivo := Vector2(-g * local.z - 0.6 * g * local.y, g * 1.5 * giro_vel)
		var f: Vector2 = (objetivo - _cola_ang[i]) * w * w - _cola_vel[i] * 2.0 * COLA_AMORT * w
		_cola_vel[i] += f * delta
		_cola_ang[i] += _cola_vel[i] * delta
		_cola_ang[i] = _cola_ang[i].clamp(Vector2(-COLA_TOPE, -COLA_TOPE), Vector2(COLA_TOPE, COLA_TOPE))
	# Capa aditiva: cada hueso gira en el espacio del esqueleto alrededor de su cabeza.
	# Felipe mira a +Z y su izquierda es +X: girar en +X lleva la cola adelante y girar en
	# -Z la lleva a su izquierda.
	for i in COLA.size():
		var b := _cola_idx[i]
		if b < 0:
			continue
		var a := _cola_ang[i]
		var giro := Basis(Vector3.RIGHT, deg_to_rad(a.x)) * Basis(Vector3.BACK, deg_to_rad(-a.y))
		var padre := sk.get_bone_parent(b)
		var gp := sk.get_bone_global_pose(b)
		var pp := sk.get_bone_global_pose(padre) if padre >= 0 else Transform3D()
		var nueva := pp.basis.inverse() * (giro * gp.basis)
		sk.set_bone_pose_rotation(b, nueva.get_rotation_quaternion())


func _process(delta: float) -> void:
	if ap == null:
		return
	if rutina and not _pasos.is_empty():
		_rutina(delta)
	animar(delta)


# ------------------------------------------------------------------ rutina
## Pasos: ["quieto", s] | ["girar", grados, s] | ["caminar", x, z] | ["saltar", Vector3] |
## ["anim", nombre, veces] | ["atras", nombre].
func _armar_rutina() -> void:
	var cojin := Vector3(0.26, 0.43, -0.74)
	var piso_sofa := Vector3(0.02, 0.0, 0.2)
	var valeria := Vector3(-0.72, 0.0, 0.26)
	_pasos = [
		["quieto", 1.2],
		["girar", 70.0, 0.35], ["caminar", piso_sofa.x, piso_sofa.z],
		["girar", _rumbo(piso_sofa, cojin), 0.4], ["saltar", cojin],
		["girar", 135.0, 0.45],
		["anim", "aranar_entrada", 1], ["anim", "aranar", 3], ["anim", "aranar_salida", 1],
		["quieto", 0.4],
		["girar", -20.0, 0.5], ["saltar", Vector3(-0.08, 0.0, 0.08)],
		["girar", -70.0, 0.35], ["caminar", valeria.x, valeria.z],
		["girar", -25.0, 0.45],
		["anim", "pedir_entrada", 1], ["anim", "pedir", 2], ["atras", "pedir_entrada"],
		["quieto", 0.8],
	]
	position = valeria
	rotation.y = deg_to_rad(-25.0)
	_siguiente()


func _rumbo(desde: Vector3, hasta: Vector3) -> float:
	var d := hasta - desde
	return rad_to_deg(atan2(d.x, d.z))


func _siguiente() -> void:
	_i = (_i + 1) % _pasos.size()
	_t = 0.0
	_desde = position
	_giro_desde = rotation.y
	var p: Array = _pasos[_i]
	match p[0]:
		"quieto", "girar":
			if ap.current_animation != "quieto":
				reproducir("quieto")
		"caminar":
			reproducir("caminar")
		"saltar":
			reproducir("saltar")
		"anim":
			reproducir(p[1])
		"atras":
			reproducir(p[1], true)


func _rutina(delta: float) -> void:
	_t += delta
	var p: Array = _pasos[_i]
	var listo := false
	match p[0]:
		"quieto":
			listo = _t >= p[1]
		"girar":
			var u := clampf(_t / p[2], 0.0, 1.0)
			rotation.y = lerp_angle(_giro_desde, deg_to_rad(p[1]), smoothstep(0.0, 1.0, u))
			listo = u >= 1.0
		"caminar":
			var meta := Vector3(p[1], position.y, p[2])
			var d := meta - position
			var paso := velocidad() * delta
			if d.length() <= paso:
				position = meta
				listo = true
			else:
				position += d.normalized() * paso
		"saltar":
			position = arco_salto(_desde, p[1], _t)
			listo = _t >= duracion("saltar")
		"anim", "atras":
			listo = _t >= duracion(p[1]) * (p[2] if p[0] == "anim" else 1) - 0.02
	if listo:
		_siguiente()
