# PROTOTIPO: no es código del juego.
# Pregunta: ¿se ve vivo Felipe en 3D si parte de un gato animado por un animador?
# Fecha: 2026-10-22 (v5)
# Base: el gato de "Animal Pack Vol.2" de Quaternius (CC0), con sus animaciones Idle y
# Walking hechas a mano (no se tocan sus curvas). Encima, por código:
# - Forma de Felipe (persa chibi) editando la malla en su pose de reposo: cabeza ×1,8 y
#   hocico achatado, cuerpo más gordo, cola esponjada, patas más gruesas; las patas se
#   acortan con la escala del hueso del hombro y la cadera (y el gato baja al piso).
# - Colores y cara pintados por píxel (shaders/felipe_pack.gdshader) según la posición de
#   reposo, que se guarda en UV y UV2.
# - Capas sutiles al estilo Stray: cola que sigue el movimiento con retraso y se mece en
#   quieto, cabeza que mira hacia la cámara en quieto y se suaviza, respiración, el cuerpo
#   se adelanta al arrancar y se atrasa al frenar; mezclas de 0,2 s entre animaciones.
# - Salto (el pack no trae): anticipación, impulso, recogida, caída y amortiguación con
#   estirar y aplastar dentro de ±8 %.
extends Node3D

const RUTA := "res://assets/pack/gato_quaternius.glb"
const SHADER := preload("res://shaders/felipe_pack.gdshader")
const ESCALA_CABEZA := 2.5
const ENGORDE := 1.45
const COLA_ESPONJA := 2.6
const PATA_CORTA := 0.72
const PATA_GROSOR := 2.3
const DEFORMACION_MAXIMA := 0.08
const MEZCLA := 0.2
const DUR_SALTAR := 1.2
const DESPEGUE := 0.40
const ATERRIZAJE := 0.88
const CABEZA := "Bone_003"
const CUERPO := ["Bone", "Bone_001", "Bone_002"]
const COLA := ["Bone_004", "Bone_005", "Bone_006", "Bone_007"]
const PATAS := {
	"dd": ["Bone_014", "Bone_015", "Bone_016", "Bone_016_end"],
	"di": ["Bone_017", "Bone_018", "Bone_019", "Bone_019_end"],
	"ti": ["Bone_008", "Bone_009", "Bone_010", "Bone_010_end"],
	"td": ["Bone_011", "Bone_012", "Bone_013", "Bone_013_end"],
}

## Alto total (con la cola): 67 px = 0,554 m; `escala` lo agranda.
@export var alto := 67.0 / 121.0
@export var escala := 1.0
@export var giro_3_4 := 35.0
@export var usar_toon := true
## Al caminar se pone de perfil (las patas no patinan de lado).
@export var perfil_al_caminar := true
## Si es true, lo avanza otro script con avanzar(dt).
@export var manual := false

var ap: AnimationPlayer
var sk: Skeleton3D
var giro: Node3D
var estira: Node3D
var mira_derecha := true
var caminando := false
var metros_por_unidad := 1.0
var _t := 0.0
var _t_sk := Transform3D()   # esqueleto -> modelo
var _vel_paso := 1.0         # unidades del modelo por segundo con la caminata a ritmo 1
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


## Metros por segundo que avanza la caminata del pack con ritmo 1 (sin patinar).
func velocidad_caminar() -> float:
	return _vel_paso * metros_por_unidad * escala


static func arco_salto(t: float) -> Vector2:
	var s := clampf((t - DESPEGUE) / (ATERRIZAJE - DESPEGUE), 0.0, 1.0)
	return Vector2(s, 4.0 * s * (1.0 - s))


func avanzar(delta: float) -> void:
	_t += delta
	var lado := 0.0 if (caminando and perfil_al_caminar) else giro_3_4
	var meta := -lado if mira_derecha else 180.0 + lado
	giro.rotation.y = lerp_angle(giro.rotation.y, deg_to_rad(meta), clampf(delta * 8.0, 0.0, 1.0))
	# Velocidad y aceleración propias (para inclinarse al arrancar y frenar).
	var v := (global_position - _pos_antes).length() / maxf(delta, 0.0001)
	_pos_antes = global_position
	var acel := (v - _vel) / maxf(delta, 0.0001)
	_vel = lerpf(_vel, v, clampf(delta * 10.0, 0.0, 1.0))
	_inclina = lerpf(_inclina, clampf(acel * 0.05, -0.12, 0.12), clampf(delta * 6.0, 0.0, 1.0))
	for b in _huesos_capa:
		sk.reset_bone_pose(b)
	ap.advance(delta)
	_patas_cortas()
	_capas(delta)


# ---------------------------------------------------------------- capas

func _capas(delta: float) -> void:
	var anim := ap.current_animation
	var quieto := anim == "quieto"
	# Respiración (quieto) y estirar y aplastar del salto.
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
	# El cuerpo se adelanta al arrancar y se atrasa al frenar.
	_girar(sk.find_bone("Bone_001"), Vector3.BACK, -_inclina)
	# Cabeza: en quieto mira hacia la cámara (lado de la pantalla), suave; al caminar al
	# frente; compensa el cabeceo del salto.
	var meta_mirar := (-0.45 if mira_derecha else 0.45) if quieto else 0.0
	_mirar = lerpf(_mirar, meta_mirar, clampf(delta * 2.5, 0.0, 1.0))
	var cab := sk.find_bone(CABEZA)
	_girar(cab, Vector3.UP, _mirar + 0.04 * sin(_t * 0.9))
	_girar(cab, Vector3.BACK, 0.03 * sin(_t * 1.3 + 0.5) - cabeceo * 0.6 + _inclina * 0.5)
	# Cola: onda que viaja a la punta, más amplia al caminar, y se atrasa al acelerar.
	_cola_lag = lerpf(_cola_lag, -_inclina * 2.0, clampf(delta * 3.0, 0.0, 1.0))
	var amp := 0.16 if caminando else 0.09
	var frec := 3.8 if caminando else 1.6
	for i in COLA.size():
		var b := sk.find_bone(COLA[i])
		_girar(b, Vector3.UP, amp * sin(_t * frec - 0.7 * i))
		_girar(b, Vector3.BACK, _cola_lag * (0.4 + 0.2 * i) + 0.04 * sin(_t * frec * 0.5 - 0.5 * i))


## [estirar, cabeceo del cuerpo, patas delanteras, patas traseras] en el tiempo t.
func _claves_salto(t: float) -> Array:
	var c := [
		[0.00, 1.00, 0.0, 0.0, 0.0],
		[0.28, 0.92, -0.12, 0.25, -0.35],   # anticipación: se agacha, mira al frente
		[0.40, 1.08, 0.30, -0.5, 0.6],      # impulso: se estira, patas atrás
		[0.62, 1.00, 0.05, 0.7, -0.6],      # recoge las patas
		[0.84, 1.03, -0.25, -0.35, 0.3],    # delanteras abajo para caer
		[0.94, 0.92, -0.08, 0.15, -0.25],   # amortigua
		[1.20, 1.00, 0.0, 0.0, 0.0],
	]
	for i in c.size() - 1:
		if t <= c[i + 1][0]:
			var k := smoothstep(0.0, 1.0, (t - c[i][0]) / (c[i + 1][0] - c[i][0]))
			return [lerpf(c[i][1], c[i + 1][1], k), lerpf(c[i][2], c[i + 1][2], k),
				lerpf(c[i][3], c[i + 1][3], k), lerpf(c[i][4], c[i + 1][4], k)]
	return [1.0, 0.0, 0.0, 0.0]


## Gira un hueso alrededor de un eje del modelo (x adelante, y arriba, z lado), encima
## de lo que ya tenga.
func _girar(b: int, eje_modelo: Vector3, angulo: float) -> void:
	if b < 0 or absf(angulo) < 0.00001:
		return
	var eje := (_t_sk.basis.inverse() * eje_modelo).normalized()
	var padre := sk.get_bone_parent(b)
	var bp := sk.get_bone_global_pose(padre).basis.orthonormalized() if padre >= 0 else Basis()
	var local := Basis(sk.get_bone_pose_rotation(b))
	var nuevo := bp.inverse() * Basis(eje, angulo) * bp * local
	sk.set_bone_pose_rotation(b, nuevo.get_rotation_quaternion())


func _patas_cortas() -> void:
	for p in PATAS:
		sk.set_bone_pose_scale(sk.find_bone(PATAS[p][0]), Vector3.ONE * PATA_CORTA)


# ---------------------------------------------------------------- armado

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
	doc.append_from_file(RUTA, estado)
	var escena: Node3D = doc.generate_scene(estado)
	base.add_child(escena)
	sk = escena.find_children("*", "Skeleton3D", true, false)[0]
	ap = escena.find_children("*", "AnimationPlayer", true, false)[0]
	var mi: MeshInstance3D = escena.find_children("*", "MeshInstance3D", true, false)[0]
	_t_sk = _relativo(escena, sk)
	var t_mi := _relativo(escena, mi)
	var t_mi_inv := t_mi.affine_inverse()

	# Huesos en reposo, en el espacio del modelo.
	var g := {}
	for i in sk.get_bone_count():
		g[sk.get_bone_name(i)] = (_t_sk * sk.get_bone_global_rest(i)).origin
	var hueso_de := {}  # índice de bind de la piel -> nombre de hueso
	var piel := mi.skin
	for i in piel.get_bind_count():
		var nombre := String(piel.get_bind_name(i))
		hueso_de[i] = nombre if nombre != "" else sk.get_bone_name(piel.get_bind_bone(i))

	# Leer todas las superficies.
	var malla := mi.mesh
	var sup: Array = []
	for s in malla.get_surface_count():
		sup.append(malla.surface_get_arrays(s))
	# Centro de la cabeza: a media distancia entre el cuello y la punta del hueso.
	var hc: Vector3 = (g[CABEZA] + g[CABEZA + "_end"]) * 0.5
	var r_cab := 0.0
	for arr in sup:
		var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		var bo: PackedInt32Array = arr[Mesh.ARRAY_BONES]
		var we: PackedFloat32Array = arr[Mesh.ARRAY_WEIGHTS]
		var n := bo.size() / vs.size()
		for vi in vs.size():
			if _peso(bo, we, n, vi, hueso_de, [CABEZA, CABEZA + "_end"]) > 0.9:
				var d := t_mi * vs[vi] - hc
				if d.y < 0.3:  # sin orejas
					r_cab = maxf(r_cab, Vector2(d.y, d.z).length())
	var cola_pts: Array[Vector3] = []
	for b in COLA:
		cola_pts.append(g[b])
	cola_pts.append(g["Bone_007_end"])
	var y_centro_cuerpo := 1.95

	# Editar la malla en reposo.
	var nueva := ArrayMesh.new()
	var cab_min := Vector3(INF, INF, INF)
	var cab_max := -Vector3(INF, INF, INF)
	var y_max := -INF
	for s in sup.size():
		var arr: Array = sup[s]
		var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		var bo: PackedInt32Array = arr[Mesh.ARRAY_BONES]
		var we: PackedFloat32Array = arr[Mesh.ARRAY_WEIGHTS]
		var n := bo.size() / vs.size()
		var uv := PackedVector2Array()
		var uv2 := PackedVector2Array()
		uv.resize(vs.size())
		uv2.resize(vs.size())
		for vi in vs.size():
			var p := t_mi * vs[vi]
			var w_cab := _peso(bo, we, n, vi, hueso_de, [CABEZA, CABEZA + "_end"])
			var w_cue := _peso(bo, we, n, vi, hueso_de, CUERPO)
			var w_col := _peso(bo, we, n, vi, hueso_de, COLA + ["Bone_007_end"])
			var q := p
			# Cabeza grande y redonda, hocico achatado (persa).
			if w_cab > 0.0:
				var d := (p - hc) * (1.0 + (ESCALA_CABEZA - 1.0) * w_cab)
				var r := r_cab * ESCALA_CABEZA
				# Redondear (persa): la cabeza low poly se acerca a una esfera, salvo
				# las orejas, que siguen saliendo arriba.
				var largo := d.length()
				if largo > 0.0001:
					var arriba := clampf((d.y / largo - 0.45) / 0.25, 0.0, 1.0)
					var hacia := 0.65 * w_cab * (1.0 - arriba)
					d = d / largo * lerpf(largo, r, hacia)
				# Hocico achatado.
				if d.x > 0.8 * r:
					d.x = lerpf(d.x, 0.8 * r + (d.x - 0.8 * r) * 0.3, w_cab)
				q = hc + d
				if w_cab > 0.8 and d.y < 0.5 * r:
					cab_min = cab_min.min(q)
					cab_max = cab_max.max(q)
			# Cuerpo más gordo (alrededor del eje del tronco).
			if w_cue > 0.0:
				var eje := Vector3(q.x, y_centro_cuerpo, 0.0)
				var f := 1.0 + (ENGORDE - 1.0) * w_cue
				q = eje + Vector3(0.0, (q.y - eje.y) * f, q.z * f)
			# Cola esponjada.
			if w_col > 0.0:
				var c := _mas_cerca(q, cola_pts)
				q = c + (q - c) * (1.0 + (COLA_ESPONJA - 1.0) * w_col)
			# Patas más gruesas (se acortan con la escala del hueso).
			for pata in PATAS:
				var w_p := _peso(bo, we, n, vi, hueso_de, PATAS[pata])
				if w_p > 0.0:
					var pts: Array[Vector3] = []
					for b in PATAS[pata]:
						pts.append(g[b])
					var c := _mas_cerca(q, pts)
					q = c + (q - c) * (1.0 + (PATA_GROSOR - 1.0) * w_p)
			vs[vi] = t_mi_inv * q
			uv[vi] = Vector2(q.x, q.y)
			uv2[vi] = Vector2(q.z, 0.0)
			y_max = maxf(y_max, q.y)
		var nuevo: Array = []
		nuevo.resize(Mesh.ARRAY_MAX)
		nuevo[Mesh.ARRAY_VERTEX] = vs
		nuevo[Mesh.ARRAY_NORMAL] = _normales_suaves(vs, arr[Mesh.ARRAY_INDEX])
		nuevo[Mesh.ARRAY_TEX_UV] = uv
		nuevo[Mesh.ARRAY_TEX_UV2] = uv2
		nuevo[Mesh.ARRAY_BONES] = bo
		nuevo[Mesh.ARRAY_WEIGHTS] = we
		nuevo[Mesh.ARRAY_INDEX] = arr[Mesh.ARRAY_INDEX]
		var banderas := Mesh.ARRAY_FLAG_USE_8_BONE_WEIGHTS if n == 8 else 0
		nueva.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, nuevo, [], {}, banderas)
	mi.mesh = nueva

	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	# Cabeza medida ya editada: centro y radios para pintar la cara.
	var rad := (cab_max - cab_min) * 0.5
	var c_cab := Vector3(cab_max.x - rad.z, cab_min.y + rad.z, (cab_min.z + cab_max.z) * 0.5)
	mat.set_shader_parameter("centro_cabeza", c_cab)
	mat.set_shader_parameter("radio_cabeza", rad.z)
	mat.set_shader_parameter("x_cola", g["Bone_004"].x + 0.1)
	mat.set_shader_parameter("y_lomo", g["Bone_004"].y)
	var lomo: Vector3 = g["Bone"]
	# Manchas grandes del lomo: una sobre las caderas y otra sobre los hombros.
	var y_lomo_alto := y_centro_cuerpo + (lomo.y + 0.25 - y_centro_cuerpo) * ENGORDE
	mat.set_shader_parameter("mancha0_c", Vector3(lomo.x - 0.05, y_lomo_alto + 0.15, 0.0))
	mat.set_shader_parameter("mancha0_r", 0.8)
	mat.set_shader_parameter("mancha1_c", Vector3(g["Bone_002"].x - 0.35, y_lomo_alto + 0.2, 0.0))
	mat.set_shader_parameter("mancha1_r", 0.6)
	if usar_toon:
		Toon.materiales.append(mat)
	else:
		mat.set_shader_parameter("escalones", false)
		mat.set_shader_parameter("ambiente_suave", 1.0)
	mi.material_override = mat
	if OS.get_environment("DEPURAR") != "":
		mat.set_shader_parameter("depurar", int(OS.get_environment("DEPURAR")))

	# Patas cortas: el gato baja hasta que la pata más baja toca el piso.
	var y_pie := INF
	for pata in PATAS:
		var r: Vector3 = g[PATAS[pata][0]]
		var e: Vector3 = g[PATAS[pata][3]]
		y_pie = minf(y_pie, r.y + (e.y - r.y) * PATA_CORTA)
	var alto_u := y_max - y_pie
	metros_por_unidad = alto / alto_u
	base.scale = Vector3.ONE * metros_por_unidad * escala
	base.position.y = -y_pie * metros_por_unidad * escala

	# Animaciones con nombre propio, en bucle; el salto parte de la pose de quieto.
	var idle := ap.get_animation("CatArmature|Idle").duplicate() as Animation
	idle.loop_mode = Animation.LOOP_LINEAR
	var walk := ap.get_animation("CatArmature|Walking").duplicate() as Animation
	walk.loop_mode = Animation.LOOP_LINEAR
	var salto := ap.get_animation("CatArmature|Idle").duplicate() as Animation
	salto.loop_mode = Animation.LOOP_NONE
	salto.length = DUR_SALTAR
	var lib := ap.get_animation_library("")
	lib.add_animation("quieto", idle)
	lib.add_animation("caminar", walk)
	lib.add_animation("saltar", salto)
	ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL

	for b in ["Bone", "Bone_001", CABEZA] + COLA:
		_huesos_capa.append(sk.find_bone(b))
	for pata in PATAS:
		_huesos_capa.append(sk.find_bone(PATAS[pata][0]))
		_huesos_capa.append(sk.find_bone(PATAS[pata][1]))
	_vel_paso = _medir_paso()


## Velocidad de la pata apoyada respecto del cuerpo en la caminata (unidades/s).
func _medir_paso() -> float:
	ap.play("caminar")
	var largo := ap.current_animation_length
	var n := 60
	var pie := sk.find_bone(PATAS["dd"][3])
	var xs: Array[float] = []
	var ys: Array[float] = []
	for i in n:
		ap.seek(largo * i / n, true)
		_patas_cortas()
		sk.force_update_all_bone_transforms()
		var p := _t_sk * sk.get_bone_global_pose(pie).origin
		xs.append(p.x)
		ys.append(p.y)
	var y_min: float = ys.min()
	var vels: Array[float] = []
	for i in n:
		var j := (i + 1) % n
		if ys[i] < y_min + 0.08 and ys[j] < y_min + 0.08:
			vels.append(-(xs[j] - xs[i]) / (largo / n))
	vels.sort()
	ap.play("quieto")
	return absf(vels[vels.size() / 2]) if vels.size() > 0 else 1.0


func _peso(bo: PackedInt32Array, we: PackedFloat32Array, n: int, vi: int, hueso_de: Dictionary, nombres: Array) -> float:
	var w := 0.0
	for j in n:
		if we[vi * n + j] > 0.0 and String(hueso_de.get(bo[vi * n + j], "")) in nombres:
			w += we[vi * n + j]
	return w


func _mas_cerca(p: Vector3, pts: Array[Vector3]) -> Vector3:
	var mejor := pts[0]
	var dm := INF
	for i in pts.size() - 1:
		var c := Geometry3D.get_closest_point_to_segment(p, pts[i], pts[i + 1])
		var d := p.distance_squared_to(c)
		if d < dm:
			dm = d
			mejor = c
	return mejor


## Normales suaves: promedio de las caras que comparten cada posición.
func _normales_suaves(vs: PackedVector3Array, idx) -> PackedVector3Array:
	var ind := PackedInt32Array()
	if idx == null or (idx as PackedInt32Array).size() == 0:
		for i in vs.size():
			ind.append(i)
	else:
		ind = idx
	var suma := {}
	for t in range(0, ind.size(), 3):
		var a := vs[ind[t]]
		var b := vs[ind[t + 1]]
		var c := vs[ind[t + 2]]
		var nf := (c - a).cross(b - a)  # orden de Godot (horario)
		for k in 3:
			var clave := Vector3i((vs[ind[t + k]] * 100000.0).round())
			suma[clave] = suma.get(clave, Vector3.ZERO) + nf
	var nor := PackedVector3Array()
	nor.resize(vs.size())
	for i in vs.size():
		var s: Vector3 = suma.get(Vector3i((vs[i] * 100000.0).round()), Vector3.UP)
		nor[i] = s.normalized() if s.length() > 0.0 else Vector3.UP
	return nor


func _relativo(raiz: Node3D, nodo: Node3D) -> Transform3D:
	var t := Transform3D()
	var n: Node = nodo
	while n != raiz and n is Node3D:
		t = (n as Node3D).transform * t
		n = n.get_parent()
	return t
