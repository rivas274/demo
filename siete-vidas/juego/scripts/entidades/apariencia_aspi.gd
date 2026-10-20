class_name AparienciaAspi
extends Node2D
## Dibujo de A.S.P.I. (la aspiradora robot de Valeria; los números están en datos/enemigos/aspi.tres): su imagen, la
## luz de estado (verde patrullando, roja persiguiendo, la de aviso antes de un ataque), la tapa del depósito que se abre
## al llenarse (G8: misma vista y tamaño que cerrada), las estrellitas de aturdida y el destello del golpe. La pelea
## (BatallaAspi) maneja `luz_aviso`, `vibrando` y la tapa; el resto lo lee de las piezas del Enemigo.

## Anticipación de un ataque: luz que parpadea (roja: embestida; amarilla: soplido) y vibración.
var luz_aviso := Color(0, 0, 0, 0)
var vibrando := false
## Tapa del depósito: 0 cerrada, 1 abierta (lleno). Se anima con abrir_tapa() y cerrar_tapa().
var tapa := 0.0
## Saltito del cuerpo al abrirse la tapa (px hacia arriba, negativo).
var salto := 0.0
var _tween_tapa: Tween
var _enemigo: Enemigo


func _init() -> void:
	name = "Apariencia"


func _ready() -> void:
	_enemigo = get_parent() as Enemigo


func _physics_process(_delta: float) -> void:
	if not (_enemigo.vida.muerto or _enemigo.patrulla.esta_detenida()):
		queue_redraw()


## Lo que ocupa en el mundo (con la tapa abierta, más alto): la cola de anuncios no lo tapa (G5).
func rect_dibujado() -> Rect2:
	var ancho := _enemigo.datos.ancho
	var arriba := _enemigo.datos.alto_dibujo + (32.0 if tapa > 0.0 else 0.0)
	return Rect2(global_position + Vector2(-ancho / 2.0 - 2.0, -arriba), Vector2(ancho + 4.0, arriba + 2.0))


## Depósito lleno: salta un poco y la tapa se levanta en 0,25 s (G8: misma vista y tamaño que la cerrada).
func abrir_tapa() -> void:
	_animar_tapa(1.0, true)


func cerrar_tapa() -> void:
	_animar_tapa(0.0, false)


func _animar_tapa(hasta: float, saltar: bool) -> void:
	if _tween_tapa:
		_tween_tapa.kill()
	_tween_tapa = create_tween()
	_tween_tapa.tween_property(self, "tapa", hasta, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if saltar:
		_tween_tapa.parallel().tween_property(self, "salto", -5.0, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween_tapa.parallel().tween_property(self, "salto", 0.0, 0.14).set_delay(0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _draw() -> void:
	var datos := _enemigo.datos
	var apagada := _enemigo.vida.muerto
	var direccion := _enemigo.patrulla.direccion
	var temblor := Vector2(1 if vibrando and Time.get_ticks_msec() % 80 < 40 else 0, roundf(salto))
	draw_set_transform(temblor)
	if tapa > 0.0:
		_dibujar_tapa_detras()
	if not ArteNivel.dibujar(self, datos.arte, 0.0, 1.0, false, Color(0.6, 0.6, 0.62) if apagada else Color.WHITE):
		var cuerpo := Color("3a3d44") if not apagada else Color("6a6d72")
		draw_rect(Rect2(-datos.ancho / 2.0 + 3.0, -datos.alto, datos.ancho - 6.0, datos.alto), cuerpo)
		draw_circle(Vector2(-datos.ancho / 2.0 + 4.0, -datos.alto / 2.0), datos.alto / 2.0, cuerpo)
		draw_circle(Vector2(datos.ancho / 2.0 - 4.0, -datos.alto / 2.0), datos.alto / 2.0, cuerpo)
	# Luz de estado: verde patrullando, roja persiguiendo, apagada sin luz.
	var luz := Color("e0483b") if _enemigo.patrulla.persiguiendo else Color("5fd18a")
	if apagada:
		luz = Color("2a2a2a")
	elif luz_aviso.a > 0.0:
		luz = luz_aviso if Time.get_ticks_msec() % 160 < 80 else Color(1, 1, 1)
		draw_circle(Vector2(direccion * 18.0, -40.0), 7.0, Color(luz_aviso, 0.35))
	# LED más brillante (crítica de Gemini): halo que late, luz plena y un pixel blanco de brillo.
	var led := Vector2(direccion * 18.0, -40.0)
	if not apagada:
		draw_circle(led, 6.0, Color(luz, 0.22 + 0.12 * sin(Time.get_ticks_msec() * 0.006)))
		draw_circle(led, 4.0, Color(luz, 0.45))
	draw_circle(led, 3.0, luz.lightened(0.15) if not apagada else luz)
	if not apagada:
		draw_rect(Rect2(led + Vector2(-2, -2), Vector2(1, 1)), Color(1, 1, 1, 0.9))
	if tapa > 0.0:
		_dibujar_deposito_abierto()
	draw_set_transform(Vector2.ZERO)
	if _enemigo.recibe_golpes.esta_aturdido():
		for i in 3:
			var angulo := Time.get_ticks_msec() * 0.006 + i * TAU / 3.0
			draw_circle(Vector2(cos(angulo) * 22.0, -54.0 + sin(angulo) * 4.0), 3.0, Color("f2d36b"))
	if _enemigo.patrulla.retroceso > 0.0:
		draw_rect(Rect2(-38.0, -47.0, 76.0, 48.0), Color(1, 1, 1, 0.5))


## Tapa del depósito (dibujada sobre el arte cerrado, en la misma vista 3/4): bisagra en el borde de atrás de la cara de
## arriba (centro (0, -33), radios 28 × 9 en aspi.png). Abierta, queda parada detrás, mostrando su cara de abajo.
const CENTRO_TAPA := Vector2(0, -33)
const RADIO_TAPA := Vector2(28, 9)


func _puntos_tapa() -> PackedVector2Array:
	var angulo := tapa * deg_to_rad(100.0)
	var bisagra := CENTRO_TAPA.y - RADIO_TAPA.y
	var puntos := PackedVector2Array()
	for i in 20:
		var a := TAU * i / 20.0
		var x := cos(a) * RADIO_TAPA.x
		# Profundidad desde la bisagra (0 atrás, 2 × radio adelante), en unidades "reales" (la vista achata a la mitad).
		var hondo := (sin(a) + 1.0) * RADIO_TAPA.y * 2.0
		puntos.append(Vector2(x, bisagra + hondo * cos(angulo) * 0.5 - hondo * sin(angulo) * 0.9))
	return puntos


func _dibujar_tapa_detras() -> void:
	# Parada detrás del cuerpo: se dibuja antes que el arte.
	var puntos := _puntos_tapa()
	draw_colored_polygon(puntos, Color("4a4d55") if tapa > 0.55 else Color("3a3d44"))
	draw_polyline(puntos + PackedVector2Array([puntos[0]]), Color("1b1c20"), 1.0)


func _dibujar_deposito_abierto() -> void:
	# El hueco del depósito, lleno de pelos y pelusas.
	var hueco := PackedVector2Array()
	var abierto := clampf(tapa, 0.0, 1.0)
	for i in 16:
		var a := TAU * i / 16.0
		hueco.append(CENTRO_TAPA + Vector2(cos(a) * (RADIO_TAPA.x - 3.0), sin(a) * (RADIO_TAPA.y - 2.0)))
	draw_colored_polygon(hueco, Color(0.08, 0.08, 0.1, abierto))
	for i in 9:
		var p := CENTRO_TAPA + Vector2(-18.0 + i * 4.5, sin(i * 2.1) * 3.0 - 1.0)
		draw_circle(p, 2.5, Color(0.72, 0.7, 0.66, abierto))
		draw_line(p, p + Vector2(4, -2), Color(0.55, 0.53, 0.5, abierto), 1.0)
	if tapa < 0.55:
		# Todavía casi cerrada: la tapa va encima del hueco.
		var puntos := _puntos_tapa()
		draw_colored_polygon(puntos, Color("3a3d44"))
		draw_polyline(puntos + PackedVector2Array([puntos[0]]), Color("1b1c20"), 1.0)
