class_name Objeto
extends Node2D
## Objeto que Felipe tira de un manotazo: el vaso (se rompe y da «La Gravedad Funciona»), la taza de café y las macetas
## (aturden a lo que esté debajo) y las llaves (no se rompen: «¡CLINK CRÍTICO!»). Todo el comportamiento está en su
## pieza Tirable; este nodo solo lo dibuja: apoyado en el medio de la cubierta con su sombra de contacto, cayendo
## (gira) o roto en el piso. En la pelea lo roto vuelve a su lugar de a uno (Tirable.reponer, lo decide BatallaAspi).
## Escala de gato: vaso, taza, maceta y llaves al doble de su tamaño real (lado menor ≥ 24 px, R8).

## Qué es: "vaso", "taza", "maceta" o "llaves" (también la imagen de assets/nivel1/).
var tipo: String
var tirable: Tirable


## Fábrica: un objeto tirable apoyado `hundido` px dentro de la cubierta, que cae hasta `piso`.
static func crear(tipo_objeto: String, piso: float, hundido := 0.0) -> Objeto:
	var objeto := Objeto.new()
	objeto.tipo = tipo_objeto
	objeto.name = "Vaso" if tipo_objeto == "vaso" else tipo_objeto.capitalize()
	var pieza := Tirable.new()
	pieza.arte = tipo_objeto
	pieza.piso = piso
	pieza.hundido = hundido
	# El vaso se rompe y da su logro; lo demás aturde a lo que tenga debajo. Las llaves suenan a metal, no a vidrio.
	pieza.aturde = tipo_objeto != "vaso"
	pieza.logro = "La Gravedad Funciona" if tipo_objeto == "vaso" else ""
	pieza.sonido = "caja" if tipo_objeto == "llaves" else "vidrio"
	objeto.tirable = pieza
	objeto.add_child(pieza)
	return objeto


func _draw() -> void:
	var roto := tirable.roto
	var hundido := tirable.hundido
	if not roto and not tirable.cayendo:
		var t := ArteNivel.textura(tipo)
		if t:
			# Sombra de contacto (Gemini, tanda 3F): 1 px más ancha que la base a cada lado; el vaso, además, sobre un
			# posavasos de 1 px.
			var ancho := t.get_width() * 0.8 + 2.0
			if tipo == "vaso":
				draw_rect(Rect2(-ancho / 2.0 - 1.0, hundido - 1.0, ancho + 2.0, 1.0), Color("8a4a3a"))
			ArteNivel.sombra(self, Vector2(0, hundido), ancho + 2.0, 0.5)
			ArteNivel.dibujar(self, tipo, 0.0, hundido - (1.0 if tipo == "vaso" else 0.0))
			return
	if (not roto or tipo == "llaves") and ArteNivel.dibujar(self, tipo, 0.0, 0.0):
		return
	match tipo:
		"taza":
			# Rota: el charco de café y los trozos de loza (en la pelea, además, la mancha que A.S.P.I. limpia).
			draw_rect(Rect2(-15, -2, 30, 2), Color("4a2a1a"))
			draw_rect(Rect2(-11, -3, 20, 1), Color("6b3e22"))
			for trozo: Rect2 in [Rect2(-12, -6, 6, 4), Rect2(-2, -5, 5, 3), Rect2(6, -7, 7, 5)]:
				draw_rect(trozo.grow(1), Color("2b1712"))
				draw_rect(trozo, Color("f1e6d2"))
				draw_rect(Rect2(trozo.position, Vector2(trozo.size.x, 1)), Color("c0603f"))
		"maceta":
			if roto:
				draw_rect(Rect2(-10, -3, 20, 3), Color("6e4a2c"))
				draw_rect(Rect2(-8, -5, 6, 3), Color("b0613f"))
				draw_rect(Rect2(3, -4, 6, 3), Color("b0613f"))
				return
			draw_colored_polygon(PackedVector2Array([Vector2(-8, -14), Vector2(8, -14), Vector2(6, 0), Vector2(-6, 0)]), Color("b0613f"))
			draw_circle(Vector2(-3, -18), 5.0, Color("5f8f5a"))
			draw_circle(Vector2(4, -20), 5.0, Color("6f9f6a"))
		_:
			if roto:
				for trozo: Vector2 in [Vector2(-9, -2), Vector2(-3, -3), Vector2(4, -2), Vector2(9, -1)]:
					draw_colored_polygon(PackedVector2Array([trozo, trozo + Vector2(3, -2), trozo + Vector2(4, 1)]), Color(0.85, 0.93, 1.0, 0.8))
				draw_rect(Rect2(-12, -1, 24, 1), Color(0.6, 0.8, 1.0, 0.6))
				return
			draw_rect(Rect2(-5, -15, 10, 15), Color(0.85, 0.93, 1.0, 0.45))
			draw_rect(Rect2(-4, -9, 8, 8), Color(0.45, 0.7, 0.95, 0.6))
			draw_rect(Rect2(-5, -15, 10, 15), Color(0.9, 0.95, 1.0, 0.9), false, 1.0)
