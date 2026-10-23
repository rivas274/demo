class_name CuadroDialogo
extends Control
## Pieza de interfaz: el cuadro de diálogo de la interfaz v2 («A + C», kit assets/ui/v2/), con las medidas de la
## lámina aprobada (zona B: arriba de y 44 a 103; con texto grande, de 64 a 163; abajo, si Felipe está arriba, hasta
## y 342):
## - la caja oscura de 528 px (x 80 a 608) con las esquinas cortadas, las líneas crema y la sombra dura de 3 px DEL
##   COLOR del personaje (ámbar Felipe, magenta Valeria, rojo A.S.P.I.);
## - el retrato de 52 px a la izquierda (desde x 32) sobre su fondo inclinado del mismo color, con sus fragmentos;
## - la franja del nombre en bloque del color y la flecha de «sigue» que late;
## - el texto (nodo %Texto) a 24 px del borde de la caja: queda 13 px libre después del retrato (12 en grande).
## Entra subiendo 10 px en 150 ms (con «Reducir movimiento», solo aparece). No sabe de colas: `Dialogo` le dice qué
## mostrar con armar().
## Escena: escenas/ui/cuadro_dialogo.tscn.

const X_CAJA := 80.0
const ANCHO_CAJA := 528.0
## Por tamaño de texto (1 normal, 2 grande): alto de la franja del nombre, alto de una línea y dónde empieza el texto
## (arriba de las mayúsculas) dentro de la caja.
const FRANJA := {1: 15.0, 2: 26.0}
const LINEA := {1: 17.0, 2: 34.0}
const Y_TEXTO := {1: 9.0, 2: 13.0}
const LINEAS := 2
## Sangría del texto: la diagonal de la caja más 14 px.
const SANGRIA_EXTRA := 14.0
const MARGEN_DERECHO := 24.0
const SUBIDA := 10.0
const ENTRADA := 0.15

var quien := "felipe"
var cara: Texture2D
var nombre := ""
## 1 normal, 2 texto grande (200 %).
var escala := 1
var abajo := false
var _t := 0.0
var _entrada := 1.0

@onready var texto: RichTextLabel = %Texto


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = ZonasTexto.PANTALLA.size


## Arma el cuadro para `quien` con esa cara y ese nombre, arriba (o abajo), normal o grande, y lo hace entrar.
func armar(de: String, con_cara: Texture2D, con_nombre: String, grande: bool, en_abajo: bool) -> void:
	quien = de
	cara = con_cara
	nombre = con_nombre
	escala = 2 if grande else 1
	abajo = en_abajo
	var estilo := estilo_texto()
	texto.add_theme_color_override("default_color", Estilo.color(&"ui_texto"))
	texto.add_theme_font_override("normal_font", Estilo.fuente(estilo))
	texto.add_theme_font_size_override("normal_font_size", Estilo.letra(estilo))
	texto.add_theme_constant_override("line_separation", int(LINEA[escala]) - Estilo.fuente(estilo).get_height(Estilo.letra(estilo)))
	var caja := rect_caja()
	var x := caja.position.x + sangria()
	# El texto se pone con su caja de línea: la parte de arriba de las mayúsculas cae en Y_TEXTO.
	var arriba: float = caja.position.y + Y_TEXTO[escala] + KitUI.alto_mayuscula(estilo) - Estilo.fuente(estilo).get_ascent(Estilo.letra(estilo))
	texto.position = Vector2(x, roundf(arriba))
	texto.size = Vector2(ancho_texto(), LINEA[escala] * LINEAS + 4.0)
	_entrada = 0.0 if not Opciones.reducir_movimiento else 1.0
	_t = 0.0
	queue_redraw()


func estilo_texto() -> StringName:
	return &"dialogo_texto_grande" if escala == 2 else &"dialogo_texto"


func estilo_nombre() -> StringName:
	return &"dialogo_nombre_grande" if escala == 2 else &"dialogo_nombre"


func alto_caja() -> float:
	return 16.0 + LINEAS * LINEA[escala]


## Dónde va la franja del nombre (y): arriba, bajo la salud (y bajo la barra del jefe, si se ve: ZonasTexto.techo);
## abajo, sobre la caja que termina en el borde de la zona segura.
func y_franja() -> float:
	if abajo:
		return rect_caja().position.y - floorf(FRANJA[escala] / 2.0) - 2.0
	return ZonasTexto.techo(escala == 2)


func rect_caja() -> Rect2:
	var alto := alto_caja()
	var y := ZonasTexto.SEGURA.end.y - alto if abajo else ZonasTexto.techo(escala == 2) + floorf(FRANJA[escala] / 2.0) + 2.0
	return Rect2(X_CAJA, y, ANCHO_CAJA, alto)


func sangria() -> float:
	return KitUI.inclinacion(alto_caja()) + SANGRIA_EXTRA


## Ancho del texto (lo usa Dialogo para partir en líneas y páginas).
func ancho_texto() -> float:
	return ANCHO_CAJA - sangria() - MARGEN_DERECHO


## Todo lo que ocupa en pantalla (franja, retrato y caja, con su medida lógica: la sombra de 3 px queda afuera).
func rect_en_pantalla() -> Rect2:
	var caja := rect_caja()
	var arriba := minf(y_franja(), caja.end.y - alto_fondo())
	return Rect2(ZonasTexto.SEGURA.position.x, arriba, caja.end.x - ZonasTexto.SEGURA.position.x, caja.end.y - arriba)


func alto_fondo() -> float:
	return minf(60.0, alto_caja() + 8.0)


func _process(delta: float) -> void:
	if not visible:
		return
	# Tiempo real (sin el congelado del Jugo).
	delta = delta / maxf(Engine.time_scale, 0.001)
	_t += delta
	if _entrada < 1.0:
		_entrada = minf(1.0, _entrada + delta / ENTRADA)
		texto.position.y = roundf(_y_texto_base() + (1.0 - _entrada) * SUBIDA)
	modulate.a = 0.4 + 0.6 * _entrada if not Opciones.reducir_movimiento else 1.0
	queue_redraw()


func _y_texto_base() -> float:
	var estilo := estilo_texto()
	return roundf(rect_caja().position.y + Y_TEXTO[escala] + KitUI.alto_mayuscula(estilo) - Estilo.fuente(estilo).get_ascent(Estilo.letra(estilo)))


func _draw() -> void:
	var sube := Vector2(0, roundf((1.0 - _entrada) * SUBIDA))
	var g := "-grande" if escala == 2 else ""
	var caja := rect_caja()
	caja.position += sube
	KitUI.pieza(self, "dialogo-marco-%s%s" % [quien, g], caja)
	# Retrato: fondo inclinado del color, fragmentos y la cara apoyada abajo.
	var fondo := Vector2(ZonasTexto.SEGURA.position.x, caja.end.y - alto_fondo())
	KitUI.icono(self, "retrato-fondo-%s%s" % [quien, g], fondo)
	KitUI.fragmentos(self, StringName(quien), fondo + Vector2(4, 2), 1.0 - _entrada)
	if cara:
		draw_texture(cara, Vector2(fondo.x + 3.0, caja.end.y - cara.get_height()))
	# Franja del nombre: Valeria en texto claro (sobre magenta); los demás en oscuro.
	var color_nombre := Estilo.color(&"ui_texto") if quien == "valeria" else Estilo.color(&"ui_contorno")
	KitUI.franja_texto(self, "nombre-franja-%s%s" % [quien, g], Vector2(X_CAJA + 22.0, y_franja()) + sube, FRANJA[escala], nombre, estilo_nombre(), color_nombre)
	# La flecha de «sigue» late (con «Reducir movimiento», quieta).
	var salto := 0.0 if Opciones.reducir_movimiento else (1.0 if fmod(_t, 0.8) < 0.4 else 0.0)
	KitUI.icono(self, "dialogo-flecha", Vector2(caja.end.x - 16.0, caja.end.y - 12.0 + salto))
