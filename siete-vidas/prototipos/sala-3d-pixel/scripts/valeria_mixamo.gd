# PROTOTIPO: no es código del juego.
# Pregunta: ¿se ve mejor la sala en 3D renderizado como pixel art?
# Fecha: 2026-10-22
# Valeria de Meshy (CC BY 4.0) con esqueleto y animaciones de Mixamo, en la sala toon.
# Rutina de unos 20 s en bucle: entra caminando, se detiene y mira el celular, camina al sofá,
# se sienta, se levanta, se agacha a recoger una pelota y sale por la derecha.
# Fuentes, en orden: assets/meshy_prueba/valeria/mixamo/valeria_animada.glb (5 clips con
# nombre), si no los FBX de Mixamo de esa carpeta (el de caminar con skin) y, si no hay nada,
# valeria_meshy.glb estático (se desliza, solo para revisar carga y estilo).
# Para probar cada fuente: `-- --valeria-mixamo --valeria-fbx` o `--valeria-estatica`.
extends Node3D

signal empieza_vuelta

const Carga := preload("res://scripts/mixamo_carga.gd")
const CARPETA := "res://assets/meshy_prueba/valeria/mixamo/"
const GLB_ANIMADO := CARPETA + "valeria_animada.glb"
const RESPALDO := "res://assets/meshy_prueba/valeria/valeria_meshy.glb"
## Clips del GLB juntado -> papel en la rutina.
const CLIPS_GLB := {"caminar": "walking", "quieto": "idle", "sentada": "sitting_idle",
	"celular": "texting", "recoger": "picking_up"}
const EN_BUCLE := ["caminar", "quieto", "sentada", "celular"]
const PELOTA := Color("c27046")

## Valeria mide 1,65 m hasta la coronilla (el moño queda por encima).
@export var alto_m := 1.65
@export var mezcla := 0.25
## Sentarse y levantarse no tienen animación propia: corte con esta mezcla más larga.
@export var mezcla_corte := 0.6
@export var x_fuera := 4.6
@export var x_celular := 2.4
@export var x_sofa := 0.4
@export var x_recoger := 1.65
@export var z_camino := -0.12
## Cojín del sofá (loungeSofa de Kenney a 0,85 m en sala.gd): altura del asiento y dónde
## queda la cadera (el asiento va de z -0,37 a -0,96).
@export var y_asiento := 0.425
@export var z_cadera_sentada := -0.66
@export var cadera_sobre_cojin := 0.1
@export var tiempo_celular := 3.5
@export var tiempo_sentada := 4.0
@export var tiempo_giro := 0.35

## principal.gd lo cambia con Tab; aquí no hay modo manual.
var manual := false

var _modelo: Node3D
var _sk: Skeleton3D
var _ap: AnimationPlayer
var _t_sk := Transform3D.IDENTITY  # esqueleto -> espacio de _modelo (sin su escala)
var _arriba := Vector3.UP  # "arriba" en el espacio del esqueleto
var _animado := false
var _velocidad := 1.0
var _pos_sentada := Vector3.ZERO
var _t_agarre := 1.5
var _t_fin_recoger := 3.0
var _mano := ""
var _pelota: MeshInstance3D
var _pasos: Array[Dictionary] = []
var _paso := -1
var _t := 0.0
var _desde := Vector3.ZERO
var _rumbo := -PI * 0.5
var _rumbo_desde := 0.0


func _ready() -> void:
	var fuente := _cargar()
	_aplicar_toon()
	if _animado:
		_medir()
	_crear_pelota()
	_armar_guion()
	print("Valeria Mixamo: fuente=%s velocidad=%.2f m/s agarre=%.2f s fin_recoger=%.2f s sentada=%s"
		% [fuente, _velocidad, _t_agarre, _t_fin_recoger, _pos_sentada])
	_reiniciar()


# --- Carga ------------------------------------------------------------------

func _cargar() -> String:
	var clips := {}
	var fuente := ""
	var args := OS.get_cmdline_user_args()
	if "--valeria-estatica" in args:
		return _cargar_respaldo()
	var usar_glb := not "--valeria-fbx" in args
	if usar_glb and (FileAccess.file_exists(GLB_ANIMADO) or ResourceLoader.exists(GLB_ANIMADO)):
		_modelo = Carga.cargar(GLB_ANIMADO)
		fuente = GLB_ANIMADO
		var ap := Carga.primero(_modelo, "AnimationPlayer") as AnimationPlayer
		if ap:
			for papel: String in CLIPS_GLB:
				if ap.has_animation(CLIPS_GLB[papel]):
					clips[papel] = ap.get_animation(CLIPS_GLB[papel])
	if _modelo == null:
		var archivos := Carga.buscar(CARPETA)
		var con_piel := ""
		for papel: String in archivos:
			var escena := Carga.cargar(archivos[papel])
			if escena == null:
				continue
			if _modelo == null and Carga.tiene_piel(escena) and (con_piel == "" or papel == "caminar"):
				_modelo = escena
				con_piel = archivos[papel]
			clips[papel] = Carga.animacion(escena)
		fuente = con_piel
	if _modelo == null or Carga.primero(_modelo, "Skeleton3D") == null or clips.is_empty():
		return _cargar_respaldo()
	add_child(_modelo)
	_sk = Carga.primero(_modelo, "Skeleton3D") as Skeleton3D
	for viejo: AnimationPlayer in _modelo.find_children("*", "AnimationPlayer", true, false):
		viejo.stop()
		viejo.queue_free()
	_t_sk = Carga.relativa(_sk, _modelo)
	_arriba = (_t_sk.basis.inverse() * Vector3.UP).normalized()
	# Escala: la coronilla (HeadTop_End) a alto_m.
	var coronilla := Carga.hueso(_sk, "HeadTop_End")
	if coronilla < 0:
		coronilla = Carga.hueso(_sk, "Head")
	var alto_sk := _sk.get_bone_global_rest(coronilla).origin.dot(_arriba)
	var por_unidad := (_t_sk.basis * _arriba).length()
	_modelo.scale = Vector3.ONE * alto_m / maxf(alto_sk * por_unidad, 0.01)
	# AnimationPlayer propio con las pistas copiadas al esqueleto del modelo.
	_ap = AnimationPlayer.new()
	_modelo.add_child(_ap)
	_ap.root_node = _ap.get_path_to(_modelo)
	var lib := AnimationLibrary.new()
	var ruta := String(_modelo.get_path_to(_sk))
	for papel: String in clips:
		if clips[papel]:
			lib.add_animation(papel, Carga.copiar(clips[papel], ruta, _sk, papel in EN_BUCLE))
	_ap.add_animation_library("", lib)
	_animado = lib.has_animation("caminar")
	return fuente


func _cargar_respaldo() -> String:
	if _modelo:
		_modelo.free()
	_modelo = Carga.cargar(RESPALDO)
	add_child(_modelo)
	var caja := Carga.caja(_modelo)
	var k := (alto_m + 0.1) / caja.size.y  # con el moño
	_modelo.scale = Vector3.ONE * k
	_modelo.position.y = -caja.position.y * k
	_animado = false
	_velocidad = 1.05
	return RESPALDO + " (estático)"


## Material toon de la sala con la textura de Meshy como color; los bordes los pone el
## post-proceso de la sala (profundidad y normales), igual que a los muebles.
func _aplicar_toon() -> void:
	var tex := Carga.textura(_modelo)
	if tex == null:
		var glb := Carga.cargar(RESPALDO)
		tex = Carga.textura(glb)
		glb.free()
	for mi: MeshInstance3D in _modelo.find_children("*", "MeshInstance3D", true, false):
		for s in mi.mesh.get_surface_count():
			var m := Toon.material(Color.WHITE)
			m.set_shader_parameter("usar_textura", tex != null)
			m.set_shader_parameter("textura", tex)
			mi.set_surface_override_material(s, m)
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON


# --- Medidas sacadas de las animaciones --------------------------------------

## Punto del esqueleto en el espacio de este nodo (sin contar su posición ni su giro).
func _en_mi(p: Vector3) -> Vector3:
	return _modelo.transform * (_t_sk * p)


func _medir() -> void:
	var k := _modelo.scale.x * (_t_sk.basis * _arriba).length()
	# Caminata: se ancla la raíz (Mixamo la trae avanzando) y el nodo avanza a esa velocidad.
	var caminar := _ap.get_animation("caminar")
	var avance := Carga.quitar_avance(caminar, _sk, _arriba)
	var por_pies := Carga.velocidad_pies(caminar, _sk, _arriba)
	_velocidad = (avance if avance > 0.0 else por_pies) * k
	print("Valeria Mixamo: avance de la raíz %.2f m/s, medido en los pies %.2f m/s"
		% [avance * k, por_pies * k])
	var cadera := Carga.hueso(_sk, "Hips")
	if _ap.has_animation("sentada"):
		var meta := Vector3(x_sofa, y_asiento + cadera_sobre_cojin, z_cadera_sentada)
		var c := _en_mi(Carga.pose(_sk, _ap.get_animation("sentada"), cadera, 0.0).origin)
		_pos_sentada = meta - c
	if _ap.has_animation("recoger"):
		var rec := _ap.get_animation("recoger")
		_mano = _sk.get_bone_name(Carga.hueso(_sk, "RightHand"))
		var mano := Carga.alturas(rec, _sk, _sk.find_bone(_mano), _arriba)
		var g := 0
		for i in mano.size():
			if mano[i] < mano[g]:
				g = i
		_t_agarre = g / 30.0
		# Termina cuando la cadera vuelve a estar de pie (el resto del clip es estar parada).
		var cad := Carga.alturas(rec, _sk, cadera, _arriba)
		var fin := cad.size() - 1
		for i in range(g, cad.size()):
			if cad[i] >= cad[0] * 0.97:
				fin = i
				break
		_t_fin_recoger = minf(rec.length, fin / 30.0 + 0.4)


func _crear_pelota() -> void:
	_pelota = MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.06
	sm.height = 0.12
	sm.radial_segments = 12
	sm.rings = 6
	_pelota.mesh = sm
	_pelota.material_override = Toon.material(PELOTA)
	_pelota.name = "Pelota"


# --- Rutina ------------------------------------------------------------------

func _armar_guion() -> void:
	_pasos = [
		{"tipo": "caminar", "x": x_celular},
		{"tipo": "girar", "rumbo": deg_to_rad(-30.0)},
		{"tipo": "anim", "anim": "celular", "tiempo": tiempo_celular},
		{"tipo": "girar", "rumbo": -PI * 0.5},
		{"tipo": "caminar", "x": x_sofa},
		{"tipo": "girar", "rumbo": 0.0},
		{"tipo": "sentarse"},
		{"tipo": "anim", "anim": "sentada", "tiempo": tiempo_sentada},
		{"tipo": "levantarse"},
		{"tipo": "girar", "rumbo": PI * 0.5},
		{"tipo": "caminar", "x": x_recoger},
		{"tipo": "girar", "rumbo": deg_to_rad(25.0)},
		{"tipo": "recoger"},
		{"tipo": "girar", "rumbo": PI * 0.5},
		{"tipo": "caminar", "x": x_fuera},
	]


func _reiniciar() -> void:
	position = Vector3(x_fuera, 0.0, z_camino)
	_rumbo = -PI * 0.5
	rotation.y = _rumbo
	if _pelota.get_parent():
		_pelota.get_parent().remove_child(_pelota)
	_pelota.visible = false
	_paso = -1
	empieza_vuelta.emit()
	_siguiente()


func _siguiente() -> void:
	_paso += 1
	_t = 0.0
	if _paso >= _pasos.size():
		_reiniciar()
		return
	var p := _pasos[_paso]
	_desde = position
	_rumbo_desde = _rumbo
	match p["tipo"]:
		"caminar":
			_tocar("caminar", mezcla)
		"girar":
			_tocar("quieto", mezcla)
		"anim":
			_tocar(p["anim"], mezcla)
		"sentarse":
			if _tiene("sentarse"):
				_tocar("sentarse", mezcla)
			else:
				_tocar("sentada", mezcla_corte)
		"levantarse":
			if _tiene("levantarse"):
				_tocar("levantarse", mezcla)
			else:
				_tocar("quieto", mezcla_corte)
		"recoger":
			_tocar("recoger", mezcla)
			_poner_pelota()


func _tiene(anim: String) -> bool:
	return _animado and _ap.has_animation(anim)


func _tocar(anim: String, mezcla_s: float) -> void:
	if _tiene(anim):
		_ap.play(anim, mezcla_s)


func _process(delta: float) -> void:
	_t += delta
	var p := _pasos[_paso]
	match p["tipo"]:
		"caminar":
			var d: float = p["x"] - position.x
			position.x += signf(d) * minf(absf(d), _velocidad * delta)
			if absf(d) < 0.001:
				_siguiente()
		"girar":
			var k := clampf(_t / tiempo_giro, 0.0, 1.0)
			_rumbo = lerp_angle(_rumbo_desde, p["rumbo"], k)
			if k >= 1.0:
				_siguiente()
		"anim":
			if _t >= p["tiempo"]:
				_siguiente()
		"sentarse", "levantarse":
			var dur := _duracion(p["tipo"])
			var meta := Vector3(x_sofa, 0.0, z_camino)
			if p["tipo"] == "sentarse":
				meta = _pos_sentada if _animado else meta
			var k := smoothstep(0.0, 1.0, clampf(_t / dur, 0.0, 1.0))
			position = _desde.lerp(meta, k)
			if _t >= dur:
				_siguiente()
		"recoger":
			if _pelota.visible and _pelota.get_parent() != _anexo_mano() and _t >= _t_agarre:
				_pelota.reparent(_anexo_mano(), true)
			if _t >= (_t_fin_recoger if _animado else 1.5):
				_siguiente()
	rotation.y = _rumbo


func _duracion(tipo: String) -> float:
	if _tiene(tipo):
		return _ap.get_animation(tipo).length
	return mezcla_corte


## La pelota se deja en el piso justo donde la mano llega más abajo.
func _poner_pelota() -> void:
	get_parent().add_child(_pelota)
	_pelota.visible = true
	var donde := global_position + Vector3(0.35, 0.0, 0.25).rotated(Vector3.UP, rotation.y)
	if _animado and _mano != "":
		var rec := _ap.get_animation("recoger")
		var m := _en_mi(Carga.pose(_sk, rec, _sk.find_bone(_mano), _t_agarre).origin)
		donde = global_transform * m
	_pelota.global_position = Vector3(donde.x, 0.06, donde.z)


var _anexo: BoneAttachment3D


func _anexo_mano() -> Node3D:
	if _anexo == null and _sk:
		_anexo = BoneAttachment3D.new()
		_anexo.bone_name = _mano
		_sk.add_child(_anexo)
	return _anexo if _anexo else self


func _exit_tree() -> void:
	if _pelota and not _pelota.is_inside_tree():
		_pelota.free()
