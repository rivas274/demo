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
	for i in felipe.get_slide_collision_count():
		var choque := felipe.get_slide_collision(i)
		if choque.get_normal().y < -0.7 and choque.get_collider() is Node:
			var nombre := String((choque.get_collider() as Node).name)
			var cuerpo := nivel.pieza(nombre)
			# El piso del nivel (y lo que está a su altura) es "piso", no un mueble.
			if cuerpo != null and cuerpo.global_position.y < nivel.datos.suelo - 1.0:
				return nombre
	return "piso"


func revisar() -> void:
	var ahora := actual()
	if ahora != superficie or ahora != Profundidad.superficie_felipe:
		superficie = ahora
		Profundidad.felipe_cambio(get_tree(), ahora)
