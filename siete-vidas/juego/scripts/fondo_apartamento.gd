class_name FondoApartamento
extends Node2D
## Fondo del dúplex, en capas con parallax (como Silksong): lo lejano se mueve menos que la cámara
## y el primer plano, más. La pared es una imagen armada por habitación (Sala.HABITACIONES) con las
## ventanas recortadas (Sala.VENTANAS); por los huecos y el balcón se ve la ciudad.
## Arte provisional: cada estilo de pared se reemplaza por su textura final sin tocar el resto.

## nombre -> [cuánto sigue a la cámara (1 = igual que el juego), z_index, función que la dibuja]
const CAPAS := {
	"Cielo": [0.05, -40, "_dibujar_cielo"],
	"CiudadLejana": [0.2, -35, "_dibujar_ciudad_lejana"],
	"CiudadCercana": [0.45, -30, "_dibujar_ciudad_cercana"],
	"PrimerPlano": [1.3, Capas.PRIMER_PLANO_LEJOS, "_dibujar_primer_plano"],
}
## Paleta del Barrio Viejo: terracota y atardecer.
const CIELO := [Color("3b2a5a"), Color("c8576b"), Color("f2a65a"), Color("ffd58a")]
const SOL := Color("ffe3a3")
const CIUDAD_LEJANA := Color("7a4262")
const CIUDAD_CERCANA := [Color("8f4a4a"), Color("a65a45"), Color("7d3f3f")]
const VENTANA_ENCENDIDA := Color("ffcf7a")
const MOLDURA := Color("7f3b30")
const MADERA := Color("9a5b3c")
const MADERA_OSCURA := Color("6e3a26")
const CORTINA := Color("c46a5a")
const SILUETA := Color(0.17, 0.1, 0.13, 0.94)
const LUZ := Color(1.0, 0.85, 0.55, 0.09)
## Estilo de pared -> [mosaico de Gemini (assets/nivel1/), tinte]. Cada habitación tiene el suyo (hito, regla R9).
const PAREDES := {
	"tapiz": ["pared_tapiz", Color.WHITE],
	"tapiz_verde": ["pared_tapiz", Color(0.86, 1.0, 0.86)],
	"azulejo": ["pared_azulejo", Color.WHITE],
	"tapiz_azul": ["pared_tapiz", Color(0.84, 0.92, 1.06)],
	"rosa": ["pared_rosa", Color.WHITE],
	"tapiz_mostaza": ["pared_tapiz", Color(1.06, 0.95, 0.72)],
}
## Entre habitaciones: muro (no se ve, la cámara queda dentro de cada cuarto).
const MURO := Color("2a1d1a")

var ancho: float
var alto: float
var _textura_pared: ImageTexture


func _init(ancho_nivel: float, alto_nivel: float) -> void:
	ancho = ancho_nivel
	alto = alto_nivel
	name = "Fondo"


func _ready() -> void:
	for nombre: String in CAPAS:
		var datos: Array = CAPAS[nombre]
		var capa := Parallax2D.new()
		capa.name = nombre
		capa.scroll_scale = Vector2(datos[0], datos[0])
		capa.z_index = datos[1]
		var lienzo := _lienzo(datos[2])
		lienzo.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		capa.add_child(lienzo)
		add_child(capa)
	_textura_pared = ImageTexture.create_from_image(_crear_pared())
	var pared := _lienzo("_dibujar_pared")
	pared.name = "Pared"
	pared.z_index = Capas.PARED
	pared.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	add_child(pared)
	var luz := _lienzo("_dibujar_luz")
	luz.name = "Luz"
	luz.z_index = Capas.LUZ
	add_child(luz)


func _lienzo(funcion: String) -> Node2D:
	var lienzo := Node2D.new()
	lienzo.draw.connect(Callable(self, funcion).bind(lienzo))
	return lienzo


## Imagen de assets/nivel1/ como Image (para armar la pared), o null si no está.
func _imagen(nombre: String) -> Image:
	var textura := ArteNivel.textura(nombre) if nombre != "" else null
	if textura == null:
		return null
	var imagen := textura.get_image()
	imagen.convert(Image.FORMAT_RGBA8)
	return imagen


## Repite el mosaico dentro del rectángulo.
func _repetir(destino: Image, mosaico: Image, rect: Rect2i) -> void:
	var y := rect.position.y
	while y < rect.end.y:
		var x := rect.position.x
		while x < rect.end.x:
			var tam := Vector2i(mini(mosaico.get_width(), rect.end.x - x), mini(mosaico.get_height(), rect.end.y - y))
			destino.blit_rect(mosaico, Rect2i(Vector2i.ZERO, tam), Vector2i(x, y))
			x += mosaico.get_width()
		y += mosaico.get_height()


## Pinta cada habitación con su estilo y deja transparentes las ventanas y el exterior (balcón).
func _crear_pared() -> Image:
	var imagen := Image.create(int(ancho), int(alto), false, Image.FORMAT_RGBA8)
	imagen.fill(MURO)
	var moldura := _imagen("moldura")
	for habitacion: Array in Sala.HABITACIONES:
		var rect: Rect2i = Rect2i(habitacion[0])
		if habitacion[2] == "exterior":
			imagen.fill_rect(Rect2i(rect.position.x, 0, rect.size.x, int(Sala.SUELO)), Color(0, 0, 0, 0))
			continue
		var estilo: Array = PAREDES[habitacion[2]]
		var mosaico := _imagen(estilo[0])
		if estilo[1] != Color.WHITE:
			_tenir(mosaico, estilo[1])
		_repetir(imagen, mosaico, rect)
		_repetir(imagen, moldura, Rect2i(rect.position.x, rect.position.y, rect.size.x, moldura.get_height()))
		_repetir(imagen, moldura, Rect2i(rect.position.x, rect.end.y - moldura.get_height(), rect.size.x, moldura.get_height()))
	for ventana: Rect2 in Sala.VENTANAS:
		imagen.fill_rect(Rect2i(ventana), Color(0, 0, 0, 0))
	return imagen


func _tenir(imagen: Image, tinte: Color) -> void:
	for y in imagen.get_height():
		for x in imagen.get_width():
			var color := imagen.get_pixel(x, y)
			imagen.set_pixel(x, y, Color(minf(color.r * tinte.r, 1.0), minf(color.g * tinte.g, 1.0), minf(color.b * tinte.b, 1.0), color.a))


func _degradado(c: CanvasItem, rect: Rect2, arriba: Color, abajo: Color) -> void:
	var puntos := PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)])
	c.draw_polygon(puntos, PackedColorArray([arriba, arriba, abajo, abajo]))


func _dibujar_cielo(c: Node2D) -> void:
	var cielo := ArteNivel.textura("cielo")
	if cielo:
		c.draw_rect(Rect2(-200, -300, 1600, 300), Color("4f3a7a"))
		c.draw_rect(Rect2(-200, 790, 1600, 300), Color("f0915a"))
		c.draw_texture_rect(cielo, Rect2(-200, -100, 1600, 894), false)
		return
	var cortes := [-200.0, 160.0, 320.0, 450.0, 900.0]
	for i in CIELO.size():
		var siguiente: Color = CIELO[mini(i + 1, CIELO.size() - 1)]
		_degradado(c, Rect2(-200, cortes[i], 1600, cortes[i + 1] - cortes[i]), CIELO[i], siguiente)
	for i in 4:
		c.draw_circle(Vector2(520, 360), 70.0 - i * 10.0, Color(SOL, 0.12 + i * 0.05))
	c.draw_circle(Vector2(520, 360), 34.0, SOL)
	for nube: Vector3 in [Vector3(160, 180, 1.0), Vector3(760, 140, 1.4), Vector3(1050, 220, 0.8)]:
		for j in 4:
			c.draw_circle(Vector2(nube.x + j * 16 * nube.z, nube.y - (j % 2) * 7 * nube.z), 12.0 * nube.z, Color("f4a3a8", 0.55))


func _dibujar_ciudad_lejana(c: Node2D) -> void:
	if _dibujar_ciudad(c, "ciudad_lejana", 40.0, Color("a0626e")):
		return
	var azar := RandomNumberGenerator.new()
	azar.seed = 7
	var x := -40.0
	while x < 1400.0:
		var w := azar.randf_range(30, 70)
		var arriba := azar.randf_range(160, 330)
		c.draw_rect(Rect2(x, arriba, w, 700 - arriba), CIUDAD_LEJANA)
		match azar.randi() % 4:
			0: c.draw_circle(Vector2(x + w / 2, arriba), w / 3, CIUDAD_LEJANA)
			1: c.draw_line(Vector2(x + w * 0.7, arriba), Vector2(x + w * 0.7, arriba - 25), CIUDAD_LEJANA, 2)
		x += w + azar.randf_range(-6, 8)


func _dibujar_ciudad_cercana(c: Node2D) -> void:
	if _dibujar_ciudad(c, "ciudad_cercana", 110.0, Color("8a7a76")):
		return
	var azar := RandomNumberGenerator.new()
	azar.seed = 11
	var x := -40.0
	while x < 2100.0:
		var w := azar.randf_range(60, 120)
		var arriba := azar.randf_range(160, 420)
		var color: Color = CIUDAD_CERCANA[azar.randi() % CIUDAD_CERCANA.size()]
		c.draw_rect(Rect2(x, arriba, w, 900 - arriba), color)
		c.draw_rect(Rect2(x - 3, arriba, w + 6, 6), color.darkened(0.25))
		var fila := arriba + 18
		while fila < 880:
			var col := x + 10
			while col < x + w - 12:
				c.draw_rect(Rect2(col, fila, 8, 11), VENTANA_ENCENDIDA if azar.randf() < 0.35 else color.darkened(0.3))
				col += 18
			fila += 24
		if azar.randf() < 0.4:
			c.draw_rect(Rect2(x + w * 0.3, arriba - 22, 22, 18), color.darkened(0.4))
		x += w + azar.randf_range(4, 18)


## Fila de casas de Gemini repetida a lo ancho, con su base rellena hacia abajo.
func _dibujar_ciudad(c: Node2D, nombre: String, arriba: float, base: Color) -> bool:
	var ciudad := ArteNivel.textura(nombre)
	if ciudad == null:
		return false
	var tam := ciudad.get_size()
	c.draw_texture_rect(ciudad, Rect2(-200, arriba, 5000, tam.y), true)
	c.draw_rect(Rect2(-200, arriba + tam.y - 2, 5000, 900), base)
	return true


func _dibujar_pared(c: Node2D) -> void:
	c.draw_texture(_textura_pared, Vector2.ZERO)
	for ventana: Rect2 in Sala.VENTANAS:
		c.draw_rect(ventana.grow(3), MADERA_OSCURA, false, 6)
		c.draw_line(Vector2(ventana.get_center().x, ventana.position.y), Vector2(ventana.get_center().x, ventana.end.y), MADERA_OSCURA, 4)
		c.draw_line(Vector2(ventana.position.x, ventana.get_center().y), Vector2(ventana.end.x, ventana.get_center().y), MADERA_OSCURA, 4)
		c.draw_rect(Rect2(ventana.position.x - 30, ventana.position.y - 18, ventana.size.x + 60, 5), MADERA_OSCURA)
	# Piso de madera de cada habitación.
	var madera := ArteNivel.textura("piso")
	for habitacion: Array in Sala.HABITACIONES:
		var rect: Rect2 = habitacion[0]
		c.draw_texture_rect(madera, Rect2(rect.position.x, Sala.SUELO, rect.size.x, madera.get_height()), true)


func _dibujar_luz(c: Node2D) -> void:
	for ventana: Rect2 in Sala.VENTANAS:
		var piso := Sala.SUELO
		var rayo := PackedVector2Array([
			ventana.position, Vector2(ventana.end.x, ventana.position.y),
			Vector2(ventana.end.x + 140, piso), Vector2(ventana.position.x + 90, piso),
		])
		c.draw_colored_polygon(rayo, LUZ)


func _dibujar_primer_plano(c: Node2D) -> void:
	# Siluetas oscuras delante de Felipe, a la altura de la planta baja: dan profundidad y enmarcan.
	# Solo en el balcón (afuera): adentro taparían zonas de juego (M3).
	for planta: Vector3 in [Vector3(9760, 560, 0.6)]:
		_planta(c, Vector2(planta.x, planta.y), planta.z)


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
