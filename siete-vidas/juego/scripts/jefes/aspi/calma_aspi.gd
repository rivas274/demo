class_name CalmaAspi
extends Node2D
## Un solo foco a la vez (pelea con A.S.P.I. v5; el creador: «la batalla es confusa, mucho ruido visual»). Receta de
## Cuphead y Hollow Knight: el fondo, calmado; lo jugable, con contraste. Pieza de BatallaAspi; los números, en
## `datos/jefes/aspi_jugo.tres` (grupo «Ruido»), elegidos entre 5 variantes comparadas a ×1
## (`diseno/revisiones/2026-10-23-pelea-aspi-v5.md`).
## - **Velo:** durante la pelea, un velo del color del cuarto, apenas opaco, sobre el decorado (pared, cuadros, ventana
##   y corcho; según `velo_capa`, también los muebles). Baja su contraste; Felipe, A.S.P.I., lo que se puede tirar y
##   los avisos van delante, a todo color.
## - **Sin motas** de polvo en el rayo de la ventana, **LED quieta** en reposo, **restos** más oscuros y con menos
##   pedazos.
## - **«+1»** chico (letra de 8 px, celeste) sobre los LED al limpiar una mancha, en vez de la palabra «+1 · Glup.».

## Segundos que se ve el «+1» y cuánto sube.
const DURA_MAS_UNO := 0.6
const SUBE_MAS_UNO := 6.0

var b: BatallaAspi
var datos: DatosJugoJefe
## Para las pruebas: cuándo fue el último «+1» (segundos del reloj del juego) y cuántos hubo.
var mas_uno := -10.0
var mas_unos := 0
var _velo: Node2D
var _reloj := 0.0


func _init(de: BatallaAspi) -> void:
	name = "Calma"
	b = de
	datos = de.datos.jugo if de.datos.jugo else DatosJugoJefe.new()


func _ready() -> void:
	Capas.usar(self, Capas.EFECTOS)
	_velo = Node2D.new()
	_velo.name = "Velo del fondo"
	_velo.draw.connect(_dibujar_velo)
	add_child(_velo)
	Capas.usar(_velo, datos.velo_capa)


## Empieza la pelea: el cuarto se calma (motas, LED, restos).
func empezar() -> void:
	Capas.usar(_velo, datos.velo_capa)
	for fondo in b.nivel.find_children("*", "FondoApartamento", true, false):
		(fondo as FondoApartamento).sin_motas = "" if datos.motas_ambiente else "estudio"
	b.apariencia.led_parpadea = datos.led_parpadea
	PiezaSuelta.tinte_resto = datos.tinte_resto
	_velo.queue_redraw()


## Terminó la pelea: vuelven las motas y la LED (los restos quedan como quedaron: el trofeo de Felipe).
func terminar() -> void:
	for fondo in b.nivel.find_children("*", "FondoApartamento", true, false):
		(fondo as FondoApartamento).sin_motas = ""
	_velo.queue_redraw()


## Limpió una mancha: «+1» chico sobre los LED.
func sumar_uno() -> void:
	mas_uno = _reloj
	mas_unos += 1


func _process(delta: float) -> void:
	_reloj += delta
	if _reloj - mas_uno <= DURA_MAS_UNO + delta:
		queue_redraw()


func _dibujar_velo() -> void:
	if datos.velo <= 0.0 or b.fase != PeleaJefe.Fase.PELEA:
		return
	_velo.draw_rect(b.arena, Color(datos.velo_color, datos.velo))


func _draw() -> void:
	var t := _reloj - mas_uno
	if t > DURA_MAS_UNO or not is_instance_valid(b.jefe):
		return
	var texto := "+1"
	var punto := b.jefe.global_position + Vector2(-roundf(Estilo.ancho(texto, &"etiqueta") / 2.0), -BatallaAspi.ALTO_ARRIBA - 6.0 - roundf(SUBE_MAS_UNO * t / DURA_MAS_UNO))
	Estilo.texto_con_contorno(self, punto.round(), texto, &"etiqueta", Color(0.5, 0.85, 1.0), &"contorno_palabra", 1)
