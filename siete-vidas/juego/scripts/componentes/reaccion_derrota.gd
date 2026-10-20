class_name ReaccionDerrota
extends Node
## Pieza: la derrota jugosa de un enemigo (decisión del creador, 2026-10-20). Se conecta a `Vida.murio` y hace los 5 pasos
## que pidan sus datos (DatosDerrota):
##   1. destello blanco por silueta, destello de pantalla, congelado y sacudida (Jugo);
##   2. sale volando dando vueltas hacia donde iba el zarpazo y rebota en paredes y piso (move_and_collide);
##   3. «¡POP!»: se desarma al tocar el piso y suelta sus piezas (PiezaSuelta) con una nube (Particulas);
##   4. cámara lenta, solo si los datos la piden (y siempre vuelve a time_scale 1);
##   5. la marca que queda: las piezas en el piso (la llave sigue girando sola), una marca al lado y un fantasmita.
## Felipe lo comenta sin culpa (Frases, sin repetir la anterior). Anti-pilar: nada sufre ni sangra.
## Enemigo la arma sola si DatosEnemigo.derrota trae datos; un enemigo nuevo solo necesita su .tres en datos/derrotas/.

signal desarmado
signal terminada

var datos: DatosDerrota
## Volando tras el golpe (paso 2).
var volando := false
var velocidad := Vector2.ZERO
## Piezas que soltó (paso 3) y la marca que dejó (paso 5).
var piezas: Array[PiezaSuelta] = []
var marca: PiezaSuelta
var fantasma: PiezaSuelta
## La cámara lenta está puesta por esta derrota.
var en_camara_lenta := false
var reaccionada := false

var _cuerpo: CharacterBody2D
var _apariencia: Node2D
var _lado := 1.0
var _vuelo := 0.0
var _giro := 0.0

## Tiempo máximo en el aire (por si nunca toca el piso).
const VUELO_MAXIMO := 3.0
## Color de la silueta en el destello (modulate por encima de 1: se satura a blanco).
const BLANCO := Color(12, 12, 12)


func _init(con_datos: DatosDerrota = null) -> void:
	name = "ReaccionDerrota"
	datos = con_datos


func _ready() -> void:
	_cuerpo = get_parent() as CharacterBody2D
	set_physics_process(false)


func _exit_tree() -> void:
	if en_camara_lenta:
		Engine.time_scale = 1.0
		en_camara_lenta = false


## Vida.murio: arranca la derrota (una sola vez).
func reaccionar() -> void:
	if reaccionada or datos == null or _cuerpo == null:
		return
	reaccionada = true
	_apariencia = _cuerpo.get("apariencia") as Node2D
	var nivel := Componentes.nivel(_cuerpo)
	var jugo: Jugo = nivel.travesuras.jugo if nivel and nivel.travesuras else null
	var felipe := get_tree().get_first_node_in_group("felipe") as Felipe
	if felipe:
		_lado = signf(_cuerpo.global_position.x - felipe.global_position.x)
		if _lado == 0.0:
			_lado = felipe.mirando
	# 1. Destello por silueta, congelado y sacudida.
	if _apariencia and datos.destello > 0.0:
		_apariencia.self_modulate = BLANCO
		get_tree().create_timer(datos.destello, true, false, true).timeout.connect(func() -> void:
			if is_instance_valid(_apariencia):
				_apariencia.self_modulate = Color.WHITE)
	if jugo:
		if datos.destello_pantalla > 0.0:
			jugo.destello(datos.destello_pantalla)
		if datos.congelado > 0.0:
			jugo.congelar(datos.congelado)
		if datos.sacudida.x > 0.0:
			jugo.sacudir(datos.sacudida.x, datos.sacudida.y)
	RecetaJugo.vibrar(datos.vibracion, get_tree())
	if nivel and nivel.travesuras and datos.frase != "":
		nivel.travesuras.decir_felipe(datos.frase)
	if datos.congelado > 0.0:
		await get_tree().create_timer(datos.congelado, true, false, true).timeout
		# Un cuadro más: el Jugo devuelve el tiempo a 1 al terminar su congelado.
		await get_tree().process_frame
	if not is_inside_tree():
		return
	# 4. Cámara lenta (solo si se pide).
	if datos.camara_lenta < 1.0:
		_empezar_camara_lenta()
	# 2. Sale volando.
	velocidad = Vector2(_lado * datos.impulso.x, datos.impulso.y)
	volando = true
	_vuelo = 0.0
	var patrulla: Node = _cuerpo.get("patrulla")
	if patrulla:
		patrulla.set_physics_process(false)
	set_physics_process(true)


func _empezar_camara_lenta() -> void:
	en_camara_lenta = true
	Engine.time_scale = datos.camara_lenta
	await get_tree().create_timer(datos.duracion_lenta, true, false, true).timeout
	if en_camara_lenta:
		en_camara_lenta = false
		Engine.time_scale = 1.0


func _physics_process(delta: float) -> void:
	if not volando:
		return
	_vuelo += delta
	velocidad.y += datos.gravedad * delta
	_girar(datos.vueltas * TAU * delta)
	var choque := _cuerpo.move_and_collide(velocidad * delta)
	if choque:
		var normal := choque.get_normal()
		if normal.y < -0.5:
			if datos.desarmarse:
				_desarmar()
				return
			if velocidad.y > 90.0:
				velocidad = Vector2(velocidad.x * 0.7, -velocidad.y * datos.rebote_piso)
			else:
				_aterrizar()
				return
		elif absf(normal.x) > 0.5:
			velocidad.x = -velocidad.x * datos.rebote_pared
			_lado = -_lado
		else:
			velocidad = velocidad.slide(normal)
	if _vuelo > VUELO_MAXIMO:
		if datos.desarmarse:
			_desarmar()
		else:
			_aterrizar()


## Gira el dibujo alrededor de su centro (no de los pies).
func _girar(angulo: float) -> void:
	if _apariencia == null:
		return
	_giro += angulo
	var centro := Vector2(0, -_alto() / 2.0)
	_apariencia.rotation = _giro
	_apariencia.position = centro - centro.rotated(_giro)


func _alto() -> float:
	var d: DatosEnemigo = _cuerpo.get("datos")
	return d.alto_dibujo if d else 30.0


func _enderezar() -> void:
	_giro = 0.0
	if _apariencia:
		_apariencia.rotation = 0.0
		_apariencia.position = Vector2.ZERO


## 3. ¡POP!: el dibujo desaparece y suelta sus piezas, una nube y el fantasmita.
func _desarmar() -> void:
	volando = false
	set_physics_process(false)
	_enderezar()
	if _apariencia:
		_apariencia.visible = false
	# Sin cuerpo, sin sombra (la dibuja SombrasVivas mientras `mostrar` diga que sí).
	var sombra := _cuerpo.get("sombra") as SombraContacto
	if sombra:
		sombra.mostrar = func() -> bool: return false
	var mundo := _cuerpo.get_parent()
	var pie := _cuerpo.position
	for i in datos.piezas.size():
		var angulo := -PI / 2.0 + randf_range(-1.1, 1.1)
		var rapidez := randf_range(datos.velocidad_piezas.x, datos.velocidad_piezas.y)
		var pieza := PiezaSuelta.crear(datos.piezas[i], pie + Vector2(0, -8), Vector2.from_angle(angulo) * rapidez, pie.y)
		pieza.vueltas = randf_range(-2.5, 2.5)
		pieza.z_index = _cuerpo.z_index
		if datos.piezas[i] == datos.pieza_que_gira:
			pieza.gira_segundos = datos.giro_segundos
		mundo.add_child(pieza)
		piezas.append(pieza)
	_soltar_nube(pie)
	_palabra(datos.palabra, pie + Vector2(0, -44))
	if datos.fantasma != "":
		fantasma = PiezaSuelta.crear(datos.fantasma, pie + Vector2(0, -10), Vector2.ZERO, pie.y)
		fantasma.set_physics_process(false)
		fantasma.modulate.a = 0.6
		fantasma.z_index = _cuerpo.z_index + 1
		mundo.add_child(fantasma)
		# Después del «¡POP!» (zonas de texto: una palabra a la vez, cada una 0,9 s).
		_palabra(datos.palabra_fantasma, pie + Vector2(0, -70), ZonasTexto.DURACION_PALABRA)
		var subir := fantasma.create_tween().set_parallel()
		subir.tween_property(fantasma, "position:y", fantasma.position.y - datos.subida_fantasma, datos.tiempo_fantasma).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		subir.tween_property(fantasma, "modulate:a", 0.0, datos.tiempo_fantasma).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		subir.chain().tween_callback(fantasma.queue_free)
	if datos.marca != "":
		_dejar_marca(pie)
	desarmado.emit()
	terminada.emit()


## Cae sin desarmarse (A.S.P.I.): se endereza, escupe su nube y deja su marca.
func _aterrizar() -> void:
	volando = false
	set_physics_process(false)
	_enderezar()
	var patrulla: Node = _cuerpo.get("patrulla")
	if patrulla:
		patrulla.set_physics_process(true)
	_soltar_nube(_cuerpo.position)
	_palabra(datos.palabra, _cuerpo.position + Vector2(0, -50))
	if datos.marca != "":
		_dejar_marca(_cuerpo.position)
	terminada.emit()


func _dejar_marca(pie: Vector2) -> void:
	# Del lado de donde vino el golpe (hacia Felipe), en el piso.
	marca = PiezaSuelta.crear(datos.marca, pie + Vector2(-_lado * datos.lado_marca, 0), Vector2.ZERO, pie.y)
	marca.z_index = _cuerpo.z_index
	_cuerpo.get_parent().add_child(marca)
	marca._apoyar()


func _soltar_nube(pie: Vector2) -> void:
	if datos.nube <= 0:
		return
	var nube := Particulas.polvo(datos.nube, 0.9, Vector2(0, 60), Vector2(30, 90), Vector2(2, 4), datos.color_nube, 80.0)
	nube.position = pie + Vector2(0, -10)
	nube.z_index = _cuerpo.z_index + 1
	_cuerpo.get_parent().add_child(nube)
	nube.restart()
	nube.emitting = true
	nube.finished.connect(nube.queue_free)


func _palabra(clave: String, donde: Vector2, retraso := 0.0) -> void:
	if clave == "":
		return
	var nivel := Componentes.nivel(_cuerpo)
	if nivel and nivel.travesuras and nivel.travesuras.jugo:
		nivel.travesuras.jugo.palabra_en_mundo(clave, donde, Color(1.0, 0.9, 0.5), 14, retraso)
