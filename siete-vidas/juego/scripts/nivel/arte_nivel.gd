class_name ArteNivel
## Arte del nivel 1 hecho con Gemini. `siete-vidas/herramientas/preparar_arte_nivel.py` lo deja en assets/nivel1/
## sin fondo y al tamaño del juego (1,21 px por cm), así que se dibuja a escala 1, apoyado en el piso.

const RUTA := "res://assets/nivel1/%s.png"

static var _cache := {}


static func textura(nombre: String) -> Texture2D:
	if not _cache.has(nombre):
		var ruta := RUTA % nombre
		_cache[nombre] = load(ruta) if ResourceLoader.exists(ruta) else null
	return _cache[nombre]


## Imagen y rectángulo (en el mundo) de una pieza dibujada en `c` con dibujar(); {} si no hay imagen.
## Lo usa el Indicador para el contorno del objeto cercano.
static func arte_en(c: Node2D, nombre: String, centro_x: float, base: float) -> Dictionary:
	var t := textura(nombre)
	if t == null:
		return {}
	var tam := t.get_size()
	return {"textura": t, "rect": Rect2(c.global_position + Vector2(centro_x - tam.x / 2.0, base - tam.y), tam)}


## Dibuja la pieza con la base en `base` y centrada en `centro_x` (en coordenadas de `c`). Devuelve si existía.
static func dibujar(c: CanvasItem, nombre: String, centro_x: float, base: float, espejo := false, tinte := Color.WHITE) -> bool:
	var t := textura(nombre)
	if t == null:
		return false
	var tam := t.get_size()
	if espejo:
		c.draw_set_transform(Vector2(centro_x, base), 0.0, Vector2(-1, 1))
		c.draw_texture(t, Vector2(-tam.x / 2.0, -tam.y), tinte)
		c.draw_set_transform(Vector2.ZERO)
	else:
		c.draw_texture(t, Vector2(centro_x - tam.x / 2.0, base - tam.y), tinte)
	return true


## Color de las sombras de contacto (de muebles, objetos y personajes).
const COLOR_SOMBRA := Color(0.12, 0.05, 0.03)


## Sombra de contacto de pixel (Gemini, pasada única): 2 px de alto, la fila de la base entera y la de delante 2 px más
## angosta por lado (bordes redondeados), nada de manchas grandes.
static func sombra(c: CanvasItem, centro: Vector2, ancho: float, alfa := 0.4) -> void:
	var filas := [[-1.0, 1.0, 1.0], [0.0, 1.0, 0.7]]
	for f: Array in filas:
		var w := roundf(ancho * f[1] / 2.0) * 2.0 - (4.0 if f[0] == 0.0 else 0.0)
		c.draw_rect(Rect2(roundf(centro.x - w / 2.0), roundf(centro.y) + f[0], w, 1.0), Color(COLOR_SOMBRA, alfa * f[2]))


# --- Dibujo por capas de cualquier nivel (lo usa el arte de cada nivel) ------------------------------------------

## Bases opacas del arte (sombras de contacto): imagen -> [x0, x1, patas [[centro], ...]] (en cache).
static var _bases := {}


## Dibuja las piezas de `arte` ([imagen, (x izquierda, base), espejo, capa]) que van en `capa`. Las de `apoyados` llevan
## su sombra de contacto sobre la cubierta del mueble; las de `especiales` (imagen -> Callable(lienzo, posición)) se
## dibujan con su propia función (la baranda con sus plantas que se mecen).
static func dibujar_capa(c: CanvasItem, arte: Array, capa: String, apoyados: Array = [], especiales := {}) -> void:
	for datos: Array in arte:
		if datos[3] != capa:
			continue
		if especiales.has(datos[0]):
			(especiales[datos[0]] as Callable).call(c, datos[1])
			continue
		var t := textura(datos[0])
		if t == null:
			continue
		if datos[0] in apoyados:
			# Sombra de contacto sobre la cubierta: 1 px más ancha que la base a cada lado (Gemini, tanda 3F).
			var base := base_opaca(datos[0])
			if not base.is_empty():
				sombra(c, Vector2(datos[1].x + (base[0] + base[1]) / 2.0, datos[1].y), base[1] - base[0] + 2.0, 0.5)
		dibujar(c, datos[0], datos[1].x + t.get_width() / 2.0, datos[1].y, datos[2])


## Sombra de lo colgado en la pared (G5): la silueta de las piezas de `con_sombra`, 1 px a la derecha y 2 px abajo, al 20 %.
static func sombras_de_pared(c: CanvasItem, arte: Array, con_sombra: Array) -> void:
	for datos: Array in arte:
		if datos[3] == "pared" and datos[0] in con_sombra:
			var t := textura(datos[0])
			if t:
				dibujar(c, datos[0], datos[1].x + t.get_width() / 2.0 + 1.0, datos[1].y + 2.0, datos[2], Color(0, 0, 0, 0.2))


## Sombras de contacto (crítica de Gemini y piso con profundidad): cada mueble de `piezas` ([imagen, (x, base), espejo])
## deja una sombra de pixel sobre el piso, centrada en su base (la mitad de atrás asoma entre las patas, la de delante
## cae sobre la banda del frente), y un bloque más oscuro bajo cada pata. Los muebles grandes tapan la luz en la unión
## pared-piso (`pared_base`) detrás de ellos. Va en la capa de la pared: debajo de los muebles y de Felipe.
static func sombras_de_contacto(c: CanvasItem, piezas: Array, pared_base: float) -> void:
	for datos: Array in piezas:
		var nombre: String = datos[0]
		var base := base_opaca(nombre)
		if base.is_empty():
			continue
		var x: float = datos[1].x
		var y: float = datos[1].y
		var ancho := float(textura(nombre).get_width())
		var espejo: bool = datos.size() > 2 and datos[2]
		var x0: float = x + (ancho - base[1] if espejo else base[0])
		var x1: float = x + (ancho - base[0] if espejo else base[1])
		sombra(c, Vector2((x0 + x1) / 2.0, y), x1 - x0 + 4.0, 0.3)
		# Bajo cada pata, 2 px más oscuros del ancho de la pata.
		for pata: Array in base[2]:
			var centro: float = x + (ancho - pata[0] if espejo else pata[0])
			c.draw_rect(Rect2(roundf(centro) - 2.0, y - 1.0, 4.0, 2.0), Color(0.08, 0.03, 0.02, 0.5))
		# Oclusión: los muebles grandes tapan la luz en la unión pared-piso detrás de ellos (1 px).
		if x1 - x0 >= 80.0:
			c.draw_rect(Rect2(roundf(x0), pared_base + 1.0, roundf(x1 - x0), 1.0), Color(COLOR_SOMBRA, 0.4))


## Base opaca de una imagen: [x0, x1 de las 3 filas de abajo, patas [[centro], ...] de la fila de abajo] (en cache).
static func base_opaca(nombre: String) -> Array:
	if _bases.has(nombre):
		return _bases[nombre]
	var t := textura(nombre)
	var base: Array = []
	if t:
		var imagen := t.get_image()
		var x0 := imagen.get_width()
		var x1 := 0
		for y in range(imagen.get_height() - 3, imagen.get_height()):
			for x in imagen.get_width():
				if imagen.get_pixel(x, y).a > 0.5:
					x0 = mini(x0, x)
					x1 = maxi(x1, x + 1)
		var patas: Array = []
		var desde := -1
		var abajo := imagen.get_height() - 1
		for x in imagen.get_width() + 1:
			var opaco := x < imagen.get_width() and imagen.get_pixel(x, abajo).a > 0.5
			if opaco and desde < 0:
				desde = x
			elif not opaco and desde >= 0:
				if x - desde <= 16:
					patas.append([(desde + x) / 2.0])
				desde = -1
		if x1 > x0:
			base = [float(x0), float(x1), patas]
	_bases[nombre] = base
	return base


## Repisa de pared con su tabla vista desde arriba (`fondo` px de hondo, más oscura junto a la pared) y un listón; la
## repisa con ménsulas de Gemini, estirada al ancho de la pieza, es el canto de delante. `adorno`: imagen encima (la
## caja de recuerdos del lugar visto) o "".
static func dibujar_repisa(c: CanvasItem, tamano: Vector2, fondo: float, adorno := "") -> void:
	var ancho := tamano.x + 8.0
	c.draw_rect(Rect2(-4, -fondo - 4, ancho, 4), Color("5a3626"))
	c.draw_rect(Rect2(-4, -fondo - 4, ancho, 1), Color("8a5a3c"))
	# Tabla vista desde arriba: más clara que el canto (le da la luz), en franjas que se oscurecen hacia la pared y con
	# las juntas de las tablas a lo largo.
	for k in 5:
		var franja := Rect2(-4, -fondo + k * fondo / 5.0, ancho, fondo / 5.0)
		c.draw_rect(franja, Color("d9a272").darkened(0.3 - k * 0.07))
	for junta: float in [0.35, 0.7]:
		c.draw_rect(Rect2(-4, roundf(-fondo * junta), ancho, 1), Color(0.35, 0.2, 0.12, 0.35))
	c.draw_rect(Rect2(-4, -fondo, ancho, 1), Color("4a2c1e"))
	c.draw_rect(Rect2(-5, -fondo, 1, fondo), Color("4a2c1e"))
	c.draw_rect(Rect2(ancho - 4, -fondo, 1, fondo), Color("4a2c1e"))
	var arte := textura("repisa")
	c.draw_texture_rect(arte, Rect2(-4, 0, ancho, ancho * arte.get_size().y / arte.get_size().x), false)
	if adorno != "":
		dibujar(c, adorno, tamano.x / 2.0, -8.0)
