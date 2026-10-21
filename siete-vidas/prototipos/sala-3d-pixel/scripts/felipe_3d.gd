# PROTOTIPO: no es código del juego.
# Pregunta: ¿se ve mejor la sala en 3D renderizado como pixel art? (y Felipe en 3D)
# Fecha: 2026-10-21
# Felipe chibi armado con primitivas y animado por código (no hay un gato 3D libre
# con proporciones de persa chibi). Mide 0,48 m de orejas a patas (58 px) y la
# cabeza es el 56 % de eso. Mira +x; se gira 30° hacia la cámara para verse en 3/4.
# Guion en bucle sincronizado con Valeria: espera, camina, salta al sofá, se queda
# a su lado, baja y vuelve.
# Con `modelo_ia` carga en su lugar un modelo hecho por IA de imagen a 3D (sin huesos):
# se anima el cuerpo entero (respirar ±2 %, rebote y balanceo al caminar, saltito).
# Con `solo_quieto` se queda en su sitio respirando (para comparar).
extends Node3D

const BLANCO := Color("f3efe8")
const ATIGRADO := Color("8b7864")
const RAYA := Color("5b4d41")
const ROSA := Color("e59aa2")
const OJO := Color("a3b06a")
const PUPILA := Color("1b1714")

@export var velocidad := 120.0 / 121.0
@export var ciclo := 30.0
@export var x_casa := -2.3
@export var x_sofa := 1.08
@export var z_piso := 0.3
@export var z_cojin := -0.62
@export var alto_cojin := 0.36
@export var giro_3_4 := 40.0
@export var modelo_ia := ""
## Alto total en pantalla: 67 px = 0,554 m (con la cola).
@export var alto_ia := 67.0 / 121.0
## Giro del modelo IA para que la cara de la imagen mire a la cámara.
@export var frente_ia_grados := 0.0
@export var solo_quieto := false

var _cuerpo: Node3D
var _cabeza: Node3D
var _cola: Node3D
var _patas: Array[Node3D] = []
var _t := 0.0
var _paso := 0.0
var _mira_derecha := true


func _ready() -> void:
	if modelo_ia != "":
		_cargar_ia()
	else:
		_armar()
	if not solo_quieto:
		position = Vector3(x_casa, 0.0, z_piso)


func _process(delta: float) -> void:
	_t = fmod(_t + delta, ciclo)
	if solo_quieto:
		_animar(delta, false, 0.0)
		return
	var caminando := false
	var salto := 0.0  # 0..1 dentro de un salto
	if _t < 1.5:
		pass
	elif position.y < 0.01 and _t < 6.0:
		caminando = _ir_a(x_sofa, delta)
	elif _t >= 6.0 and _t < 6.6:
		salto = (_t - 6.0) / 0.6
		_saltar(salto, Vector3(x_sofa, 0.0, z_piso), Vector3(x_sofa, alto_cojin, z_cojin))
	elif _t >= 6.6 and _t < 10.9:
		position = Vector3(x_sofa, alto_cojin, z_cojin)
	elif _t >= 10.9 and _t < 11.4:
		salto = (_t - 10.9) / 0.5
		_saltar(salto, Vector3(x_sofa, alto_cojin, z_cojin), Vector3(x_sofa + 0.35, 0.0, z_piso))
	elif _t >= 11.4:
		caminando = _ir_a(x_casa, delta)
	_animar(delta, caminando, salto)


func _ir_a(x: float, delta: float) -> bool:
	var d := x - position.x
	if absf(d) < 0.02:
		_mira_derecha = true
		return false
	_mira_derecha = d > 0.0
	position.x += signf(d) * minf(absf(d), velocidad * delta)
	return true


func _saltar(k: float, desde: Vector3, hasta: Vector3) -> void:
	var p := desde.lerp(hasta, k)
	p.y += sin(k * PI) * 0.35
	position = p


func _animar(delta: float, caminando: bool, salto: float) -> void:
	if modelo_ia != "":
		_animar_ia(caminando, salto)
		return
	var giro := -giro_3_4 if _mira_derecha else 180.0 + giro_3_4
	rotation.y = lerp_angle(rotation.y, deg_to_rad(giro), clampf(delta * 12.0, 0.0, 1.0))
	if caminando:
		_paso += delta * 9.0
	# Patas alternadas en diagonal.
	for i in _patas.size():
		var fase := 0.0 if i == 0 or i == 3 else PI
		var amp := 0.55 if caminando else 0.0
		if salto > 0.0:
			amp = 0.0
			_patas[i].rotation.z = (0.6 if i < 2 else -0.6) * sin(salto * PI)
		else:
			_patas[i].rotation.z = sin(_paso + fase) * amp
	# Respirar (y rebote al caminar), estirar/aplastar dentro de ±8 %.
	var resp := sin(_t * 2.4) * 0.025
	var bote := absf(sin(_paso)) * 0.012 if caminando else 0.0
	var est := 1.0 + resp
	if salto > 0.0:
		est = 1.0 + 0.08 * cos(salto * PI) * (1.0 if salto < 0.5 else -1.0)
	_cuerpo.scale = Vector3(1.0 / sqrt(est), est, 1.0 / sqrt(est))
	_cuerpo.position.y = bote
	# Cola esponjada que se mece; la cabeza acompaña un poco.
	_cola.rotation.x = sin(_t * 1.7) * 0.35
	_cola.rotation.z = 0.25 + sin(_t * 2.3) * 0.12
	_cabeza.rotation.z = sin(_paso) * 0.04 if caminando else sin(_t * 0.8) * 0.03


## Modelo IA: se mueve entero, como un sprite con volumen. Mira siempre en 3/4 y se
## voltea con un espejo (escala x negativa) al caminar a la izquierda.
func _animar_ia(caminando: bool, salto: float) -> void:
	var resp := sin(_t * 2.4) * 0.02
	var est := 1.0 + resp
	if salto > 0.0:
		est = 1.0 + 0.08 * cos(salto * PI) * (1.0 if salto < 0.5 else -1.0)
	var lado := 1.0 if _mira_derecha else -1.0
	_cuerpo.scale = Vector3(lado / sqrt(est), est, 1.0 / sqrt(est))
	_cuerpo.position.y = absf(sin(_paso)) * 0.03 if caminando else 0.0
	_cuerpo.rotation.z = sin(_paso) * 0.07 * lado if caminando else 0.0
	if salto > 0.0:
		_cuerpo.rotation.z = -0.25 * sin(salto * PI) * lado


func _cargar_ia() -> void:
	_cuerpo = Node3D.new()
	add_child(_cuerpo)
	var raiz := (load(modelo_ia) as PackedScene).instantiate() as Node3D
	var giro := Node3D.new()
	giro.rotation_degrees.y = frente_ia_grados
	_cuerpo.add_child(giro)
	giro.add_child(raiz)
	var mallas := raiz.find_children("*", "MeshInstance3D", true, false)
	if raiz is MeshInstance3D:
		mallas.append(raiz)
	var caja := AABB()
	for i in mallas.size():
		var mi := mallas[i] as MeshInstance3D
		caja = mi.mesh.get_aabb() if i == 0 else caja.merge(mi.mesh.get_aabb())
		var mat := Toon.material(Color.WHITE)
		mat.set_shader_parameter("usar_color_vertice", true)
		mi.material_override = mat
	var k := alto_ia / caja.size.y
	raiz.scale = Vector3.ONE * k
	raiz.position = -Vector3(caja.get_center().x, caja.position.y, caja.get_center().z) * k


# ---------------------------------------------------------------- armado

func _armar() -> void:
	_cuerpo = Node3D.new()
	add_child(_cuerpo)
	# Cuerpo de persa grande: redondo, lomo atigrado, panza y pecho blancos.
	_ovalo(_cuerpo, 0.13, Vector3(-0.03, 0.15, 0), Vector3(1.3, 0.88, 1.0), func(p: Vector3) -> Color:
		if p.y < -0.15 or (p.x > 0.55 and p.y < 0.5):
			return BLANCO
		return RAYA if fmod(p.x * 2.2 + 10.0, 1.0) < 0.28 and p.y > 0.1 else ATIGRADO)
	# Patas cortas y blancas (pivote arriba para mecerlas).
	for pos in [Vector3(0.1, 0.1, 0.07), Vector3(0.1, 0.1, -0.07), Vector3(-0.13, 0.1, 0.07), Vector3(-0.13, 0.1, -0.07)]:
		var pivote := Node3D.new()
		pivote.position = pos
		_cuerpo.add_child(pivote)
		_ovalo(pivote, 0.045, Vector3(0, -0.055, 0), Vector3(1.0, 1.35, 1.0), func(_p: Vector3) -> Color: return BLANCO)
		_patas.append(pivote)
	# Cola enorme: varias esferas que suben en curva.
	_cola = Node3D.new()
	_cola.position = Vector3(-0.17, 0.2, 0)
	_cuerpo.add_child(_cola)
	var puntos := [Vector3(-0.04, 0.03, 0), Vector3(-0.09, 0.1, 0), Vector3(-0.1, 0.18, 0), Vector3(-0.08, 0.25, 0)]
	for i in puntos.size():
		var r := 0.068 + 0.016 * sin(float(i) / 3.0 * PI)
		var oscura := i % 2 == 1
		_ovalo(_cola, r, puntos[i], Vector3.ONE, func(_p: Vector3) -> Color: return RAYA if oscura else ATIGRADO)
	# Cabeza grande (56 % de la altura): gorro atigrado con franja blanca, cachetes blancos.
	_cabeza = Node3D.new()
	_cabeza.position = Vector3(0.13, 0.31, 0)
	_cuerpo.add_child(_cabeza)
	_ovalo(_cabeza, 0.145, Vector3.ZERO, Vector3(0.95, 0.92, 1.08), func(p: Vector3) -> Color:
		if p.y < -0.05 or (p.x > 0.35 and absf(p.z) < 0.28):
			return BLANCO
		if p.y > 0.35 and absf(p.z) < 0.4 and fmod(absf(p.z) * 6.0, 1.0) > 0.6:
			return RAYA
		return ATIGRADO)
	for lado in [-1.0, 1.0]:
		# Cachetes esponjados de persa.
		_ovalo(_cabeza, 0.07, Vector3(0.075, -0.06, 0.065 * lado), Vector3(1.0, 0.8, 1.0), func(_p: Vector3) -> Color: return BLANCO)
		# Orejas pequeñas.
		var oreja := MeshInstance3D.new()
		var cono := CylinderMesh.new()
		cono.top_radius = 0.0
		cono.bottom_radius = 0.04
		cono.height = 0.06
		cono.radial_segments = 4
		oreja.mesh = cono
		oreja.position = Vector3(-0.01, 0.13, 0.08 * lado)
		oreja.rotation = Vector3(0.45 * lado, 0, 0)
		_material(oreja, ATIGRADO)
		_cabeza.add_child(oreja)
		# Ojos verde avellana a media asta, mirando de reojo hacia la cámara.
		var ojo_pos := Vector3(0.122, 0.018, 0.058 * lado)
		_ovalo(_cabeza, 0.031, ojo_pos, Vector3(0.5, 1.0, 1.0), func(_p: Vector3) -> Color: return OJO, false)
		_ovalo(_cabeza, 0.014, ojo_pos + Vector3(0.014, -0.005, 0.014), Vector3(0.5, 1.4, 1.0), func(_p: Vector3) -> Color: return PUPILA, false)
		_ovalo(_cabeza, 0.034, ojo_pos + Vector3(0.008, 0.02, 0), Vector3(0.5, 0.55, 1.05), func(_p: Vector3) -> Color: return ATIGRADO, false)
	# Nariz rosada.
	_ovalo(_cabeza, 0.02, Vector3(0.14, -0.035, 0), Vector3(0.6, 0.7, 1.0), func(_p: Vector3) -> Color: return ROSA, false)


## Esfera escalada con color por vértice según una función de la posición (de -1 a 1).
func _ovalo(padre: Node3D, r: float, pos: Vector3, esc: Vector3, color_de: Callable, contorno: bool = true) -> MeshInstance3D:
	var sm := SphereMesh.new()
	sm.radius = 1.0
	sm.height = 2.0
	sm.radial_segments = 20
	sm.rings = 10
	var arr := sm.surface_get_arrays(0)
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var colores := PackedColorArray()
	for v in verts:
		colores.append(color_de.call(v))
	var limpio: Array = []
	limpio.resize(Mesh.ARRAY_MAX)
	limpio[Mesh.ARRAY_VERTEX] = verts
	limpio[Mesh.ARRAY_NORMAL] = arr[Mesh.ARRAY_NORMAL]
	limpio[Mesh.ARRAY_COLOR] = colores
	limpio[Mesh.ARRAY_INDEX] = arr[Mesh.ARRAY_INDEX]
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, limpio)
	var mi := MeshInstance3D.new()
	mi.mesh = am
	mi.position = pos
	mi.scale = esc * r
	var mat := Toon.material(Color.WHITE, 0.25)
	mat.set_shader_parameter("usar_color_vertice", true)
	if contorno:
		mat.next_pass = Toon.material_contorno()
	mi.material_override = mat
	padre.add_child(mi)
	return mi


func _material(mi: MeshInstance3D, c: Color) -> void:
	var mat := Toon.material(c)
	mat.next_pass = Toon.material_contorno()
	mi.material_override = mat
