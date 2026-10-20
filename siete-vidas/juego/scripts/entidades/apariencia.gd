class_name Apariencia
extends Node2D
## Pieza de dibujo de un Enemigo: su imagen (DatosEnemigo.arte) mirando hacia donde camina y, vencido, la de vencido
## (el ratón patas arriba, con la llave de cuerda que sigue girando). Se redibuja cada cuadro mientras se mueve; quieta
## (aturdida o vencida) queda como está, salvo la llave; el Enemigo la redibuja al golpearla o aturdirla.

var _enemigo: Enemigo


func _init() -> void:
	name = "Apariencia"


func _ready() -> void:
	_enemigo = get_parent() as Enemigo


func _physics_process(_delta: float) -> void:
	if not (_enemigo.vida.muerto or _enemigo.patrulla.esta_detenida()):
		queue_redraw()


## Lo que ocupa en el mundo (la cola de anuncios no lo tapa, G5).
func rect_dibujado() -> Rect2:
	var datos := _enemigo.datos
	return Rect2(global_position + Vector2(-datos.ancho / 2.0 - 2.0, -datos.alto_dibujo), Vector2(datos.ancho + 4.0, datos.alto_dibujo + 2.0))


func _draw() -> void:
	var datos := _enemigo.datos
	# Las imágenes miran a la izquierda: hacia la derecha van en espejo.
	var espejo := (signf(_enemigo.velocity.x) if _enemigo.velocity.x != 0.0 else 1.0) > 0.0
	if _enemigo.vida.muerto:
		var vencido := datos.arte_vencido if datos.arte_vencido != "" else datos.arte
		if ArteNivel.dibujar(self, vencido, 0.0, 0.0, espejo, Color.WHITE if datos.arte_vencido != "" else Color(0.6, 0.6, 0.62)):
			if datos.llave_de_cuerda:
				var giro := sin(Time.get_ticks_msec() * 0.02) * 4.0
				draw_line(Vector2(0, -38), Vector2(giro, -44), Color("d9a65b"), 2.0)
				queue_redraw()
			return
		draw_rect(Rect2(-8, -4, 16, 4), Color("8a8f96"))
		return
	if ArteNivel.dibujar(self, datos.arte, 0.0, datos.apoyo, espejo):
		return
	# Sin imagen: un bloque del tamaño de su cuerpo (arte provisional).
	draw_rect(Rect2(-datos.ancho / 2.0, -datos.alto, datos.ancho, datos.alto), Color("9aa0a8"))
