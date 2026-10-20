class_name BarraEstadistica
extends Control
## Pieza de interfaz: una estadística de la Ficha de Su Majestad. Ícono, nombre, barra (marco del kit «Decreto real»
## con su relleno de color) y una frase satírica de una línea debajo. Solo escucha: escuchar(señal) la conecta a una
## fuente que avisa {estadistica: [valor 0 a 1, clave de la frase]} (FichaSuMajestad.estadisticas_cambiadas) y toma
## lo suyo. Al cambiar, la barra se llena de a poco (de golpe con Opciones.reducir_movimiento).
## Sin barra (`con_barra` falso) es solo nombre y frase fija: la velocidad, que es un chiste y no cambia.
## Escena: escenas/ui/barra_estadistica.tscn.

## Qué estadística muestra (la clave en lo que avisa la fuente).
@export var estadistica := &"defensa"
## Nombre en pantalla (clave de traducción).
@export var nombre := "FICHA_DEFENSA"
@export var icono: Texture2D
@export var relleno: Texture2D
@export var con_barra := true
## Frase fija (para la que no tiene barra).
@export var frase := ""
## Ancho del marco de la barra (8:1 con su alto de 12 px) y lo que tarda en llenarse.
@export var ancho_barra := 96.0
@export var tiempo_llenar := 0.45

## Lo que vale ahora (0 a 1) y lo que se ve (sube de a poco hasta `valor`).
var valor := 0.0
var mostrado := 0.0
var _tween: Tween

const ALTO_MARCO := 12.0
const LADO_ICONO := 24.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS


## Se conecta a la fuente (una señal con el diccionario de estadísticas).
func escuchar(senal: Signal) -> void:
	if not senal.is_connected(_al_cambiar):
		senal.connect(_al_cambiar)


func _al_cambiar(estadisticas: Dictionary) -> void:
	if not estadisticas.has(estadistica):
		return
	var datos: Array = estadisticas[estadistica]
	fijar(float(datos[0]), String(datos[1]))


## Muestra un valor y su frase; `animar` llena la barra de a poco desde donde está.
func fijar(nuevo: float, clave_frase: String, animar := true) -> void:
	valor = clampf(nuevo, 0.0, 1.0)
	frase = clave_frase
	if _tween and _tween.is_valid():
		_tween.kill()
	if animar and not Opciones.reducir_movimiento and is_inside_tree():
		_tween = create_tween()
		_tween.tween_method(_poner_mostrado, mostrado, valor, tiempo_llenar).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		_poner_mostrado(valor)
	queue_redraw()


## Vuelve a llenar la barra desde 0 (al abrir la ficha).
func rellenar() -> void:
	mostrado = 0.0
	fijar(valor, frase)


func _poner_mostrado(v: float) -> void:
	mostrado = v
	queue_redraw()


## Dónde va la barra (el marco) dentro de la pieza.
func rect_barra() -> Rect2:
	return Rect2(LADO_ICONO + 4.0, 12.0, ancho_barra, ALTO_MARCO)


## Ancho disponible para la frase (toda la pieza).
func ancho_frase() -> float:
	return size.x


func _draw() -> void:
	var tinta := Estilo.color(&"tinta_decreto")
	var x_texto := LADO_ICONO + 4.0 if icono else 0.0
	if icono:
		draw_texture(icono, Vector2.ZERO)
	Estilo.escribir(self, Vector2(x_texto, 9), tr(nombre), &"ficha_nombre", tinta)
	if con_barra:
		var marco := rect_barra()
		Estilo.panel(self, marco, &"marco_barra")
		if relleno and mostrado > 0.0:
			var caja := Estilo.caja(&"marco_barra")
			var dentro := Rect2(marco.position + Vector2(caja.content_margin_left, caja.content_margin_top), marco.size - Vector2(caja.content_margin_left + caja.content_margin_right, caja.content_margin_top + caja.content_margin_bottom))
			Estilo.relleno(self, relleno, Rect2(dentro.position, Vector2(roundf(dentro.size.x * mostrado), dentro.size.y)))
	var y_frase := LADO_ICONO + 9.0 if icono else 19.0
	Estilo.escribir(self, Vector2(0, y_frase), Estilo.recortar(tr(frase), &"ficha_frase", ancho_frase()), &"ficha_frase", Estilo.color(&"tinta_decreto_suave"))

