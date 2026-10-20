class_name IconosBotones
## Íconos de teclas y botones del mando para el Indicador, los diálogos y la libreta.
## Salen del paquete "Input Prompts Pixel" de Kenney (CC0, assets/kenney/, cuadros de 16 px); si la imagen
## no está o la tecla no tiene ícono, se dibuja una tecla simple por código con su nombre. Qué tecla o botón tiene
## cada acción lo dice Controles (el InputMap): si el jugador las cambia, los íconos cambian solos.

const HOJA := "res://assets/kenney/input-prompts-pixel.png"
## Los botones de PlayStation que le faltan a esa hoja, hechos de su botón redondo (herramientas/preparar_iconos_mando.py,
## colores del paquete «Input Prompts» 1.5 de Kenney, CC0): cruz, círculo, cuadrado y triángulo.
const HOJA_PLAYSTATION := "res://assets/kenney/input-prompts-playstation-pixel.png"
const LADO := 16

## Tecla (physical_keycode) -> rectángulo en la hoja (columna, fila, ancho en cuadros).
const TECLADO := {
	KEY_A: [18, 3, 1], KEY_D: [20, 3, 1], KEY_W: [18, 2, 1], KEY_S: [19, 3, 1], KEY_SPACE: [17, 4, 1],
	KEY_SHIFT: [17, 7, 2], KEY_J: [24, 3, 1], KEY_E: [19, 2, 1], KEY_Q: [17, 2, 1], KEY_TAB: [19, 5, 2],
	KEY_ESCAPE: [17, 0, 1], KEY_ENTER: [32, 3, 1],
}
## Botón del mando (Xbox, genérico y Steam Deck) -> rectángulo en la hoja: A, B, X, Y, RB, LB, View y Menu.
const MANDO := {
	JOY_BUTTON_A: [4, 0, 1], JOY_BUTTON_B: [5, 0, 1], JOY_BUTTON_X: [6, 0, 1], JOY_BUTTON_Y: [7, 0, 1],
	JOY_BUTTON_RIGHT_SHOULDER: [10, 16, 1], JOY_BUTTON_LEFT_SHOULDER: [9, 16, 1], JOY_BUTTON_BACK: [4, 18, 1],
	JOY_BUTTON_START: [5, 18, 1],
}

## Por tipo de mando (DetectorMando), los botones que se ven distintos: [columna, fila, ancho, hoja] (hoja 1 =
## HOJA_PLAYSTATION). Godot da los botones por posición: en Switch el de abajo (JOY_BUTTON_A) dice «B».
const MANDO_POR_TIPO := {
	&"playstation": {
		JOY_BUTTON_A: [0, 0, 1, 1], JOY_BUTTON_B: [1, 0, 1, 1], JOY_BUTTON_X: [2, 0, 1, 1], JOY_BUTTON_Y: [3, 0, 1, 1],
		JOY_BUTTON_LEFT_SHOULDER: [19, 18, 1], JOY_BUTTON_RIGHT_SHOULDER: [20, 18, 1],
	},
	&"switch": {
		JOY_BUTTON_A: [14, 0, 1], JOY_BUTTON_B: [13, 0, 1], JOY_BUTTON_X: [16, 0, 1], JOY_BUTTON_Y: [15, 0, 1],
		JOY_BUTTON_LEFT_SHOULDER: [15, 18, 1], JOY_BUTTON_RIGHT_SHOULDER: [16, 18, 1], JOY_BUTTON_BACK: [13, 20, 1],
		JOY_BUTTON_START: [14, 20, 1],
	},
}

static var _hojas := {}
static var _cache := {}


## DetectorMando avisa que cambió el mando: los íconos se vuelven a armar para ese tipo.
static func al_cambiar_mando(_tipo: StringName) -> void:
	_cache.clear()


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
		var propios: Dictionary = MANDO_POR_TIPO.get(Controles.tipo_mando, {})
		datos = propios.get(boton, MANDO.get(boton))
		clave = "m:%s:%d" % [Controles.tipo_mando, boton]
	if datos == null:
		return null
	if _cache.has(clave):
		return _cache[clave]
	var ruta := HOJA_PLAYSTATION if datos.size() > 3 and int(datos[3]) == 1 else HOJA
	if not _hojas.has(ruta):
		_hojas[ruta] = load(ruta) if ResourceLoader.exists(ruta) else null
	var hoja: Texture2D = _hojas[ruta]
	if hoja == null:
		return null
	var cuadro := AtlasTexture.new()
	cuadro.atlas = hoja
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
	return maxf(alto, Estilo.ancho(texto(accion), &"tecla") + 6.0)


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
	var etiqueta := texto(accion)
	var ancho_texto := Estilo.ancho(etiqueta, &"tecla")
	Estilo.escribir(c, caja.position + Vector2((caja.size.x - ancho_texto) / 2.0, alto * 0.5 + 4.0), etiqueta, &"tecla", Estilo.color(&"tecla_texto"))
