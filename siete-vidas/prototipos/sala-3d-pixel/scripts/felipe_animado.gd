# PROTOTIPO: no es código del juego.
# Pregunta: ¿se puede animar a Felipe 3D (modelo IA coloreado) con un esqueleto simple?
# Fecha: 2026-10-22 (v2: patas más largas, columna y cola flexibles, pies sin resbalar)
# Toma `felipe_color_patas.glb` (sin huesos; patas alargadas un 60 %), le arma por código
# un esqueleto de cuadrúpedo midiendo la malla y hornea 3 animaciones:
# - Huesos: raíz, columna de 3 (caderas, medio, hombros), cabeza, cola de 5 y 4 patas de 2.
# - Pesos: cada vértice a sus 2 huesos más cercanos (distancia a la superficie del hueso),
#   sin cruzar de lado ni de mitad en las patas.
# - Patas por cinemática inversa de 2 huesos: la pata apoyada queda quieta respecto del
#   piso y la que avanza se levanta y se dobla.
# "quieto" (respira, cola lenta), "caminar" (diagonales, 0,8 s, columna en S, cola en onda)
# y "saltar" (1,2 s: se agacha, se estira, recoge, cae con las delanteras y amortigua).
extends Node3D

const RUTA := "res://assets/local3d/texturizados/felipe_color_patas.glb"
const DUR_CAMINAR := 0.8
const DUR_SALTAR := 1.2
const DUR_QUIETO := 3.2
## Fracción del ciclo con la pata apoyada (el resto, en el aire avanzando).
const APOYO := 0.62
## Tramo del salto en el aire (segundos dentro de "saltar"): despega y aterriza.
const DESPEGUE := 0.40
const ATERRIZAJE := 0.88
## Estirar y aplastar como mucho ±8 % (regla de Felipe).
const DEFORMACION_MAXIMA := 0.08
const PATAS := ["di", "dd", "ti", "td"]  # delantera/trasera, izquierda/derecha
const COLA := ["cola1", "cola2", "cola3", "cola4", "cola5"]

## Metros por unidad de la malla: con esto Felipe mide 67 px (0,554 m) como antes de
## alargarle las patas; `escala` lo agranda (1,3 = 30 % más grande).
@export var metros_por_unidad := (67.0 / 121.0) / 1.977
@export var escala := 1.0
## Giro hacia la cámara cuando está quieto o saltando (al caminar va de perfil, para
## que las patas apoyadas no resbalen de lado).
@export var giro_3_4 := 35.0
@export var usar_toon := true

var ap: AnimationPlayer
var sk: Skeleton3D
var giro: Node3D
var estira: Node3D
var mira_derecha := true
var caminando := false
var _rest: Dictionary = {}    # hueso -> posición de reposo local
var _padre: Dictionary = {}   # hueso -> padre ("" en la raíz)
var _orden: Array[String] = []
var _suelo := 0.0
var _pie: Dictionary = {}     # pata -> posición del pie en reposo (unidades de la malla)
var _l1 := 0.1
var _l2 := 0.1
var _paso := 0.2              # largo del paso (unidades de la malla)


func _ready() -> void:
	_armar()
	_hornear_animaciones()
	ap.play("quieto")


func _process(delta: float) -> void:
	var lado := 90.0 if caminando else 90.0 - giro_3_4
	var meta := lado if mira_derecha else -lado
	giro.rotation.y = lerp_angle(giro.rotation.y, deg_to_rad(meta), clampf(delta * 10.0, 0.0, 1.0))


func reproducir(nombre: String, velocidad: float = 1.0) -> void:
	caminando = nombre == "caminar"
	if ap.current_animation != nombre:
		ap.play(nombre, 0.12, velocidad)
	ap.speed_scale = velocidad


## Metros por segundo que avanza al caminar con ritmo 1: así los pies no resbalan.
func velocidad_caminar() -> float:
	return _paso * metros_por_unidad * escala / (APOYO * DUR_CAMINAR)


## Avance (0..1) y altura (0..1) de la raíz durante el salto.
static func arco_salto(t: float) -> Vector2:
	var s := clampf((t - DESPEGUE) / (ATERRIZAJE - DESPEGUE), 0.0, 1.0)
	return Vector2(s, 4.0 * s * (1.0 - s))


# ---------------------------------------------------------------- armado

func _armar() -> void:
	var doc := GLTFDocument.new()
	var estado := GLTFState.new()
	doc.append_from_file(RUTA, estado)
	var escena := doc.generate_scene(estado)
	var fuente := escena.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
	var arr := fuente.mesh.surface_get_arrays(0)
	escena.free()
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var caja := AABB(verts[0], Vector3.ZERO)
	for v in verts:
		caja = caja.expand(v)
	_suelo = caja.position.y
	var k := metros_por_unidad * escala

	giro = Node3D.new()
	giro.name = "Giro"
	add_child(giro)
	estira = Node3D.new()
	estira.name = "Estira"
	giro.add_child(estira)
	var modelo := Node3D.new()
	modelo.name = "Modelo"
	modelo.scale = Vector3.ONE * k
	modelo.position = -Vector3(caja.get_center().x, _suelo, 0.0) * k
	estira.add_child(modelo)
	sk = Skeleton3D.new()
	sk.name = "Esqueleto"
	modelo.add_child(sk)

	# --- medir la malla ---
	var cx := caja.get_center().x
	# Pies: los 4 grupos de vértices más bajos.
	var bajos: Array[Vector3] = []
	for v in verts:
		if v.y < _suelo + 0.08:
			bajos.append(v)
	var z_min := INF
	var z_max := -INF
	for v in bajos:
		z_min = minf(z_min, v.z)
		z_max = maxf(z_max, v.z)
	var z_mitad := (z_min + z_max) * 0.5
	var cuenta := {}
	for p in PATAS:
		_pie[p] = Vector3.ZERO
	for v in bajos:
		var p := ("d" if v.z > z_mitad else "t") + ("i" if v.x < cx else "d")
		_pie[p] += v
		cuenta[p] = cuenta.get(p, 0) + 1
	for p in PATAS:
		var q: Vector3 = _pie[p] / float(cuenta[p])
		q.y = _suelo
		_pie[p] = q
	# Panza: lo más bajo entre las patas delanteras y traseras.
	var y_panza := INF
	for v in verts:
		if absf(v.z - z_mitad) < 0.06 and absf(v.x - cx) < 0.15:
			y_panza = minf(y_panza, v.y)
	# Cabeza: centro de los vértices de arriba y adelante.
	var cab := Vector3.ZERO
	var nc := 0
	for v in verts:
		if v.z > z_mitad and v.y > y_panza + 0.77:
			cab += v
			nc += 1
	cab /= float(nc)
	# Cola: detrás y por encima del lomo, en 6 tramos de altura (5 huesos).
	var y_cola := y_panza + 0.86
	var tramos: Array[Vector3] = []
	for i in 6:
		var a := lerpf(y_cola, caja.end.y, i / 6.0)
		var b := lerpf(y_cola, caja.end.y, (i + 1) / 6.0)
		var suma := Vector3.ZERO
		var n := 0
		for v in verts:
			if v.z < caja.position.z + 0.3 * caja.size.z and v.y >= a and v.y < b:
				suma += v
				n += 1
		tramos.append(suma / maxf(n, 1))

	# --- huesos (posiciones globales en unidades de la malla) ---
	var y_cadera := y_panza + 0.10
	var y_rodilla := _suelo + 0.45 * (y_cadera - _suelo)
	_l1 = y_cadera - y_rodilla
	_l2 = y_rodilla - _suelo
	_paso = 0.6 * (_l1 + _l2)
	var y_col := y_panza + 0.40
	var z_hombros: float = (_pie["di"].z + _pie["dd"].z) * 0.5 - 0.08
	var z_caderas: float = (_pie["ti"].z + _pie["td"].z) * 0.5 + 0.08
	var g := {}
	g["raiz"] = Vector3(cx, _suelo, z_mitad)
	g["medio"] = Vector3(cx, y_col, z_mitad)
	g["hombros"] = Vector3(cx, y_col, z_hombros)
	g["caderas"] = Vector3(cx, y_col, z_caderas)
	g["cabeza"] = Vector3(cx, cab.y - 0.22, cab.z - 0.12)
	g["cola1"] = Vector3(cx, tramos[0].y - 0.1, tramos[0].z + 0.08)
	for i in range(1, 5):
		g[COLA[i]] = tramos[i]
	for p in PATAS:
		g[p + "1"] = Vector3(_pie[p].x, y_cadera, _pie[p].z)
		g[p + "2"] = Vector3(_pie[p].x, y_rodilla, _pie[p].z)
	_padre = {"raiz": "", "medio": "raiz", "hombros": "medio", "caderas": "medio",
		"cabeza": "hombros", "cola1": "caderas"}
	for i in range(1, 5):
		_padre[COLA[i]] = COLA[i - 1]
	for p in PATAS:
		_padre[p + "1"] = "hombros" if p[0] == "d" else "caderas"
		_padre[p + "2"] = p + "1"
	_orden = ["raiz", "medio", "hombros", "caderas", "cabeza"]
	_orden.append_array(COLA)
	for p in PATAS:
		_orden.append(p + "1")
		_orden.append(p + "2")
	for nombre in _orden:
		var i := sk.add_bone(nombre)
		var pp: String = _padre[nombre]
		var local: Vector3 = g[nombre] - (g[pp] if pp != "" else Vector3.ZERO)
		if pp != "":
			sk.set_bone_parent(i, sk.find_bone(pp))
		sk.set_bone_rest(i, Transform3D(Basis(), local))
		_rest[nombre] = local
	sk.reset_bone_poses()

	# --- pesos ---
	# Segmentos [desde, hasta, radio]: el radio hace que cuerpo y cabeza ganen los
	# vértices de su superficie aunque su eje quede lejos.
	var seg := {
		"caderas": [Vector3(cx, y_col, caja.position.z + 0.2), Vector3(cx, y_col, z_mitad - 0.12), 0.42],
		"medio": [Vector3(cx, y_col, z_mitad - 0.08), Vector3(cx, y_col, z_hombros - 0.08), 0.42],
		"hombros": [Vector3(cx, y_col, z_hombros - 0.04), Vector3(cx, y_col, z_max - 0.12), 0.42],
		"cabeza": [g["cabeza"] + Vector3(0, 0.12, 0), cab + Vector3(0, 0.1, 0.05), 0.42],
		"cola1": [g["cola1"], g["cola2"], 0.13],
	}
	for i in range(1, 5):
		var fin: Vector3 = tramos[i + 1] if i < 4 else tramos[5] + (tramos[5] - tramos[4]) * 0.5
		seg[COLA[i]] = [g[COLA[i]], fin, 0.14 + 0.01 * i]
	for p in PATAS:
		seg[p + "1"] = [g[p + "1"], g[p + "2"], 0.1]
		seg[p + "2"] = [g[p + "2"], _pie[p], 0.1]
	var nombres: Array = seg.keys()
	var huesos := PackedInt32Array()
	var pesos := PackedFloat32Array()
	huesos.resize(verts.size() * 4)
	pesos.resize(verts.size() * 4)
	var y_pata := y_cadera + 0.03
	var y_cabeza := y_panza + 0.37
	for vi in verts.size():
		var v := verts[vi]
		var mejor := [-1, -1]
		var dist := [INF, INF]
		for c in nombres.size():
			var nombre: String = nombres[c]
			if nombre.length() == 3:  # pata: solo abajo, de su lado y de su mitad
				if v.y > y_pata:
					continue
				var lado := -1.0 if nombre[1] == "i" else 1.0
				if absf(v.x - cx) > 0.03 and signf(v.x - cx) != lado:
					continue
				if (nombre[0] == "d") != (v.z > z_mitad):
					continue
			elif nombre.begins_with("cola"):
				if v.z > z_mitad - 0.1 or v.y < y_panza + 0.67:
					continue
			elif nombre == "cabeza" and (v.y < y_cabeza or v.z < z_mitad - 0.1):
				continue
			var s: Array = seg[nombre]
			var d := v.distance_to(Geometry3D.get_closest_point_to_segment(v, s[0], s[1])) - float(s[2])
			d = maxf(d, 0.01)
			if d < dist[0]:
				dist[1] = dist[0]
				mejor[1] = mejor[0]
				dist[0] = d
				mejor[0] = c
			elif d < dist[1]:
				dist[1] = d
				mejor[1] = c
		if mejor[1] < 0:
			mejor[1] = mejor[0]
			dist[1] = dist[0]
		var w0 := 1.0 / pow(dist[0], 3.0)
		var w1 := 1.0 / pow(dist[1], 3.0)
		huesos[vi * 4] = sk.find_bone(nombres[mejor[0]])
		huesos[vi * 4 + 1] = sk.find_bone(nombres[mejor[1]])
		pesos[vi * 4] = w0 / (w0 + w1)
		pesos[vi * 4 + 1] = w1 / (w0 + w1)

	var limpio: Array = []
	limpio.resize(Mesh.ARRAY_MAX)
	limpio[Mesh.ARRAY_VERTEX] = verts
	limpio[Mesh.ARRAY_NORMAL] = arr[Mesh.ARRAY_NORMAL]
	limpio[Mesh.ARRAY_COLOR] = arr[Mesh.ARRAY_COLOR]
	limpio[Mesh.ARRAY_INDEX] = arr[Mesh.ARRAY_INDEX]
	limpio[Mesh.ARRAY_BONES] = huesos
	limpio[Mesh.ARRAY_WEIGHTS] = pesos
	var malla := ArrayMesh.new()
	malla.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, limpio)
	var piel := Skin.new()
	for i in sk.get_bone_count():
		piel.add_named_bind(sk.get_bone_name(i), sk.get_bone_global_rest(i).affine_inverse())
	var mi := MeshInstance3D.new()
	mi.name = "Malla"
	mi.mesh = malla
	mi.skin = piel
	sk.add_child(mi)
	mi.skeleton = mi.get_path_to(sk)
	if usar_toon:
		var mat := Toon.material(Color.WHITE)
		mat.set_shader_parameter("usar_color_vertice", true)
		mi.material_override = mat
	else:
		var std := StandardMaterial3D.new()
		std.vertex_color_use_as_albedo = true
		std.roughness = 0.85
		mi.material_override = std

	ap = AnimationPlayer.new()
	ap.name = "Animaciones"
	add_child(ap)


# ---------------------------------------------------------------- poses

## Una pose es {hueso: giro (Vector3 en radianes)} más "pos_medio" y "pos_cabeza"
## (desplazamientos), "escala" (estirar) y "pies" {pata: [z extra, alto]} para la
## cinemática inversa. Las patas sin "pies" usan el giro que traigan.
func _pose_caminar(t: float) -> Dictionary:
	var u := t / DUR_CAMINAR
	var w := TAU * u
	var l := _l1 + _l2
	var p := {}
	# Columna en S: hombros y caderas giran y se ladean en contra.
	p["hombros"] = Vector3(0.0, 0.08 * sin(w), 0.05 * sin(w))
	p["caderas"] = Vector3(0.0, -0.08 * sin(w), -0.05 * sin(w))
	p["medio"] = Vector3(0.0, 0.0, 0.0)
	# Sube y baja con cada paso (2 veces por ciclo).
	var bote := 0.035 * l * cos(2.0 * w)
	p["pos_medio"] = Vector3(0, -0.08 * l + bote, 0)
	# La cabeza compensa: deshace casi todo el giro de los hombros, se queda más quieta
	# y cabecea un poco, atrasada respecto del bote.
	p["cabeza"] = Vector3(0.04 * sin(2.0 * w - 1.0), -0.07 * sin(w), -0.045 * sin(w))
	p["pos_cabeza"] = Vector3(0, -0.5 * bote, 0)
	# Cola en onda que viaja hacia la punta, levantada.
	for i in COLA.size():
		p[COLA[i]] = Vector3(0.03 * sin(w - 0.9 * i), 0.0, (0.09 + 0.04 * i) * sin(w - 0.9 * i))
	# Patas en diagonal (delantera izquierda con trasera derecha).
	var fase := {"di": 0.0, "td": 0.0, "dd": 0.5, "ti": 0.5}
	var pies := {}
	for pata in PATAS:
		var f: float = fmod(u + fase[pata], 1.0)
		var z := 0.0
		var alto := 0.0
		if f < APOYO:  # apoyada: retrocede respecto del cuerpo a la velocidad del avance
			z = _paso * (0.5 - f / APOYO)
		else:  # avanza por el aire: se levanta y dobla
			var s := (f - APOYO) / (1.0 - APOYO)
			z = _paso * (-0.5 + smoothstep(0.0, 1.0, s))
			alto = 0.25 * l * sin(PI * s)
		pies[pata] = [z, alto]
	p["pies"] = pies
	p["escala"] = 1.0 + 0.012 * cos(2.0 * w)
	return p


func _pose_quieto(t: float) -> Dictionary:
	var w := TAU * t / DUR_QUIETO
	var l := _l1 + _l2
	var p := {}
	p["pos_medio"] = Vector3(0, -0.04 * l + 0.012 * l * sin(2.0 * w), 0)
	p["cabeza"] = Vector3(0.015 * sin(w), 0.03 * sin(w * 0.5 + 1.0), 0)
	for i in COLA.size():
		p[COLA[i]] = Vector3(0.0, 0.0, (0.05 + 0.025 * i) * sin(w - 0.7 * i))
	var pies := {}
	for pata in PATAS:
		pies[pata] = [0.0, 0.0]
	p["pies"] = pies
	p["escala"] = 1.0 + 0.012 * sin(2.0 * w)  # respiración muy suave
	return p


## Salto por claves. [tiempo, cuerpo y (× largo de pata), cuerpo x, cabeza x, cola x,
## escala, alto pie delantero, alto pie trasero (× largo de pata),
## en el aire: delantera (1, 2), trasera (1, 2)]
const CLAVES_SALTO := [
	[0.00, -0.04, 0.0, 0.0, 0.0, 1.00, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
	[0.28, -0.42, -0.06, 0.08, 0.25, 0.92, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],    # se agacha
	[0.36, -0.10, -0.16, 0.0, 0.0, 1.06, 0.30, 0.0, -0.6, 0.5, 0.4, 0.2],     # empuja
	[0.42, 0.00, -0.22, -0.05, -0.20, 1.08, 0.0, 0.0, -0.95, 0.15, 0.75, 0.3],  # se estira
	[0.62, 0.00, 0.00, 0.0, -0.10, 1.00, 0.0, 0.0, -0.25, 1.4, -0.65, 1.3],   # recoge
	[0.84, 0.00, 0.16, -0.06, 0.15, 1.04, 0.0, 0.0, -0.55, 0.05, 0.35, 0.6],  # delanteras abajo
	[0.90, -0.16, 0.12, -0.04, 0.20, 0.94, 0.0, 0.35, 0.0, 0.0, 0.0, 0.0],    # apoya delante
	[0.98, -0.34, 0.00, 0.0, 0.15, 0.92, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],       # amortigua
	[1.20, -0.04, 0.0, 0.0, 0.0, 1.00, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
]


func _pose_saltar(t: float) -> Dictionary:
	var a: Array = CLAVES_SALTO[0]
	var b: Array = CLAVES_SALTO[-1]
	for i in CLAVES_SALTO.size() - 1:
		if t >= CLAVES_SALTO[i][0] and t <= CLAVES_SALTO[i + 1][0]:
			a = CLAVES_SALTO[i]
			b = CLAVES_SALTO[i + 1]
			break
	var k := smoothstep(0.0, 1.0, (t - a[0]) / maxf(b[0] - a[0], 0.001))
	var v := func(j: int) -> float: return lerpf(a[j], b[j], k)
	var l := _l1 + _l2
	var p := {}
	p["pos_medio"] = Vector3(0, v.call(1) * l, 0)
	p["medio"] = Vector3(v.call(2), 0, 0)
	p["cabeza"] = Vector3(v.call(3) - v.call(2) * 0.6, 0, 0)
	for i in COLA.size():
		p[COLA[i]] = Vector3(v.call(4) * (1.0 - 0.15 * i), 0, 0.06 * sin(t * 6.0 - 0.7 * i))
	p["escala"] = v.call(5)
	if t <= DESPEGUE or t >= ATERRIZAJE:
		var pies := {}
		for pata in PATAS:
			pies[pata] = [0.0, (v.call(6) if pata[0] == "d" else v.call(7)) * l]
		p["pies"] = pies
	else:
		for pata in PATAS:
			var o := 8 if pata[0] == "d" else 10
			p[pata + "1"] = Vector3(v.call(o), 0, 0)
			p[pata + "2"] = Vector3(v.call(o + 1), 0, 0)
	return p


# ---------------------------------------------------------------- horneado

func _hornear_animaciones() -> void:
	var lib := AnimationLibrary.new()
	lib.add_animation("quieto", _hornear(_pose_quieto, DUR_QUIETO, 48, true))
	lib.add_animation("caminar", _hornear(_pose_caminar, DUR_CAMINAR, 32, true))
	lib.add_animation("saltar", _hornear(_pose_saltar, DUR_SALTAR, 60, false))
	ap.add_animation_library("", lib)


func _hornear(pose: Callable, dur: float, n: int, bucle: bool) -> Animation:
	var anim := Animation.new()
	anim.length = dur
	anim.loop_mode = Animation.LOOP_LINEAR if bucle else Animation.LOOP_NONE
	var ruta := "Giro/Estira/Modelo/Esqueleto:"
	var pistas := {}
	for nombre in _orden:
		var t := anim.add_track(Animation.TYPE_ROTATION_3D)
		anim.track_set_path(t, ruta + nombre)
		pistas[nombre] = t
	var t_medio := anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(t_medio, ruta + "medio")
	var t_cabeza := anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(t_cabeza, ruta + "cabeza")
	var t_esc := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(t_esc, "Giro/Estira:scale")
	# En bucle, el último cuadro es igual al primero (n pasos cubren todo el ciclo).
	for i in n + 1:
		var tiempo := dur * i / n
		var p: Dictionary = pose.call(tiempo)
		_resolver_patas(p)
		for nombre in _orden:
			var e: Vector3 = p.get(nombre, Vector3.ZERO)
			anim.rotation_track_insert_key(pistas[nombre], tiempo, Quaternion.from_euler(e))
		anim.position_track_insert_key(t_medio, tiempo, _rest["medio"] + p.get("pos_medio", Vector3.ZERO))
		anim.position_track_insert_key(t_cabeza, tiempo, _rest["cabeza"] + p.get("pos_cabeza", Vector3.ZERO))
		var e_: float = clampf(p.get("escala", 1.0), 1.0 - DEFORMACION_MAXIMA, 1.0 + DEFORMACION_MAXIMA)
		anim.track_insert_key(t_esc, tiempo, Vector3(1.0 / sqrt(e_), e_, 1.0 / sqrt(e_)))
	return anim


## Transformación global (unidades de la malla) de un hueso en la pose dada.
func _global(p: Dictionary, nombre: String) -> Transform3D:
	var pos: Vector3 = _rest[nombre]
	if nombre == "medio":
		pos += p.get("pos_medio", Vector3.ZERO)
	elif nombre == "cabeza":
		pos += p.get("pos_cabeza", Vector3.ZERO)
	var local := Transform3D(Basis.from_euler(p.get(nombre, Vector3.ZERO)), pos)
	var pp: String = _padre[nombre]
	return local if pp == "" else _global(p, pp) * local


## Cinemática inversa de 2 huesos en el plano de la pata (giro en x del hueso): pone la
## punta de la pata en el pie pedido. Delanteras con el codo atrás, traseras con la
## rodilla adelante.
func _resolver_patas(p: Dictionary) -> void:
	if not p.has("pies"):
		return
	var pies: Dictionary = p["pies"]
	for pata in PATAS:
		var pp: String = _padre[pata + "1"]
		var g_padre := _global(p, pp)
		var meta: Vector3 = _pie[pata] + Vector3(0, pies[pata][1], pies[pata][0])
		var dv: Vector3 = g_padre.affine_inverse() * meta - _rest[pata + "1"]
		var d := clampf(Vector2(dv.y, dv.z).length(), 0.05, (_l1 + _l2) * 0.999)
		var alfa := atan2(-dv.z, -dv.y)
		var gamma := acos(clampf((_l1 * _l1 + d * d - _l2 * _l2) / (2.0 * _l1 * d), -1.0, 1.0))
		var kappa := acos(clampf((_l1 * _l1 + _l2 * _l2 - d * d) / (2.0 * _l1 * _l2), -1.0, 1.0))
		if pata[0] == "d":
			p[pata + "1"] = Vector3(alfa + gamma, 0, 0)
			p[pata + "2"] = Vector3(-(PI - kappa), 0, 0)
		else:
			p[pata + "1"] = Vector3(alfa - gamma, 0, 0)
			p[pata + "2"] = Vector3(PI - kappa, 0, 0)
