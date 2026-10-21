# PROTOTIPO: no es código del juego.
# Pregunta: ¿se ve mejor la sala en 3D renderizado como pixel art? (Valeria IA con esqueleto)
# Fecha: 2026-10-21
# "Auto-piel" simple: toma una malla sin huesos (Valeria hecha por IA desde su imagen) y la
# pega al esqueleto CC0 de Quaternius, para reutilizar sus animaciones.
# 1. Pose de referencia: la primera pose de "Idle" (brazos abajo, como la imagen).
# 2. El esqueleto se reajusta a las proporciones de Valeria (cabeza grande, piernas
#    más cortas) moviendo la altura de cada hueso por tramos (tobillo, rodilla, cadera,
#    hombro, cuello, cabeza) y abriendo o cerrando los brazos.
# 3. Cada vértice se asigna a sus 2 huesos más cercanos con peso 1/d^4, sin cruzar
#    de lado (la pierna izquierda no se pega a la derecha).
# 4. Cada cuadro, después de la animación, se reponen los largos de hueso de Valeria.
class_name AutoPiel
extends RefCounted

## Alturas de Valeria como fracción de su alto total (medidas sobre su imagen).
const PROPORCIONES := {
	"tobillo": 0.06, "rodilla": 0.23, "cadera": 0.41, "hombro": 0.655, "cuello": 0.70, "cabeza": 0.735,
}
const BRAZO := ["shoulder", "upper_arm", "forearm", "hand", "f_", "thumb"]

var sk: Skeleton3D
var ap: AnimationPlayer
var largos: Array[Vector3] = []
var i_cadera := -1
var k_cadera := 1.0


func armar(skel: Skeleton3D, player: AnimationPlayer, ruta_malla: String) -> MeshInstance3D:
	sk = skel
	ap = player
	var n := sk.get_bone_count()
	ap.play("Idle")
	ap.seek(0.0, true)
	sk.force_update_all_bone_transforms()
	var g: Array[Transform3D] = []
	for i in n:
		g.append(sk.get_bone_global_pose(i))
	var y_de := func(nombre: String) -> float: return g[sk.find_bone(nombre)].origin.y
	# Alto del maniquí: su malla en reposo llega a 1,83.
	var alto := 1.83
	var tramos_m: Array[float] = [0.0, y_de.call("DEF-foot.L"), y_de.call("DEF-shin.L"), y_de.call("DEF-thigh.L"),
		y_de.call("DEF-upper_arm.L"), y_de.call("DEF-neck"), y_de.call("DEF-head"), alto]
	var tramos_v: Array[float] = [0.0]
	for k in ["tobillo", "rodilla", "cadera", "hombro", "cuello", "cabeza"]:
		tramos_v.append(PROPORCIONES[k] * alto)
	tramos_v.append(alto)

	# Malla IA llevada al espacio del esqueleto (pies en 0, mismo alto, centrada en la cadera).
	var escena := (load(ruta_malla) as PackedScene).instantiate()
	var mi_ia := escena.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
	var arr := mi_ia.mesh.surface_get_arrays(0)
	escena.free()
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var caja := AABB(verts[0], Vector3.ZERO)
	for v in verts:
		caja = caja.expand(v)
	var s := alto / caja.size.y
	var i_cad := sk.find_bone("DEF-hips")
	for i in verts.size():
		var v := verts[i]
		verts[i] = Vector3((v.x - caja.get_center().x) * s + g[i_cad].origin.x, (v.y - caja.position.y) * s,
			(v.z - caja.get_center().z) * s + g[i_cad].origin.z)
	# Apertura de brazos: ancho de Valeria a la altura del pecho contra las manos del maniquí.
	var ancho_v := 0.0
	for v in verts:
		if v.y > 0.45 * alto and v.y < 0.6 * alto:
			ancho_v = maxf(ancho_v, absf(v.x - g[i_cad].origin.x))
	var ancho_m := absf(g[sk.find_bone("DEF-hand.L")].origin.x - g[i_cad].origin.x) + 0.05
	var sx := clampf(ancho_v / ancho_m, 0.6, 1.3)

	# Esqueleto con las proporciones de Valeria.
	var p_nueva: Array[Vector3] = []
	for i in n:
		var o := g[i].origin
		var x := o.x
		if _es_brazo(sk.get_bone_name(i)):
			x = g[i_cad].origin.x + (o.x - g[i_cad].origin.x) * sx
		p_nueva.append(Vector3(x, _tramo(o.y, tramos_m, tramos_v), o.z))
	largos.resize(n)
	var bind: Array[Transform3D] = []
	for i in n:
		var padre := sk.get_bone_parent(i)
		if padre >= 0:
			largos[i] = g[padre].basis.inverse() * (p_nueva[i] - p_nueva[padre])
		else:
			largos[i] = sk.get_bone_pose_position(i)
		bind.append(Transform3D(g[i].basis, p_nueva[i]))
	i_cadera = i_cad
	k_cadera = p_nueva[i_cad].y / maxf(g[i_cad].origin.y, 0.001)

	# Pesos: 2 huesos más cercanos (segmento del hueso a su primer hijo).
	var candidatos: Array[int] = []
	var desde: Array[Vector3] = []
	var hasta: Array[Vector3] = []
	for i in n:
		var nombre := sk.get_bone_name(i)
		if not nombre.begins_with("DEF-") or "f_" in nombre or "thumb" in nombre:
			continue
		var fin := p_nueva[i]
		var hijos := sk.get_bone_children(i)
		if nombre == "DEF-head":
			fin = p_nueva[i] + Vector3(0, (alto - p_nueva[i].y) * 0.75, 0)
		elif nombre.begins_with("DEF-hand"):
			fin = p_nueva[i] + (p_nueva[i] - p_nueva[sk.get_bone_parent(i)]) * 0.6
		elif hijos.size() > 0:
			fin = p_nueva[hijos[0]]
		else:
			fin = p_nueva[i] + (p_nueva[i] - p_nueva[sk.get_bone_parent(i)]) * 0.5
		candidatos.append(i)
		desde.append(p_nueva[i])
		hasta.append(fin)
	var cx := g[i_cad].origin.x
	var huesos := PackedInt32Array()
	var pesos := PackedFloat32Array()
	huesos.resize(verts.size() * 4)
	pesos.resize(verts.size() * 4)
	for vi in verts.size():
		var v := verts[vi]
		var mejor := [-1, -1]
		var dist := [1e9, 1e9]
		for c in candidatos.size():
			# Un vértice de la pierna o el brazo izquierdo no se pega al lado derecho.
			var lado_hueso := desde[c].x - cx
			if absf(lado_hueso) > 0.03 and absf(v.x - cx) > 0.02 and signf(lado_hueso) != signf(v.x - cx):
				continue
			var d := v.distance_to(Geometry3D.get_closest_point_to_segment(v, desde[c], hasta[c]))
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
		var w0 := 1.0 / pow(maxf(dist[0], 0.005), 4.0)
		var w1 := 1.0 / pow(maxf(dist[1], 0.005), 4.0)
		huesos[vi * 4] = candidatos[mejor[0]]
		huesos[vi * 4 + 1] = candidatos[mejor[1]]
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
	for i in n:
		piel.add_named_bind(sk.get_bone_name(i), bind[i].affine_inverse())
	var mi := MeshInstance3D.new()
	mi.name = "ValeriaIA"
	mi.mesh = malla
	mi.skin = piel
	sk.add_child(mi)
	mi.skeleton = mi.get_path_to(sk)
	var mat := Toon.material(Color.WHITE)
	mat.set_shader_parameter("usar_color_vertice", true)
	mi.material_override = mat
	ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	return mi


## Avanza la animación y repone los largos de hueso de Valeria.
func avanzar(delta: float) -> void:
	ap.advance(delta)
	for i in largos.size():
		if i == i_cadera:
			var p := sk.get_bone_pose_position(i)
			sk.set_bone_pose_position(i, Vector3(p.x, p.y * k_cadera, p.z))
		elif sk.get_bone_parent(i) >= 0:
			sk.set_bone_pose_position(i, largos[i])


func _es_brazo(nombre: String) -> bool:
	for b in BRAZO:
		if b in nombre:
			return true
	return false


func _tramo(y: float, de: Array[float], a: Array[float]) -> float:
	for t in range(1, de.size()):
		if y <= de[t] or t == de.size() - 1:
			var k := (y - de[t - 1]) / maxf(de[t] - de[t - 1], 0.0001)
			return lerpf(a[t - 1], a[t], k)
	return y
