class_name ContadorRecurso
extends Control
## Pieza de interfaz: un recurso con ícono y número ("calcetin 3", "snack 2/5"). Solo muestra lo que le dicen con
## fijar(); al cambiar el valor da un golpe (el ícono y el número crecen un instante). El ícono lo dibuja un Callable
## (por ejemplo Recogible.dibujar_icono), así sirve para cualquier recurso. Colores y letra salen del tema.

## Clave del recurso ("calcetin", "foto", "snack"...): la usa el ícono.
@export var clave := ""
## Ancho de la caja (el alto sale del tema: medida "alto_hud").
@export var ancho := 52.0

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
	draw_rect(Rect2(0, 0, ancho, alto), Estilo.color(&"fondo_hud"))
	if dibujar_icono.is_valid():
		dibujar_icono.call(self, clave, Vector2(13, 11), 0.6 + 0.25 * golpe)
	if not tiene:
		draw_rect(Rect2(1, 1, 24, 20), Estilo.color(&"apagado_hud"))
	var color := Estilo.color(&"hud_numero").lerp(Estilo.color(&"hud_golpe"), golpe) if tiene else Estilo.color(&"hud_numero_vacio")
	Estilo.texto_con_contorno(self, Vector2(27, 15), texto, Estilo.letra(&"hud") + int(golpe * 4), color)
