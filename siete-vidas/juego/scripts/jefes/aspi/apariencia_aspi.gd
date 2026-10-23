class_name AparienciaAspi
extends Node2D
## Dibujo de A.S.P.I. (la aspiradora robot de Valeria; los números de su cuerpo están en datos/enemigos/aspi.tres), DE
## LADO en 3/4 como el resto de la casa (arte de Gemini `aspi-lateral.png`, 2026-10-21: el disco visto desde arriba se
## veía plano). Las partes van aparte y se animan aquí, con los números de abajo (en el inspector):
## - la rueda gira con lo que avanza; el cepillo lateral gira siempre que está encendida;
## - rebota 1 px al andar; la LED parpadea (la de aviso antes de un ataque, más rápido y de su color);
## - el ojo se enoja al perseguir o en la fase 3 (`furia`, lo pone la pelea);
## - tapa abierta con la pelusa cuando el depósito está lleno (`abrir_tapa`, con saltito);
## - apagada (vencida): sin luces y con las espirales de mareo girando.
## La pelea (BatallaAspi) maneja `luz_aviso`, `vibrando`, `furia` y la tapa; el resto lo lee de las piezas del Enemigo.
## Las imágenes miran a la derecha (el ojo adelante): hacia la izquierda van en espejo.

## Cuadros de la rueda por px avanzado y cuadros por segundo del cepillo.
@export var px_por_cuadro_rueda := 5.0
@export var fps_cepillo := 14.0
## Rebote al andar (px) y cada cuántos px avanzados.
@export var rebote := 1.0
@export var px_por_rebote := 8.0
## Parpadeo de la LED: segundos encendida y apagada (con aviso, la mitad).
@export var led_encendida := 1.1
@export var led_apagada := 0.18
## Dónde van las partes, respecto del pie del cuerpo (mirando a la derecha): rueda y cepillo.
@export var lugar_rueda := Vector2(-4, 0)
@export var lugar_cepillo := Vector2(30, 1)
## Cuánto sube el cuerpo sobre el piso (deja ver la rueda) y espirales de la apagada.
@export var alto_rueda := 2.0
@export var espirales := 3
## Dónde se estaciona (x en el mundo; INF = sin base) y hacia dónde mira ahí: acoplada de frente a la estación.
var base_x := INF
var lado_base := 1.0
## A cuántos px de la base empieza a subir en diagonal hacia el fondo (la estación está contra la pared).
@export var acercamiento_base := 36.0

const CUADROS_CEPILLO := 6
## Medidor del depósito (v4, idea de Gemini): 3 LED en el lomo, a esta altura sobre el pie del cuerpo y estas x
## (mirando a la derecha). Verdes al encenderse; con el depósito lleno, los 3 parpadean en amarillo (oportunidad).
const LEDS_ALTO := 29.0
const LEDS_X: Array[float] = [-15.0, -8.0, -1.0]
## La franja verde de la LED en el arte del cuerpo (aspi_lado, mirando a la derecha) y la franja gris de la apagada.
const FRANJA_LED := Rect2(29, 27, 19, 5)
const FRANJA_LED_APAGADA := Rect2(1, 2, 22, 4)

## Anticipación de un ataque: luz que parpadea (roja: peligro, v4) y vibración.
var luz_aviso := Color(0, 0, 0, 0)
var vibrando := false
## Fase 3 (la pone la pelea): el ojo queda enojado.
var furia := false
## Tapa del depósito: 0 cerrada, 1 abierta (lleno). Se anima con abrir_tapa() y cerrar_tapa().
var tapa := 0.0
## Saltito del cuerpo al abrirse la tapa (px hacia arriba, negativo).
var salto := 0.0
## v4: el depósito hinchado (0 a 0,08: tope ±8 %, como el estirar y aplastar de Felipe), cuántos de los 3 LED del
## medidor de su lomo están encendidos y si está mareada (estrellitas que giran).
var inflado := 0.0
## La LED parpadea en reposo (v5: en la pelea queda quieta; solo parpadea con un aviso).
var led_parpadea := true
var leds := 0
var mareada := false
var _tween_tapa: Tween
var _enemigo: Enemigo
var _avance := 0.0
var _ultimo_x := 0.0
var _mirando := 1.0


func _init() -> void:
	name = "Apariencia"


func _ready() -> void:
	_enemigo = get_parent() as Enemigo
	_ultimo_x = _enemigo.global_position.x
	if _enemigo.sombra:
		_enemigo.sombra.desfase = func() -> Vector2: return Vector2(0, profundidad_actual())
	if _enemigo.dano:
		_enemigo.dano.desfase_felipe = Vector2(0, -_enemigo.datos.profundidad)


## Cuánto más abajo se dibuja ahora: toda su profundidad andando; en los últimos px antes de la base sube en diagonal
## hasta la pared, donde se acopla a la estación.
func profundidad_actual() -> float:
	var p := _enemigo.datos.profundidad
	if base_x != INF and not _enemigo.vida.muerto:
		p *= clampf(absf(_enemigo.global_position.x - base_x) / acercamiento_base, 0.0, 1.0)
	return roundf(p)


func _physics_process(_delta: float) -> void:
	var x := _enemigo.global_position.x
	_avance += absf(x - _ultimo_x)
	if absf(x - _ultimo_x) > 0.05:
		_mirando = signf(x - _ultimo_x)
	_ultimo_x = x
	if absf(_enemigo.velocity.x) < 1.0 and absf(x - base_x) < 6.0:
		_mirando = lado_base
	queue_redraw()


## ¿Dibujada en espejo (mirando a la izquierda)?
func en_espejo() -> bool:
	return _mirando < 0.0


## ¿Encendida? (no vencida).
func encendida() -> bool:
	return not _enemigo.vida.muerto


## ¿Con el ojo enojado ahora?
func enojada() -> bool:
	return encendida() and (furia or _enemigo.patrulla.persiguiendo)


## La imagen del cuerpo que corresponde ahora.
func cuerpo_actual() -> String:
	if not encendida():
		return "aspi_apagada"
	if tapa > 0.5:
		return "aspi_tapa"
	return "aspi_enojada" if enojada() else "aspi_lado"


## Lo que ocupa en el mundo (con la tapa abierta, más alto): la cola de anuncios no lo tapa (G5).
func rect_dibujado() -> Rect2:
	var t := ArteNivel.textura(cuerpo_actual())
	var tam := t.get_size() if t else Vector2(_enemigo.datos.ancho, _enemigo.datos.alto_dibujo)
	return Rect2(global_position + Vector2(-tam.x / 2.0 - 2.0, -tam.y - alto_rueda + profundidad_actual()), Vector2(tam.x + 4.0, tam.y + alto_rueda + 2.0))


## Depósito lleno: salta un poco y la tapa se levanta en 0,25 s.
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
	var prendida := encendida()
	var lado := _mirando
	var espejo := lado < 0.0
	var temblor := Vector2(1 if vibrando and Time.get_ticks_msec() % 80 < 40 else 0, 0)
	var anda := prendida and absf(_enemigo.velocity.x) > 1.0
	var bote := -rebote if anda and int(_avance / px_por_rebote) % 2 == 1 else 0.0
	var hondo := profundidad_actual()
	var base := Vector2(0, roundf(-alto_rueda + bote + salto + hondo)) + temblor
	# Rueda (detrás del cuerpo: asoma abajo), con su cuadro según lo que avanzó.
	var rueda := "aspi_rueda_%d" % (int(_avance / px_por_cuadro_rueda) % 2 + 1)
	ArteNivel.dibujar(self, rueda, lugar_rueda.x * lado + temblor.x, lugar_rueda.y + hondo, espejo)
	# Hinchado desde el pie del cuerpo (no se despega del piso).
	if inflado > 0.0:
		var k := 1.0 + minf(inflado, 0.08)
		draw_set_transform(base * (1.0 - k), 0.0, Vector2(k, k))
	ArteNivel.dibujar(self, cuerpo_actual(), base.x, base.y, espejo)
	if prendida:
		_dibujar_led(base, lado, espejo)
		_dibujar_medidor(base, lado)
	draw_set_transform(Vector2.ZERO)
	# Cepillo lateral adelante, girando mientras está encendida.
	var cuadro := int(Time.get_ticks_msec() / 1000.0 * fps_cepillo) % CUADROS_CEPILLO + 1 if prendida else 1
	ArteNivel.dibujar(self, "aspi_cepillo_%d" % cuadro, lugar_cepillo.x * lado + temblor.x, lugar_cepillo.y + roundf(bote) + hondo, espejo)
	if not prendida:
		_dibujar_espirales(base)
	if _enemigo.recibe_golpes.esta_aturdido() or mareada:
		# Estrellitas de mareo que giran sobre la tapa (cruces de pixel con borde oscuro).
		for i in 3:
			var angulo := Time.get_ticks_msec() * 0.006 + i * TAU / 3.0
			var punto := Vector2(cos(angulo) * 20.0, -46.0 + roundf(profundidad_actual()) + sin(angulo) * 4.0).round()
			draw_rect(Rect2(punto + Vector2(-3, -1), Vector2(7, 3)), Color(0.15, 0.08, 0.05, 0.8))
			draw_rect(Rect2(punto + Vector2(-1, -3), Vector2(3, 7)), Color(0.15, 0.08, 0.05, 0.8))
			draw_rect(Rect2(punto + Vector2(-2, 0), Vector2(5, 1)), Color("f2d36b"))
			draw_rect(Rect2(punto + Vector2(0, -2), Vector2(1, 5)), Color("f2d36b"))
	if _enemigo.patrulla.retroceso > 0.0:
		var r := rect_dibujado()
		draw_rect(Rect2(r.position - global_position, r.size), Color(1, 1, 1, 0.5))


## Los 3 LED del depósito en el lomo: hueco oscuro de 5 × 4 y luz de 3 × 2.
func _dibujar_medidor(base: Vector2, lado: float) -> void:
	var lleno := tapa > 0.5
	var brilla := int(Time.get_ticks_msec() / 150) % 2 == 0
	for i in LEDS_X.size():
		var punto := (base + Vector2(LEDS_X[i] * lado - (2.0 if lado < 0.0 else 0.0), -LEDS_ALTO)).round()
		draw_rect(Rect2(punto - Vector2(1, 1), Vector2(5, 4)), Color(0.08, 0.08, 0.1))
		var color := Color(0.18, 0.3, 0.2)
		if lleno:
			color = Estilo.color(&"oportunidad") if brilla else Color(1, 1, 1)
		elif i < leds:
			color = Color(0.45, 1.0, 0.5)
		draw_rect(Rect2(punto, Vector2(3, 2)), color)


## La franja verde parpadea: cada tanto se tapa con la franja de la LED apagada del arte (`aspi_led_off`), puesta justo
## sobre la del cuerpo. Con aviso de ataque, parpadea rápido y en su color.
func _dibujar_led(base: Vector2, _lado: float, espejo: bool) -> void:
	var cuerpo := ArteNivel.textura(cuerpo_actual())
	var apagada_tex := ArteNivel.textura("aspi_led_off")
	if cuerpo == null or apagada_tex == null:
		return
	var periodo := led_encendida + led_apagada
	var apagada_ahora := led_parpadea and fmod(Time.get_ticks_msec() / 1000.0, periodo) > led_encendida
	var franja := FRANJA_LED
	var arriba := base + Vector2(-cuerpo.get_width() / 2.0, -cuerpo.get_height())
	var x := arriba.x + (cuerpo.get_width() - franja.end.x if espejo else franja.position.x)
	var destino := Rect2(Vector2(roundf(x), roundf(arriba.y + franja.position.y)), franja.size)
	if luz_aviso.a > 0.0:
		if Time.get_ticks_msec() % 160 < 80:
			draw_rect(destino, luz_aviso.lightened(0.25))
		else:
			draw_texture_rect_region(apagada_tex, destino, FRANJA_LED_APAGADA)
		return
	if apagada_ahora:
		draw_texture_rect_region(apagada_tex, destino, FRANJA_LED_APAGADA)


## Apagada: espirales de mareo que giran sobre la tapa, en pasos de 90° (pixel nítido).
func _dibujar_espirales(base: Vector2) -> void:
	var t := ArteNivel.textura("aspi_espiral")
	if t == null:
		return
	var apagada_tex := ArteNivel.textura("aspi_apagada")
	var alto: float = apagada_tex.get_height() if apagada_tex else 38.0
	var paso := int(Time.get_ticks_msec() / 150.0)
	for i in espirales:
		var centro := base + Vector2(-14.0 + i * 14.0, -alto - 6.0 - (i % 2) * 6.0)
		draw_set_transform(centro.round(), (paso + i) % 4 * PI / 2.0)
		draw_texture(t, -t.get_size() / 2.0)
	draw_set_transform(Vector2.ZERO)
