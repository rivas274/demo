class_name RemateAspi
extends Node2D
## El momento estrella de la pelea con A.S.P.I. (v4; respuestas de ChatGPT y Gemini a la v3,
## `diseno/revisiones/2026-10-23-pelea-aspi-v4.md`): quedar vulnerable, la anticipación y el golpe. Pieza de
## BatallaAspi; sus números están en `datos/jefes/aspi_jugo.tres` (DatosJugoJefe, grupo «Remate»).
## - **Vulnerable:** con el depósito lleno («¡LLENA! ¡SALTA!») o electrocutada en un charco («¡EN CORTO! ¡AHORA!») se
##   queda quieta e inofensiva; nunca justo bajo la repisa ni bajo la isla del librero.
## - **Anticipación (depósito lleno):** el motor falla (tosidos cada vez más graves), el depósito se hincha (tope ±8 %),
##   echa humo y vibra. Si Felipe le cae encima, justo antes del golpe se hace silencio.
## - **Golpe:** pausa de impacto de 4 cuadros (el final, más larga), destello blanco de su silueta, estrellas, la onda y
##   el temblor (ReaccionesAspi.golpe), «¡CLIC!» y polvo. Al tercero se apaga del todo.

## Margen a cada lado de los muebles bajo los que no se queda llena (medio cuerpo de A.S.P.I. y un poco).
const MARGEN_LLENA := 44.0
## Lleno bajo la repisa: sale disparada hacia adelante (nunca queda justo bajo la repisa).
const EMPUJE_LLENA := 80.0
## Al apagarla, Felipe rebota hacia arriba.
const REBOTE := -420.0
## Color de la silueta en el destello (modulate por encima de 1: se satura a blanco).
const BLANCO := Color(12, 12, 12)
## Estrellas: cuánto vuelan (s) y a qué velocidad (px/s).
const VUELO_ESTRELLA := 0.6
const VELOCIDAD_ESTRELLA := 240.0

var b: BatallaAspi
var datos: DatosJugoJefe
## Segundos que lleva vulnerable.
var reloj := 0.0
## Para las pruebas: hubo silencio antes del último golpe, y cuántos golpes con pausa de impacto.
var hubo_silencio := false
var congelados := 0
var _callado := false
var _reloj_humo := 0.0
var _reloj_falla := 0.0
var _fallas := 0
## Estrellas en vuelo: [posición inicial, dirección, tiempo].
var _estrellas: Array = []
var _humo: CPUParticles2D


func _init(de: BatallaAspi) -> void:
	name = "Remate de A.S.P.I."
	b = de
	datos = de.datos.jugo if de.datos.jugo else DatosJugoJefe.new()


func _ready() -> void:
	Profundidad.poner(self, Capas.Rol.EFECTO)
	material = b.sin_sombrear
	_humo = Particulas.polvo(6, 0.9, Vector2(0, -30), Vector2(10, 30), Vector2(3, 5), Color(0.62, 0.62, 0.66, 0.85), 20.0)
	_humo.name = "Humo"
	_humo.direction = Vector2(0, -1)
	add_child(_humo)


## Queda quieta, inofensiva y vulnerable: con el depósito lleno (tapa abierta, se hincha y echa humo) o electrocutada por
## un charco en el apagón (vibra con chispas). El aviso nace sobre ella (DibujoBatallaAspi), en amarillo: oportunidad.
func quedar_vulnerable(por: String) -> void:
	b.motivo = por
	b.llena = true
	reloj = 0.0
	_callado = false
	_fallas = 0
	_reloj_falla = 0.0
	_reloj_humo = 0.0
	b.terminar_ataque()
	b.jefe.patrulla.destino = INF
	b.jefe.patrulla.quieta = true
	b.jefe.dano.activo = false
	b.apariencia.vibrando = true
	if por == "deposito":
		b.apariencia.abrir_tapa()
		b.nivel.sonar("logro")
	# En corto se queda sobre el charco (v5: correrla cruzaba medio estudio; «Aplastar» la alcanza igual).
	if por == "charco":
		return
	var x := b.jefe.global_position.x
	var libre := piso_libre(x)
	if absf(libre - x) > 0.5:
		var sale := create_tween()
		sale.tween_property(b.jefe, "position:x", b.jefe.position.x + (libre - x), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## La x libre más cercana para quedarse llena: fuera de lo que tapa su botón desde arriba (Nivel1.ASPI_NO_SE_LLENA_BAJO,
## con medio cuerpo de margen) y dentro de su patrulla. La repisa conserva su regla de siempre (80 px hacia adelante).
func piso_libre(x: float) -> float:
	var patrulla := b.jefe.patrulla
	var zonas: Array[Vector2] = []
	for nombre: String in Nivel1.ASPI_NO_SE_LLENA_BAJO:
		var pieza := Nivel1.rect_pieza(nombre)
		if pieza.has_area():
			zonas.append(Vector2(pieza.position.x - MARGEN_LLENA, pieza.end.x + MARGEN_LLENA))
	var repisa := b.nivel.pieza("Repisa de las macetas")
	if repisa and absf(x - (repisa.position.x + 30.0)) < 70.0:
		var hacia := 1.0 if x + EMPUJE_LLENA < patrulla.limite_derecho else -1.0
		x = clampf(x + hacia * EMPUJE_LLENA, patrulla.limite_izquierdo, patrulla.limite_derecho)
	# Las zonas se tocan (la caja va delante del librero): se sale por la derecha, hacia la puerta del balcón (piso
	# libre); si no cabe en su patrulla, por la izquierda.
	for zona in zonas:
		if x > zona.x and x < zona.y:
			var desde := zona.x
			var hasta := zona.y
			for otra in zonas:
				if otra.x <= hasta and otra.y >= desde:
					desde = minf(desde, otra.x)
					hasta = maxf(hasta, otra.y)
			x = hasta if hasta <= patrulla.limite_derecho else desde
			break
	return x


## Cada cuadro mientras está vulnerable: anticipación, silencio, el golpe si Felipe le cae encima, o se le pasa.
func actualizar(delta: float) -> void:
	reloj += delta
	var felipe := b.felipe
	# El botón está arriba del dibujo, que va `profundidad` px más abajo que los pies (más cerca de la cámara).
	var distancia := felipe.global_position - b.jefe.global_position - Vector2(0, b.jefe.datos.profundidad)
	var arriba := -BatallaAspi.ALTO_ARRIBA
	if not b.aplastar.saltando and felipe.velocity.y > 0.0 and absf(distancia.x) < b.jefe.datos.ancho / 2.0 + 4.0 and distancia.y > arriba - 14.0 and distancia.y < arriba + 18.0:
		felipe.velocity.y = REBOTE
		apagar()
		return
	_anticipar(delta, distancia)
	if reloj >= DatosJefe.por_fase(b.datos.tiempo_vulnerable, b.vencidas):
		_se_le_paso()


## Lleno: el depósito se hincha en pulsos (más rápido al final), echa humo y el motor tose cada vez más grave. Si Felipe
## viene cayendo encima, silencio (contraste antes del golpe).
func _anticipar(delta: float, distancia: Vector2) -> void:
	var cayendo := b.felipe.velocity.y > 0.0 and absf(distancia.x) < b.jefe.datos.ancho and distancia.y < -BatallaAspi.ALTO_ARRIBA and distancia.length() < datos.silencio_distancia
	if cayendo:
		silenciar()
	if b.motivo != "deposito":
		return
	var pulso := 2.0 + reloj * 0.8
	b.apariencia.inflado = datos.inflado * (0.5 + 0.5 * absf(sin(reloj * pulso * PI)))
	_reloj_humo -= delta
	if _reloj_humo <= 0.0:
		_reloj_humo = datos.humo_cada
		_humo.global_position = b.jefe.global_position + Vector2(-6, -BatallaAspi.ALTO_ARRIBA - 4 + b.jefe.datos.profundidad)
		_humo.restart()
		_humo.emitting = true
	_reloj_falla -= delta
	if _reloj_falla <= 0.0 and not _callado:
		_reloj_falla = datos.falla_cada
		_fallas += 1
		b.sonar_evento("falla", maxf(0.5, 1.0 - _fallas * 0.08))


## Silencio de golpe justo antes del impacto (una vez por cada vez que queda vulnerable).
func silenciar() -> void:
	if _callado:
		return
	_callado = true
	hubo_silencio = true
	b.nivel.callar()


## Nadie la apagó a tiempo: con el depósito lleno lo vacía EN EL PISO (montaña de pelusa con todo lo que tenía); en
## corto, sigue con lo que tenía.
func _se_le_paso() -> void:
	b.llena = false
	b.jefe.patrulla.quieta = false
	b.apariencia.vibrando = false
	b.apariencia.inflado = 0.0
	if b.motivo == "charco":
		return
	var tenia := b.deposito
	b.deposito = 0
	b.escupir_pelusa(tenia)
	b.nivel.travesuras.jugo.palabra_en_mundo("JEFE_LO_VACIO", b.jefe.global_position + Vector2(0, -96), Color(1.0, 0.88, 0.4), 16)


## ¡CLIC!: pausa de impacto, destello de su silueta, estrellas, onda, temblor, polvo y sonido en capas.
func apagar() -> void:
	b.vencidas += 1
	var final := b.vencidas >= b.datos.fases
	b.apariencia.cerrar_tapa()
	b.apariencia.inflado = 0.0
	b.apariencia.vibrando = false
	congelados += 1
	b.nivel.travesuras.jugo.congelar(datos.congelado_final if final else datos.congelado_golpe)
	b.presentacion.destello(0.25 if not final else 0.45)
	_destello_silueta(datos.destello_final if final else datos.destello_golpe)
	_soltar_estrellas(datos.estrellas_final if final else datos.estrellas)
	b.nivel.travesuras.jugo.palabra_en_mundo("PALABRA_CLIC", b.jefe.global_position + Vector2(0, -70), Color(1.0, 0.95, 0.5), 22)
	b.tiempo_clic = Time.get_ticks_msec() / 1000.0
	b.soltar_polvo(b.jefe.global_position + Vector2(0, -20))
	b.nivel.sonar("golpe")
	b.nivel.sonar("caja")
	# El piso tiembla: onda de choque, polvo, lo tirado brinca y sacudida vertical (más fuerte el último golpe).
	b.reacciones.golpe(b.jefe.global_position, final)
	b.limpiar.limpiando = false
	if final:
		# Vuelve la luz de golpe con el «¡APAGADA!» y la cámara lenta de su derrota.
		b.apagon.encender()
		b.jefe.vida.morir()
		return
	var motas: int = DatosJefe.por_fase(b.datos.devuelve, b.vencidas - 1) if not b.datos.devuelve.is_empty() else 0
	b.cambiar_fase()
	# Se le abre el depósito y escupe la pelusa: lo que limpió vuelve al piso (cuando ya se fue el «¡CLIC!»).
	b.pelusa.prometidas += motas
	var escupe := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	escupe.tween_interval(datos.espera_escupir)
	escupe.tween_callback(func() -> void:
		b.pelusa.prometidas = maxi(0, b.pelusa.prometidas - motas)
		if b.fase == PeleaJefe.Fase.PELEA:
			b.escupir_pelusa(motas))


## Su silueta se pone blanca un instante (en tiempo real: dura aunque el juego esté congelado).
func _destello_silueta(segundos: float) -> void:
	var apariencia := b.apariencia
	apariencia.self_modulate = BLANCO
	get_tree().create_timer(segundos, true, false, true).timeout.connect(func() -> void:
		if is_instance_valid(apariencia):
			apariencia.self_modulate = Color.WHITE)


func _soltar_estrellas(cantidad: int) -> void:
	var centro := b.jefe.global_position + Vector2(0, -BatallaAspi.ALTO_ARRIBA - 6.0)
	for i in cantidad:
		var angulo := PI + PI * (float(i) + 0.5) / float(cantidad)
		_estrellas.append([centro, Vector2(cos(angulo), sin(angulo)), 0.0])


func _process(delta: float) -> void:
	if _estrellas.is_empty():
		return
	# En tiempo real: las estrellas saltan durante la pausa de impacto.
	var real := minf(delta / maxf(Engine.time_scale, 0.001), 0.05)
	for estrella: Array in _estrellas:
		estrella[2] += real
	_estrellas = _estrellas.filter(func(e: Array) -> bool: return e[2] < VUELO_ESTRELLA)
	queue_redraw()


## Estrellas de 7 px (cruz de pixel con borde oscuro y centro blanco) que salen del golpe hacia arriba y a los lados.
func _draw() -> void:
	for estrella: Array in _estrellas:
		var t: float = estrella[2]
		var punto: Vector2 = (estrella[0] as Vector2) + (estrella[1] as Vector2) * VELOCIDAD_ESTRELLA * t * (1.0 - t) + Vector2(0, 120.0 * t * t)
		punto = punto.round()
		var color := Color(1.0, 0.88, 0.4) if int(t * 20.0) % 2 == 0 else Color(1, 1, 1)
		var largo := 3.0 if t < VUELO_ESTRELLA * 0.7 else 2.0
		draw_rect(Rect2(punto + Vector2(-largo - 1, -1), Vector2(largo * 2 + 3, 3)), Color(0.15, 0.08, 0.05, 0.8))
		draw_rect(Rect2(punto + Vector2(-1, -largo - 1), Vector2(3, largo * 2 + 3)), Color(0.15, 0.08, 0.05, 0.8))
		draw_rect(Rect2(punto + Vector2(-largo, 0), Vector2(largo * 2 + 1, 1)), color)
		draw_rect(Rect2(punto + Vector2(0, -largo), Vector2(1, largo * 2 + 1)), color)
		draw_rect(Rect2(punto, Vector2(1, 1)), Color.WHITE)
