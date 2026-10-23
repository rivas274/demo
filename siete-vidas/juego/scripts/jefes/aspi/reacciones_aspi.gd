class_name ReaccionesAspi
extends Node2D
## El «jugo» de los momentos fuertes de la pelea con A.S.P.I. (v3; video «How to make enemy spawns feel good» que mandó
## el creador: avisar, hacer temblar el piso y despertar al enemigo con una pausa). Pieza de BatallaAspi; los números
## están en `datos/jefes/aspi_jugo.tres` (DatosJugoJefe).
## - **Golpe:** cuando Felipe le salta encima, el piso tiembla: onda de choque en escalones de pixel, polvo, lo tirado
##   cerca brinca y la cámara se sacude en vertical (además del congelado del «¡CLIC!»). El golpe final (el que la
##   apaga del todo) es más fuerte.
## - **Despertar:** al entrar y al volver de cada fase, pitido, la luz pasa a roja, «!» sobre ella y una pausa antes de
##   moverse; mientras, una marca roja en el piso hacia donde va a ir (Felipe).
## - **Celebración:** Felipe, alegre y juguetón, maúlla de gusto al aterrizar después de apagarla (si no está moviéndose).

var b: BatallaAspi
var datos: DatosJugoJefe
## Onda de choque en curso: centro, tiempo y fuerza (1 = normal).
var _onda_centro := Vector2.ZERO
var _onda_t := -1.0
var _onda_fuerza := 1.0
## Despertar en curso (segundos que faltan; 0 = no) y adónde mira.
var despertando := 0.0
var _celebrar := false
## Para las pruebas: cuántos golpes y despertares hubo, y si el último golpe fue el final.
var golpes := 0
var despertares := 0
var ultimo_final := false


func _init(de: BatallaAspi) -> void:
	name = "Reacciones de A.S.P.I."
	b = de
	datos = de.datos.jugo if de.datos.jugo else DatosJugoJefe.new()


func _ready() -> void:
	Capas.usar(self, Capas.EFECTOS)
	material = b.sin_sombrear


## ¡Golpe! El piso tiembla. `final`: el que la apaga del todo (más fuerte que los de las otras fases).
func golpe(donde: Vector2, final := false) -> void:
	var k := datos.multiplicador_final if final else 1.0
	golpes += 1
	ultimo_final = final
	_onda_centro = Vector2(roundf(donde.x), b.nivel.datos.suelo + 2.0)
	_onda_t = 0.0
	_onda_fuerza = k
	if final:
		b.nivel.travesuras.jugo.temblar(datos.temblor_final, datos.temblor_final_s)
	else:
		b.nivel.travesuras.jugo.temblar(datos.temblor_golpe, datos.temblor_golpe_s)
	var polvo := Particulas.polvo(int(datos.polvo * k), 0.6, Vector2(0, 320), Vector2(60, 150), Vector2(2, 3), Color(0.86, 0.8, 0.72), 70.0)
	polvo.global_position = _onda_centro + Vector2(0, -2)
	Capas.usar(polvo, Capas.EFECTOS)
	b.add_child(polvo)
	polvo.restart()
	polvo.emitting = true
	polvo.finished.connect(polvo.queue_free)
	# Lo tirado cerca brinca (pedazos, papeles, notas, libros, motas de pelusa): más cerca, más alto.
	for nodo in b.nivel.find_children("*", "PiezaSuelta", true, false):
		var pieza := nodo as PiezaSuelta
		var distancia := absf(pieza.global_position.x - _onda_centro.x)
		if pieza.en_piso and distancia < datos.radio_brinco * k:
			pieza.brincar(datos.brinco * k * (1.0 - distancia / (datos.radio_brinco * k * 1.4)))
	# Al último golpe le sigue su derrota (y Felipe juega con el estambre al final): ahí no maúlla.
	_celebrar = not final
	queue_redraw()


## Se despierta: pitido, luz roja, «!» y pausa de `pausa_despertar` s antes de moverse.
func despertar() -> void:
	despertando = datos.pausa_despertar
	despertares += 1
	b.jefe.patrulla.quieta = true
	b.apariencia.luz_aviso = Color("e0483b")
	b.sonar_evento("despertar")


func _process(delta: float) -> void:
	if _onda_t >= 0.0:
		_onda_t += delta / maxf(Engine.time_scale, 0.001)
		if _onda_t > datos.onda_paso * (datos.onda_escalones + 1):
			_onda_t = -1.0
		queue_redraw()
	if despertando > 0.0:
		despertando -= delta
		queue_redraw()
		if despertando <= 0.0:
			despertando = 0.0
			b.apariencia.luz_aviso = Color(0, 0, 0, 0)
			b.jefe.patrulla.quieta = false
	# Felipe celebra al aterrizar después del golpe (maullido alegre), si el jugador no lo está moviendo.
	if _celebrar and b.felipe.is_on_floor() and b.felipe.velocity.y >= 0.0 and _onda_t < 0.0:
		_celebrar = false
		var quieto := not (Input.is_action_pressed("mover_izquierda") or Input.is_action_pressed("mover_derecha"))
		if quieto and b.felipe.estado == Felipe.Estado.SUELO and b.fase == PeleaJefe.Fase.PELEA:
			b.felipe.cambiar_estado(Felipe.Estado.MAULLANDO)


func _draw() -> void:
	# Onda de choque: un anillo tendido en el piso (elipse aplastada) que crece en escalones enteros.
	if _onda_t >= 0.0:
		var escalon := mini(int(_onda_t / datos.onda_paso), datos.onda_escalones - 1)
		var radio := roundf(datos.onda_radio * _onda_fuerza * float(escalon + 1) / float(datos.onda_escalones))
		var alto := maxf(2.0, roundf(radio * 0.12))
		var color := Color(1.0, 0.95, 0.75, 0.9 - 0.25 * escalon)
		var x := -radio
		while x <= radio:
			var y := alto * sqrt(maxf(0.0, 1.0 - (x * x) / (radio * radio)))
			draw_rect(Rect2(_onda_centro + Vector2(roundf(x), -roundf(y)), Vector2(3, 1)), color)
			draw_rect(Rect2(_onda_centro + Vector2(roundf(x), roundf(y)), Vector2(3, 1)), color)
			x += 5.0
	# Al despertar: «!» rojo sobre ella (dibujado en su lugar, no una palabra que se corra) y la marca roja en el piso
	# hacia donde va a ir (Felipe).
	if despertando > 0.0:
		var arriba := (b.jefe.global_position + Vector2(0, -BatallaAspi.ALTO_ARRIBA - 22)).round()
		var salto := -2.0 if despertando > datos.pausa_despertar * 0.6 else 0.0
		var caja := Rect2(arriba + Vector2(-6, -16 + salto), Vector2(12, 16))
		draw_rect(caja.grow(1), Color(0.12, 0.05, 0.05))
		draw_rect(caja, Color("e0483b"))
		var signo := tr("PALABRA_ALERTA")
		var x := roundf((caja.size.x - Estilo.ancho(signo, &"jefe_pista")) / 2.0)
		Estilo.escribir(self, caja.position + Vector2(x, 13), signo, &"jefe_pista", Color(1, 0.97, 0.92))
	if despertando > 0.0 and is_instance_valid(b.felipe):
		marca(self, Vector2(b.felipe.global_position.x, b.nivel.datos.suelo + 2.0), datos.radio_marca, Color("e0483b"))


## Marca de aviso en el piso: un óvalo de pixel tendido que parpadea (la carga, la bola que va a caer, el despertar).
static func marca(c: CanvasItem, centro: Vector2, radio: float, color: Color) -> void:
	var parpadeo := int(Time.get_ticks_msec() / 120) % 2 == 0
	var tono := color if parpadeo else color.lightened(0.35)
	for i in 12:
		var a := TAU * i / 12.0
		c.draw_rect(Rect2((centro + Vector2(cos(a) * radio, sin(a) * radio * 0.3)).round() - Vector2(1, 0), Vector2(2, 1)), tono)
