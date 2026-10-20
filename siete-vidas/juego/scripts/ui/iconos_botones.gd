class_name IconosBotones
## Íconos de teclas y botones del mando para el Indicador, los diálogos y la libreta.
## Salen del paquete "Input Prompts Pixel" de Kenney (CC0, assets/kenney/, cuadros de 16 px); si la imagen
## no está o la tecla no tiene ícono, se dibuja una tecla simple por código con su nombre. Qué tecla o botón tiene
## cada acción lo dice Controles (el InputMap): si el jugador las cambia, los íconos cambian solos.

const HOJA := "res://assets/kenney/input-prompts-pixel.png"
const LADO := 16

## Tecla (physical_keycode) -> rectángulo en la hoja (columna, fila, ancho en cuadros).
const TECLADO := {
	KEY_A: [18, 3, 1], KEY_D: [20, 3, 1], KEY_W: [18, 2, 1], KEY_S: [19, 3, 1], KEY_SPACE: [17, 4, 1],
	KEY_SHIFT: [17, 7, 2], KEY_J: [24, 3, 1], KEY_E: [19, 2, 1], KEY_Q: [17, 2, 1], KEY_TAB: [19, 5, 2],
	KEY_ESCAPE: [17, 0, 1], KEY_ENTER: [32, 3, 1],
}
## Botón del mando (Xbox) -> rectángulo en la hoja: A, B, X, Y, RB, LB, View y Menu.
const MANDO := {
	JOY_BUTTON_A: [4, 0, 1], JOY_BUTTON_B: [5, 0, 1], JOY_BUTTON_X: [6, 0, 1], JOY_BUTTON_Y: [7, 0, 1],
	JOY_BUTTON_RIGHT_SHOULDER: [10, 16, 1], JOY_BUTTON_LEFT_SHOULDER: [9, 16, 1], JOY_BUTTON_BACK: [4, 18, 1],
	JOY_BUTTON_START: [5, 18, 1],
}

static var _hoja: Texture2D
static var _cache := {}


static func registrar_evento(evento: InputEvent) -> void:
	Controles.registrar_evento(evento)


## Ícono de la acción para el dispositivo en uso (o el pedido), o null si no hay imagen para ella.
static func textura(accion: String, mando: Variant = null) -> Texture2D:
	var e := Controles.evento(accion, mando)
	var datos: Variant = null
	var clave := ""
	if e is InputEventKey:
		var codigo := (e as InputEventKey).physical_keycode
		datos = TECLADO.get(codigo)
		clave = "t:%d" % codigo
	elif e is InputEventJoypadButton:
		var boton := (e as InputEventJoypadButton).button_index
		datos = MANDO.get(boton)
		clave = "m:%d" % boton
	if datos == null:
		return null
	if _cache.has(clave):
		return _cache[clave]
	if _hoja == null:
		_hoja = load(HOJA) if ResourceLoader.exists(HOJA) else null
	if _hoja == null:
		return null
	var cuadro := AtlasTexture.new()
	cuadro.atlas = _hoja
	cuadro.region = Rect2(int(datos[0]) * LADO, int(datos[1]) * LADO, int(datos[2]) * LADO, LADO)
	_cache[clave] = cuadro
	return cuadro


## Texto corto de la tecla o el botón (respaldo y para leerlo en las pruebas).
static func texto(accion: String, mando: Variant = null) -> String:
	return Controles.texto(accion, mando)


## Ancho que ocupa el ícono dibujado a `alto` px.
static func ancho(accion: String, alto := 16.0) -> float:
	var t := textura(accion)
	if t:
		return t.get_size().x * alto / LADO
	return maxf(alto, Estilo.fuente().get_string_size(texto(accion), HORIZONTAL_ALIGNMENT_LEFT, -1, int(alto * 0.6)).x + 6.0)


## Dibuja el ícono con la esquina de arriba a la izquierda en `pos`. Sin imagen, dibuja una tecla por código.
static func dibujar(c: CanvasItem, accion: String, pos: Vector2, alto := 16.0) -> void:
	var t := textura(accion)
	if t:
		c.draw_texture_rect(t, Rect2(pos, Vector2(t.get_size().x * alto / LADO, alto)), false)
		return
	var caja := Rect2(pos, Vector2(ancho(accion, alto), alto))
	c.draw_rect(caja, Estilo.color(&"tecla_borde"))
	c.draw_rect(caja.grow(-1), Estilo.color(&"tecla_cara"))
	c.draw_rect(Rect2(caja.position + Vector2(1, caja.size.y - 3), Vector2(caja.size.x - 2, 2)), Estilo.color(&"tecla_sombra"))
	var tam := int(alto * 0.6)
	var etiqueta := texto(accion)
	var ancho_texto := Estilo.fuente().get_string_size(etiqueta, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x
	c.draw_string(Estilo.fuente(), caja.position + Vector2((caja.size.x - ancho_texto) / 2.0, alto * 0.7), etiqueta, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, Estilo.color(&"tecla_texto"))
