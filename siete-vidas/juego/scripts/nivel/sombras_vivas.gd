class_name SombrasVivas
extends Node2D
## Sombras de contacto de lo que se mueve, en la capa de los muebles (debajo de los personajes y encima de los muebles:
## se apoyan también arriba de un mueble). La de Felipe cae en la superficie que tiene debajo (también en el aire: se
## achica y se aclara con la altura, así se lee dónde va a caer). Las demás las piden sus piezas SombraContacto
## (ratones, A.S.P.I., la caja, la comida, Valeria). Sirve para cualquier nivel.

var felipe: Felipe


func _init(de: Felipe) -> void:
	felipe = de
	name = "Sombras"


func _draw() -> void:
	var espacio := get_world_2d().direct_space_state
	var rayo := PhysicsRayQueryParameters2D.create(felipe.global_position + Vector2(0, -4), felipe.global_position + Vector2(0, 400))
	rayo.exclude = [felipe.get_rid()]
	var choque := espacio.intersect_ray(rayo)
	if not choque.is_empty() and felipe.visible:
		var altura: float = choque.position.y - felipe.global_position.y
		var cerca := clampf(1.0 - altura / 260.0, 0.35, 1.0)
		ArteNivel.sombra(self, Vector2(felipe.global_position.x, choque.position.y), 40.0 * cerca, 0.42 * cerca)
	for pieza: SombraContacto in get_tree().get_nodes_in_group(SombraContacto.GRUPO):
		if pieza.se_ve():
			ArteNivel.sombra(self, pieza.centro(), pieza.ancho, pieza.alfa * (pieza.get_parent() as CanvasItem).modulate.a)
