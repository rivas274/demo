# PROTOTIPO: no es código del juego.
# Pregunta: ¿se ve mejor la sala en 3D renderizado como pixel art?
# Fecha: 2026-10-22
# Ayudas para usar los FBX de Mixamo: busca los archivos por nombre, los carga (importados
# o, si Godot todavía no los importó, en tiempo de ejecución con FBXDocument), copia las
# animaciones al esqueleto del modelo con skin y mide poses sin reproducirlas.
extends RefCounted

## Papel de cada FBX según palabras de su nombre (minúsculas). El orden importa.
const PAPELES := {
	"levantarse": [["sit to stand"], ["stand up"], ["standing up"]],
	"sentarse": [["stand to sit"], ["sitting down"], ["sit down"]],
	"sentada": [["sitting", "idle"], ["sit", "idle"], ["sitting"]],
	"caminar": [["walk"]],
	"celular": [["text"], ["phone"]],
	"recoger": [["pick"]],
	"quieto": [["idle"]],
}


## Devuelve {papel: ruta} con los .fbx de la carpeta. Un archivo tiene un solo papel.
static func buscar(carpeta: String) -> Dictionary:
	var hallados := {}
	if not DirAccess.dir_exists_absolute(carpeta):
		return hallados
	var archivos := []
	# En un ejecutable exportado la carpeta lista "x.fbx.import" (el FBX original no viaja).
	for f: String in DirAccess.get_files_at(carpeta):
		f = f.trim_suffix(".import").trim_suffix(".remap")
		if not f in archivos:
			archivos.append(f)
	archivos.sort()
	for f: String in archivos:
		if not f.to_lower().ends_with(".fbx"):
			continue
		var n := f.to_lower()
		for papel: String in PAPELES:
			if hallados.has(papel):
				continue
			var ok := false
			for grupo: Array in PAPELES[papel]:
				var todas := true
				for palabra: String in grupo:
					todas = todas and palabra in n
				ok = ok or todas
			if ok:
				hallados[papel] = carpeta.path_join(f)
				break
	return hallados


## Carga un FBX o un GLB como escena. Si Godot todavía no lo importó (nadie abrió el
## editor), lo lee directo con FBXDocument o GLTFDocument: basta copiar el archivo y correr.
static func cargar(ruta: String) -> Node3D:
	if ResourceLoader.exists(ruta):
		var ps := load(ruta) as PackedScene
		if ps:
			return ps.instantiate() as Node3D
	var es_fbx := ruta.to_lower().ends_with(".fbx")
	var doc: GLTFDocument = FBXDocument.new() if es_fbx else GLTFDocument.new()
	var estado: GLTFState = FBXState.new() if es_fbx else GLTFState.new()
	var err := doc.append_from_file(ProjectSettings.globalize_path(ruta), estado)
	if err != OK:
		push_error("No se pudo leer %s (error %d)" % [ruta, err])
		return null
	return doc.generate_scene(estado) as Node3D


static func primero(raiz: Node, clase: String) -> Node:
	var lista := raiz.find_children("*", clase, true, false)
	return lista[0] if lista.size() > 0 else null


## ¿Tiene alguna malla con skin?
static func tiene_piel(raiz: Node) -> bool:
	for mi: MeshInstance3D in raiz.find_children("*", "MeshInstance3D", true, false):
		if mi.skin or mi.get_parent() is Skeleton3D:
			return true
	return false


## La animación de Mixamo del archivo ("mixamo_com"); si no está, la más larga.
static func animacion(raiz: Node) -> Animation:
	var ap := primero(raiz, "AnimationPlayer") as AnimationPlayer
	if ap == null:
		return null
	var mejor: Animation = null
	for nombre in ap.get_animation_list():
		var a := ap.get_animation(nombre)
		if String(nombre).begins_with("mixamo"):
			return a
		if mejor == null or a.length > mejor.length:
			mejor = a
	return mejor


## Copia la animación con las pistas apuntando a `ruta_esqueleto` (relativa al AnimationPlayer).
## Mixamo usa el mismo esqueleto `mixamorig` en todos los archivos: basta cambiar la ruta.
static func copiar(a: Animation, ruta_esqueleto: String, sk: Skeleton3D, bucle: bool) -> Animation:
	var nueva := Animation.new()
	nueva.length = a.length
	nueva.loop_mode = Animation.LOOP_LINEAR if bucle else Animation.LOOP_NONE
	for i in a.get_track_count():
		var tipo := a.track_get_type(i)
		if tipo not in [Animation.TYPE_POSITION_3D, Animation.TYPE_ROTATION_3D, Animation.TYPE_SCALE_3D]:
			continue
		var hueso := String(a.track_get_path(i).get_concatenated_subnames())
		if hueso == "" or sk.find_bone(hueso) < 0:
			continue
		var j := nueva.add_track(tipo)
		nueva.track_set_path(j, NodePath(ruta_esqueleto + ":" + hueso))
		nueva.track_set_interpolation_type(j, a.track_get_interpolation_type(i))
		# Se re-muestrea a 30 cuadros por segundo: sirve aunque la original venga comprimida.
		var n := maxi(1, ceili(a.length * 30.0))
		for k in n + 1:
			var t := minf(a.length, k / 30.0)
			match tipo:
				Animation.TYPE_POSITION_3D:
					nueva.position_track_insert_key(j, t, a.position_track_interpolate(i, t))
				Animation.TYPE_ROTATION_3D:
					nueva.rotation_track_insert_key(j, t, a.rotation_track_interpolate(i, t))
				Animation.TYPE_SCALE_3D:
					nueva.scale_track_insert_key(j, t, a.scale_track_interpolate(i, t))
	return nueva


static func hueso(sk: Skeleton3D, final: String) -> int:
	for i in sk.get_bone_count():
		if sk.get_bone_name(i).ends_with(final):
			return i
	return -1


## Pose global de un hueso (en el espacio del esqueleto) en el tiempo t, leyendo las pistas.
static func pose(sk: Skeleton3D, a: Animation, i: int, t: float) -> Transform3D:
	var total := Transform3D.IDENTITY
	var actual := i
	while actual >= 0:
		total = _pose_local(sk, a, actual, t) * total
		actual = sk.get_bone_parent(actual)
	return total


static func _pose_local(sk: Skeleton3D, a: Animation, i: int, t: float) -> Transform3D:
	var reposo := sk.get_bone_rest(i)
	var pos := reposo.origin
	var rot := reposo.basis.get_rotation_quaternion()
	var esc := reposo.basis.get_scale()
	var nombre := sk.get_bone_name(i)
	for k in a.get_track_count():
		if String(a.track_get_path(k).get_concatenated_subnames()) != nombre:
			continue
		match a.track_get_type(k):
			Animation.TYPE_POSITION_3D:
				pos = a.position_track_interpolate(k, t)
			Animation.TYPE_ROTATION_3D:
				rot = a.rotation_track_interpolate(k, t)
			Animation.TYPE_SCALE_3D:
				esc = a.scale_track_interpolate(k, t)
	return Transform3D(Basis(rot).scaled(esc), pos)


## Altura de un punto según el vector `arriba` (en el espacio del esqueleto: el GLB que
## sale de Blender trae el esqueleto con Z hacia arriba, no Y).
static func _alto(p: Vector3, arriba: Vector3) -> float:
	return p.dot(arriba)


static func _plano(p: Vector3, arriba: Vector3) -> Vector3:
	return p - arriba * p.dot(arriba)


## Quita el avance de la cadera en el plano del piso (caminata que no es "In Place") y
## devuelve cuánto avanzaba por segundo, en unidades del esqueleto (0 si ya era en el sitio).
static func quitar_avance(a: Animation, sk: Skeleton3D, arriba: Vector3) -> float:
	var cadera := hueso(sk, "Hips")
	var nombre := sk.get_bone_name(cadera)
	for k in a.get_track_count():
		if a.track_get_type(k) != Animation.TYPE_POSITION_3D:
			continue
		if String(a.track_get_path(k).get_concatenated_subnames()) != nombre:
			continue
		var n := a.track_get_key_count(k)
		if n < 2:
			return 0.0
		var p0: Vector3 = a.track_get_key_value(k, 0)
		var p1: Vector3 = a.track_get_key_value(k, n - 1)
		var avance := _plano(p1 - p0, arriba)
		if avance.length() < 0.05 * absf(_alto(sk.get_bone_rest(cadera).origin, arriba)):
			return 0.0
		for j in n:
			var t := a.track_get_key_time(k, j)
			var p: Vector3 = a.track_get_key_value(k, j)
			a.track_set_key_value(k, j, p - avance * (t / a.length))
		return avance.length() / a.length
	return 0.0


## Velocidad del paso medida en los pies: mientras un pie es el más bajo (apoyado), retrocede
## respecto a la cadera a la misma velocidad con que el cuerpo avanza. Unidades del esqueleto.
## Se usa con la caminata ya anclada (sin avance de la raíz).
static func velocidad_pies(a: Animation, sk: Skeleton3D, arriba: Vector3) -> float:
	var izq := hueso(sk, "LeftFoot")
	var der := hueso(sk, "RightFoot")
	if izq < 0 or der < 0:
		return 0.0
	var dt := 1.0 / 30.0
	var vel: Array[float] = []
	var t := 0.0
	while t + dt <= a.length:
		var pi0 := pose(sk, a, izq, t).origin
		var pd0 := pose(sk, a, der, t).origin
		var apoyo := izq if _alto(pi0, arriba) < _alto(pd0, arriba) else der
		var antes := pi0 if apoyo == izq else pd0
		var despues := pose(sk, a, apoyo, t + dt).origin
		vel.append(_plano(despues - antes, arriba).length() / dt)
		t += dt
	if vel.is_empty():
		return 0.0
	vel.sort()
	return vel[vel.size() / 2]


## Altura de un hueso a lo largo de la animación, cada 1/30 s.
static func alturas(a: Animation, sk: Skeleton3D, i: int, arriba: Vector3) -> PackedFloat32Array:
	var lista := PackedFloat32Array()
	var t := 0.0
	while t <= a.length:
		lista.append(_alto(pose(sk, a, i, t).origin, arriba))
		t += 1.0 / 30.0
	return lista


## Transformación de `n` relativa a `raiz` (siguiendo los padres).
static func relativa(n: Node3D, raiz: Node) -> Transform3D:
	var t := Transform3D.IDENTITY
	var actual: Node = n
	while actual != raiz and actual is Node3D:
		t = (actual as Node3D).transform * t
		actual = actual.get_parent()
	return t


## Caja de todas las mallas, en el espacio de `raiz` (en pose de reposo).
static func caja(raiz: Node3D) -> AABB:
	var total := AABB()
	var primera := true
	for mi: MeshInstance3D in raiz.find_children("*", "MeshInstance3D", true, false):
		var a := relativa(mi, raiz) * mi.mesh.get_aabb()
		total = a if primera else total.merge(a)
		primera = false
	return total


## Primera textura de color (albedo) que encuentre en las mallas.
static func textura(raiz: Node) -> Texture2D:
	for mi: MeshInstance3D in raiz.find_children("*", "MeshInstance3D", true, false):
		for s in mi.mesh.get_surface_count():
			var m := mi.get_surface_override_material(s)
			if m == null:
				m = mi.mesh.surface_get_material(s)
			if m is BaseMaterial3D and (m as BaseMaterial3D).albedo_texture:
				return (m as BaseMaterial3D).albedo_texture
	return null
