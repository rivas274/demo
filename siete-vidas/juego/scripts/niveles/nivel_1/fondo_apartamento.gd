class_name FondoApartamento
extends Node2D
## Fondo del dúplex, en capas con parallax (como Silksong): lo lejano se mueve menos que la cámara
## y el primer plano, más. La pared es una imagen armada por habitación (Nivel1.HABITACIONES) con las
## ventanas recortadas (Nivel1.VENTANAS); por los huecos y el balcón se ve la ciudad.
## Arte provisional: cada estilo de pared se reemplaza por su textura final sin tocar el resto.

## nombre -> [cuánto sigue a la cámara (1 = igual que el juego), z_index, función que la dibuja]
const CAPAS := {
	"Cielo": [0.05, -40, "_dibujar_cielo"],
	"CiudadLejana": [0.2, -35, "_dibujar_ciudad_lejana"],
	"CiudadCercana": [0.45, -30, "_dibujar_ciudad_cercana"],
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
## Paños del estudio: verde oliva apagado, contra la pared mostaza.
const TELA_ESTUDIO := Color("6f7a4a")
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
## Molduras de la casa (G4), iguales en los 6 cuartos interiores: zócalo de 3 px (Gemini, pasada única: 1 px de bisel
## claro arriba y 2 de madera; en el piso, 1 px de sombra en la unión) y cornisa de 14 px en dos tonos con dentículos
## cada 6 px; bajo la cornisa, 3 franjas de penumbra.
const ZOCALO := 3
const CORNISA := 14
const CANTO := Color("c98a5e")
const PENUMBRA := [0.12, 0.08, 0.04]
## Cocina (C-1): azulejo solo hasta 1,5 m (182 px) con un listel de 4 px; arriba, pintura lisa crema cálida.
const AZULEJO_ALTO := 182
const PINTURA_COCINA := Color("e9d6b4")
## Piso por estilo de cuarto (franjas de Gemini, pasada única): damero en la cocina, losa en el balcón y parquet en los
## demás.
const PISOS := {"azulejo": "piso_damero", "exterior": "piso_losa"}
## Rayos de luz (G6): el sol de la tarde entra por el oeste, siempre hacia la derecha. Tono por cuarto.
const TONO_LUZ := {
	"sala": Color(1.0, 0.74, 0.42), "cocina": Color(1.0, 0.93, 0.78), "pasillo": Color(0.74, 0.82, 0.95),
	"dormitorio": Color(1.0, 0.76, 0.78), "estudio": Color(1.0, 0.84, 0.45),
}
## Dónde empieza el hueco del vidrio en el marco de la casa (`ventana_casa`, 215 × 170; hueco de 150 × 120).
const HUECO_VENTANA := Vector2(32, 23)

## Entre habitaciones: muro (no se ve, la cámara queda dentro de cada cuarto).
const MURO := Color("2a1d1a")

var ancho: float
var alto: float
var _textura_pared: ImageTexture
var _textura_piso: ImageTexture
var _luz: Node2D
## Tono del cuarto cuyo rayo va sin motas de polvo ("" = todos con motas; la pelea con A.S.P.I. calma el estudio, v5).
var sin_motas := ""


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
	_luz = _lienzo("_dibujar_luz")
	_luz.name = "Luz"
	_luz.z_index = Capas.LUZ
	add_child(_luz)


## Las motas de polvo de los rayos suben despacio (G6): la luz se redibuja cada cuadro.
func _process(_delta: float) -> void:
	_luz.queue_redraw()


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


## Pinta cada habitación con su estilo y deja transparentes las ventanas y el exterior (balcón). Encima van la cornisa
## con su penumbra y el zócalo (G4); las puertas se dibujan delante y los cortan.
func _crear_pared() -> Image:
	var imagen := Image.create(int(ancho), int(alto), false, Image.FORMAT_RGBA8)
	imagen.fill(MURO)
	for habitacion: Array in Nivel1.HABITACIONES:
		# La pared termina en la unión con el piso (Nivel1.PARED_BASE), FONDO_PISO px sobre la línea de apoyo.
		var rect: Rect2i = Rect2i(habitacion[0])
		rect.size.y = int(Nivel1.PARED_BASE) - rect.position.y
		if habitacion[2] == "exterior":
			imagen.fill_rect(Rect2i(rect.position.x, 0, rect.size.x, int(Nivel1.PARED_BASE)), Color(0, 0, 0, 0))
			continue
		var estilo: Array = PAREDES[habitacion[2]]
		var mosaico := _imagen(estilo[0])
		if estilo[1] != Color.WHITE:
			_tenir(mosaico, estilo[1])
		if habitacion[2] == "azulejo":
			# Arriba, pintura lisa; abajo, el azulejo con menos contraste y un listel de remate.
			var pintura := _imagen("pared_rosa")
			_pintar(pintura, PINTURA_COCINA)
			_repetir(imagen, pintura, rect)
			_contraste(mosaico, 0.85)
			var corte := rect.end.y - AZULEJO_ALTO
			_repetir(imagen, mosaico, Rect2i(rect.position.x, corte, rect.size.x, AZULEJO_ALTO))
			imagen.fill_rect(Rect2i(rect.position.x, corte - 4, rect.size.x, 4), MADERA)
			imagen.fill_rect(Rect2i(rect.position.x, corte - 4, rect.size.x, 1), CANTO)
			imagen.fill_rect(Rect2i(rect.position.x, corte - 1, rect.size.x, 1), MADERA_OSCURA)
		else:
			_repetir(imagen, mosaico, rect)
		_molduras(imagen, rect)
	for ventana: Rect2 in Nivel1.VENTANAS:
		imagen.fill_rect(Rect2i(ventana), Color(0, 0, 0, 0))
	return imagen


## Cornisa, penumbra y zócalo de un cuarto (G4).
func _molduras(imagen: Image, rect: Rect2i) -> void:
	var x := rect.position.x
	var w := rect.size.x
	var arriba := rect.position.y
	# Penumbra bajo la cornisa: 3 franjas de 6 px que oscurecen la pared.
	for i in PENUMBRA.size():
		var franja := Rect2i(x, arriba + CORNISA + i * 6, w, 6)
		for yy in range(franja.position.y, franja.end.y):
			for xx in range(franja.position.x, franja.end.x):
				imagen.set_pixel(xx, yy, imagen.get_pixel(xx, yy).darkened(PENUMBRA[i]))
	# Cornisa: filete oscuro, cuerpo en dos tonos y una fila de dentículos.
	imagen.fill_rect(Rect2i(x, arriba, w, CORNISA), MADERA_OSCURA)
	imagen.fill_rect(Rect2i(x, arriba + 1, w, 5), MADERA)
	imagen.fill_rect(Rect2i(x, arriba + 1, w, 1), CANTO)
	imagen.fill_rect(Rect2i(x, arriba + 7, w, 5), MOLDURA)
	var d := x + 2
	while d < x + w - 3:
		imagen.fill_rect(Rect2i(d, arriba + 8, 3, 3), MADERA)
		d += 6
	imagen.fill_rect(Rect2i(x, arriba + CORNISA - 1, w, 1), Color("2b1712"))
	# Zócalo: bisel claro de 1 px arriba y 2 px de madera.
	var base := rect.end.y - ZOCALO
	imagen.fill_rect(Rect2i(x, base, w, ZOCALO), MADERA_OSCURA)
	imagen.fill_rect(Rect2i(x, base, w, 1), CANTO)


## Baja el contraste de un mosaico hacia su color promedio (R14).
func _contraste(imagen: Image, factor: float) -> void:
	var suma := Color(0, 0, 0)
	var n := imagen.get_width() * imagen.get_height()
	for y in imagen.get_height():
		for x in imagen.get_width():
			var c := imagen.get_pixel(x, y)
			suma = Color(suma.r + c.r / n, suma.g + c.g / n, suma.b + c.b / n)
	for y in imagen.get_height():
		for x in imagen.get_width():
			var c := imagen.get_pixel(x, y)
			imagen.set_pixel(x, y, Color(suma.r + (c.r - suma.r) * factor, suma.g + (c.g - suma.g) * factor, suma.b + (c.b - suma.b) * factor, c.a))


## Pintura lisa: la textura del mosaico conserva solo su luz (en escala de grises) sobre un color.
func _pintar(imagen: Image, color: Color) -> void:
	for y in imagen.get_height():
		for x in imagen.get_width():
			var luz := imagen.get_pixel(x, y).get_luminance()
			var k := 1.0 + (luz - 0.6) * 0.25
			imagen.set_pixel(x, y, Color(color.r * k, color.g * k, color.b * k))


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
	for ventana: Rect2 in Nivel1.VENTANAS:
		_dibujar_ventana(c, ventana)
	# Piso: la franja de Gemini, desde la unión con la pared hasta el borde de abajo.
	if _textura_piso == null:
		_textura_piso = ImageTexture.create_from_image(_crear_piso())
	c.draw_texture(_textura_piso, Vector2(0, Nivel1.PARED_BASE))
	for habitacion: Array in Nivel1.HABITACIONES:
		if habitacion[2] != "exterior":
			var rect: Rect2 = habitacion[0]
			# Sombra de 1 px donde el zócalo choca con el piso (Gemini).
			c.draw_rect(Rect2(rect.position.x, Nivel1.PARED_BASE, rect.size.x, 1), Color(0.1, 0.04, 0.02, 0.45))


static var _piso_en_cache: Image


## Arma el piso de todo el nivel (una sola vez; queda en cache entre escenas) con las franjas de Gemini (pasada única,
## 2026-10-19): parquet en los cuartos, damero en la cocina y losa en el balcón, SIN perspectiva (Gemini: en un
## plataformas lateral las tablas no convergen). Cada franja repite sin costura (`preparar_arte_nivel.pisos_gemini`) y
## mide lo que va de la unión pared-piso al borde de abajo. Cada cuarto corre el mosaico distinto para que las juntas no
## queden alineadas de un cuarto a otro.
func _crear_piso() -> Image:
	if _piso_en_cache:
		return _piso_en_cache
	var alto_piso := int(Nivel1.ALTO - Nivel1.PARED_BASE)
	var imagen := Image.create(int(ancho), alto_piso, false, Image.FORMAT_RGBA8)
	for i in Nivel1.HABITACIONES.size():
		var habitacion: Array = Nivel1.HABITACIONES[i]
		var rect := Rect2i(habitacion[0])
		var mosaico := _imagen(PISOS.get(habitacion[2], "piso_parquet"))
		var mw := mosaico.get_width()
		var corrimiento := (37 * (i + 1)) % mw
		for y in alto_piso:
			var v := mini(y, mosaico.get_height() - 1)
			for x in range(rect.position.x, rect.end.x):
				imagen.set_pixel(x, y, mosaico.get_pixel(posmod(x + corrimiento, mw), v))
	_piso_en_cache = imagen
	return imagen


## Ventana recortada (cocina, dormitorio, estudio): el mismo marco de la casa que el pasillo (`ventana_casa`, G2: madera,
## parante en cruz y alféizar de Gemini), con el hueco de 150 × 120 justo sobre el vidrio. Detrás, tinte y dos
## reflejos de pixel. La cocina lleva un visillo (C-3); el estudio, dos paños cortos (E-1); el dormitorio, la cortina
## larga de Gemini (ArteNivel1._dibujar_cortina, delante de la pared y detrás de los muebles).
func _dibujar_ventana(c: Node2D, ventana: Rect2) -> void:
	# Vidrio: tinte frío del 8 % y dos reflejos diagonales de pixel.
	c.draw_rect(ventana, Color(0.75, 0.88, 1.0, 0.08))
	for desde: float in [0.3, 0.72]:
		var x0 := ventana.position.x + ventana.size.x * desde
		c.draw_colored_polygon(PackedVector2Array([
			Vector2(x0, ventana.position.y), Vector2(x0 + 8, ventana.position.y),
			Vector2(x0 - 28, ventana.end.y), Vector2(x0 - 36, ventana.end.y),
		]), Color(1, 1, 1, 0.1))
	var centro := ventana.get_center()
	var marco := ArteNivel.textura("ventana_casa")
	if marco:
		c.draw_texture(marco, ventana.position - HUECO_VENTANA)
	if ventana == Nivel1.VENTANA_DORMITORIO:
		return
	if ventana == Nivel1.VENTANA_COCINA:
		# Visillo: cortina corta crema con franja terracota, de su propia barra, sobre el tercio de abajo del vidrio.
		var visillo := ArteNivel.textura("visillo_cocina")
		if visillo:
			ArteNivel.dibujar(c, "visillo_cocina", centro.x, ventana.end.y + 2.0)
		return
	# Estudio: barra con remates y dos paños cortos oliva (las cortinas cortas de Gemini) a los lados, hasta el alféizar.
	var barra := Rect2(ventana.position.x - 30, ventana.position.y - 3 - Nivel1.CORTINA_SOBRE_VENTANA, ventana.size.x + 60, 5)
	c.draw_rect(barra.grow(1), Color("2b1712"))
	c.draw_rect(barra, MADERA)
	for punta: float in [barra.position.x, barra.end.x]:
		c.draw_circle(Vector2(punta, barra.get_center().y), 4.0, MADERA_OSCURA)
	var pano := ArteNivel.textura("panos_estudio")
	if pano:
		var base := barra.position.y + pano.get_height()
		ArteNivel.dibujar(c, "panos_estudio", ventana.position.x - 8.0, base)
		ArteNivel.dibujar(c, "panos_estudio", ventana.end.x + 8.0, base, true)


## Vidrios de las 5 ventanas: [rectángulo, cuarto].
static func vidrios() -> Array:
	var sala := ArteNivel.textura("ventana_sala")
	var lista: Array = []
	if sala:
		var arte: Array = Nivel1.ARTE[0]
		var arriba: float = arte[1].y - sala.get_height()
		lista.append([Rect2(arte[1].x + 27, arriba + 26, 126, 111), "sala"])
	lista.append([Nivel1.VIDRIO_PASILLO, "pasillo"])
	lista.append([Nivel1.VENTANA_COCINA, "cocina"])
	lista.append([Nivel1.VENTANA_DORMITORIO, "dormitorio"])
	lista.append([Nivel1.VENTANA_ESTUDIO, "estudio"])
	return lista


## Rayos de luz (G6): uno por ventana, hacia la derecha, en 3 franjas escalonadas con el tono del cuarto, y 5 motas de
## polvo de 1 px que suben despacio dentro de cada rayo.
func _dibujar_luz(c: Node2D) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	# Los rayos llegan al piso un poco delante de la línea de apoyo.
	var piso := Nivel1.SUELO + 8.0
	for datos: Array in vidrios():
		var v: Rect2 = datos[0]
		var tono: Color = TONO_LUZ[datos[1]]
		for franja in 3:
			var adentro := v.size.x * 0.16 * franja
			c.draw_colored_polygon(PackedVector2Array([
				Vector2(v.position.x + adentro, v.position.y), Vector2(v.end.x - adentro, v.position.y),
				Vector2(v.end.x + 140 - adentro, piso), Vector2(v.position.x + 90 + adentro, piso),
			]), Color(tono, 0.035))
		for m in (0 if datos[1] == sin_motas else 5):
			var subida := fmod(t * 0.04 + m * 0.21 + v.position.x * 0.001, 1.0)
			var y := lerpf(piso - 6.0, v.position.y + 6.0, subida)
			var avance := (y - v.position.y) / (piso - v.position.y)
			var izquierda := v.position.x + 90.0 * avance
			var derecha := v.end.x + 140.0 * avance
			var x := lerpf(izquierda, derecha, fmod(m * 0.37 + 0.15, 0.8) + 0.1) + sin(t * 0.7 + m) * 3.0
			c.draw_rect(Rect2(roundf(x), roundf(y), 1, 1), Color(1.0, 0.95, 0.8, 0.55 * sin(subida * PI)))
