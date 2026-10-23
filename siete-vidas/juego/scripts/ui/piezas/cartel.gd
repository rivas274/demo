class_name Cartel
extends Control
## Pieza de interfaz: el cartel de travesura de la interfaz v2 («A + C», kit assets/ui/v2/): la franja diagonal ámbar
## (el color de Felipe) con el título en Silkscreen 16 y el sello en rombo con la huella a la izquierda, sus
## fragmentos a la derecha y, debajo, una segunda franja oscura con el nombre de la travesura (una sola línea). La
## sombra es OSCURA a propósito: el magenta es de Valeria (un color, un significado).
## Entra con un barrido de 140 ms y un rebote de 4 px, se queda `duracion` s y sale barriendo a la izquierda. Con
## «Reducir movimiento», solo aparece y se va. No sabe de colas ni de travesuras: quien lo crea (Hud, a través de
## Anuncios) decide cuándo y dónde. Colores y letras salen del tema.

const ENTRADA := 0.14
const SALIDA := 0.18
const REBOTE := 4.0
## Medidas de la lámina: franja de 22 px (título a 30 px de su borde, 48 + 10 de diagonal de más que el texto) y
## segunda línea de 19 px (el nombre a 14 px de su borde).
const ALTO_FRANJA := 22.0
const ALTO_LINEA := 19.0
const MARGEN_FRANJA := 58.0
const MARGEN_LINEA := 28.0
const LETRA_TITULO := &"cartel_kit"
const LETRA_NOMBRE := &"cartel_nombre"

var titulo := ""
var nombre := ""
var secreta := false
## Animación de entrada, espera y salida (para cortarla con ocultar()).
var animacion: Tween
## 0 a 1: cuánto entró (barrido) y cuánto salió.
var entrada := 0.0
var salida := 0.0


## Lo que ocupa un cartel con ese título y ese nombre (para pedir su lugar en la zona C).
static func medida(con_titulo: String, con_nombre: String) -> Vector2:
	var franja := ancho_franja(con_titulo) + 12.0
	var linea := ancho_linea(con_nombre)
	return Vector2(minf(maxf(franja, linea) + 8.0, ZonasTexto.SEGURA.size.x), ALTO_FRANJA + 2.0 + ALTO_LINEA + 6.0)


static func ancho_franja(con_titulo: String) -> float:
	return roundf(Estilo.ancho(con_titulo, LETRA_TITULO)) + MARGEN_FRANJA


static func ancho_linea(con_nombre: String) -> float:
	return roundf(Estilo.ancho(con_nombre, LETRA_NOMBRE)) + MARGEN_LINEA


## Arma el cartel en `rect` (su lugar en la zona C). Título grande en la franja y UNA línea corta debajo (plan de
## estabilización 2026-10-20: la recompensa se ve volar y está en la libreta).
static func crear(con_titulo: String, con_nombre: String, es_secreta: bool, rect: Rect2) -> Cartel:
	var caja := Cartel.new()
	caja.name = "Cartel"
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja.position = rect.position
	caja.size = rect.size
	caja.titulo = con_titulo
	caja.nombre = Estilo.recortar(con_nombre, LETRA_NOMBRE, ZonasTexto.SEGURA.size.x - MARGEN_LINEA)
	caja.secreta = es_secreta
	return caja


## Entra, espera y sale (ya dentro del árbol). Se borra solo al terminar.
func animar(duracion: float) -> void:
	animacion = create_tween()
	animacion.tween_property(self, "entrada", 1.0, ENTRADA)
	animacion.tween_interval(maxf(0.0, duracion - ENTRADA - SALIDA))
	animacion.tween_property(self, "salida", 1.0, SALIDA).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	animacion.tween_callback(queue_free)


## En tiempo real: la cámara lenta de una derrota no estira el cartel (Anuncios cuenta su turno igual).
func _process(_delta: float) -> void:
	if animacion and animacion.is_valid():
		animacion.set_speed_scale(1.0 / maxf(Engine.time_scale, 0.001))
	queue_redraw()


## Sale al instante (algo pidió la franja: una frase urgente o la fase del jefe). Nunca se ven dos textos en la zona
## C a la vez.
func ocultar() -> void:
	if animacion:
		animacion.kill()
	visible = false
	queue_free()


## Corrimiento en x de la franja: barre desde la izquierda, se pasa 4 px y vuelve; al salir, barre a la izquierda.
func corrimiento() -> float:
	if Opciones.reducir_movimiento:
		return 0.0
	if salida > 0.0:
		return -roundf(salida * (size.x + 60.0))
	if entrada < 0.7:
		return -roundf((1.0 - entrada / 0.7) * (size.x + 60.0))
	return roundf(REBOTE * sin(PI * (entrada - 0.7) / 0.3))


func _draw() -> void:
	if Opciones.reducir_movimiento:
		modulate.a = minf(entrada * 3.0, 1.0) * (1.0 - salida)
	var dx := corrimiento()
	var w := ancho_franja(titulo)
	var x := roundf((size.x - w) / 2.0) + dx
	KitUI.pieza(self, "cartel-franja", Rect2(x, 0, w, ALTO_FRANJA))
	KitUI.icono(self, "cartel-sello", Vector2(x - 6.0, -4.0))
	KitUI.escribir(self, x + 30.0, floorf((ALTO_FRANJA - KitUI.alto_mayuscula(LETRA_TITULO)) / 2.0), titulo, LETRA_TITULO, Estilo.color(&"ui_contorno"))
	KitUI.fragmentos(self, &"cartel", Vector2(x + w - 6.0, 4.0), 1.0 - entrada)
	# La segunda línea entra con la franja, un poco después.
	var sw := ancho_linea(nombre)
	var sx := roundf((size.x - sw) / 2.0) + roundf(dx * 1.2)
	var sy := ALTO_FRANJA + 2.0
	KitUI.pieza(self, "cartel-linea", Rect2(sx, sy, sw, ALTO_LINEA))
	KitUI.escribir(self, sx + 14.0, sy + 5.0, nombre, LETRA_NOMBRE, Estilo.color(&"ui_texto"))
