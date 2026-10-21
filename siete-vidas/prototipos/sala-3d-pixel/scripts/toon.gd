# PROTOTIPO: no es código del juego.
# Pregunta: ¿se ve mejor la sala en 3D renderizado como pixel art?
# Fecha: 2026-10-21
# Ayudas: materiales toon, casco de contorno y colocar modelos de Kenney.
class_name Toon
extends RefCounted

const SHADER_TOON := preload("res://shaders/toon.gdshader")
const SHADER_CONTORNO := preload("res://shaders/contorno.gdshader")
const COLOR_CONTORNO := Color("210c0a")
## El contorno por casco invertido quedó reemplazado por el post-proceso de bordes
## (shaders/bordes.gdshader, Forward+). Se deja apagado para comparar.
const USAR_CASCO := false

## Todos los materiales creados, para poder cambiar escalones/contorno en vivo.
static var materiales: Array[ShaderMaterial] = []
static var contornos: Array[Node3D] = []


static func material(color: Color, emision: float = 0.0) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = SHADER_TOON
	m.set_shader_parameter("color", color)
	m.set_shader_parameter("emision", emision)
	materiales.append(m)
	return m


static func material_contorno() -> ShaderMaterial:
	if not USAR_CASCO:
		return null
	var m := ShaderMaterial.new()
	m.shader = SHADER_CONTORNO
	m.set_shader_parameter("color", COLOR_CONTORNO)
	return m


## Copia la malla con normales suavizadas (las de Kenney son duras y el casco se abriría).
static func malla_contorno(malla: Mesh) -> ArrayMesh:
	var nueva := ArrayMesh.new()
	for s in malla.get_surface_count():
		var arr := malla.surface_get_arrays(s)
		var pos: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		var nor: PackedVector3Array = arr[Mesh.ARRAY_NORMAL]
		var suma: Dictionary = {}
		for i in pos.size():
			var k := Vector3i((pos[i] * 1000.0).round())
			suma[k] = suma.get(k, Vector3.ZERO) + nor[i]
		var suaves := PackedVector3Array()
		suaves.resize(pos.size())
		for i in pos.size():
			var v: Vector3 = suma[Vector3i((pos[i] * 1000.0).round())]
			suaves[i] = v.normalized() if v.length() > 0.0001 else nor[i]
		var simple: Array = []
		simple.resize(Mesh.ARRAY_MAX)
		simple[Mesh.ARRAY_VERTEX] = pos
		simple[Mesh.ARRAY_NORMAL] = suaves
		simple[Mesh.ARRAY_INDEX] = arr[Mesh.ARRAY_INDEX]
		nueva.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, simple)
	return nueva


static func agregar_contorno(mi: MeshInstance3D) -> void:
	if not USAR_CASCO:
		return
	var casco := MeshInstance3D.new()
	casco.name = "Contorno"
	casco.mesh = malla_contorno(mi.mesh)
	casco.material_override = material_contorno()
	casco.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.add_child(casco)
	contornos.append(casco)


## Caja de color plano con contorno (para pared, piso, ventana...).
static func caja(padre: Node3D, tam: Vector3, pos: Vector3, color: Color,
		con_contorno: bool = true, emision: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = tam
	mi.mesh = bm
	mi.material_override = material(color, emision)
	mi.position = pos
	padre.add_child(mi)
	if con_contorno:
		agregar_contorno(mi)
	return mi


## Instancia un .glb de Kenney, lo escala a una altura real y lo recolorea por material.
static func modelo(padre: Node3D, ruta: String, alto_m: float, pos: Vector3,
		colores: Dictionary, rot_y_grados: float = 0.0, ancho_m: float = 0.0) -> Node3D:
	var escena: PackedScene = load(ruta)
	var raiz := escena.instantiate() as Node3D
	padre.add_child(raiz)
	var caja_total := _caja_de(raiz)
	var k := alto_m / maxf(caja_total.size.y, 0.001)
	if ancho_m > 0.0:
		k = ancho_m / maxf(caja_total.size.x, 0.001)
	raiz.scale = Vector3.ONE * k
	raiz.rotation_degrees.y = rot_y_grados
	# Se apoya en el piso y se centra en x/z sobre pos.
	var centro := caja_total.get_center() * k
	var giro := Basis(Vector3.UP, deg_to_rad(rot_y_grados))
	var desplazado := giro * Vector3(centro.x, caja_total.position.y * k, centro.z)
	raiz.position = pos - desplazado
	for mi in _mallas(raiz):
		for s in mi.mesh.get_surface_count():
			var orig := mi.mesh.surface_get_material(s)
			var nombre := orig.resource_name if orig else ""
			var c: Color = colores.get(nombre, colores.get("*", Color.MAGENTA))
			var emi: float = 1.2 if nombre == "lamp" else 0.0
			mi.set_surface_override_material(s, material(c, emi))
		agregar_contorno(mi)
	return raiz


static func _mallas(n: Node) -> Array[MeshInstance3D]:
	var lista: Array[MeshInstance3D] = []
	if n is MeshInstance3D:
		lista.append(n)
	for h in n.get_children():
		lista.append_array(_mallas(h))
	return lista


static func _caja_de(raiz: Node3D) -> AABB:
	var total := AABB()
	var primera := true
	for mi in _mallas(raiz):
		var t := _transformacion_relativa(mi, raiz)
		var a := t * mi.mesh.get_aabb()
		total = a if primera else total.merge(a)
		primera = false
	return total


static func _transformacion_relativa(n: Node3D, raiz: Node3D) -> Transform3D:
	var t := Transform3D.IDENTITY
	var actual: Node = n
	while actual != raiz and actual is Node3D:
		t = (actual as Node3D).transform * t
		actual = actual.get_parent()
	return t
