class_name BarraEstadistica
extends Control
## Pieza de interfaz: una estadística de la Ficha de Su Majestad, en una fila de 17 px (interfaz v2, kit
## assets/ui/v2/): el nombre apagado, la barra con puntas en diagonal (marco del kit y su relleno de color) y una
## frase satírica de una línea a la derecha. Solo escucha: escuchar(señal) la conecta a una fuente que avisa
## {estadistica: [valor 0 a 1, clave de la frase]} (FichaSuMajestad.estadisticas_cambiadas) y toma lo suyo. Al
## cambiar, la barra se llena de a poco (de golpe con Opciones.reducir_movimiento).
## Sin barra (`con_barra` falso) es solo nombre y frase fija: la velocidad, que es un chiste y no cambia.
## Escena: escenas/ui/barra_estadistica.tscn.

## Qué estadística muestra (la clave en lo que avisa la fuente).
@export var estadistica := &"defensa"
## Nombre en pantalla (clave de traducción).
@export var nombre := "FICHA_DEFENSA"
## Color del relleno (el del kit: «felipe», «maquina» o «aspi»).
@export var relleno := "felipe"
@export var con_barra := true
## Frase fija (para la que no tiene barra).
@export var frase := ""
@export var tiempo_llenar := 0.45

## Lo que vale ahora (0 a 1) y lo que se ve (sube de a poco hasta `valor`).
var valor := 0.0
var mostrado := 0.0
var _tween: Tween

## Medidas de la lámina: marco de 60×9 a 66 px del nombre; relleno de 58 px adentro; frase a 134 px.
const X_BARRA := 66.0
const MARCO := Vector2(60, 9)
const ANCHO_RELLENO := 58.0
const X_FRASE := 134.0


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


## Ancho disponible para la frase (desde X_FRASE hasta el borde de la fila).
func ancho_frase() -> float:
	return size.x - X_FRASE


func _draw() -> void:
	KitUI.escribir(self, 0, 0, tr(nombre), &"ficha_frase", Estilo.color(&"ui_apagado"))
	if con_barra:
		KitUI.pieza(self, "ficha-barra-marco", Rect2(Vector2(X_BARRA, 0), MARCO))
		var ancho := roundf(ANCHO_RELLENO * mostrado)
		if ancho >= 1.0:
			KitUI.pieza(self, "ficha-barra-relleno-" + relleno, Rect2(Vector2(X_BARRA + 1.0, 1.0), Vector2(maxf(ancho, 7.0), 7.0)))
	KitUI.escribir(self, X_FRASE, 0, Estilo.recortar(tr(frase), &"ficha_frase", ancho_frase()), &"ficha_frase", Estilo.color(&"ui_texto"))
