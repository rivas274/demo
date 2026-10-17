class_name FondoApartamento
extends Node2D
## Escenario provisional del apartamento, dibujado con código y separado en capas con parallax
## (como Silksong): lo lejano se mueve menos que la cámara y el primer plano, más.
## Es arte de prueba de concepto: se reemplaza por el arte final sin tocar el resto del juego.

## nombre -> [cuánto sigue a la cámara (1 = igual que el juego), z_index, función que la dibuja]
const CAPAS := {
	"Cielo": [0.05, -40, "_dibujar_cielo"],
	"CiudadLejana": [0.2, -35, "_dibujar_ciudad_lejana"],
	"CiudadCercana": [0.45, -30, "_dibujar_ciudad_cercana"],
	"PrimerPlano": [1.3, 20, "_dibujar_primer_plano"],
}
## Huecos de la pared por donde se ve la ciudad (coordenadas de la sala).
const VENTANAS := [Rect2(250, 150, 150, 140), Rect2(870, 150, 180, 140)]

## Paleta del Barrio Viejo: terracota y atardecer.
const CIELO := [Color("3b2a5a"), Color("c8576b"), Color("f2a65a"), Color("ffd58a")]
const SOL := Color("ffe3a3")
const CIUDAD_LEJANA := Color("7a4262")
const CIUDAD_CERCANA := [Color("8f4a4a"), Color("a65a45"), Color("7d3f3f")]
const VENTANA_ENCENDIDA := Color("ffcf7a")
const PARED := Color("e8d6c3")
const PARED_RAYA := Color("dfc9b2")
const MOLDURA := Color("7f3b30")
const MADERA := Color("9a5b3c")
const MADERA_OSCURA := Color("6e3a26")
const CORTINA := Color("c46a5a")
const SILUETA := Color(0.17, 0.1, 0.13, 0.94)
const LUZ := Color(1.0, 0.85, 0.55, 0.09)

var ancho: float
var suelo: float


func _init(ancho_sala: float, y_suelo: float) -> void:
	ancho = ancho_sala
	suelo = y_suelo
	name = "Fondo"


func _ready() -> void:
	for nombre: String in CAPAS:
		var datos: Array = CAPAS[nombre]
		var capa := Parallax2D.new()
		capa.name = nombre
		capa.scroll_scale = Vector2(datos[0], datos[0])
		capa.z_index = datos[1]
		capa.add_child(_lienzo(datos[2]))
		add_child(capa)
	var pared := _lienzo("_dibujar_pared")
	pared.name = "Pared"
	pared.z_index = -20
	add_child(pared)
	var luz := _lienzo("_dibujar_luz")
	luz.name = "Luz"
	luz.z_index = 5
	add_child(luz)


func _lienzo(funcion: String) -> Node2D:
	var lienzo := Node2D.new()
	lienzo.draw.connect(Callable(self, funcion).bind(lienzo))
	return lienzo


func _degradado(c: CanvasItem, rect: Rect2, arriba: Color, abajo: Color) -> void:
	var puntos := PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)])
	c.draw_polygon(puntos, PackedColorArray([arriba, arriba, abajo, abajo]))


func _dibujar_cielo(c: Node2D) -> void:
	var cortes := [-200.0, 120.0, 260.0, 380.0, 700.0]
	for i in CIELO.size():
		var siguiente: Color = CIELO[mini(i + 1, CIELO.size() - 1)]
		_degradado(c, Rect2(-200, cortes[i], 1400, cortes[i + 1] - cortes[i]), CIELO[i], siguiente)
	for i in 4:
		c.draw_circle(Vector2(430, 300), 70.0 - i * 10.0, Color(SOL, 0.12 + i * 0.05))
	c.draw_circle(Vector2(430, 300), 34.0, SOL)
	for nube: Vector3 in [Vector3(120, 140, 1.0), Vector3(620, 100, 1.4), Vector3(900, 170, 0.8)]:
		for j in 4:
			c.draw_circle(Vector2(nube.x + j * 16 * nube.z, nube.y - (j % 2) * 7 * nube.z), 12.0 * nube.z, Color("f4a3a8", 0.55))


func _dibujar_ciudad_lejana(c: Node2D) -> void:
	var azar := RandomNumberGenerator.new()
	azar.seed = 7
	var x := -40.0
	while x < 1300.0:
		var w := azar.randf_range(30, 70)
		var arriba := azar.randf_range(100, 230)
		c.draw_rect(Rect2(x, arriba, w, 500 - arriba), CIUDAD_LEJANA)
		match azar.randi() % 4:
			0: c.draw_circle(Vector2(x + w / 2, arriba), w / 3, CIUDAD_LEJANA)
			1: c.draw_line(Vector2(x + w * 0.7, arriba), Vector2(x + w * 0.7, arriba - 25), CIUDAD_LEJANA, 2)
		x += w + azar.randf_range(-6, 8)


func _dibujar_ciudad_cercana(c: Node2D) -> void:
	var azar := RandomNumberGenerator.new()
	azar.seed = 11
	var x := -40.0
	while x < 1500.0:
		var w := azar.randf_range(60, 120)
		var arriba := azar.randf_range(130, 270)
		var color: Color = CIUDAD_CERCANA[azar.randi() % CIUDAD_CERCANA.size()]
		c.draw_rect(Rect2(x, arriba, w, 560 - arriba), color)
		c.draw_rect(Rect2(x - 3, arriba, w + 6, 6), color.darkened(0.25))
		var fila := arriba + 18
		while fila < 520:
			var col := x + 10
			while col < x + w - 12:
				if azar.randf() < 0.35:
					c.draw_rect(Rect2(col, fila, 8, 11), VENTANA_ENCENDIDA)
				else:
					c.draw_rect(Rect2(col, fila, 8, 11), color.darkened(0.3))
				col += 18
			fila += 24
		if azar.randf() < 0.4:
			c.draw_rect(Rect2(x + w * 0.3, arriba - 22, 22, 18), color.darkened(0.4))
			c.draw_line(Vector2(x + w * 0.3 + 4, arriba), Vector2(x + w * 0.3 + 4, arriba - 4), color.darkened(0.4), 2)
		x += w + azar.randf_range(4, 18)


func _dibujar_pared(c: Node2D) -> void:
	var arriba_ventanas: float = VENTANAS[0].position.y
	var abajo_ventanas: float = VENTANAS[0].end.y
	var bandas: Array[Rect2] = [Rect2(0, 0, ancho, arriba_ventanas), Rect2(0, abajo_ventanas, ancho, suelo - abajo_ventanas)]
	var x := 0.0
	for ventana: Rect2 in VENTANAS:
		bandas.append(Rect2(x, arriba_ventanas, ventana.position.x - x, ventana.size.y))
		x = ventana.end.x
	bandas.append(Rect2(x, arriba_ventanas, ancho - x, abajo_ventanas - arriba_ventanas))
	for banda in bandas:
		c.draw_rect(banda, PARED)
		var raya := floorf(banda.position.x / 24.0) * 24.0
		while raya < banda.end.x:
			var izquierda := maxf(raya, banda.position.x)
			var derecha := minf(raya + 10, banda.end.x)
			if derecha > izquierda:
				c.draw_rect(Rect2(izquierda, banda.position.y, derecha - izquierda, banda.size.y), PARED_RAYA)
			raya += 24
	c.draw_rect(Rect2(0, 0, ancho, 22), MOLDURA)
	c.draw_rect(Rect2(0, 22, ancho, 4), MOLDURA.darkened(0.3))
	c.draw_rect(Rect2(0, suelo - 14, ancho, 14), MOLDURA)
	for ventana: Rect2 in VENTANAS:
		c.draw_rect(ventana.grow(3), MADERA_OSCURA, false, 6)
		c.draw_line(Vector2(ventana.get_center().x, ventana.position.y), Vector2(ventana.get_center().x, ventana.end.y), MADERA_OSCURA, 4)
		c.draw_line(Vector2(ventana.position.x, ventana.get_center().y), Vector2(ventana.end.x, ventana.get_center().y), MADERA_OSCURA, 4)
		c.draw_rect(Rect2(ventana.position.x - 22, ventana.position.y - 14, 18, ventana.size.y + 30), CORTINA)
		c.draw_rect(Rect2(ventana.end.x + 4, ventana.position.y - 14, 18, ventana.size.y + 30), CORTINA)
		c.draw_rect(Rect2(ventana.position.x - 30, ventana.position.y - 18, ventana.size.x + 60, 5), MADERA_OSCURA)
	# Cuadros en la pared: el retrato oficial de Su Majestad y un paisaje.
	c.draw_rect(Rect2(560, 120, 70, 84), MADERA_OSCURA)
	c.draw_rect(Rect2(566, 126, 58, 72), Color("d9a65b"))
	c.draw_circle(Vector2(595, 158), 18, Color("8b7864"))
	c.draw_rect(Rect2(1480, 250, 110, 70), MADERA_OSCURA)
	c.draw_rect(Rect2(1486, 256, 98, 58), Color("6f8f8a"))
	# Piso de madera.
	c.draw_rect(Rect2(0, suelo, ancho, 200), MADERA)
	var tabla := 0.0
	while tabla < ancho:
		c.draw_line(Vector2(tabla, suelo), Vector2(tabla, suelo + 30), MADERA_OSCURA, 2)
		tabla += 64
	c.draw_line(Vector2(0, suelo + 15), Vector2(ancho, suelo + 15), MADERA_OSCURA, 1)


func _dibujar_luz(c: Node2D) -> void:
	for ventana: Rect2 in VENTANAS:
		var rayo := PackedVector2Array([
			ventana.position, Vector2(ventana.end.x, ventana.position.y),
			Vector2(ventana.end.x + 140, suelo), Vector2(ventana.position.x + 90, suelo),
		])
		c.draw_colored_polygon(rayo, LUZ)


func _dibujar_primer_plano(c: Node2D) -> void:
	# Siluetas oscuras delante de Felipe: dan profundidad y enmarcan la sala.
	_planta(c, Vector2(300, 610), 0.8)
	_planta(c, Vector2(2280, 610), 1.0)
	# Respaldo de una silla.
	c.draw_rect(Rect2(1380, 470, 12, 160), SILUETA)
	c.draw_rect(Rect2(1450, 470, 12, 160), SILUETA)
	c.draw_rect(Rect2(1374, 470, 94, 14), SILUETA)
	c.draw_rect(Rect2(1374, 510, 94, 8), SILUETA)
	# Lámpara colgando del techo.
	c.draw_line(Vector2(1020, -60), Vector2(1020, 60), SILUETA, 3)
	c.draw_colored_polygon(PackedVector2Array([Vector2(995, 90), Vector2(1045, 90), Vector2(1030, 58), Vector2(1010, 58)]), SILUETA)


func _planta(c: CanvasItem, base: Vector2, tamano: float) -> void:
	c.draw_colored_polygon(PackedVector2Array([
		base + Vector2(-24, -40) * tamano, base + Vector2(24, -40) * tamano,
		base + Vector2(18, 20) * tamano, base + Vector2(-18, 20) * tamano,
	]), SILUETA)
	for hoja: Vector2 in [Vector2(-70, -110), Vector2(-25, -150), Vector2(20, -140), Vector2(65, -95), Vector2(-85, -60), Vector2(80, -50)]:
		_hoja(c, base + Vector2(0, -40) * tamano, base + hoja * tamano, 14.0 * tamano)


## Hoja alargada: un rombo curvo entre el tallo y la punta.
func _hoja(c: CanvasItem, desde: Vector2, hacia: Vector2, ancho_hoja: float) -> void:
	var largo := hacia - desde
	var lado := largo.orthogonal().normalized() * ancho_hoja
	var puntos := PackedVector2Array()
	for i in 9:
		var t := i / 8.0
		puntos.append(desde + largo * t + lado * sin(t * PI))
	for i in range(7, 0, -1):
		var t := i / 8.0
		puntos.append(desde + largo * t - lado * sin(t * PI) * 0.6)
	c.draw_colored_polygon(puntos, SILUETA)
