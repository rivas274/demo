class_name KitUI
extends RefCounted
## Dibuja las piezas del kit de interfaz v2 («A + C», assets/ui/v2/, con su README) con las mismas medidas que la
## lámina aprobada (siete-vidas/diseno/revisiones/capturas/interfaz-rediseno/kit-v2.png). Las piezas viven en el tema
## (`datos/ui/tema.tres`, las pone `herramientas/interfaz_v2_tema.py`):
## - las que se estiran a lo ancho son estilos `v2_<pieza>`: se dibujan con su MEDIDA LÓGICA (la del layout) y el PNG
##   cae solo en su lugar con su sombra y su contorno (`expand_margin_*`);
## - las que no se estiran (huellas, flechas, sello, íconos, fondos de retrato y caras) son íconos `v2_<pieza>`.
## Nadie escribe aquí un color ni un tamaño de letra: los pide a `Estilo` por nombre.

## Px del texto de la base hasta la parte de arriba de las mayúsculas, por letra (a 16 px; a 32, el doble). Medido en
## las letras del juego: Pixel Operator y su negrita, 9 px de mayúscula; Silkscreen, 10.
const MAYUSCULA_16 := {"PixelOperator": 9, "Silkscreen": 10}
## Fragmentos alrededor de un retrato o del cartel: [x, y, tamaño] desde su centro (los mismos de la lámina; los
## calcula `kit.posiciones_fragmentos` con su semilla).
const FRAGMENTOS := {
	&"felipe": [[2, -7, 5], [0, -5, 3], [-5, -5, 4], [-3, 3, 5], [2, -6, 5]],
	&"valeria": [[-3, 4, 2], [7, 2, 4], [-9, -4, 3], [7, 1, 2], [0, 5, 2]],
	&"aspi": [[0, 4, 5], [-7, 0, 2], [-8, 3, 2], [1, 5, 4], [1, -7, 4]],
	&"jefe": [[-8, 1, 3], [3, 5, 4], [-10, -1, 2], [-5, 5, 2], [-1, -5, 5]],
	&"cartel": [[-4, 4, 2], [8, 3, 4], [-11, -5, 3], [9, 1, 2], [0, 6, 2]],
	&"ficha": [[0, 5, 4], [6, -3, 2], [-8, -5, 5], [-1, 4, 5], [-8, -2, 5]],
}
## Color de cada juego de fragmentos (la tira `fragmentos-<color>.png`).
const COLOR_FRAGMENTOS := {&"felipe": &"felipe", &"valeria": &"valeria", &"aspi": &"aspi", &"jefe": &"aspi",
	&"cartel": &"felipe", &"ficha": &"felipe"}


## Una pieza que se estira (estilo `v2_<nombre>`), con su medida lógica.
static func pieza(c: CanvasItem, nombre: String, rect: Rect2, modulado := Color.WHITE) -> void:
	var caja := Estilo.caja(StringName("v2_" + nombre.replace("-", "_")))
	if caja == null:
		return
	# El estilo es del tema (compartido): el tinte se pone solo para este dibujo.
	(caja as StyleBoxTexture).modulate_color = modulado
	caja.draw(c.get_canvas_item(), Rect2(rect.position.round(), rect.size.round()))
	(caja as StyleBoxTexture).modulate_color = Color.WHITE


## Textura de una pieza que no se estira o de una cara (`v2_<nombre>`).
static func textura(nombre: String) -> Texture2D:
	var id := StringName("v2_" + nombre.replace("-", "_"))
	return Estilo.tema().get_icon(id, Estilo.TIPO) if Estilo.tema().has_icon(id, Estilo.TIPO) else null


## Dibuja una pieza que no se estira con su esquina de arriba a la izquierda en `pos`.
static func icono(c: CanvasItem, nombre: String, pos: Vector2, modulado := Color.WHITE) -> void:
	var t := textura(nombre)
	if t:
		c.draw_texture(t, pos.round(), modulado)


## Una parte de un ícono (de abajo hacia arriba: `desde_abajo` 0 a 1), para la huella que se llena al curarse.
static func icono_desde_abajo(c: CanvasItem, nombre: String, pos: Vector2, desde_abajo: float) -> void:
	var t := textura(nombre)
	if t == null or desde_abajo <= 0.0:
		return
	var alto := roundf(t.get_height() * clampf(desde_abajo, 0.0, 1.0))
	var region := Rect2(0, t.get_height() - alto, t.get_width(), alto)
	c.draw_texture_rect_region(t, Rect2(pos.round() + Vector2(0, region.position.y), region.size), region)


## Cuánto corre la diagonal en una caja de alto `alto` (estilo A: 1 px cada 3, tope de 10).
static func inclinacion(alto: float, k := 3) -> int:
	return mini(int(alto) / k, 10)


## Px de la base del texto hasta la parte de arriba de sus mayúsculas, con el estilo `estilo`.
static func alto_mayuscula(estilo: StringName) -> int:
	var fuente := Estilo.fuente(estilo)
	var familia := "Silkscreen" if fuente and fuente.resource_path.contains("Silkscreen") else "PixelOperator"
	return MAYUSCULA_16[familia] * Estilo.letra(estilo) / 16


## Escribe con la parte de arriba de las mayúsculas en `y_mayus` (como la lámina). Con `contorno`, borde de 1 px.
static func escribir(c: CanvasItem, x: float, y_mayus: float, texto: String, estilo: StringName, color: Color, contorno := false) -> void:
	var base := Vector2(x, y_mayus + alto_mayuscula(estilo))
	if contorno:
		Estilo.texto_con_contorno(c, base, texto, estilo, color, &"ui_contorno", 2)
	else:
		Estilo.escribir(c, base, texto, estilo, color)


## Franja con texto (nombre, título): la pieza a lo ancho del texto + 16 px y el texto centrado en su alto. Devuelve
## el ancho.
static func franja_texto(c: CanvasItem, nombre: String, pos: Vector2, alto: float, texto: String, estilo: StringName, color: Color) -> float:
	var ancho := roundf(Estilo.ancho(texto, estilo)) + 16.0
	pieza(c, nombre, Rect2(pos, Vector2(ancho, alto)))
	escribir(c, pos.x + 8.0, pos.y + floorf((alto - alto_mayuscula(estilo)) / 2.0), texto, estilo, color)
	return ancho


## Los fragmentos (triangulitos del color del personaje) alrededor de `centro`. `vuelo` (0 a 1) los aleja un poco al
## entrar; con «Reducir movimiento» quedan quietos.
static func fragmentos(c: CanvasItem, juego: StringName, centro: Vector2, vuelo := 0.0) -> void:
	var tira := textura("fragmentos-" + String(COLOR_FRAGMENTOS.get(juego, &"felipe")))
	if tira == null:
		return
	if Opciones.reducir_movimiento:
		vuelo = 0.0
	for f: Array in FRAGMENTOS.get(juego, []):
		var t := int(f[2])
		var p := centro + Vector2(f[0], f[1]) * (1.0 + vuelo)
		c.draw_texture_rect_region(tira, Rect2(p.round(), Vector2(6, 6)), Rect2((t - 2) * 6, 0, 6, 6))
