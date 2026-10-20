class_name IconosBotones
## Íconos de teclas y botones del mando para el Indicador, los diálogos y la libreta.
## Salen del paquete "Input Prompts Pixel" de Kenney (CC0, assets/kenney/, cuadros de 16 px); si la imagen
## no está, se dibuja una tecla simple por código con la letra. Se muestra el dispositivo que se usó último.

const HOJA := "res://assets/kenney/input-prompts-pixel.png"
const LADO := 16

## acción -> rectángulo en la hoja (columna, fila, ancho en cuadros). Teclado.
const TECLADO := {
	"mover_izquierda": [18, 3, 1], "mover_derecha": [20, 3, 1], "mover_arriba": [18, 2, 1], "agacharse": [19, 3, 1],
	"saltar": [17, 4, 1], "zoomies": [17, 7, 2], "zarpazo": [24, 3, 1], "interactuar": [19, 2, 1],
	"maullar": [17, 2, 1], "agenda": [19, 5, 2], "pausa": [17, 0, 1], "saltar_dialogo": [32, 3, 1],
}
## Mando (Xbox): A, B, X, Y, RB, LB, View y Menu.
const MANDO := {
	"saltar": [4, 0, 1], "maullar": [5, 0, 1], "zarpazo": [6, 0, 1], "interactuar": [7, 0, 1],
	"zoomies": [10, 16, 1], "saltar_dialogo": [9, 16, 1], "agenda": [4, 18, 1], "pausa": [5, 18, 1],
}
## Texto de respaldo (si falta la imagen o el ícono): [tecla, botón del mando].
const TEXTO := {
	"mover_izquierda": ["A", "←"], "mover_derecha": ["D", "→"], "mover_arriba": ["W", "↑"], "agacharse": ["S", "↓"],
	"saltar": ["Espacio", "A"], "zoomies": ["Shift", "RB"], "zarpazo": ["J", "X"], "interactuar": ["E", "Y"],
	"maullar": ["Q", "B"], "agenda": ["Tab", "View"], "pausa": ["Esc", "Menu"], "saltar_dialogo": ["Enter", "LB"],
}

## Último dispositivo usado (lo actualiza registrar_evento).
static var usa_mando := false
static var _hoja: Texture2D
static var _cache := {}


## Llamar desde _input de algún nodo: cambia a íconos de mando o de teclado según lo último que se tocó.
static func registrar_evento(evento: InputEvent) -> void:
	if evento is InputEventJoypadButton or (evento is InputEventJoypadMotion and absf((evento as InputEventJoypadMotion).axis_value) > 0.5):
		usa_mando = true
	elif evento is InputEventKey:
		usa_mando = false


## Ícono de la acción para el dispositivo en uso (o el pedido), o null si no hay imagen para ella.
static func textura(accion: String, mando: Variant = null) -> Texture2D:
	var de_mando: bool = usa_mando if mando == null else bool(mando)
	var tabla: Dictionary = MANDO if de_mando else TECLADO
	if not tabla.has(accion):
		return null
	var clave := ("m:" if de_mando else "t:") + accion
	if _cache.has(clave):
		return _cache[clave]
	if _hoja == null:
		_hoja = load(HOJA) if ResourceLoader.exists(HOJA) else null
	if _hoja == null:
		return null
	var datos: Array = tabla[accion]
	var cuadro := AtlasTexture.new()
	cuadro.atlas = _hoja
	cuadro.region = Rect2(int(datos[0]) * LADO, int(datos[1]) * LADO, int(datos[2]) * LADO, LADO)
	_cache[clave] = cuadro
	return cuadro


## Texto corto de la tecla o el botón (respaldo y para leerlo en las pruebas).
static func texto(accion: String, mando: Variant = null) -> String:
	var de_mando: bool = usa_mando if mando == null else bool(mando)
	return String(TEXTO.get(accion, [accion, accion])[1 if de_mando else 0])


## Ancho que ocupa el ícono dibujado a `alto` px.
static func ancho(accion: String, alto := 16.0) -> float:
	var t := textura(accion)
	if t:
		return t.get_size().x * alto / LADO
	return maxf(alto, ThemeDB.fallback_font.get_string_size(texto(accion), HORIZONTAL_ALIGNMENT_LEFT, -1, int(alto * 0.6)).x + 6.0)


## Dibuja el ícono con la esquina de arriba a la izquierda en `pos`. Sin imagen, dibuja una tecla por código.
static func dibujar(c: CanvasItem, accion: String, pos: Vector2, alto := 16.0) -> void:
	var t := textura(accion)
	if t:
		c.draw_texture_rect(t, Rect2(pos, Vector2(t.get_size().x * alto / LADO, alto)), false)
		return
	var caja := Rect2(pos, Vector2(ancho(accion, alto), alto))
	c.draw_rect(caja, Color("3b3646"))
	c.draw_rect(caja.grow(-1), Color("e8e4dc"))
	c.draw_rect(Rect2(caja.position + Vector2(1, caja.size.y - 3), Vector2(caja.size.x - 2, 2)), Color("a8a2b0"))
	var tam := int(alto * 0.6)
	var etiqueta := texto(accion)
	var ancho_texto := ThemeDB.fallback_font.get_string_size(etiqueta, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x
	c.draw_string(ThemeDB.fallback_font, caja.position + Vector2((caja.size.x - ancho_texto) / 2.0, alto * 0.7), etiqueta, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, Color("2b2421"))
