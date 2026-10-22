# PROTOTIPO: no es código del juego.
# Pregunta: ¿se ve vivo Felipe en 3D con su modelo de Meshy y la caminata de un animador?
# Fecha: 2026-10-22 (v6, retargeting)
# - Malla visible: Felipe de Meshy (assets/meshy_prueba/felipe_meshy.glb, CC BY 4.0).
# - Movimiento: el esqueleto y las curvas Idle y Walking del gato de Quaternius (CC0,
#   assets/pack/gato_quaternius.glb). Los huesos se mueven a puntos medidos en Felipe
#   (hombros, codos, patas, columna, cuello, cabeza y cola); la rotación de reposo de
#   cada hueso se toma de un cuadro del pack con la misma postura de patas que el
#   modelo, así las curvas (rotaciones locales) siguen valiendo. Las traslaciones
#   animadas se reescalan a la nueva altura.
# - Pesos por código: distancia a cada segmento de hueso con mezcla suave; la cabeza
#   entera va al hueso de la cabeza; cada pata toma su columna y el flanco hasta media
#   altura; la cola solo a sus huesos.
# - Capas encima (como v5): cola con retraso, respiración, cabeza que mira, inclinarse al
#   arrancar y frenar, mezclas de 0,2 s y salto por código dentro de ±8 %.
extends Node3D

const RUTA_PACK := "res://assets/pack/gato_quaternius.glb"
const RUTA_MALLA := "res://assets/meshy_prueba/felipe_meshy.glb"
## Unidades del pack por unidad de Meshy (solo cambia el tamaño interno).
const ESCALA_MESHY := 2.7
const DEFORMACION_MAXIMA := 0.08
const MEZCLA := 0.2
## Cuánto del giro de cada hueso de pata del pack se usa (brazo, antebrazo, mano).
const AMPLITUD_PATAS := [0.75, 0.7, 0.45]
const DUR_SALTAR := 1.2
const DESPEGUE := 0.40
const ATERRIZAJE := 0.88
const CABEZA := "Bone_003"
const COLA := ["Bone_004", "Bone_005", "Bone_006", "Bone_007"]
const PATAS := {
	"dd": ["Bone_014", "Bone_015", "Bone_016", "Bone_016_end"],
	"di": ["Bone_017", "Bone_018", "Bone_019", "Bone_019_end"],
	"ti": ["Bone_008", "Bone_009", "Bone_010", "Bone_010_end"],
	"td": ["Bone_011", "Bone_012", "Bone_013", "Bone_013_end"],
}
## Puntos de cada hueso medidos en la malla de Meshy (x lado, y arriba, z adelante).
## Patas: el lado x- de Meshy es el +z del pack (giro de 90°), por eso "dd" va en x-.
const PUNTOS := {
	"Bone": Vector3(0, -0.20, -0.30), "Bone_001": Vector3(0, -0.25, -0.05),
	"Bone_002": Vector3(0, -0.25, 0.28), "Bone_003": Vector3(0, -0.02, 0.40),
	"Bone_003_end": Vector3(0, 0.30, 0.92),
	"Bone_004": Vector3(0, -0.12, -0.55), "Bone_005": Vector3(0, 0.08, -0.64),
	"Bone_006": Vector3(0, 0.30, -0.67), "Bone_007": Vector3(0, 0.53, -0.73),
	"Bone_007_end": Vector3(0, 0.80, -0.64),
	"Bone_014": Vector3(-0.14, -0.32, 0.44), "Bone_015": Vector3(-0.14, -0.60, 0.51),
	"Bone_016": Vector3(-0.14, -0.765, 0.55), "Bone_016_end": Vector3(-0.14, -0.80, 0.66),
	"Bone_017": Vector3(0.13, -0.32, 0.40), "Bone_018": Vector3(0.13, -0.60, 0.39),
	"Bone_019": Vector3(0.13, -0.765, 0.37), "Bone_019_end": Vector3(0.13, -0.80, 0.48),
	"Bone_008": Vector3(0.20, -0.28, -0.26), "Bone_009": Vector3(0.21, -0.52, -0.13),
	"Bone_010": Vector3(0.21, -0.755, -0.20), "Bone_010_end": Vector3(0.21, -0.80, -0.08),
	"Bone_011": Vector3(-0.20, -0.28, -0.26), "Bone_012": Vector3(-0.21, -0.52, -0.13),
	"Bone_013": Vector3(-0.21, -0.755, -0.20), "Bone_013_end": Vector3(-0.21, -0.80, -0.08),
}

@export var alto := 67.0 / 121.0
@export var escala := 1.0
@export var giro_3_4 := 35.0
@export var usar_toon := true
@export var perfil_al_caminar := true
## Al caminar se gira un poco hacia la cámara (para ver la cara); la velocidad de
## avance en x se corrige con el coseno de este giro.
@export var giro_caminar := 20.0
@export var manual := false

var ap: AnimationPlayer
var sk: Skeleton3D
var giro: Node3D
var estira: Node3D
var mira_derecha := true
var caminando := false
var metros_por_unidad := 1.0
var _t := 0.0
var _t_sk := Transform3D()
var _vel_paso := 1.0
var _pos_antes := Vector3.ZERO
var _vel := 0.0
var _inclina := 0.0
var _mirar := 0.0
var _cola_lag := 0.0
var _huesos_capa: Array[int] = []


func _ready() -> void:
	_armar()
	_pos_antes = global_position
	ap.play("quieto")


func _process(delta: float) -> void:
	if not manual:
		avanzar(delta)


func reproducir(nombre: String, velocidad: float = 1.0) -> void:
	caminando = nombre == "caminar"
	if ap.current_animation != nombre:
		ap.play(nombre, MEZCLA)
	ap.speed_scale = velocidad


func velocidad_caminar() -> float:
	return _vel_paso * metros_por_unidad * escala * cos(deg_to_rad(giro_caminar if perfil_al_caminar else giro_3_4))


static func arco_salto(t: float) -> Vector2:
	var s := clampf((t - DESPEGUE) / (ATERRIZAJE - DESPEGUE), 0.0, 1.0)
	return Vector2(s, 4.0 * s * (1.0 - s))


func avanzar(delta: float) -> void:
	_t += delta
	var lado := (giro_caminar if perfil_al_caminar else giro_3_4) if caminando else giro_3_4
	var meta := -lado if mira_derecha else 180.0 + lado
	giro.rotation.y = lerp_angle(giro.rotation.y, deg_to_rad(meta), clampf(delta * 8.0, 0.0, 1.0))
	var v := (global_position - _pos_antes).length() / maxf(delta, 0.0001)
	_pos_antes = global_position
	var acel := (v - _vel) / maxf(delta, 0.0001)
	_vel = lerpf(_vel, v, clampf(delta * 10.0, 0.0, 1.0))
	_inclina = lerpf(_inclina, clampf(acel * 0.05, -0.1, 0.1), clampf(delta * 6.0, 0.0, 1.0))
	for b in _huesos_capa:
		sk.reset_bone_pose(b)
	ap.advance(delta)
	_capas(delta)


# ---------------------------------------------------------------- capas

func _capas(delta: float) -> void:
	# Patas cortas de persa: el giro de las patas del pack se suaviza hacia el reposo
	# (paso más corto), y la mano o el pie se dobla menos.
	for pata in PATAS:
		for i in 3:
			var b := sk.find_bone(PATAS[pata][i])
			var reposo := sk.get_bone_rest(b).basis.get_rotation_quaternion()
			sk.set_bone_pose_rotation(b, reposo.slerp(sk.get_bone_pose_rotation(b), AMPLITUD_PATAS[i]))
	var anim := ap.current_animation
	var quieto := anim == "quieto"
	var e := 1.0 + (0.012 * sin(_t * 2.6) if quieto else 0.0)
	var cabeceo := 0.0
	if anim == "saltar":
		var k := _claves_salto(ap.current_animation_position)
		e = k[0]
		cabeceo = k[1]
		_girar(sk.find_bone("Bone"), Vector3.BACK, k[1])
		for p in ["dd", "di"]:
			_girar(sk.find_bone(PATAS[p][0]), Vector3.BACK, k[2])
			_girar(sk.find_bone(PATAS[p][1]), Vector3.BACK, -k[2] * 0.8)
		for p in ["td", "ti"]:
			_girar(sk.find_bone(PATAS[p][0]), Vector3.BACK, k[3])
			_girar(sk.find_bone(PATAS[p][1]), Vector3.BACK, -k[3] * 0.6)
	e = clampf(e, 1.0 - DEFORMACION_MAXIMA, 1.0 + DEFORMACION_MAXIMA)
	estira.scale = Vector3(1.0 / sqrt(e), e, 1.0 / sqrt(e))
	_girar(sk.find_bone("Bone_001"), Vector3.BACK, -_inclina)
	var meta_mirar := (-0.35 if mira_derecha else 0.35) if quieto else 0.0
	_mirar = lerpf(_mirar, meta_mirar, clampf(delta * 2.5, 0.0, 1.0))
	var cab := sk.find_bone(CABEZA)
	_girar(cab, Vector3.UP, _mirar + 0.04 * sin(_t * 0.9))
	_girar(cab, Vector3.BACK, 0.03 * sin(_t * 1.3 + 0.5) - cabeceo * 0.6 + _inclina * 0.5)
	_cola_lag = lerpf(_cola_lag, -_inclina * 2.0, clampf(delta * 3.0, 0.0, 1.0))
	var amp := 0.14 if caminando else 0.08
	var frec := 3.8 if caminando else 1.6
	for i in COLA.size():
		var b := sk.find_bone(COLA[i])
		_girar(b, Vector3.UP, amp * sin(_t * frec - 0.7 * i))
		_girar(b, Vector3.BACK, _cola_lag * (0.4 + 0.2 * i) + 0.04 * sin(_t * frec * 0.5 - 0.5 * i))


func _claves_salto(t: float) -> Array:
	var c := [
		[0.00, 1.00, 0.0, 0.0, 0.0],
		[0.28, 0.92, -0.12, 0.25, -0.35],
		[0.40, 1.08, 0.30, -0.5, 0.6],
		[0.62, 1.00, 0.05, 0.7, -0.6],
		[0.84, 1.03, -0.25, -0.35, 0.3],
		[0.94, 0.92, -0.08, 0.15, -0.25],
		[1.20, 1.00, 0.0, 0.0, 0.0],
	]
	for i in c.size() - 1:
		if t <= c[i + 1][0]:
			var k := smoothstep(0.0, 1.0, (t - c[i][0]) / (c[i + 1][0] - c[i][0]))
			return [lerpf(c[i][1], c[i + 1][1], k), lerpf(c[i][2], c[i + 1][2], k),
				lerpf(c[i][3], c[i + 1][3], k), lerpf(c[i][4], c[i + 1][4], k)]
	return [1.0, 0.0, 0.0, 0.0]


func _girar(b: int, eje_modelo: Vector3, angulo: float) -> void:
	if b < 0 or absf(angulo) < 0.00001:
		return
	var eje := (_t_sk.basis.inverse() * eje_modelo).normalized()
	var padre := sk.get_bone_parent(b)
	var bp := sk.get_bone_global_pose(padre).basis.orthonormalized() if padre >= 0 else Basis()
	var local := Basis(sk.get_bone_pose_rotation(b))
	var nuevo := bp.inverse() * Basis(eje, angulo) * bp * local
	sk.set_bone_pose_rotation(b, nuevo.get_rotation_quaternion())


# ---------------------------------------------------------------- armado

## Meshy (x lado, y arriba, z adelante) -> espacio del modelo del pack (x adelante).
func _a_pack(m: Vector3, suelo: float) -> Vector3:
	return Vector3(m.z, m.y - suelo, -m.x) * ESCALA_MESHY


func _armar() -> void:
	giro = Node3D.new()
	giro.name = "Giro"
	add_child(giro)
	estira = Node3D.new()
	estira.name = "Estira"
	giro.add_child(estira)
	var base := Node3D.new()
	base.name = "Base"
	estira.add_child(base)
	var doc := GLTFDocument.new()
	var estado := GLTFState.new()
	doc.append_from_file(RUTA_PACK, estado)
	var escena: Node3D = doc.generate_scene(estado)
	base.add_child(escena)
	sk = escena.find_children("*", "Skeleton3D", true, false)[0]
	ap = escena.find_children("*", "AnimationPlayer", true, false)[0]
	ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	for viejo in escena.find_children("*", "MeshInstance3D", true, false):
		viejo.get_parent().remove_child(viejo)
		viejo.queue_free()
	_t_sk = _relativo(escena, sk)
	var t_sk_inv := _t_sk.affine_inverse()

	# Malla de Meshy.
	var doc2 := GLTFDocument.new()
	var estado2 := GLTFState.new()
	doc2.append_from_file(RUTA_MALLA, estado2)
	var esc2: Node3D = doc2.generate_scene(estado2)
	var mi_src: MeshInstance3D = esc2.find_children("*", "MeshInstance3D", true, false)[0]
	var t_src := _relativo(esc2, mi_src)
	var arr := mi_src.mesh.surface_get_arrays(0)
	var mat_src := mi_src.mesh.surface_get_material(0)
	if mi_src.get_surface_override_material(0):
		mat_src = mi_src.get_surface_override_material(0)
	esc2.free()
	var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var ns: PackedVector3Array = arr[Mesh.ARRAY_NORMAL]
	var suelo := INF
	for i in vs.size():
		vs[i] = t_src * vs[i]
		suelo = minf(suelo, vs[i].y)
	var alto_m := 0.0
	for v in vs:
		alto_m = maxf(alto_m, v.y - suelo)

	# 1. Rotaciones de reposo: el cuadro del pack cuyas patas se parecen más a Felipe.
	var t_rest := _cuadro_parecido(suelo)
	ap.play("CatArmature|Walking")
	ap.seek(t_rest, true)
	var rot_rest: Array[Quaternion] = []
	for i in sk.get_bone_count():
		rot_rest.append(sk.get_bone_pose_rotation(i))
	var pos_vieja: Array[Vector3] = []
	for i in sk.get_bone_count():
		pos_vieja.append(sk.get_bone_rest(i).origin)

	# 2. Huesos en los puntos de Felipe (espacio del esqueleto).
	var glob: Array[Transform3D] = []
	glob.resize(sk.get_bone_count())
	for i in sk.get_bone_count():
		var nombre := sk.get_bone_name(i)
		var padre := sk.get_bone_parent(i)
		var gp := glob[padre] if padre >= 0 else Transform3D()
		var local := Transform3D(Basis(rot_rest[i]), sk.get_bone_rest(i).origin)
		if PUNTOS.has(nombre):
			var meta := t_sk_inv * _a_pack(PUNTOS[nombre], suelo)
			local.origin = gp.affine_inverse() * meta
		sk.set_bone_rest(i, local)
		glob[i] = gp * local
	sk.reset_bone_poses()
	# Las traslaciones animadas (raíz y patas) se reescalan con la nueva altura.
	var k_alto := (PUNTOS["Bone"].y - suelo) * ESCALA_MESHY / 2.2155
	for nombre_anim in ap.get_animation_list():
		var a := ap.get_animation(nombre_anim)
		for t in a.get_track_count():
			if a.track_get_type(t) != Animation.TYPE_POSITION_3D:
				continue
			var hueso := String(a.track_get_path(t).get_concatenated_subnames())
			var b := sk.find_bone(hueso)
			if b < 0:
				continue
			var nueva := sk.get_bone_rest(b).origin
			for kk in a.track_get_key_count(t):
				var p: Vector3 = a.track_get_key_value(t, kk)
				a.track_set_key_value(t, kk, nueva + (p - pos_vieja[b]) * k_alto)

	# 3. Pesos sobre la malla de Meshy (en su espacio, con los mismos puntos).
	var huesos := PackedInt32Array()
	var pesos := PackedFloat32Array()
	huesos.resize(vs.size() * 4)
	pesos.resize(vs.size() * 4)
	var seg_cuerpo := [["Bone", "Bone_001"], ["Bone_001", "Bone_002"], ["Bone_002", "Bone_003"]]
	var centro_cab := Vector3(0, 0.32, 0.55)
	for vi in vs.size():
		var v := vs[vi]
		var lista: Array = []
		# Cuerpo (3 huesos de la columna), cerca de su segmento.
		for sg in seg_cuerpo:
			var d := v.distance_to(Geometry3D.get_closest_point_to_segment(v, PUNTOS[sg[0]], PUNTOS[sg[1]]))
			lista.append([sk.find_bone(sg[0]), 1.0 / pow(maxf(d, 0.02), 4.0)])
		_normalizar(lista)
		# Cabeza entera al hueso de la cabeza (con un cuello corto de mezcla).
		var en_cab := 1.0 - smoothstep(0.38, 0.48, v.distance_to(centro_cab))
		en_cab = maxf(en_cab, smoothstep(-0.12, 0.02, v.y) * smoothstep(0.25, 0.38, v.z))
		_mezclar(lista, sk.find_bone(CABEZA), en_cab)
		# Cola: detrás y arriba.
		var en_cola := smoothstep(-0.44, -0.54, v.z) * smoothstep(-0.25, -0.12, v.y)
		if en_cola > 0.0:
			var sub: Array = []
			var cadena := COLA + ["Bone_007_end"]
			for i in COLA.size():
				var d := v.distance_to(Geometry3D.get_closest_point_to_segment(v, PUNTOS[cadena[i]], PUNTOS[cadena[i + 1]]))
				sub.append([sk.find_bone(cadena[i]), 1.0 / pow(maxf(d, 0.02), 4.0)])
			_normalizar(sub)
			_mezclar_lista(lista, sub, en_cola)
		# Patas: su columna bajo la panza y el flanco hasta media altura del torso.
		var delante := v.z > 0.12
		var pata := ("d" if delante else "t") + ("d" if v.x < 0.0 else "i")
		var nombres: Array = PATAS[pata]
		var pie: Vector3 = PUNTOS[nombres[2]]
		var hombro: Vector3 = PUNTOS[nombres[0]]
		var dxz := Vector2(v.x - pie.x, v.z - (pie.z + hombro.z) * 0.5).length()
		var y_panza := -0.62 if not delante else -0.66
		var abajo := 1.0 - smoothstep(0.10, 0.17, dxz)
		var flanco := (1.0 - smoothstep(0.14, 0.26, absf(v.z - hombro.z))) * smoothstep(0.08, 0.2, absf(v.x))
		var arriba := smoothstep(y_panza - 0.04, y_panza + 0.06, v.y)
		var wl := lerpf(abajo, flanco, arriba) * (1.0 - smoothstep(y_panza, hombro.y + 0.05, v.y)) * (1.0 - en_cab) * (1.0 - en_cola)
		if wl > 0.001:
			var sub: Array = []
			for i in 3:
				var d := v.distance_to(Geometry3D.get_closest_point_to_segment(v, PUNTOS[nombres[i]], PUNTOS[nombres[i + 1]]))
				sub.append([sk.find_bone(nombres[i]), 1.0 / pow(maxf(d, 0.015), 4.0)])
			_normalizar(sub)
			_mezclar_lista(lista, sub, wl)
		lista.sort_custom(func(m: Array, n: Array) -> bool: return m[1] > n[1])
		var total := 0.0
		for j in mini(4, lista.size()):
			total += lista[j][1]
		for j in 4:
			huesos[vi * 4 + j] = lista[j][0] if j < lista.size() else 0
			pesos[vi * 4 + j] = lista[j][1] / total if j < lista.size() else 0.0
		# Vértices al espacio del esqueleto.
		vs[vi] = t_sk_inv * _a_pack(v, suelo)
		var nw := t_src.basis * ns[vi]
		ns[vi] = (t_sk_inv.basis * Vector3(nw.z, nw.y, -nw.x)).normalized()

	var nuevo: Array = []
	nuevo.resize(Mesh.ARRAY_MAX)
	nuevo[Mesh.ARRAY_VERTEX] = vs
	nuevo[Mesh.ARRAY_NORMAL] = ns
	nuevo[Mesh.ARRAY_TEX_UV] = arr[Mesh.ARRAY_TEX_UV]
	nuevo[Mesh.ARRAY_INDEX] = arr[Mesh.ARRAY_INDEX]
	nuevo[Mesh.ARRAY_BONES] = huesos
	nuevo[Mesh.ARRAY_WEIGHTS] = pesos
	var malla := ArrayMesh.new()
	malla.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, nuevo)
	var piel := Skin.new()
	for i in sk.get_bone_count():
		piel.add_named_bind(sk.get_bone_name(i), sk.get_bone_global_rest(i).affine_inverse())
	var mi := MeshInstance3D.new()
	mi.name = "FelipeMeshy"
	mi.mesh = malla
	mi.skin = piel
	sk.add_child(mi)
	mi.skeleton = mi.get_path_to(sk)
	var tex: Texture2D = (mat_src as BaseMaterial3D).albedo_texture if mat_src is BaseMaterial3D else null
	if usar_toon:
		var mt := Toon.material(Color.WHITE)
		mt.set_shader_parameter("usar_textura", true)
		mt.set_shader_parameter("textura", tex)
		mi.material_override = mt
	else:
		var std := StandardMaterial3D.new()
		std.albedo_texture = tex
		std.roughness = 0.8
		mi.material_override = std

	metros_por_unidad = alto / (alto_m * ESCALA_MESHY)
	base.scale = Vector3.ONE * metros_por_unidad * escala

	var idle := ap.get_animation("CatArmature|Idle")
	idle.loop_mode = Animation.LOOP_LINEAR
	var walk := ap.get_animation("CatArmature|Walking")
	walk.loop_mode = Animation.LOOP_LINEAR
	var salto := idle.duplicate() as Animation
	salto.loop_mode = Animation.LOOP_NONE
	salto.length = DUR_SALTAR
	var lib := ap.get_animation_library("")
	lib.add_animation("quieto", idle)
	lib.add_animation("caminar", walk)
	lib.add_animation("saltar", salto)
	for b in ["Bone", "Bone_001", CABEZA] + COLA:
		_huesos_capa.append(sk.find_bone(b))
	for pata in PATAS:
		_huesos_capa.append(sk.find_bone(PATAS[pata][0]))
		_huesos_capa.append(sk.find_bone(PATAS[pata][1]))
	_vel_paso = _medir_paso()


## Tiempo de la caminata del pack con las patas más parecidas a las de Felipe en reposo
## (dirección hombro -> pata de cada una, de perfil).
func _cuadro_parecido(suelo: float) -> float:
	ap.play("CatArmature|Walking")
	var largo := ap.current_animation_length
	var mejor := 0.0
	var costo_min := INF
	for i in 80:
		var t := largo * i / 80.0
		ap.seek(t, true)
		sk.force_update_all_bone_transforms()
		var costo := 0.0
		for pata in PATAS:
			var n: Array = PATAS[pata]
			var a := _t_sk * sk.get_bone_global_pose(sk.find_bone(n[0])).origin
			var b := _t_sk * sk.get_bone_global_pose(sk.find_bone(n[2])).origin
			var ma := _a_pack(PUNTOS[n[0]], suelo)
			var mb := _a_pack(PUNTOS[n[2]], suelo)
			var da := Vector2(b.x - a.x, b.y - a.y).angle()
			var dm := Vector2(mb.x - ma.x, mb.y - ma.y).angle()
			costo += pow(angle_difference(da, dm), 2.0)
		if costo < costo_min:
			costo_min = costo
			mejor = t
	print("felipe_meshy: reposo en t=%.2f s de Walking (error %.1f°)" % [mejor, rad_to_deg(sqrt(costo_min / 4.0))])
	return mejor


func _medir_paso() -> float:
	ap.play("caminar")
	var largo := ap.current_animation_length
	var n := 60
	var pie := sk.find_bone(PATAS["dd"][2])
	var xs: Array[float] = []
	var ys: Array[float] = []
	for i in n:
		ap.seek(largo * i / n, true)
		_capas(0.0)
		sk.force_update_all_bone_transforms()
		var p := _t_sk * sk.get_bone_global_pose(pie).origin
		xs.append(p.x)
		ys.append(p.y)
	var y_min: float = ys.min()
	var rango: float = ys.max() - y_min
	var vels: Array[float] = []
	for i in n:
		var j := (i + 1) % n
		if ys[i] < y_min + 0.15 * rango and ys[j] < y_min + 0.15 * rango:
			vels.append(-(xs[j] - xs[i]) / (largo / n))
	vels.sort()
	ap.play("quieto")
	return absf(vels[vels.size() / 2]) if vels.size() > 0 else 1.0


func _normalizar(l: Array) -> void:
	var s := 0.0
	for e in l:
		s += e[1]
	for e in l:
		e[1] /= maxf(s, 1e-9)


func _mezclar(l: Array, hueso: int, w: float) -> void:
	if w <= 0.0:
		return
	for e in l:
		e[1] *= 1.0 - w
	l.append([hueso, w])


func _mezclar_lista(l: Array, sub: Array, w: float) -> void:
	for e in l:
		e[1] *= 1.0 - w
	for e in sub:
		l.append([e[0], e[1] * w])


func _relativo(raiz: Node3D, nodo: Node3D) -> Transform3D:
	var t := Transform3D()
	var n: Node = nodo
	while n != raiz and n is Node3D:
		t = (n as Node3D).transform * t
		n = n.get_parent()
	return t
