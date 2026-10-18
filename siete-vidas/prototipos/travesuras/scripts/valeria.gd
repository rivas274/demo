# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-18
class_name Valeria
extends Node2D
## Valeria provisional (rectángulos, 200 px = 3 Felipes). Oye el ruido, entra por la puerta, se enoja
## ("¡FELIPE!") y abre una ventana de encanto: si Felipe ronronea cerca de ella, lo perdona y le deja
## un snack. Si no, lo persigue un poco (sin castigo) y se va. Al irse lo deja todo en su lugar.
## La posición es la de sus pies.

signal grita(valeria: Valeria)
signal perdona(valeria: Valeria)
signal persigue(valeria: Valeria)
signal se_va(valeria: Valeria)
signal se_fue(valeria: Valeria)

enum Estado { FUERA, ENTRANDO, REGANANDO, PERSIGUIENDO, PERDONANDO, SALIENDO }

const ALTO := 200.0
const PUERTA_X := 582.0

## Ruido que hace falta (sumado) para que venga a ver.
@export var umbral_ruido := 3.0
## Ruido que se olvida por segundo.
@export var olvido_ruido := 0.25
@export var velocidad := 95.0
@export var velocidad_persecucion := 105.0
## Segundos que espera enojada antes de perseguir (la ventana para ronronear).
@export var ventana_encanto := 5.0
@export var duracion_persecucion := 3.0
## Segundos de ronroneo cerca de ella para que perdone.
@export var ronroneo_para_perdonar := 0.9
## Distancia horizontal a la que cuenta el ronroneo.
@export var distancia_ronroneo := 110.0
## Distancia horizontal a la que se para frente a Felipe para regañarlo.
@export var distancia_cara := 66.0
## Segundos que no vuelve después de irse.
@export var descanso := 2.0

var estado := Estado.FUERA
var ruido := 0.0
var felipe: FelipeProto
var ronroneo_acumulado := 0.0
var mirando := -1.0
var _tiempo := 0.0
var _paso := 0.0
var _descanso := 0.0
var _corazones: Array = []


func _ready() -> void:
	visible = false
	position = Vector2(PUERTA_X, 296)


func oir(cantidad: float) -> void:
	ruido += cantidad


func presente() -> bool:
	return estado in [Estado.REGANANDO, Estado.PERSIGUIENDO]


func _physics_process(delta: float) -> void:
	_tiempo += delta
	_actualizar_corazones(delta)
	match estado:
		Estado.FUERA:
			_descanso -= delta
			if ruido >= umbral_ruido and _descanso <= 0.0:
				ruido = 0.0
				estado = Estado.ENTRANDO
				visible = true
				position.x = PUERTA_X
				ronroneo_acumulado = 0.0
		Estado.ENTRANDO:
			var destino := _destino_junto_a_felipe()
			if _caminar_hacia(destino, velocidad, delta):
				estado = Estado.REGANANDO
				_tiempo = 0.0
				grita.emit(self)
		Estado.REGANANDO:
			# Se acomoda a su lado (no debajo de él: si no, Felipe le tapa la cara).
			_caminar_hacia(_destino_junto_a_felipe(), velocidad * 0.6, delta)
			_mirar_a_felipe()
			if _revisar_ronroneo(delta):
				return
			if _tiempo > ventana_encanto:
				estado = Estado.PERSIGUIENDO
				_tiempo = 0.0
				persigue.emit(self)
		Estado.PERSIGUIENDO:
			if _revisar_ronroneo(delta):
				return
			_caminar_hacia(_destino_junto_a_felipe(), velocidad_persecucion, delta)
			_mirar_a_felipe()
			if _tiempo > duracion_persecucion:
				estado = Estado.SALIENDO
				se_va.emit(self)
		Estado.PERDONANDO:
			if _tiempo > 2.2:
				estado = Estado.SALIENDO
		Estado.SALIENDO:
			if _caminar_hacia(PUERTA_X, velocidad, delta):
				estado = Estado.FUERA
				visible = false
				_descanso = descanso
				ruido = 0.0
				se_fue.emit(self)
	ruido = maxf(0.0, ruido - olvido_ruido * delta)
	queue_redraw()


func _destino_junto_a_felipe() -> float:
	# Del lado en que ya está, a distancia_cara de Felipe (si no cabe, del otro lado).
	var lado := signf(position.x - felipe.global_position.x)
	if lado == 0.0:
		lado = 1.0
	var x := felipe.global_position.x + lado * distancia_cara
	if x < 40.0 or x > 580.0:
		x = felipe.global_position.x - lado * distancia_cara
	return clampf(x, 40.0, 580.0)


## Camina hacia x; devuelve true al llegar.
func _caminar_hacia(x: float, rapidez: float, delta: float) -> bool:
	var dx := x - position.x
	if absf(dx) < 3.0:
		_paso = 0.0
		return true
	mirando = signf(dx)
	position.x += signf(dx) * minf(absf(dx), rapidez * delta)
	_paso += delta * 9.0
	return false


func _mirar_a_felipe() -> void:
	var dx := felipe.global_position.x - position.x
	if absf(dx) > 4.0:
		mirando = signf(dx)


func _revisar_ronroneo(delta: float) -> bool:
	var cerca := absf(felipe.global_position.x - position.x) <= distancia_ronroneo
	if felipe.ronroneando and cerca:
		ronroneo_acumulado += delta
		if int(ronroneo_acumulado * 6.0) != int((ronroneo_acumulado - delta) * 6.0):
			_corazones.append([Vector2(randf_range(-14, 14), -ALTO + 30), 0.0])
		if ronroneo_acumulado >= ronroneo_para_perdonar:
			estado = Estado.PERDONANDO
			_tiempo = 0.0
			_mirar_a_felipe()
			for i in 6:
				_corazones.append([Vector2(randf_range(-30, 30), -ALTO + randf_range(10, 60)), -i * 0.08])
			perdona.emit(self)
			return true
	return false


func _actualizar_corazones(delta: float) -> void:
	for corazon: Array in _corazones:
		corazon[1] += delta
	_corazones = _corazones.filter(func(c: Array) -> bool: return c[1] < 1.2)


func _draw() -> void:
	var enojada := estado in [Estado.REGANANDO, Estado.PERSIGUIENDO, Estado.ENTRANDO]
	var feliz := estado == Estado.PERDONANDO
	var piel := Color(0.93, 0.76, 0.62)
	var pelo := Color(0.28, 0.16, 0.1)
	var polera := Color(0.35, 0.55, 0.62)
	var jeans := Color(0.22, 0.27, 0.45)
	var m := mirando
	var paso := sin(_paso) * 6.0
	# Piernas y zapatos.
	draw_rect(Rect2(-14 + paso * 0.5, -96, 12, 92), jeans)
	draw_rect(Rect2(2 - paso * 0.5, -96, 12, 92), jeans.darkened(0.1))
	draw_rect(Rect2(-16 + paso * 0.5, -6, 16, 6), Color(0.9, 0.9, 0.9))
	draw_rect(Rect2(0 - paso * 0.5, -6, 16, 6), Color(0.85, 0.85, 0.85))
	# Cadera y torso.
	draw_rect(Rect2(-18, -110, 36, 16), jeans)
	draw_rect(Rect2(-19, -166, 38, 58), polera)
	# Brazos: enojada, uno en la cintura y el otro apuntando a Felipe; feliz, abiertos hacia él.
	if enojada:
		# Brazo de atrás: mano en la cintura.
		var atras := -27.0 if m > 0 else 18.0
		draw_rect(Rect2(atras, -164, 9, 34), polera.darkened(0.15))
		draw_rect(Rect2(atras + (5.0 if m > 0 else -5.0), -132, 9, 10), piel)
		var hombro := Vector2(16 * m, -160)
		var mano := hombro + Vector2(46 * m, 10 + sin(_tiempo * 18.0) * 3.0)
		draw_line(hombro, mano, polera.darkened(0.15), 10.0)
		draw_line(hombro.lerp(mano, 0.6), mano, piel, 8.0)
		draw_circle(mano + Vector2(4 * m, 0), 4.0, piel)
	elif feliz:
		for lado in [-1.0, 1.0]:
			var hombro := Vector2(17 * lado, -160)
			var mano := hombro + Vector2(26 * lado + 18 * m, 44)
			draw_line(hombro, mano, polera.darkened(0.15), 10.0)
			draw_circle(mano, 5.0, piel)
	else:
		draw_rect(Rect2(-27, -164, 9, 62), polera.darkened(0.15))
		draw_rect(Rect2(18, -164, 9, 62), polera.darkened(0.15))
		draw_rect(Rect2(-27, -110, 9, 10), piel)
		draw_rect(Rect2(18, -110, 9, 10), piel)
	# Cuello, cabeza y pelo (cola de caballo detrás).
	draw_rect(Rect2(-5, -172, 10, 8), piel)
	draw_rect(Rect2(-22.0 if m > 0 else 12.0, -192, 10, 24), pelo)
	draw_rect(Rect2(-13, -200, 26, 30), piel)
	draw_rect(Rect2(-14, -202, 28, 9), pelo)
	draw_rect(Rect2(-16.0 if m > 0 else 4.0, -198, 12, 16), pelo)
	var ojo := Vector2(6 * m, -186)
	if feliz:
		draw_arc(ojo, 3.0, PI, TAU, 6, Color(0.15, 0.1, 0.1), 1.5)
		draw_arc(Vector2(6 * m, -177), 4.0, 0.0, PI, 6, Color(0.6, 0.2, 0.2), 1.5)
	else:
		draw_rect(Rect2(ojo - Vector2(1.5, 1.5), Vector2(3, 3)), Color(0.15, 0.1, 0.1))
		if enojada:
			draw_line(ojo + Vector2(-4, -6), ojo + Vector2(4, -3) , Color(0.2, 0.1, 0.08), 2.0)
			draw_rect(Rect2(Vector2(6 * m - 4, -176), Vector2(8, 3)), Color(0.55, 0.15, 0.15))
		else:
			draw_line(Vector2(6 * m - 3, -176), Vector2(6 * m + 3, -176), Color(0.55, 0.2, 0.2), 1.5)
	# Corazones del perdón.
	for corazon: Array in _corazones:
		var vida: float = corazon[1]
		if vida < 0.0:
			continue
		var p: Vector2 = corazon[0] + Vector2(0, -vida * 30.0)
		var c := Color(1.0, 0.35, 0.5, 1.0 - vida / 1.2)
		draw_circle(p + Vector2(-3, 0), 3.5, c)
		draw_circle(p + Vector2(3, 0), 3.5, c)
		draw_colored_polygon(PackedVector2Array([p + Vector2(-6.5, 1), p + Vector2(6.5, 1), p + Vector2(0, 8)]), c)
