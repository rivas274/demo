class_name BatallaAspi
extends Node2D
## Pelea con A.S.P.I. en el estudio de Valeria ("La Bestia del Estudio"). Al entrar, A.S.P.I. despierta en su base y
## la presentación de jefe (PresentacionJefe, la misma para todos) congela el juego: en la imaginación de Felipe crece
## hasta volverse una bestia gigante en un estudio en llamas. Al terminar la entrada, la imaginación se desvanece y
## el estudio vuelve a verse normal.
## La pelea: los zarpazos rebotan en la carcasa. A.S.P.I. persigue a Felipe; cuando algo se rompe en el piso deja una
## mancha y ella va a limpiarla (aspira: de pie arrastra a Felipe, agachado se aferra). Solo mientras limpia o está
## aturdida se puede tirar de un enchufe de su base. Cada enchufe sube una fase (más rápida, limpia menos; en la
## tercera escupe bolas de pelo). Con los tres, se apaga: se abre la puerta del balcón y Felipe se lame la pata.

signal empezada
signal fase_cambiada(fase: Fase)
signal terminada

enum Fase { ESPERANDO, ENTRADA, PELEA, FIN }

const NOMBRE := "A.S.P.I."
const TITULO := "Devoradora de Pelos · Nivel 99"
const ENCHUFES_TOTALES := 3
## Segundos limpiando cada mancha, por fase (0, 1 o 2 enchufes tirados).
const TIEMPO_LIMPIEZA := [6.0, 5.0, 4.5]
const VELOCIDAD := [60.0, 85.0, 105.0]
## Más que caminar (120 px/s): de pie no se escapa; hay que agacharse.
const FUERZA_SUCCION := 150.0
const RADIO_SUCCION := 200.0
const ESPERA_BOLAS := 1.6
const VELOCIDAD_BOLA := 150.0
const DESVANECER := 0.8
const PISTAS := [
	"Ensucia el piso y desenchúfala con {interactuar}",
	"¡Más rápida! Si te aspira, mantén {agacharse}",
	"¡Furia! Salta las bolas de pelo",
]
const CARTELES := ["FASE 1: ¡ENSUCIA Y DESENCHUFA!", "FASE 2: ¡MÁS RÁPIDA!", "FASE 3: ¡FURIA!"]

var fase := Fase.ESPERANDO
var aspi: Aspi
var felipe: Felipe
var sala: Sala
var enchufes: Array[Enchufe] = []
var tirados := 0
var manchas: Array[float] = []
var limpiando := false
var succionando := false
## 0 = estudio normal, 1 = fin del mundo (solo en la entrada).
var transformacion := 0.0
## 0 = A.S.P.I. de tamaño real, 1 = bestia gigante del fondo (solo en la entrada).
var gigante := 0.0
var bolas: Array[Node2D] = []
## Entrada tipo Broforce, carteles y barra de vida (componente reutilizable para cualquier jefe).
var presentacion: PresentacionJefe
## El estudio: ahí se pelea.
var arena: Rect2

var _reloj := 0.0
var _rayo := 0.0
var _origen_gigante := Vector2.ZERO
var _centro_gigante := Vector2.ZERO
var _viento: Node2D
var _manchas_dibujo: Node2D


func _init(jefa: Aspi, gato: Felipe, nivel: Sala, tomas: Array[Enchufe]) -> void:
	aspi = jefa
	felipe = gato
	sala = nivel
	enchufes = tomas
	name = "Batalla"
	arena = Sala.rect_de("estudio")
	_centro_gigante = Vector2(arena.get_center().x, Sala.SUELO - 160)
	# Detrás de los muebles y delante de la pared: la imaginación se ve en el estudio.
	z_index = -10
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	aspi.apagado.connect(_terminar)
	aspi.quieta = true
	aspi.invulnerable = true
	# Sin jefa no hay pelea (algunas pruebas la quitan).
	aspi.tree_exiting.connect(queue_free)
	for enchufe in enchufes:
		enchufe.permiso = puede_desenchufar
		enchufe.desenchufado.connect(_al_desenchufar)
		enchufe.rechazado.connect(_al_rechazar)
	presentacion = PresentacionJefe.new(NOMBRE, TITULO)
	presentacion.encuadre_momento = _centro_gigante + Vector2(0, 40)
	presentacion.terminada.connect(_al_terminar_presentacion)
	add_child(presentacion)
	_manchas_dibujo = Node2D.new()
	_manchas_dibujo.name = "Manchas"
	_manchas_dibujo.z_index = 9
	_manchas_dibujo.draw.connect(_dibujar_manchas)
	add_child(_manchas_dibujo)
	_viento = Node2D.new()
	_viento.name = "Viento"
	_viento.z_index = 30
	_viento.draw.connect(_dibujar_viento)
	add_child(_viento)


func _process(delta: float) -> void:
	_rayo = maxf(0.0, _rayo - delta * 4.0)
	if fase == Fase.ENTRADA:
		gigante = ease(presentacion.momento, 0.4)
		transformacion = presentacion.momento
		aspi.visible = gigante < 0.15 or presentacion.t >= PresentacionJefe.MOMENTO
		if presentacion.momento > 0.0 and fmod(presentacion.t, 0.9) < delta:
			_rayo = 1.0
	_actualizar_barra()
	queue_redraw()
	_viento.queue_redraw()
	_manchas_dibujo.queue_redraw()


func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	match fase:
		Fase.ESPERANDO:
			# Al entrar al estudio, A.S.P.I. despierta.
			if arena.grow_individual(-30, 0, -30, 0).has_point(felipe.global_position - Vector2(0, 1)) and felipe.is_on_floor():
				empezar()
		Fase.PELEA:
			_actualizar_pelea(delta)
	_mover_bolas(delta)


## Arranca la entrada: congela el juego y toma la cámara.
func empezar() -> void:
	if fase != Fase.ESPERANDO:
		return
	fase = Fase.ENTRADA
	aspi.necesita_aturdir = true
	aspi.invulnerable = true
	aspi.quieta = true
	felipe.empuje = Vector2.ZERO
	_origen_gigante = aspi.global_position + Vector2(0, -Aspi.ALTO / 2.0)
	presentacion.divisiones = ENCHUFES_TOTALES
	presentacion.pantallas = sala.pantallas
	sala.sonar("batalla")
	presentacion.presentar(felipe, aspi, Rect2(arena.position.x, 0, arena.size.x, Sala.ALTO))
	empezada.emit()


## Para pruebas y depuración: termina la entrada de golpe.
func saltar_entrada() -> void:
	presentacion.saltar()


## Se puede tirar de un enchufe mientras A.S.P.I. está ocupada: limpiando o aturdida.
func puede_desenchufar() -> bool:
	return fase == Fase.PELEA and (limpiando or aspi.esta_aturdida())


## Algo se rompió en el piso: si es en el estudio y hay pelea, queda una mancha para limpiar.
func agregar_mancha(posicion: Vector2) -> void:
	if fase in [Fase.ESPERANDO, Fase.FIN] or not arena.grow(4).has_point(posicion - Vector2(0, 1)):
		return
	manchas.append(clampf(posicion.x, aspi.limite_izquierdo, aspi.limite_derecho))


func _actualizar_barra() -> void:
	presentacion.vida = 1.0 - float(tirados) / ENCHUFES_TOTALES if fase == Fase.PELEA else -1.0
	presentacion.escudo = 0.0


func _al_terminar_presentacion() -> void:
	aspi.visible = true
	if fase != Fase.ENTRADA:
		return
	fase = Fase.PELEA
	aspi.quieta = false
	aspi.vision = arena.size.x
	_cambiar_fase()
	# La imaginación se desvanece: el resto de la pelea se ve el estudio normal.
	var vuelta := create_tween().set_parallel()
	vuelta.tween_property(self, "gigante", 0.0, DESVANECER)
	vuelta.tween_property(self, "transformacion", 0.0, DESVANECER)


func _cambiar_fase() -> void:
	_reloj = 0.0
	aspi.velocidad_patrulla = VELOCIDAD[tirados] * 0.7
	aspi.velocidad_persecucion = VELOCIDAD[tirados]
	presentacion.cartel(CARTELES[tirados])
	presentacion.destello(0.4)
	presentacion.sacudir(0.25)
	if sala.pantallas:
		sala.pantallas.aviso_fijo = PISTAS[tirados]
	fase_cambiada.emit(fase)


func _actualizar_pelea(delta: float) -> void:
	felipe.empuje = Vector2.ZERO
	succionando = false
	if aspi.esta_aturdida():
		limpiando = false
		aspi.destino = INF
		return
	if not manchas.is_empty():
		var mancha := manchas[0]
		aspi.destino = mancha
		if absf(aspi.global_position.x - mancha) < 6.0:
			if not limpiando:
				limpiando = true
				_reloj = 0.0
				sala.sonar("succion")
			_reloj += delta
			succionando = true
			_aspirar()
			if _reloj >= TIEMPO_LIMPIEZA[tirados]:
				manchas.pop_front()
				limpiando = false
				_reloj = 0.0
		return
	limpiando = false
	aspi.destino = INF
	if tirados >= 2:
		_reloj += delta
		if _reloj >= ESPERA_BOLAS:
			_reloj = 0.0
			_escupir_bola()


## Mientras limpia aspira: de pie, Felipe se desliza hacia ella; agachado se aferra.
func _aspirar() -> void:
	var distancia := aspi.global_position.x - felipe.global_position.x
	if absf(distancia) < RADIO_SUCCION and absf(distancia) > 6.0 and absf(felipe.global_position.y - aspi.global_position.y) < 40.0:
		felipe.empuje = Vector2(signf(distancia) * FUERZA_SUCCION, 0.0)


func _al_desenchufar(_enchufe: Enchufe) -> void:
	tirados += 1
	sala.sonar("golpe")
	# Se enoja: deja de limpiar y va por Felipe.
	manchas.clear()
	limpiando = false
	aspi.destino = INF
	if tirados >= ENCHUFES_TOTALES:
		aspi.apagada = true
		aspi.apagado.emit()
		return
	_cambiar_fase()


func _al_rechazar(_enchufe: Enchufe) -> void:
	sala.sonar("golpe")
	presentacion.cartel("¡TE VIO! DISTRÁELA PRIMERO", 1.2)


func _escupir_bola() -> void:
	var bola := Node2D.new()
	bola.name = "Bola de pelo"
	bola.z_index = 30
	var hacia := signf(felipe.global_position.x - aspi.global_position.x)
	bola.set_meta("velocidad", (hacia if hacia != 0.0 else 1.0) * VELOCIDAD_BOLA)
	bola.global_position = aspi.global_position + Vector2(hacia * 20.0, -6.0)
	bola.draw.connect(_dibujar_bola.bind(bola))
	add_child(bola)
	bolas.append(bola)
	sala.sonar("caja")


func _mover_bolas(delta: float) -> void:
	for bola: Node2D in bolas.duplicate():
		bola.global_position.x += float(bola.get_meta("velocidad")) * delta
		bola.rotation += float(bola.get_meta("velocidad")) * delta * 0.15
		bola.queue_redraw()
		var distancia := felipe.global_position - bola.global_position
		# Rueda por el piso: solo pega si Felipe tiene las patas abajo.
		if absf(distancia.x) < 12.0 and distancia.y > -4.0 and distancia.y < 14.0:
			felipe.recibir_dano(1, bola.global_position.x)
			_quitar_bola(bola)
		elif not arena.grow(20).has_point(bola.global_position) or fase == Fase.FIN:
			_quitar_bola(bola)


func _quitar_bola(bola: Node2D) -> void:
	bolas.erase(bola)
	bola.queue_free()


## Al desenchufarla se apaga: cartel, puerta del balcón abierta (lo hace la sala) y Felipe se acicala.
func _terminar() -> void:
	presentacion.saltar()
	fase = Fase.FIN
	succionando = false
	limpiando = false
	manchas.clear()
	aspi.destino = INF
	felipe.empuje = Vector2.ZERO
	presentacion.destello(1.0)
	presentacion.cartel("¡DESENCHUFADA!", 1.6)
	if sala.pantallas:
		sala.pantallas.aviso_fijo = ""
	sala.sonar("puf")
	await get_tree().create_timer(0.9, false).timeout
	felipe.acicalarse()
	terminada.emit()


func _dibujar_bola(bola: Node2D) -> void:
	bola.draw_circle(Vector2.ZERO, 6.0, Color("8a7a6a"))
	for i in 6:
		var angulo := i * TAU / 6.0
		bola.draw_line(Vector2.from_angle(angulo) * 3.0, Vector2.from_angle(angulo + 0.4) * 8.0, Color("b8a894"), 1.0)


## La imaginación de Felipe en la entrada: el estudio en llamas y la bestia gigante (detrás de los muebles).
func _draw() -> void:
	var tiempo := Time.get_ticks_msec() / 1000.0
	if transformacion > 0.0:
		var a := transformacion
		draw_texture_rect(ArteNivel.textura("fin_del_mundo"), arena, false, Color(1, 1, 1, a))
		if _rayo > 0.0:
			draw_rect(arena, Color(1, 0.9, 0.9, 0.18 * _rayo * a))
	if gigante > 0.0:
		var arte := ArteNivel.textura("aspi_gigante")
		var tam := arte.get_size()
		var k := ease(gigante, 0.6)
		var escala := lerpf(Aspi.ANCHO / tam.x, 1.0, k)
		var centro := _origen_gigante.lerp(_centro_gigante + Vector2(0, sin(tiempo * 2.0) * 5.0), k)
		if fase == Fase.ENTRADA and gigante < 1.0:
			# Temblor de sueño mientras crece.
			centro += Vector2(sin(tiempo * 40.0), cos(tiempo * 33.0)) * 2.0
		var mira := 1.0 if felipe.global_position.x >= centro.x else -1.0
		draw_set_transform(centro, sin(tiempo * 1.3) * 0.03 * k, Vector2(escala * mira, escala))
		draw_texture(arte, -tam / 2.0, Color(1, 1, 1, minf(gigante * 3.0, 1.0)))
		draw_set_transform(Vector2.ZERO)


## Las manchas en el piso (tierra de maceta, agua, papel) que A.S.P.I. va a limpiar.
func _dibujar_manchas() -> void:
	var c := _manchas_dibujo
	for x in manchas:
		c.draw_rect(Rect2(x - 16, Sala.SUELO - 3, 32, 3), Color("6e4a2c"))
		c.draw_circle(Vector2(x - 8, Sala.SUELO - 3), 4.0, Color("7d5634"))
		c.draw_circle(Vector2(x + 6, Sala.SUELO - 2), 3.0, Color("7d5634"))


func _dibujar_viento() -> void:
	if not succionando:
		return
	var tiempo := Time.get_ticks_msec() / 1000.0
	var x_jefa := aspi.global_position.x
	for i in 16:
		var lado := -1.0 if i % 2 == 0 else 1.0
		var avance := fmod(tiempo * 1.4 + i * 0.37, 1.0)
		var x := x_jefa + lado * (1.0 - avance) * RADIO_SUCCION
		var y := Sala.SUELO - 6.0 - fmod(i * 23.0, 70.0)
		if arena.has_point(Vector2(x, y)):
			_viento.draw_line(Vector2(x, y), Vector2(x + lado * 18.0, y), Color(Color("dff3ff"), 0.7 * avance), 1.5)
