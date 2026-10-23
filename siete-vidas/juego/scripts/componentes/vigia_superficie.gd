class_name VigiaSuperficie
extends Node
## El evento central de la profundidad (v5): mira en qué superficie está Felipe DESPUÉS de que se movió en el cuadro
## (prioridad de física alta) y, solo si cambió, avisa a Profundidad.felipe_cambio. Así el cambio de capa es inmediato
## al aterrizar y al despegar, sin que cada objeto pregunte cada cuadro. Superficie: "piso", el nombre de la pieza
## (mueble) donde está parado o "aire". La crea el Nivel.

var nivel: Nivel
var felipe: Felipe
## La última superficie avisada.
var superficie := ""


func _init(de_nivel: Nivel, de_felipe: Felipe) -> void:
	name = "Vigía de superficie"
	nivel = de_nivel
	felipe = de_felipe
	process_physics_priority = 90
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	revisar()


func _physics_process(_delta: float) -> void:
	revisar()


## Dónde está parado Felipe ahora.
func actual() -> String:
	if felipe == null or not is_instance_valid(felipe):
		return "piso"
	if not felipe.is_on_floor():
		return "aire"
	# Lo que hay justo bajo sus patas (con la misma máscara con que choca): funciona también quieto, sin choques del
	# cuadro (move_and_slide no los registra si no se movió).
	var consulta := PhysicsPointQueryParameters2D.new()
	consulta.position = felipe.global_position + Vector2(0, 2)
	consulta.collision_mask = felipe.collision_mask
	for choque in felipe.get_world_2d().direct_space_state.intersect_point(consulta, 8):
		var cuerpo := choque["collider"] as Node2D
		if cuerpo == null:
			continue
		var pieza := nivel.pieza(String(cuerpo.name))
		# El piso del nivel (y lo que está a su altura) es "piso", no un mueble.
		if pieza != null and pieza == cuerpo and pieza.global_position.y < nivel.datos.suelo - 1.0:
			return String(cuerpo.name)
	return "piso"


func revisar() -> void:
	var ahora := actual()
	if ahora != superficie or ahora != Profundidad.superficie_felipe:
		superficie = ahora
		Profundidad.felipe_cambio(get_tree(), ahora)
