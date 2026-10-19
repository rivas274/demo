class_name Raton
extends Aspi
## Ratón de cuerda: el enemigo más fácil del apartamento. Va y viene sin perseguir y cae de un zarpazo.
## Escala de gato: mide la mitad que Felipe, para que se lea como el juguete enorme que es para él.
## Se apoya por el cuerpo, no por la cola (G1: la cola cuelga 7 px bajo el cuerpo en el arte). Al caer queda patas
## arriba, con la llave girando y un resorte.

## Pixeles de cola bajo el cuerpo en raton.png.
const COLA := 7.0


func _init(izquierda: float, derecha: float) -> void:
	super(izquierda, derecha)
	name = "Raton"
	# Escala de gato: la mitad de Felipe.
	ancho = 48.0
	alto = 30.0
	golpes_para_apagar = 1
	velocidad_patrulla = 55.0
	vision = 0.0


func recibir_zarpazo(felipe: Felipe) -> void:
	var antes := apagada
	super(felipe)
	if apagada and not antes:
		var sala := get_parent()
		if sala and sala.has_method("sonar"):
			sala.sonar("resorte")


func _draw() -> void:
	if apagada:
		# Patas arriba, con la llave que sigue girando.
		if ArteNivel.dibujar(self, "raton_volcado", 0.0, 0.0, _direccion_dibujo() > 0.0):
			var giro := sin(Time.get_ticks_msec() * 0.02) * 4.0
			draw_line(Vector2(0, -38), Vector2(giro, -44), Color("d9a65b"), 2.0)
			queue_redraw()
			return
		draw_rect(Rect2(-8, -4, 16, 4), Color("8a8f96"))
		return
	# La imagen mira a la izquierda; se apoya por el cuerpo (la cola queda sobre el piso).
	if ArteNivel.dibujar(self, "raton", 0.0, COLA, _direccion_dibujo() > 0.0):
		return
	var cuerpo := Color("9aa0a8")
	draw_circle(Vector2(0, -5), 5.0, cuerpo)
	draw_rect(Rect2(-6, -6, 10, 6), cuerpo)
	draw_circle(Vector2(_direccion_dibujo() * 6.0, -6), 2.5, Color("e59aa2"))
	draw_circle(Vector2(_direccion_dibujo() * 7.0, -4), 1.0, Color("241c1a"))
	# Llave de cuerda en el lomo, que gira.
	var giro := sin(Time.get_ticks_msec() * 0.02) * 3.0
	draw_line(Vector2(-1, -10), Vector2(-1 + giro, -14), Color("d9a65b"), 2.0)
	draw_line(Vector2(-_direccion_dibujo() * 6.0, -3), Vector2(-_direccion_dibujo() * 12.0, -6), cuerpo, 1.0)


func _direccion_dibujo() -> float:
	return signf(velocity.x) if velocity.x != 0.0 else 1.0
