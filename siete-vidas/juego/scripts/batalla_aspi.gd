class_name BatallaAspi
extends Node2D
## Pelea con A.S.P.I. en el estudio de Valeria ("La Bestia del Estudio", depósito lleno). Al entrar, A.S.P.I. despierta
## en su base y la presentación de jefe (PresentacionJefe, la misma para todos) congela el juego: en la imaginación de
## Felipe crece hasta volverse una bestia gigante en un estudio en llamas. Al terminar la entrada, la imaginación se
## desvanece y el estudio vuelve a verse normal.
## La pelea: los zarpazos rebotan en la carcasa. A.S.P.I. persigue a Felipe; cuando algo se rompe en el piso deja una
## mancha y ella va a limpiarla (aspira: de pie arrastra a Felipe, agachado se aferra). Cada mancha le llena el
## depósito; lleno, se detiene pitando unos segundos, inofensiva, y Felipe le salta encima para apretarle el botón de
## apagado. Cada apagado es una fase: se reinicia enojada, con más depósito y más rápida (en la tercera escupe bolas de
## pelo). Al tercer apagado se apaga del todo: se abre la puerta del balcón y Felipe se lame la pata.

signal empezada
signal fase_cambiada(fase: Fase)
signal terminada

enum Fase { ESPERANDO, ENTRADA, PELEA, FIN }

const NOMBRE := "A.S.P.I."
const TITULO := "Devoradora de Pelos · Nivel 99"
const APAGADOS_TOTALES := 3
## Por fase (0, 1 o 2 apagados): manchas para llenar el depósito, segundos detenida y segundos limpiando cada mancha.
const CAPACIDAD := [2, 3, 3]
const TIEMPO_LLENA := [4.0, 3.5, 3.0]
const TIEMPO_LIMPIEZA := [3.0, 2.5, 2.0]
const VELOCIDAD := [60.0, 85.0, 105.0]
## Más que caminar (120 px/s): de pie no se escapa; hay que agacharse.
const FUERZA_SUCCION := 150.0
const RADIO_SUCCION := 200.0
const ESPERA_BOLAS := 1.6
const VELOCIDAD_BOLA := 150.0
const DESVANECER := 0.8
## Al reiniciarse tras un apagado se queda quieta e inofensiva un momento: Felipe alcanza a alejarse.
const REINICIO := 1.5
const REBOTE := -420.0
## Alto del dibujo de A.S.P.I.: Felipe la apaga si cae sobre esa franja.
const ALTO_ARRIBA := 40.0
const PISTAS := [
	"Ensucia el piso: limpiar le llena el depósito",
	"¡Más rápida! Si te aspira, mantén {agacharse}",
	"¡Furia! Salta las bolas de pelo",
]
const PISTA_LLENA := "¡Depósito lleno! Sáltale encima"
const CARTELES := ["FASE 1: ¡LLÉNALE EL DEPÓSITO!", "FASE 2: ¡SE REINICIÓ!", "FASE 3: ¡FURIA!"]

var fase := Fase.ESPERANDO
var aspi: Aspi
var felipe: Felipe
var sala: Sala
var apagados := 0
var deposito := 0
var llena := false
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
var _reinicio := 0.0
var _rayo := 0.0
var _origen_gigante := Vector2.ZERO
var _centro_gigante := Vector2.ZERO
var _encima: Node2D
var _manchas_dibujo: Node2D


func _init(jefa: Aspi, gato: Felipe, nivel: Sala) -> void:
	aspi = jefa
	felipe = gato
	sala = nivel
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
	presentacion = PresentacionJefe.new(NOMBRE, TITULO)
	presentacion.encuadre_momento = _centro_gigante + Vector2(0, 40)
	presentacion.terminada.connect(_al_terminar_presentacion)
	add_child(presentacion)
	_manchas_dibujo = Node2D.new()
	_manchas_dibujo.name = "Manchas"
	_manchas_dibujo.z_index = 9
	_manchas_dibujo.draw.connect(_dibujar_manchas)
	add_child(_manchas_dibujo)
	_encima = Node2D.new()
	_encima.name = "Viento y depósito"
	_encima.z_index = 30
	_encima.draw.connect(_dibujar_encima)
	add_child(_encima)


func _process(delta: float) -> void:
	_rayo = maxf(0.0, _rayo - delta * 4.0)
	if fase == Fase.ENTRADA:
		gigante = ease(presentacion.momento, 0.4)
		transformacion = presentacion.momento
		aspi.visible = gigante < 0.15 or presentacion.t >= PresentacionJefe.MOMENTO
		if presentacion.momento > 0.0 and fmod(presentacion.t, 0.9) < delta:
			_rayo = 1.0
	presentacion.vida = 1.0 - float(apagados) / APAGADOS_TOTALES if fase == Fase.PELEA else -1.0
	presentacion.escudo = float(deposito) / CAPACIDAD[mini(apagados, 2)] if fase == Fase.PELEA else 0.0
	queue_redraw()
	_encima.queue_redraw()
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
	presentacion.divisiones = APAGADOS_TOTALES
	presentacion.pantallas = sala.pantallas
	sala.sonar("batalla")
	presentacion.presentar(felipe, aspi, Rect2(arena.position.x, 0, arena.size.x, Sala.ALTO))
	empezada.emit()


## Para pruebas y depuración: termina la entrada de golpe.
func saltar_entrada() -> void:
	presentacion.saltar()


## Algo se rompió en el piso: si es en el estudio y hay pelea, queda una mancha para limpiar.
func agregar_mancha(posicion: Vector2) -> void:
	if fase in [Fase.ESPERANDO, Fase.FIN] or not arena.grow(4).has_point(posicion - Vector2(0, 1)):
		return
	manchas.append(clampf(posicion.x, aspi.limite_izquierdo, aspi.limite_derecho))


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
	deposito = 0
	llena = false
	_reinicio = REINICIO if apagados > 0 else 0.0
	aspi.quieta = _reinicio > 0.0
	aspi.inofensiva = _reinicio > 0.0
	aspi.velocidad_patrulla = VELOCIDAD[apagados] * 0.7
	aspi.velocidad_persecucion = VELOCIDAD[apagados]
	presentacion.cartel(CARTELES[apagados])
	presentacion.destello(0.4)
	presentacion.sacudir(0.25)
	if sala.pantallas:
		sala.pantallas.aviso_fijo = PISTAS[apagados]
	fase_cambiada.emit(fase)


func _actualizar_pelea(delta: float) -> void:
	felipe.empuje = Vector2.ZERO
	succionando = false
	if _reinicio > 0.0:
		_reinicio -= delta
		if _reinicio <= 0.0:
			aspi.quieta = false
			aspi.inofensiva = false
		return
	if llena:
		_actualizar_llena(delta)
		return
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
			if _reloj >= TIEMPO_LIMPIEZA[apagados]:
				manchas.pop_front()
				limpiando = false
				_reloj = 0.0
				deposito += 1
				if deposito >= CAPACIDAD[apagados]:
					_llenar()
		return
	limpiando = false
	aspi.destino = INF
	if apagados >= 2:
		_reloj += delta
		if _reloj >= ESPERA_BOLAS:
			_reloj = 0.0
			_escupir_bola()


## Depósito lleno: se detiene pitando, inofensiva, y espera a que se lo vacíen... o a que Felipe la apague.
func _llenar() -> void:
	llena = true
	_reloj = 0.0
	aspi.destino = INF
	aspi.quieta = true
	aspi.inofensiva = true
	aspi.arte = "aspi_llena"
	aspi.queue_redraw()
	sala.sonar("logro")
	presentacion.cartel("¡DEPÓSITO LLENO!", 1.0)
	if sala.pantallas:
		sala.pantallas.aviso_fijo = PISTA_LLENA


func _actualizar_llena(delta: float) -> void:
	_reloj += delta
	# Felipe cae sobre ella: le aprieta el botón de apagado con las patas.
	var distancia := felipe.global_position - aspi.global_position
	if felipe.velocity.y > 0.0 and absf(distancia.x) < Aspi.ANCHO / 2.0 + 4.0 and distancia.y > -ALTO_ARRIBA - 14.0 and distancia.y < -ALTO_ARRIBA + 18.0:
		# Rebote como un pisotón: con el doble salto alcanza la repisa de las macetas.
		felipe.velocity.y = REBOTE
		_apagar()
		return
	if _reloj >= TIEMPO_LLENA[apagados]:
		# Nadie la apagó: vacía el depósito y sigue.
		deposito = 0
		llena = false
		aspi.quieta = false
		aspi.inofensiva = false
		aspi.arte = "aspi"
		presentacion.cartel("¡LO VACIÓ!", 1.0)
		if sala.pantallas:
			sala.pantallas.aviso_fijo = PISTAS[apagados]


func _apagar() -> void:
	apagados += 1
	aspi.arte = "aspi"
	sala.sonar("golpe")
	manchas.clear()
	limpiando = false
	if apagados >= APAGADOS_TOTALES:
		aspi.apagada = true
		aspi.apagado.emit()
		return
	_cambiar_fase()


## Mientras limpia aspira: de pie, Felipe se desliza hacia ella; agachado se aferra.
func _aspirar() -> void:
	var distancia := aspi.global_position.x - felipe.global_position.x
	if absf(distancia) < RADIO_SUCCION and absf(distancia) > 6.0 and absf(felipe.global_position.y - aspi.global_position.y) < 40.0:
		felipe.empuje = Vector2(signf(distancia) * FUERZA_SUCCION, 0.0)


func _escupir_bola() -> void:
	var bola := Node2D.new()
	bola.name = "Bola de pelo"
	bola.z_index = 30
	var hacia := signf(felipe.global_position.x - aspi.global_position.x)
	bola.set_meta("velocidad", (hacia if hacia != 0.0 else 1.0) * VELOCIDAD_BOLA)
	bola.global_position = aspi.global_position + Vector2(hacia * 36.0, -12.0)
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
		if absf(distancia.x) < 14.0 and distancia.y > -4.0 and distancia.y < 16.0:
			felipe.recibir_dano(1, bola.global_position.x)
			_quitar_bola(bola)
		elif not arena.grow(20).has_point(bola.global_position) or fase == Fase.FIN:
			_quitar_bola(bola)


func _quitar_bola(bola: Node2D) -> void:
	bolas.erase(bola)
	bola.queue_free()


## Al tercer apagado se apaga del todo: cartel, puerta del balcón abierta (lo hace la sala) y Felipe se acicala.
func _terminar() -> void:
	presentacion.saltar()
	fase = Fase.FIN
	succionando = false
	limpiando = false
	llena = false
	manchas.clear()
	aspi.destino = INF
	aspi.inofensiva = true
	felipe.empuje = Vector2.ZERO
	presentacion.destello(1.0)
	presentacion.cartel("¡APAGADA!", 1.6)
	if sala.pantallas:
		sala.pantallas.aviso_fijo = ""
	sala.sonar("puf")
	await get_tree().create_timer(0.9, false).timeout
	felipe.acicalarse()
	terminada.emit()


func _dibujar_bola(bola: Node2D) -> void:
	# Escala de gato: bolas de pelo grandes y legibles (rueda: el dibujo gira con el nodo).
	var arte := ArteNivel.textura("bola_pelo")
	bola.draw_texture(arte, -arte.get_size() / 2.0)


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
		ArteNivel.dibujar(c, "mancha", x, Sala.SUELO + 2.0)


## Delante de todo: el viento de la succión y el aviso del depósito lleno sobre A.S.P.I.
func _dibujar_encima() -> void:
	var c := _encima
	var tiempo := Time.get_ticks_msec() / 1000.0
	if _reinicio > 0.0 and fase == Fase.PELEA:
		var fuente_r := ThemeDB.fallback_font
		var punto := aspi.global_position + Vector2(-34, -ALTO_ARRIBA - 22)
		c.draw_string(fuente_r, punto, "REINICIANDO" + ".".repeat(int(tiempo * 3.0) % 4), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("9fd8ff"))
	if llena:
		var arriba := aspi.global_position + Vector2(0, -ALTO_ARRIBA - 34)
		if int(tiempo * 4.0) % 2 == 0:
			c.draw_circle(aspi.global_position + Vector2(0, -ALTO_ARRIBA - 4), 5.0, Color("e0483b"))
		var fuente := ThemeDB.fallback_font
		var texto := "¡LLENO!"
		var ancho := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
		c.draw_rect(Rect2(arriba.x - ancho / 2.0 - 6, arriba.y - 13, ancho + 12, 18), Color(0.1, 0.05, 0.07, 0.85))
		c.draw_string(fuente, Vector2(arriba.x - ancho / 2.0, arriba.y), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("ffe066"))
		# Flecha hacia abajo: hay que caerle encima.
		c.draw_colored_polygon(PackedVector2Array([arriba + Vector2(-6, 8), arriba + Vector2(6, 8), arriba + Vector2(0, 16)]), Color("ffe066"))
	if not succionando:
		return
	var x_jefa := aspi.global_position.x
	for i in 16:
		var lado := -1.0 if i % 2 == 0 else 1.0
		var avance := fmod(tiempo * 1.4 + i * 0.37, 1.0)
		var x := x_jefa + lado * (1.0 - avance) * RADIO_SUCCION
		var y := Sala.SUELO - 6.0 - fmod(i * 23.0, 70.0)
		if arena.has_point(Vector2(x, y)):
			c.draw_line(Vector2(x, y), Vector2(x + lado * 18.0, y), Color(Color("dff3ff"), 0.7 * avance), 1.5)
