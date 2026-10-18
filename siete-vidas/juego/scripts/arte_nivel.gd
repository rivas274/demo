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
