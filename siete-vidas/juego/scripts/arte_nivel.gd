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
