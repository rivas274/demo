class_name Raton
extends Aspi
## Ratón de cuerda: el enemigo más fácil del apartamento. Va y viene sin perseguir y cae de un zarpazo.
## Medidas reales: 12 cm de largo (15 px de cuerpo). Arte provisional dibujado con código.


func _init(izquierda: float, derecha: float) -> void:
	super(izquierda, derecha)
	name = "Raton"
	ancho = 18.0
	alto = 9.0
	golpes_para_apagar = 1
	velocidad_patrulla = 55.0
	vision = 0.0


func _draw() -> void:
	if apagada:
		draw_rect(Rect2(-8, -4, 16, 4), Color("8a8f96"))
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
