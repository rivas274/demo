class_name ContadorRecurso
extends Control
## Pieza de interfaz: un recurso con ícono y número ("calcetin 3", "snack 2/5"). Solo muestra lo que le dicen con
## fijar(); al cambiar el valor da un golpe (el número salta y se tiñe de lacre un instante). Va en un pergamino del
## kit «Decreto real»; el ícono es una textura del kit (`icono`) o, si no hay, lo dibuja un Callable (por ejemplo
## Recogible.dibujar_icono), así sirve para cualquier recurso. Colores y letra salen del tema.

## Clave del recurso ("calcetin", "foto", "snack"...): la usa el ícono.
@export var clave := ""
## Ancho de la caja (el alto sale del tema: medida "alto_hud").
@export var ancho := 52.0
## Ícono del kit (20×20, a 1 pixel por pixel); sin él, lo dibuja `dibujar_icono`.
@export var icono: Texture2D

var texto := "0"
## Si no tiene nada, el ícono se ve apagado y el número gris.
var tiene := false
## 0 a 1: cuánto le queda al golpe.
var golpe := 0.0
## func(c: CanvasItem, clave: String, centro: Vector2, escala: float) que dibuja el ícono.
var dibujar_icono := Callable()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(ancho, Estilo.medida(&"alto_hud"))
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)


## Muestra un valor nuevo. Con `golpear`, salta (al cambiar en el juego; no al armar la interfaz).
func fijar(nuevo_texto: String, tiene_algo: bool, golpear := true) -> void:
	texto = nuevo_texto
	tiene = tiene_algo
	if golpear:
		dar_golpe()
	queue_redraw()


func dar_golpe() -> void:
	golpe = 1.0
	set_process(true)


func _process(delta: float) -> void:
	golpe = maxf(0.0, golpe - delta * 3.0)
	if golpe <= 0.0:
		set_process(false)
	queue_redraw()


func _draw() -> void:
	var alto := float(Estilo.medida(&"alto_hud"))
	Estilo.panel(self, Rect2(0, 0, ancho, alto), &"panel")
	var apagado := Color(1, 1, 1, 1.0 if tiene else 0.45)
	if icono:
		draw_texture(icono, Vector2(1, roundf((alto - icono.get_height()) / 2.0) - roundf(golpe * 2.0)), apagado)
	elif dibujar_icono.is_valid():
		dibujar_icono.call(self, clave, Vector2(12, 11), 0.6 + 0.25 * golpe)
	var tinta := Estilo.color(&"tinta_decreto")
	var color := tinta.lerp(Estilo.color(&"lacre"), golpe) if tiene else Estilo.color(&"tinta_decreto_suave")
	# El golpe hace saltar el número 2 px (no lo agranda: la letra pixel va siempre a su tamaño).
	Estilo.escribir(self, Vector2(25, 16 - roundf(golpe * 2.0)), texto, &"hud", color)
