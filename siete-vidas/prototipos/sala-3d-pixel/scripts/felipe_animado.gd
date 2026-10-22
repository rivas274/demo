# PROTOTIPO: no es código del juego.
# Pregunta: ¿se puede animar a Felipe 3D (modelo IA coloreado) con un esqueleto simple?
# Fecha: 2026-10-22
# Toma `felipe_color.glb` (sin huesos), le arma por código un esqueleto de cuadrúpedo
# midiendo la malla (raíz, cuerpo, cabeza, cola de 3 huesos y 4 patas de 2 huesos),
# pega cada vértice a sus 2 huesos más cercanos y hornea 3 animaciones en bucle o no:
# "quieto", "caminar" (patas en diagonal, 0,8 s) y "saltar" (1,2 s).
# El cuerpo se apoya siempre en la pata más baja (cinemática directa al hornear), así
# ninguna pata atraviesa el piso y el subir y bajar del cuerpo sale del paso.
extends Node3D

const RUTA := "res://assets/local3d/texturizados/felipe_color.glb"
const DUR_CAMINAR := 0.8
const DUR_SALTAR := 1.2
const DUR_QUIETO := 3.2
## Tramo del salto en el aire (segundos dentro de "saltar"): despega y aterriza.
const DESPEGUE := 0.40
const ATERRIZAJE := 0.88
## Estirar y aplastar como mucho ±8 % (regla de Felipe).
const DEFORMACION_MAXIMA := 0.08
const PATAS := ["di", "dd", "ti", "td"]  # delantera/trasera, izquierda/derecha

## Alto total en pantalla: 67 px = 0,554 m (con la cola).
@export var alto := 67.0 / 121.0
## Giro hacia la cámara para verse en 3/4 al caminar de lado.
@export var giro_3_4 := 35.0
@export var usar_toon := true

var ap: AnimationPlayer
var sk: Skeleton3D
var giro: Node3D
var estira: Node3D
var mira_derecha := true
var _rest: Dictionary = {}  # hueso -> posición de reposo local
var _suelo := 0.0  # y de las patas en la malla
var _k := 1.0
var _largo_pie := 0.1


func _ready() -> void:
	_armar()
	_hornear_animaciones()
	ap.play("quieto")


## Orientación: el modelo mira a +z; se gira para que mire a +x (derecha) o -x.
func _process(delta: float) -> void:
	var meta := 90.0 - giro_3_4 if mira_derecha else -90.0 + giro_3_4
	giro.rotation.y = lerp_angle(giro.rotation.y, deg_to_rad(meta), clampf(delta * 10.0, 0.0, 1.0))


func reproducir(nombre: String, velocidad: float = 1.0) -> void:
	if ap.current_animation != nombre:
		ap.play(nombre, 0.12, velocidad)
	ap.speed_scale = velocidad


## Altura de la raíz durante el salto (0 en tierra, 1 en el punto más alto) y avance 0..1.
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
	_k = alto / caja.size.y

	giro = Node3D.new()
	giro.name = "Giro"
	add_child(giro)
	estira = Node3D.new()
	estira.name = "Estira"
	giro.add_child(estira)
	var modelo := Node3D.new()
	modelo.name = "Modelo"
	modelo.scale = Vector3.ONE * _k
	modelo.position = -Vector3(caja.get_center().x, _suelo, 0.0) * _k
	estira.add_child(modelo)
	sk = Skeleton3D.new()
	sk.name = "Esqueleto"
	modelo.add_child(sk)

	# --- medir la malla ---
	# Patas: los 4 grupos de vértices más bajos (izquierda/derecha, delante/detrás).
	var bajos: Array[Vector3] = []
	for v in verts:
		if v.y < _suelo + 0.08 * caja.size.y / 2.0:
			bajos.append(v)
	var z_min := INF
	var z_max := -INF
	for v in bajos:
		z_min = minf(z_min, v.z)
		z_max = maxf(z_max, v.z)
	var z_mitad := (z_min + z_max) * 0.5
	var cx := caja.get_center().x
	var patas := {}
	for p in PATAS:
		patas[p] = Vector3.ZERO
	var cuenta := {}
	for v in bajos:
		var p := ("d" if v.z > z_mitad else "t") + ("i" if v.x < cx else "d")
		patas[p] += v
		cuenta[p] = cuenta.get(p, 0) + 1
	for p in PATAS:
		patas[p] /= float(cuenta[p])
	# Cola: vértices detrás del cuerpo y por encima del lomo, en 3 tramos de altura.
	var cola_pts: Array[Vector3] = []
	for v in verts:
		if v.z < caja.position.z + 0.3 * caja.size.z and v.y > _suelo + 0.5 * caja.size.y:
			cola_pts.append(v)
	var y0 := _suelo + 0.5 * caja.size.y
	var y1 := caja.end.y
	var tramos: Array[Vector3] = []
	for i in 4:
		var a := lerpf(y0, y1, i / 4.0)
		var b := lerpf(y0, y1, (i + 1) / 4.0)
		var suma := Vector3.ZERO
		var n := 0
		for v in cola_pts:
			if v.y >= a and v.y < b:
				suma += v
				n += 1
		tramos.append(suma / maxf(n, 1))
	# Cabeza: centro de los vértices de la mitad de arriba y adelante.
	var cab := Vector3.ZERO
	var nc := 0
	for v in verts:
		if v.z > z_mitad and v.y > _suelo + 0.45 * caja.size.y:
			cab += v
			nc += 1
	cab /= float(nc)

	# --- huesos (posiciones globales en unidades de la malla) ---
	var alto_m := caja.size.y
	var g := {}
	g["raiz"] = Vector3(cx, _suelo, z_mitad)
	g["cuerpo"] = Vector3(cx, _suelo + 0.27 * alto_m, z_mitad)
	g["cabeza"] = Vector3(cx, cab.y - 0.22, cab.z - 0.12)  # cuello: pivote bajo la cabeza
	g["cola1"] = Vector3(cx, tramos[0].y - 0.12, tramos[0].z + 0.08)
	g["cola2"] = tramos[1]
	g["cola3"] = tramos[2]
	var y_cadera := _suelo + 0.16 * alto_m
	var y_rodilla := _suelo + 0.06 * alto_m
	_largo_pie = y_rodilla - _suelo
	for p in PATAS:
		var c: Vector3 = patas[p]
		g[p + "1"] = Vector3(c.x, y_cadera, c.z)
		g[p + "2"] = Vector3(c.x, y_rodilla, c.z)
	var padre := {"raiz": "", "cuerpo": "raiz", "cabeza": "cuerpo", "cola1": "cuerpo", "cola2": "cola1", "cola3": "cola2"}
	for p in PATAS:
		padre[p + "1"] = "cuerpo"
		padre[p + "2"] = p + "1"
	var orden := ["raiz", "cuerpo", "cabeza", "cola1", "cola2", "cola3"]
	for p in PATAS:
		orden.append(p + "1")
		orden.append(p + "2")
	for nombre in orden:
		var i := sk.add_bone(nombre)
		var pp: String = padre[nombre]
		var local: Vector3 = g[nombre] - (g[pp] if pp != "" else Vector3.ZERO)
		if pp != "":
			sk.set_bone_parent(i, sk.find_bone(pp))
		sk.set_bone_rest(i, Transform3D(Basis(), local))
		_rest[nombre] = local
	sk.reset_bone_poses()

	# Segmentos para los pesos: [desde, hasta, radio]. El radio hace que el cuerpo y la
	# cabeza "ganen" los vértices de su superficie aunque su eje quede lejos.
	var seg := {
		"cuerpo": [Vector3(cx, g["cuerpo"].y, z_min + 0.2), Vector3(cx, g["cuerpo"].y, z_max - 0.15), 0.42],
		"cabeza": [g["cabeza"] + Vector3(0, 0.12, 0), cab + Vector3(0, 0.1, 0.05), 0.42],
		"cola1": [g["cola1"], g["cola2"], 0.13],
		"cola2": [g["cola2"], g["cola3"], 0.15],
		"cola3": [g["cola3"], tramos[3], 0.17],
	}
	for p in PATAS:
		seg[p + "1"] = [g[p + "1"], g[p + "2"], 0.1]
		seg[p + "2"] = [g[p + "2"], Vector3(g[p + "2"].x, _suelo, g[p + "2"].z), 0.1]
	var nombres: Array = seg.keys()
	var huesos := PackedInt32Array()
	var pesos := PackedFloat32Array()
	huesos.resize(verts.size() * 4)
	pesos.resize(verts.size() * 4)
	var y_pata := _suelo + 0.17 * alto_m
	var y_cabeza := _suelo + 0.25 * alto_m
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
				if v.z > z_mitad - 0.1 or v.y < _suelo + 0.4 * alto_m:
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


# ---------------------------------------------------------------- animaciones

## Pose de cada momento: {hueso: Vector3 de giro en radianes (x, y, z)} más
## "cuerpo_y" (desplazamiento extra), "escala" (estirar) y "aire" (no apoyar en el piso).
func _pose_caminar(t: float) -> Dictionary:
	var u := t / DUR_CAMINAR
	var p := {}
	var fase := {"di": 0.0, "td": 0.0, "dd": 0.5, "ti": 0.5}  # en diagonal, como un gato
	for pata in PATAS:
		var a: float = TAU * (u + fase[pata])
		var adelante := 1.0 if pata[0] == "d" else 0.85
		p[pata + "1"] = Vector3(-0.42 * adelante * sin(a), 0, 0)
		p[pata + "2"] = Vector3(0.9 * maxf(0.0, cos(a)), 0, 0)  # recoge la pata al avanzar
	p["cuerpo"] = Vector3(0.0, 0.0, 0.025 * sin(TAU * u))
	p["cabeza"] = Vector3(0.015 * sin(2.0 * TAU * u), 0.03 * sin(TAU * u), -0.03 * sin(TAU * u))
	p["cola1"] = Vector3(0.05 * sin(TAU * u), 0, 0.12 * sin(TAU * u))
	p["cola2"] = Vector3(0, 0, 0.15 * sin(TAU * u - 0.8))
	p["cola3"] = Vector3(0, 0, 0.18 * sin(TAU * u - 1.6))
	p["escala"] = 1.0 + 0.015 * cos(2.0 * TAU * u)
	return p


func _pose_quieto(t: float) -> Dictionary:
	var u := t / DUR_QUIETO
	var p := {}
	p["cuerpo"] = Vector3.ZERO
	p["cabeza"] = Vector3(0.01 * sin(TAU * u), 0.02 * sin(TAU * u * 0.5 + 1.0), 0)
	p["cola1"] = Vector3(0, 0, 0.09 * sin(TAU * u))
	p["cola2"] = Vector3(0, 0, 0.11 * sin(TAU * u - 0.7))
	p["cola3"] = Vector3(0, 0, 0.13 * sin(TAU * u - 1.4))
	p["escala"] = 1.0 + 0.012 * sin(TAU * u * 2.0)  # respiración muy suave
	return p


## Salto por claves: agacharse, estirarse, recoger en el aire, caer con las delanteras
## primero y amortiguar. [tiempo, delanteras (1, 2), traseras (1, 2), cuerpo x, cabeza x, cola x, escala]
const CLAVES_SALTO := [
	[0.00, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.00],
	[0.26, 0.55, -1.0, -0.65, 1.1, 0.10, -0.12, 0.25, 0.92],   # se agacha (traseras más)
	[0.36, 0.30, -0.6, -0.30, 0.5, 0.0, -0.05, 0.1, 0.96],
	[0.42, -0.75, 0.0, 0.70, 0.15, -0.22, 0.10, -0.25, 1.08],  # se estira: patas extendidas
	[0.62, -0.25, 1.25, -0.45, 1.1, -0.05, 0.05, -0.1, 1.00],  # recoge las patas en el aire
	[0.82, -0.55, 0.0, 0.35, 0.5, 0.20, -0.08, 0.2, 1.04],     # baja con las delanteras adelante
	[0.92, 0.40, -0.8, 0.10, 0.5, 0.08, -0.05, 0.2, 0.92],     # apoya delante y amortigua
	[1.00, 0.35, -0.7, -0.40, 0.8, 0.0, -0.02, 0.15, 0.94],    # apoyan las traseras
	[1.20, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.00],
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
	var p := {}
	for pata in PATAS:
		var o := 1 if pata[0] == "d" else 3
		p[pata + "1"] = Vector3(v.call(o), 0, 0)
		p[pata + "2"] = Vector3(v.call(o + 1), 0, 0)
	p["cuerpo"] = Vector3(v.call(5), 0, 0)
	p["cabeza"] = Vector3(v.call(6), 0, 0)
	p["cola1"] = Vector3(v.call(7), 0, 0)
	p["cola2"] = Vector3(v.call(7) * 0.8, 0, 0.05 * sin(t * 6.0))
	p["cola3"] = Vector3(v.call(7) * 0.6, 0, 0.08 * sin(t * 6.0 - 0.6))
	p["escala"] = v.call(8)
	p["aire"] = t > DESPEGUE and t < ATERRIZAJE
	return p


func _hornear_animaciones() -> void:
	var lib := AnimationLibrary.new()
	lib.add_animation("quieto", _hornear(_pose_quieto, DUR_QUIETO, 48, true))
	lib.add_animation("caminar", _hornear(_pose_caminar, DUR_CAMINAR, 24, true))
	lib.add_animation("saltar", _hornear(_pose_saltar, DUR_SALTAR, 48, false))
	ap.add_animation_library("", lib)


func _hornear(pose: Callable, dur: float, n: int, bucle: bool) -> Animation:
	var anim := Animation.new()
	anim.length = dur
	anim.loop_mode = Animation.LOOP_LINEAR if bucle else Animation.LOOP_NONE
	var ruta := "Giro/Estira/Modelo/Esqueleto:"
	var pistas := {}
	for nombre in _rest.keys():
		var t := anim.add_track(Animation.TYPE_ROTATION_3D)
		anim.track_set_path(t, ruta + nombre)
		pistas[nombre] = t
	var t_pos := anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(t_pos, ruta + "cuerpo")
	var t_esc := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(t_esc, "Giro/Estira:scale")
	# Apoyo en tierra calculado antes, para poder interpolarlo en el tramo en el aire.
	var apoyo: Array[float] = []
	for i in n + 1:
		apoyo.append(_apoyo(pose.call(dur * i / n)))
	var i_desp := -1
	var i_ater := -1
	for i in n + 1:
		var p: Dictionary = pose.call(dur * i / n)
		if p.get("aire", false):
			if i_desp < 0:
				i_desp = i - 1
			i_ater = i + 1
	for i in n + 1:
		var tiempo := dur * i / n
		var p: Dictionary = pose.call(tiempo)
		for nombre in _rest.keys():
			var e: Vector3 = p.get(nombre, Vector3.ZERO)
			anim.rotation_track_insert_key(pistas[nombre], tiempo, Quaternion.from_euler(e))
		var y := apoyo[i]
		if i_desp >= 0 and i > i_desp and i < i_ater:
			y = lerpf(apoyo[i_desp], apoyo[i_ater], float(i - i_desp) / float(i_ater - i_desp))
		anim.position_track_insert_key(t_pos, tiempo, _rest["cuerpo"] + Vector3(0, y, 0))
		var e_: float = clampf(p.get("escala", 1.0), 1.0 - DEFORMACION_MAXIMA, 1.0 + DEFORMACION_MAXIMA)
		anim.track_insert_key(t_esc, tiempo, Vector3(1.0 / sqrt(e_), e_, 1.0 / sqrt(e_)))
	return anim


## Cuánto subir o bajar el cuerpo para que la pata más baja toque el piso (cinemática
## directa de las patas con la pose dada).
func _apoyo(p: Dictionary) -> float:
	var cuerpo := Transform3D(Basis.from_euler(p.get("cuerpo", Vector3.ZERO)), _rest["raiz"] + _rest["cuerpo"])
	var mas_baja := INF
	for pata in PATAS:
		var t1 := cuerpo * Transform3D(Basis.from_euler(p.get(pata + "1", Vector3.ZERO)), _rest[pata + "1"])
		var t2 := t1 * Transform3D(Basis.from_euler(p.get(pata + "2", Vector3.ZERO)), _rest[pata + "2"])
		for punta in [Vector3(0, -_largo_pie, 0.06), Vector3(0, -_largo_pie, -0.06)]:
			mas_baja = minf(mas_baja, (t2 * punta).y)
	return _suelo - mas_baja
