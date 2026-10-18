class_name BatallaAspi
extends Node2D
## Pelea con A.S.P.I. desde la cabeza de Felipe. Al cruzarse con ella, su imaginación la vuelve una bestia gigante:
## entrada tipo Broforce (todo se congela, acercamiento a Felipe, «¡BATALLA INICIADA!», salto a la jefa y su nombre),
## el pasillo se vuelve el fin del mundo y la pelea tiene tres fases:
##   1. Succión: aspira y arrastra a Felipe; agachado se aferra. Aguantar SUCCIONES rompe su escudo.
##   2. Aturdir: una maceta encima la aturde y los zarpazos le hacen daño.
##   3. Furia: escupe bolas de pelo por el piso que hay que saltar.
## Al apagarla, todo vuelve de golpe a ser un pasillo y Felipe se lame la pata como si nada.
## La gigante es solo imaginación: se dibuja en el fondo, sin colisión. La A.S.P.I. real conserva su tamaño (34 cm).

signal empezada
signal fase_cambiada(fase: Fase)
signal terminada

enum Fase { ESPERANDO, ENTRADA, SUCCION, ATURDIR, FURIA, FIN }

const NOMBRE := "A.S.P.I."
const TITULO := "Devoradora de Pelos · Nivel 99"
## El pasillo de A.S.P.I.: ahí se transforma el mundo.
const ARENA := Rect2(2480, 0, 416, Sala.PISO_ALTO)
const DISTANCIA_ENCUENTRO := 150.0
const SUCCIONES := 3
const PATRULLA_ENTRE_SUCCIONES := 2.0
const DURACION_SUCCION := 2.4
## Más que caminar (120 px/s): de pie no se escapa; hay que agacharse.
const FUERZA_SUCCION := 150.0
const GOLPES_FASE_ATURDIR := 2
const GOLPES_TOTALES := 4
const ESPERA_BOLAS := 1.6
const VELOCIDAD_BOLA := 150.0
const ESCALA_GIGANTE := 8.5
## Justo sobre la cabeza de Felipe, para que se vea entera con la cámara del juego.
const CENTRO_GIGANTE := Vector2(2700, Sala.PISO_ALTO - 128)
## Línea de tiempo de la entrada, en segundos.
const ENTRADA_ACERCAMIENTO := 0.35
const ENTRADA_CARTEL := 1.45
const ENTRADA_GIRO := 1.75
const ENTRADA_CRECER := 2.65
const ENTRADA_NOMBRE := 4.0
const ENTRADA_FIN := 4.5
const ZOOM_FELIPE := 2.6
const ZOOM_JEFA := 3.0
const PISTAS := {
	Fase.SUCCION: "¡Te aspira! Mantén {agacharse} para aferrarte",
	Fase.ATURDIR: "Tírale una maceta con {interactuar} y remátala con {zarpazo}",
	Fase.FURIA: "¡Furia! Salta las bolas de pelo",
}
const CARTELES := {Fase.SUCCION: "FASE 1: ¡SUCCIÓN!", Fase.ATURDIR: "FASE 2: ¡ATÚRDELA!", Fase.FURIA: "FASE 3: ¡FURIA!"}
const CIELO := [Color("1d0f2b"), Color("5a1430"), Color("b3262e"), Color("f07a2a")]
const LLAMA := [Color("ffcf4a"), Color("f07a2a"), Color("d43a2a")]

var fase := Fase.ESPERANDO
var aspi: Aspi
var felipe: Felipe
var sala: Sala
var succiones := 0
var succionando := false
## Mayor zoom que alcanzó la cámara en la entrada (lo revisan las pruebas).
var zoom_maximo := 1.0
## Texto grande que se ve ahora en pantalla (lo revisan las pruebas).
var texto_en_pantalla := ""
## 0 = pasillo normal, 1 = fin del mundo.
var transformacion := 0.0
## 0 = A.S.P.I. de tamaño real, 1 = bestia gigante del fondo.
var gigante := 0.0
var bolas: Array[Node2D] = []

var _t := 0.0
var _reloj := 0.0
var _rayo := 0.0
var _proximo_rayo := 1.0
var _flash := 0.0
var _sacudida := 0.0
var _barras := 0.0
var _cartel_fase := 0.0
var _texto_fase := ""
var _origen_gigante := Vector2.ZERO
var _camara: Camera2D
var _interfaz: Node2D
var _viento: Node2D
var _azar := RandomNumberGenerator.new()


func _init(jefa: Aspi, gato: Felipe, nivel: Sala) -> void:
	aspi = jefa
	felipe = gato
	sala = nivel
	name = "Batalla"
	# Detrás de los muebles y delante de la pared: el fin del mundo se ve por el pasillo.
	z_index = -10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_azar.seed = 99


func _ready() -> void:
	aspi.apagado.connect(_terminar)
	# Sin jefa no hay pelea (algunas pruebas la quitan).
	aspi.tree_exiting.connect(queue_free)
	_camara = Camera2D.new()
	_camara.name = "Camara de batalla"
	_camara.limit_left = 0
	_camara.limit_top = 0
	_camara.limit_right = int(Sala.ANCHO)
	_camara.limit_bottom = int(Sala.ALTO)
	add_child(_camara)
	_viento = Node2D.new()
	_viento.name = "Viento"
	_viento.z_index = 30
	_viento.draw.connect(_dibujar_viento)
	add_child(_viento)
	var capa := CanvasLayer.new()
	capa.layer = 30
	add_child(capa)
	_interfaz = Node2D.new()
	_interfaz.name = "Interfaz de batalla"
	_interfaz.draw.connect(_dibujar_interfaz)
	capa.add_child(_interfaz)


func _process(delta: float) -> void:
	_flash = maxf(0.0, _flash - delta * 3.0)
	_sacudida = maxf(0.0, _sacudida - delta)
	_cartel_fase = maxf(0.0, _cartel_fase - delta)
	_rayo = maxf(0.0, _rayo - delta * 4.0)
	if fase == Fase.ENTRADA:
		_actualizar_entrada(delta)
	if fase in [Fase.SUCCION, Fase.ATURDIR, Fase.FURIA]:
		_proximo_rayo -= delta
		if _proximo_rayo <= 0.0:
			_rayo = 1.0
			_proximo_rayo = _azar.randf_range(1.5, 3.2)
	queue_redraw()
	_viento.queue_redraw()
	_interfaz.queue_redraw()


func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	match fase:
		Fase.ESPERANDO:
			var distancia := felipe.global_position - aspi.global_position
			var se_cruzan := absf(distancia.x) < DISTANCIA_ENCUENTRO and absf(distancia.y) < 40.0 and not felipe.agachado
			if se_cruzan or aspi.esta_aturdida() or aspi.golpes > 0:
				empezar()
		Fase.SUCCION:
			_actualizar_succion(delta)
		Fase.ATURDIR:
			if aspi.golpes >= GOLPES_FASE_ATURDIR:
				_cambiar_fase(Fase.FURIA)
		Fase.FURIA:
			_actualizar_furia(delta)
	_mover_bolas(delta)


## Arranca la entrada: congela el juego y toma la cámara.
func empezar() -> void:
	if fase != Fase.ESPERANDO:
		return
	fase = Fase.ENTRADA
	_t = 0.0
	aspi.golpes_para_apagar = GOLPES_TOTALES
	aspi.necesita_aturdir = true
	aspi.invulnerable = true
	felipe.empuje = Vector2.ZERO
	_origen_gigante = aspi.global_position + Vector2(0, -Aspi.ALTO / 2.0)
	_camara.global_position = felipe.global_position + Vector2(0, -30)
	_camara.zoom = Vector2.ONE
	_camara.make_current()
	_flash = 1.0
	sala.sonar("batalla")
	get_tree().paused = true
	empezada.emit()


## Para pruebas y depuración: salta la entrada o una fase.
func forzar_fase(nueva: Fase) -> void:
	if fase == Fase.ENTRADA:
		_terminar_entrada()
	_cambiar_fase(nueva)


func _actualizar_entrada(delta: float) -> void:
	_t += delta
	var en_felipe := felipe.global_position + Vector2(0, -30)
	var en_jefa := aspi.global_position + Vector2(0, -20)
	texto_en_pantalla = ""
	if _t < ENTRADA_ACERCAMIENTO:
		# Golpe de cámara a la cara de Felipe.
		var k := ease(_t / ENTRADA_ACERCAMIENTO, 0.3)
		_camara.zoom = Vector2.ONE * lerpf(1.0, ZOOM_FELIPE, k)
		_camara.global_position = en_felipe
		_barras = k
		_sacudida = 0.2
	elif _t < ENTRADA_CARTEL:
		texto_en_pantalla = "¡BATALLA INICIADA!"
		_camara.zoom = Vector2.ONE * ZOOM_FELIPE
		_barras = 1.0
		if _t - delta < ENTRADA_ACERCAMIENTO:
			_sacudida = 0.35
			_flash = 0.6
	elif _t < ENTRADA_GIRO:
		# Barrido rápido hasta la jefa.
		var k := ease((_t - ENTRADA_CARTEL) / (ENTRADA_GIRO - ENTRADA_CARTEL), -2.0)
		_camara.global_position = en_felipe.lerp(en_jefa, k)
		_camara.zoom = Vector2.ONE * lerpf(ZOOM_FELIPE, ZOOM_JEFA, k)
	elif _t < ENTRADA_CRECER:
		# La imaginación de Felipe la vuelve gigante; la cámara se aleja para que quepa.
		var k := (_t - ENTRADA_GIRO) / (ENTRADA_CRECER - ENTRADA_GIRO)
		gigante = ease(k, 0.4)
		aspi.visible = gigante < 0.15
		_camara.zoom = Vector2.ONE * lerpf(ZOOM_JEFA, 1.15, ease(k, 0.5))
		_camara.global_position = en_jefa.lerp(CENTRO_GIGANTE + Vector2(0, 40), ease(k, 0.5))
		transformacion = k
		_sacudida = 0.1
	elif _t < ENTRADA_NOMBRE:
		texto_en_pantalla = NOMBRE
		gigante = 1.0
		transformacion = 1.0
		if _t - delta < ENTRADA_CRECER:
			_sacudida = 0.4
			_flash = 0.5
	elif _t < ENTRADA_FIN:
		var k := (_t - ENTRADA_NOMBRE) / (ENTRADA_FIN - ENTRADA_NOMBRE)
		_barras = 1.0 - k
		_camara.zoom = Vector2.ONE * lerpf(1.15, 1.0, k)
		_camara.global_position = _camara.global_position.lerp(en_felipe, k)
	else:
		_terminar_entrada()
		_cambiar_fase(Fase.SUCCION)
		return
	zoom_maximo = maxf(zoom_maximo, _camara.zoom.x)
	_camara.offset = Vector2(_azar.randf_range(-1, 1), _azar.randf_range(-1, 1)) * 6.0 * minf(_sacudida * 3.0, 1.0)


func _terminar_entrada() -> void:
	texto_en_pantalla = ""
	gigante = 1.0
	transformacion = 1.0
	_barras = 0.0
	aspi.visible = true
	_camara.offset = Vector2.ZERO
	felipe.get_node("Camara").make_current()
	if sala.pantallas == null or sala.pantallas.modo == Pantallas.Modo.JUGANDO:
		get_tree().paused = false


func _cambiar_fase(nueva: Fase) -> void:
	fase = nueva
	_reloj = 0.0
	succionando = false
	aspi.quieta = false
	felipe.empuje = Vector2.ZERO
	aspi.invulnerable = nueva == Fase.SUCCION
	if nueva == Fase.FURIA:
		aspi.velocidad_patrulla = 70.0
		aspi.velocidad_persecucion = 105.0
	if CARTELES.has(nueva):
		_texto_fase = CARTELES[nueva]
		_cartel_fase = 1.4
		_flash = 0.4
		_sacudida = 0.25
	if sala.pantallas:
		sala.pantallas.aviso_fijo = PISTAS.get(nueva, "")
	fase_cambiada.emit(nueva)


func _actualizar_succion(delta: float) -> void:
	_reloj += delta
	var aspirando := _reloj >= PATRULLA_ENTRE_SUCCIONES
	if aspirando and not succionando:
		sala.sonar("succion")
	succionando = aspirando
	aspi.quieta = aspirando
	felipe.empuje = Vector2.ZERO
	if aspirando and _en_arena(felipe.global_position):
		var hacia := signf(aspi.global_position.x - felipe.global_position.x)
		if absf(aspi.global_position.x - felipe.global_position.x) > 6.0:
			felipe.empuje = Vector2(hacia * FUERZA_SUCCION, 0.0)
	if _reloj >= PATRULLA_ENTRE_SUCCIONES + DURACION_SUCCION:
		_reloj = 0.0
		succiones += 1
		succionando = false
		aspi.quieta = false
		felipe.empuje = Vector2.ZERO
		if succiones >= SUCCIONES:
			_cambiar_fase(Fase.ATURDIR)


func _actualizar_furia(delta: float) -> void:
	if aspi.esta_aturdida():
		return
	_reloj += delta
	if _reloj >= ESPERA_BOLAS:
		_reloj = 0.0
		_escupir_bola()


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
		elif not ARENA.grow(20).has_point(bola.global_position) or fase == Fase.FIN:
			_quitar_bola(bola)


func _quitar_bola(bola: Node2D) -> void:
	bolas.erase(bola)
	bola.queue_free()


## Al apagarla, todo vuelve de golpe a ser un pasillo; la bestia se desinfla y Felipe se acicala.
func _terminar() -> void:
	if fase == Fase.ENTRADA:
		_terminar_entrada()
	fase = Fase.FIN
	succionando = false
	felipe.empuje = Vector2.ZERO
	transformacion = 0.0
	_flash = 1.0
	_texto_fase = "¡DESENCHUFADA!"
	_cartel_fase = 1.6
	if sala.pantallas:
		sala.pantallas.aviso_fijo = ""
	sala.sonar("puf")
	var desinflar := create_tween()
	desinflar.tween_property(self, "gigante", 0.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(0.9, false).timeout
	felipe.acicalarse()
	terminada.emit()


func _en_arena(punto: Vector2) -> bool:
	return ARENA.grow_individual(0, 0, 0, 2).has_point(punto)


func _dibujar_bola(bola: Node2D) -> void:
	bola.draw_circle(Vector2.ZERO, 6.0, Color("8a7a6a"))
	for i in 6:
		var angulo := i * TAU / 6.0
		bola.draw_line(Vector2.from_angle(angulo) * 3.0, Vector2.from_angle(angulo + 0.4) * 8.0, Color("b8a894"), 1.0)


## El pasillo como fin del mundo y la bestia gigante, en el mundo (detrás de los muebles).
func _draw() -> void:
	var tiempo := Time.get_ticks_msec() / 1000.0
	if transformacion > 0.0:
		var a := transformacion
		var bandas := 24
		for i in bandas:
			var k := float(i) / bandas
			var color: Color = CIELO[mini(int(k * 3.0), 2)].lerp(CIELO[mini(int(k * 3.0) + 1, 3)], fmod(k * 3.0, 1.0))
			draw_rect(Rect2(ARENA.position.x, ARENA.position.y + ARENA.size.y * k, ARENA.size.x, ARENA.size.y / bandas + 1.0), Color(color, a))
		draw_circle(Vector2(ARENA.position.x + 300, ARENA.end.y - 120), 70.0, Color(Color("ff5a3a"), 0.55 * a))
		# Ciudad en llamas a lo lejos.
		# Siluetas claras y bajas: Felipe (gris y blanco) tiene que destacar delante.
		for i in 9:
			var x := ARENA.position.x + i * 48.0
			var alto := 26.0 + fmod(i * 37.0, 40.0)
			draw_rect(Rect2(x, ARENA.end.y - alto, 40, alto), Color(Color("7a2a32"), 0.8 * a))
			var llama := 8.0 + sin(tiempo * 9.0 + i) * 4.0
			for j in 3:
				var base := Vector2(x + 8 + j * 12, ARENA.end.y - alto)
				draw_colored_polygon(PackedVector2Array([base + Vector2(-6, 0), base + Vector2(6, 0), base + Vector2(sin(tiempo * 7.0 + i + j) * 3.0, -llama - j * 3.0)]), Color(LLAMA[j], a))
		# Calcetines y cuadros flotando.
		for i in 4:
			var p := Vector2(ARENA.position.x + 60 + i * 95, ARENA.position.y + 60 + sin(tiempo * 1.5 + i * 2.0) * 10.0)
			draw_set_transform(p, sin(tiempo + i) * 0.4)
			if i % 2 == 0:
				draw_rect(Rect2(-5, -10, 10, 14), Color(Color("f2e6d0"), a))
				draw_rect(Rect2(-5, 0, 14, 6), Color(Color("f2e6d0"), a))
			else:
				draw_rect(Rect2(-12, -9, 24, 18), Color(Color("7f3b30"), a))
				draw_rect(Rect2(-9, -6, 18, 12), Color(Color("d9a65b"), a))
			draw_set_transform(Vector2.ZERO)
		if _rayo > 0.0:
			var x := ARENA.position.x + 80 + fmod(_proximo_rayo * 997.0, ARENA.size.x - 160)
			var puntos := PackedVector2Array([Vector2(x, ARENA.position.y)])
			for i in 6:
				puntos.append(Vector2(x + (i % 2 * 2 - 1) * 14.0, ARENA.position.y + (i + 1) * 40.0))
			draw_polyline(puntos, Color(1, 1, 0.9, _rayo * a), 3.0)
			draw_rect(ARENA, Color(1, 0.9, 0.9, 0.15 * _rayo * a))
	if gigante > 0.0:
		_dibujar_gigante(tiempo)


func _dibujar_gigante(tiempo: float) -> void:
	var k := ease(gigante, 0.6)
	var escala := lerpf(1.0, ESCALA_GIGANTE, k)
	var centro := _origen_gigante.lerp(CENTRO_GIGANTE + Vector2(0, sin(tiempo * 2.0) * 5.0), k)
	# Temblor de sueño mientras crece.
	if fase == Fase.ENTRADA and gigante < 1.0:
		centro += Vector2(sin(tiempo * 40.0), cos(tiempo * 33.0)) * 2.0
	draw_set_transform(centro, sin(tiempo * 1.3) * 0.03 * k, Vector2(escala, escala))
	var w := Aspi.ANCHO
	var h := Aspi.ALTO
	var aturdida := aspi.esta_aturdida()
	var cuerpo := Color("2c2f36")
	# Cepillos laterales que giran.
	for lado: float in [-1.0, 1.0]:
		var eje := Vector2(lado * (w / 2.0 - 2.0), h / 2.0 - 1.0)
		for i in 3:
			var angulo := tiempo * (14.0 if succionando else 6.0) * lado + i * TAU / 3.0
			draw_line(eje, eje + Vector2.from_angle(angulo) * 5.0, Color("d9a65b"), 0.6)
	draw_rect(Rect2(-w / 2.0 + 3.0, -h / 2.0, w - 6.0, h), cuerpo)
	draw_circle(Vector2(-w / 2.0 + 4.0, 0), h / 2.0, cuerpo)
	draw_circle(Vector2(w / 2.0 - 4.0, 0), h / 2.0, cuerpo)
	draw_rect(Rect2(-w / 2.0 + 4.0, -h / 2.0, w - 8.0, 2.0), cuerpo.lightened(0.3))
	# Cara de villano: ceja, ojo rojo que brilla y boca con dientes.
	var ojo := Color("ff3b2f") if not aturdida else Color("f2d36b")
	draw_circle(Vector2(6, -1), 2.6, Color(ojo, 0.35))
	if aturdida:
		draw_line(Vector2(4, -3), Vector2(8, 1), ojo, 0.8)
		draw_line(Vector2(8, -3), Vector2(4, 1), ojo, 0.8)
	else:
		draw_circle(Vector2(6, -1), 1.4, ojo)
	draw_line(Vector2(2, -4.5), Vector2(10, -2.5), Color("0e0f12"), 1.0)
	var boca := 2.5 if succionando else 1.0
	draw_rect(Rect2(-12, 2.0, 20, boca), Color("120a0c"))
	for i in 5:
		draw_colored_polygon(PackedVector2Array([Vector2(-11 + i * 4, 2.0), Vector2(-9 + i * 4, 2.0), Vector2(-10 + i * 4, 3.2)]), Color("e8e2d6"))
	if succionando:
		for i in 3:
			var r := fmod(tiempo * 6.0 + i, 3.0) * 3.0
			draw_arc(Vector2(-2, 3.0), 12.0 - r, 0.0, PI, 10, Color(Color("9fd8ff"), 0.6), 0.5)
	# Grietas: una por golpe.
	for i in aspi.golpes:
		var x := -12.0 + i * 7.0
		draw_polyline(PackedVector2Array([Vector2(x, -h / 2.0), Vector2(x + 2, -1), Vector2(x - 1, 1.5)]), Color("f2e6d0"), 0.5)
	if aturdida:
		for i in 3:
			var angulo := tiempo * 5.0 + i * TAU / 3.0
			draw_circle(Vector2(cos(angulo) * 10.0, -h / 2.0 - 3.0 + sin(angulo) * 2.0), 1.0, Color("f2d36b"))
	draw_set_transform(Vector2.ZERO)


func _dibujar_viento() -> void:
	if not succionando:
		return
	var tiempo := Time.get_ticks_msec() / 1000.0
	var x_jefa := aspi.global_position.x
	for i in 16:
		var lado := -1.0 if i % 2 == 0 else 1.0
		var avance := fmod(tiempo * 1.4 + i * 0.37, 1.0)
		var x := x_jefa + lado * (1.0 - avance) * 200.0
		var y := Sala.PISO_ALTO - 6.0 - fmod(i * 23.0, 70.0)
		if ARENA.has_point(Vector2(x, y)):
			_viento.draw_line(Vector2(x, y), Vector2(x + lado * 18.0, y), Color(Color("dff3ff"), 0.7 * avance), 1.5)


## Barras de cine, destellos, carteles y barra de vida de la jefa (en pantalla).
func _dibujar_interfaz() -> void:
	var c := _interfaz
	var tam := c.get_viewport_rect().size
	var fuente := ThemeDB.fallback_font
	if _barras > 0.0:
		c.draw_rect(Rect2(0, 0, tam.x, 44.0 * _barras), Color.BLACK)
		c.draw_rect(Rect2(0, tam.y - 44.0 * _barras, tam.x, 44.0 * _barras), Color.BLACK)
	if fase == Fase.ENTRADA and _t >= ENTRADA_GIRO and _t < ENTRADA_CRECER:
		# Nube de pensamiento: es la imaginación de Felipe.
		var tiempo := Time.get_ticks_msec() / 1000.0
		for i in 22:
			var angulo := i * TAU / 22.0
			var p := tam / 2.0 + Vector2(cos(angulo) * tam.x * 0.56, sin(angulo) * tam.y * 0.62)
			c.draw_circle(p, 38.0 + sin(tiempo * 6.0 + i) * 5.0, Color(Color("f5d0e6"), 0.55))
	if texto_en_pantalla == "¡BATALLA INICIADA!":
		var k := clampf((_t - ENTRADA_ACERCAMIENTO) / 0.15, 0.0, 1.0)
		_banda(c, tam, tam.y * 0.5, Color("c81e2a"), -1.0)
		c.draw_set_transform(tam / 2.0 + Vector2(0, 10), -0.06, Vector2.ONE * lerpf(2.6, 1.0, k))
		var texto := texto_en_pantalla
		var ancho := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 30).x
		c.draw_string(fuente, Vector2(-ancho / 2.0 + 2, 2), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color.BLACK)
		c.draw_string(fuente, Vector2(-ancho / 2.0, 0), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("ffe066"))
		c.draw_set_transform(Vector2.ZERO)
		c.draw_string(fuente, Vector2(20, tam.y - 56), "FELIPE · 8 kg de furia", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	elif texto_en_pantalla == NOMBRE:
		var k := clampf((_t - ENTRADA_CRECER) / 0.2, 0.0, 1.0)
		var desliza := (1.0 - ease(k, 0.3)) * tam.x
		_banda(c, tam, tam.y * 0.68, Color("15101a"), 1.0, desliza)
		c.draw_set_transform(Vector2(tam.x * 0.5 + desliza, tam.y * 0.68), 0.05)
		var ancho := fuente.get_string_size(NOMBRE, HORIZONTAL_ALIGNMENT_LEFT, -1, 40).x
		c.draw_string(fuente, Vector2(-ancho / 2.0 + 3, 6), NOMBRE, HORIZONTAL_ALIGNMENT_LEFT, -1, 40, Color("c81e2a"))
		c.draw_string(fuente, Vector2(-ancho / 2.0, 3), NOMBRE, HORIZONTAL_ALIGNMENT_LEFT, -1, 40, Color("ffe066"))
		var sub := fuente.get_string_size(TITULO, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
		c.draw_string(fuente, Vector2(-sub / 2.0, 24), TITULO, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
		c.draw_set_transform(Vector2.ZERO)
	if _cartel_fase > 0.0 and _texto_fase != "":
		var ancho := fuente.get_string_size(_texto_fase, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
		var y := tam.y * 0.38
		c.draw_rect(Rect2(0, y - 22, tam.x, 30), Color(0.08, 0.03, 0.05, 0.8 * minf(_cartel_fase * 2.0, 1.0)))
		c.draw_string(fuente, Vector2((tam.x - ancho) / 2.0, y), _texto_fase, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(Color("ffe066"), minf(_cartel_fase * 2.0, 1.0)))
	if fase in [Fase.SUCCION, Fase.ATURDIR, Fase.FURIA]:
		# Arriba a la derecha, lejos de los corazones y la báscula.
		var caja := Rect2(tam.x - 232, 22, 220, 9)
		c.draw_rect(Rect2(caja.position.x - 6, 4, caja.size.x + 12, 34), Color(0.1, 0.05, 0.07, 0.6))
		c.draw_string(fuente, Vector2(caja.position.x, 16), "%s — %s" % [NOMBRE, TITULO], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		c.draw_rect(caja.grow(2), Color(0.1, 0.05, 0.07, 0.85))
		var vida := 1.0 - float(aspi.golpes) / GOLPES_TOTALES
		c.draw_rect(Rect2(caja.position, Vector2(caja.size.x * vida, caja.size.y)), Color("c81e2a"))
		for i in range(1, GOLPES_TOTALES):
			c.draw_line(caja.position + Vector2(caja.size.x * i / GOLPES_TOTALES, 0), caja.position + Vector2(caja.size.x * i / GOLPES_TOTALES, caja.size.y), Color(0, 0, 0, 0.6), 1.0)
		if fase == Fase.SUCCION:
			# Escudo: se rompe al aguantar las succiones.
			var escudo := 1.0 - float(succiones) / SUCCIONES
			c.draw_rect(Rect2(caja.position + Vector2(0, caja.size.y - 3), Vector2(caja.size.x * escudo, 3)), Color("7fd0ff"))
	if _flash > 0.0:
		c.draw_rect(Rect2(Vector2.ZERO, tam), Color(1, 1, 1, minf(_flash, 1.0) * 0.8))


## Franja inclinada que cruza la pantalla.
func _banda(c: Node2D, tam: Vector2, y: float, color: Color, inclinacion: float, desliza := 0.0) -> void:
	var alto := 56.0
	var caida := 14.0 * inclinacion
	c.draw_colored_polygon(PackedVector2Array([
		Vector2(desliza - 20, y - alto / 2.0 + caida), Vector2(tam.x + desliza + 20, y - alto / 2.0 - caida),
		Vector2(tam.x + desliza + 20, y + alto / 2.0 - caida), Vector2(desliza - 20, y + alto / 2.0 + caida),
	]), color)
