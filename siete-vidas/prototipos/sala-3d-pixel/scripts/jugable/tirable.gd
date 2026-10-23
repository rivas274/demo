# PROTOTIPO: no es código del juego.
# Pregunta: ¿se siente bien controlar a Felipe 3D (con rig) en una sala jugable: caminar, saltar
# a los muebles, arañar, tirar cosas y pedirle a Valeria?
# Fecha: 2026-10-23
# Vaso o taza sobre un mueble: quieto (congelado) hasta el manotazo; entonces cae con física
# hacia el borde del mueble (lado_caida), con el eje Z bloqueado (no sale de su plano). El vaso
# se rompe en pedazos al tocar el piso; la taza rueda. Avisa con `caido` para que
# Valeria vaya a recogerlo; `recoger()` lo hace desaparecer y al rato vuelve a su lugar.
extends RigidBody3D

signal caido(obj: Node3D, pos: Vector3)

@export var rompible := true
@export var alto := 0.24
@export var radio := 0.07
@export var color := Color("e8dccb")
## Alcance del manotazo: distancia en el piso y altura sobre los pies de Felipe (m).
@export var alcance := 0.5
@export var alcance_alto := 0.62
## Hacia qué borde del mueble sale con el manotazo (-1 izquierda, 1 derecha).
@export var lado_caida := -1.0

var _inicio := Transform3D.IDENTITY
var _volando := false
var _caido := false
var _vel_antes := Vector3.ZERO
var _malla: MeshInstance3D
var _forma: CollisionShape3D
var pedazos: Array[RigidBody3D] = []


func _ready() -> void:
	mass = 0.25
	collision_layer = 8
	collision_mask = 1 | 8 | 64
	axis_lock_linear_z = true
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	contact_monitor = true
	max_contacts_reported = 4
	freeze = true
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	var pm := PhysicsMaterial.new()
	pm.bounce = 0.15
	pm.friction = 0.6
	physics_material_override = pm
	_forma = CollisionShape3D.new()
	var cil := CylinderShape3D.new()
	cil.height = alto
	cil.radius = radio
	_forma.shape = cil
	add_child(_forma)
	_malla = MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.height = alto
	cm.top_radius = radio
	cm.bottom_radius = radio * (0.8 if rompible else 1.0)
	cm.radial_segments = 10
	cm.rings = 1
	_malla.mesh = cm
	_malla.material_override = Toon.material(color)
	add_child(_malla)
	if not rompible:
		# Asa de la taza.
		var asa := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.05, alto * 0.55, 0.03)
		asa.mesh = bm
		asa.position = Vector3(radio + 0.02, 0.0, 0.0)
		asa.material_override = Toon.material(color.darkened(0.15))
		add_child(asa)
	body_entered.connect(_al_tocar)
	add_to_group("interactuable")
	_inicio = global_transform


func _physics_process(_delta: float) -> void:
	if _volando:
		_vel_antes = linear_velocity


## Qué haría Felipe con E ("" si no está a su alcance).
func verbo(f: Node3D) -> String:
	if not freeze or _caido or not visible:
		return ""
	var d := global_position - f.global_position
	var base := global_position.y - alto * 0.5 - f.global_position.y
	if absf(d.x) <= alcance and base > -0.1 and base < alcance_alto:
		return "Tirar"
	return ""


func punto() -> Vector3:
	return global_position + Vector3.UP * (alto * 0.5 + 0.1)


func golpear(dir: Vector3) -> void:
	freeze = false
	_volando = true
	sleeping = false
	var lado := Vector3(lado_caida, 0.0, 0.0)
	apply_central_impulse((lado * 1.2 + Vector3.UP * 0.6) * mass)
	apply_torque_impulse(Vector3(0.0, 0.0, -lado_caida * 0.02))


func _al_tocar(_cuerpo: Node) -> void:
	# Cuenta como "tirado" al tocar algo más abajo que su mueble (piso, brazo o cojín del sofá).
	if not _volando or global_position.y > _inicio.origin.y - 0.05:
		return
	_volando = false
	_caido = true
	if rompible and _vel_antes.length() > 0.8:
		_romper()
	caido.emit(self, global_position)


func _romper() -> void:
	var donde := global_position
	visible = false
	_forma.set_deferred("disabled", true)
	set_deferred("freeze", true)
	for i in 8:
		var p := RigidBody3D.new()
		p.collision_layer = 16
		p.collision_mask = 1 | 64
		p.axis_lock_linear_z = true
		p.mass = 0.02
		var tam := Vector3(randf_range(0.03, 0.07), randf_range(0.02, 0.05), randf_range(0.03, 0.06))
		var f := CollisionShape3D.new()
		var b := BoxShape3D.new()
		b.size = tam
		f.shape = b
		p.add_child(f)
		var m := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = tam
		m.mesh = bm
		m.material_override = Toon.material(color if i % 3 else color.darkened(0.2))
		p.add_child(m)
		get_parent().add_child(p)
		p.global_position = donde + Vector3(randf_range(-0.05, 0.05), 0.04, randf_range(-0.05, 0.05))
		var ang := TAU * i / 8.0 + randf_range(-0.3, 0.3)
		p.linear_velocity = Vector3(cos(ang), 0.0, 0.0) * randf_range(0.4, 1.0) + Vector3.UP * randf_range(0.6, 1.2)
		p.angular_velocity = Vector3(randf_range(-9, 9), randf_range(-9, 9), randf_range(-9, 9))
		pedazos.append(p)


## Valeria lo recoge: los pedazos (o la taza) desaparecen y al rato vuelve a su mueble.
func recoger() -> void:
	for p in pedazos:
		if is_instance_valid(p):
			p.queue_free()
	pedazos.clear()
	visible = false
	_forma.set_deferred("disabled", true)
	set_deferred("freeze", true)
	get_tree().create_timer(2.5).timeout.connect(reponer)


func reponer() -> void:
	freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_transform = _inicio
	_forma.disabled = false
	visible = true
	_caido = false
	_volando = false


func esta_caido() -> bool:
	return _caido
