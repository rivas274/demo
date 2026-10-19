class_name Valeria
extends Node2D
## Valeria, la dueña de Felipe (decisiones del creador, 2026-10-19): 4 poses fijas de Gemini (enojada, perdonando,
## grabando con el celular, viendo la serie) más una de pie y su caminar, todas a una sola escala (de pie, 200 px).
## Vive en la planta baja y va donde hay ruido: regaña señalando (5 s, corazón roto encima), perdona si Felipe se
## frota contra ella (botón de acción: "Encantar"), graba el rascador con el celular (8 s, de espaldas al sofá), abre
## la puerta de la cocina si Felipe maúlla del otro lado. Arriba no oye nada (audífonos de la reunión).
##
## Cumple la interfaz de testigo del rascador (grupo Rascador.GRUPO_TESTIGOS: ve(punto), visita, perdonar) y la de
## los maullidos (grupo Felipe.GRUPO_OYENTES: oir_maullido). Sus frases van por Travesuras.decir_valeria().
## La posición son sus pies (al centro). Nunca se para en una puerta (destinos con lugar_seguro()).

## Perdonó a Felipe: `motivo` es lo que lo tenía enojado ("rotura", "almuerzo", ...) o "rascador".
signal perdono(motivo: String)
## Llegó a donde iba (para encadenar escenas en el nivel).
signal llego

enum Actividad { SENTADA, DE_PIE, CAMINANDO, REGANANDO, PERDONANDO, GRABANDO, FUERA }

const RUTA := "res://assets/personajes/valeria_%s.png"
## Cuadros del caminar (hoja de 8 cuadros iguales, alineados por pies y cabeza en preparar_arte_nivel.py).
const CUADROS_CAMINAR := 8
const FPS_CAMINAR := 9.0
const VELOCIDAD := 95.0
const TIEMPO_REGANO := 5.0
const TIEMPO_PERDON := 1.6
const TIEMPO_GRABANDO := 8.0
## Lo que ve hacia donde mira (y un poco hacia atrás: la visión de reojo).
const VISTA := 560.0
const DE_REOJO := 30.0
## Sentada en el sofá siente todo lo que pasa a su lado (el sofá es suyo).
const SIENTE_SOFA := 170.0
## Grabando, solo ve lo que tiene enfrente del celular.
const VISTA_CELULAR := 150.0
## Fila del arte "serie" que queda sobre el asiento (la cadera).
const FILA_CADERA := 148
## Distancia a la que se para para regañar (no encima de Felipe).
const DISTANCIA_REGANO := 58.0
const ALTO := 200.0

var actividad := Actividad.DE_PIE
## Habitación donde está (Sala.habitacion_de no sirve cuando está FUERA).
var cuarto := ""
var mirando := 1.0
## Sube cada vez que Felipe vuelve a entrar al cuarto donde está ella (el bis del rascador no se cobra dos veces).
var visita := 0
var audifonos := false
var mascarilla := false
## Por qué está enojada ("rotura", "almuerzo", "sofa", ...).
var motivo_regano := ""
## Quien le pone la voz (frases) y cuenta los perdones.
var travesuras: Travesuras
## Las puertas del nivel, para no pararse en una: [x de centro] (las pone el nivel).
var puertas_x: Array[float] = []
## A dónde vuelve después de cada escena: {"x", "y", "actividad", "mirando", "cuarto"}.
var casa := {}

var _texturas := {}
var _destino := Vector2.INF
var _al_llegar := Callable()
var _reloj := 0.0
var _anim := 0.0
var _felipe: Felipe
var _ultimo_maullido := -10.0


func _init(nombre := "Valeria") -> void:
	name = nombre


func _ready() -> void:
	add_to_group(Rascador.GRUPO_TESTIGOS)
	add_to_group(Felipe.GRUPO_OYENTES)
	add_to_group(Comida.GRUPO)
	z_index = -1
	for pose in ["neutra", "enojada", "perdonando", "grabando", "serie", "caminar"]:
		var ruta := RUTA % pose
		_texturas[pose] = load(ruta) if ResourceLoader.exists(ruta) else null
	_felipe = get_tree().get_first_node_in_group("felipe")


## Se pone en un lugar sin caminar (al empezar o al entrar por una puerta).
func poner(lugar: Vector2, en_cuarto: String, hacia := 1.0, que := Actividad.DE_PIE) -> void:
	global_position = lugar
	cuarto = en_cuarto
	mirando = hacia
	actividad = que
	visible = que != Actividad.FUERA
	_destino = Vector2.INF
	_al_llegar = Callable()
	queue_redraw()


## Guarda el lugar actual como "su casa": ahí vuelve después de regañar, perdonar o grabar.
func fijar_casa() -> void:
	casa = {"x": global_position.x, "y": global_position.y, "actividad": actividad, "mirando": mirando, "cuarto": cuarto}


func volver_a_casa() -> void:
	if casa.is_empty():
		actividad = Actividad.DE_PIE
		return
	if casa["cuarto"] != cuarto:
		poner(Vector2(casa["x"], casa["y"]), casa["cuarto"], casa["mirando"], casa["actividad"])
		return
	caminar_a(casa["x"], func() -> void:
		global_position.y = casa["y"]
		mirando = casa["mirando"]
		actividad = casa["actividad"])


## Camina hasta x (en su cuarto) y al llegar llama `al_llegar`.
func caminar_a(x: float, al_llegar := Callable()) -> void:
	global_position.y = Sala.SUELO
	_destino = Vector2(x, Sala.SUELO)
	_al_llegar = al_llegar
	actividad = Actividad.CAMINANDO
	visible = true
	if absf(x - global_position.x) > 1.0:
		mirando = signf(x - global_position.x)


## Una x donde pararse que no esté en ninguna puerta (rectángulo sagrado) ni fuera del cuarto.
func lugar_seguro(x: float) -> float:
	var rect := Sala.rect_de(cuarto)
	x = clampf(x, rect.position.x + 40.0, rect.end.x - 40.0)
	for centro in puertas_x:
		if absf(x - centro) < Sala.MEDIO_RECT_PUERTA + 34.0 and Sala.habitacion_de(Vector2(centro, Sala.SUELO)) == cuarto:
			var izquierda := centro - Sala.MEDIO_RECT_PUERTA - 36.0
			var derecha := centro + Sala.MEDIO_RECT_PUERTA + 36.0
			x = izquierda if absf(x - izquierda) < absf(x - derecha) else derecha
			if x < rect.position.x + 40.0 or x > rect.end.x - 40.0:
				x = derecha if x == izquierda else izquierda
	return x


func _physics_process(delta: float) -> void:
	_anim += delta
	match actividad:
		Actividad.CAMINANDO:
			var falta := _destino.x - global_position.x
			if absf(falta) <= VELOCIDAD * delta:
				global_position.x = _destino.x
				_destino = Vector2.INF
				actividad = Actividad.DE_PIE
				var accion := _al_llegar
				_al_llegar = Callable()
				llego.emit()
				if accion.is_valid():
					accion.call()
			else:
				mirando = signf(falta)
				global_position.x += mirando * VELOCIDAD * delta
		Actividad.REGANANDO:
			_reloj -= delta
			if _felipe and absf(_felipe.global_position.x - global_position.x) > 4.0:
				mirando = signf(_felipe.global_position.x - global_position.x)
			if _reloj <= 0.0:
				motivo_regano = ""
				volver_a_casa()
		Actividad.PERDONANDO, Actividad.GRABANDO:
			_reloj -= delta
			if _reloj <= 0.0:
				volver_a_casa()
	queue_redraw()


## ¿Está mirando ese punto? (interfaz de testigo del rascador; también la usa el nivel para el sofá).
func ve(punto: Vector2) -> bool:
	if actividad in [Actividad.FUERA, Actividad.PERDONANDO] or not visible:
		return false
	if Sala.habitacion_de(punto) != cuarto:
		return false
	var dx := punto.x - global_position.x
	if actividad == Actividad.GRABANDO:
		return dx * mirando > 0.0 and absf(dx) < VISTA_CELULAR
	if actividad == Actividad.SENTADA and absf(dx) < SIENTE_SOFA:
		return true
	return dx * mirando > -DE_REOJO and absf(dx) < VISTA


## Algo se rompió o Felipe hizo una travesura donde ella lo ve: se para, va hacia él y lo regaña 5 s.
func reganar(felipe: Felipe, motivo: String, evento := "regana") -> void:
	if actividad in [Actividad.FUERA, Actividad.PERDONANDO] or audifonos:
		return
	motivo_regano = motivo
	if travesuras:
		travesuras.decir_valeria(evento, true)
	var lado := signf(global_position.x - felipe.global_position.x)
	var x := lugar_seguro(felipe.global_position.x + (lado if lado != 0.0 else 1.0) * DISTANCIA_REGANO)
	caminar_a(x, func() -> void:
		actividad = Actividad.REGANANDO
		_reloj = TIEMPO_REGANO
		if _felipe:
			mirando = signf(_felipe.global_position.x - global_position.x) if absf(_felipe.global_position.x - global_position.x) > 1.0 else mirando)


## Perdona a Felipe (interfaz de testigo). "frotarse": solo si estaba regañando; "rascador": se pone a grabar.
func perdonar(felipe: Felipe, motivo: String) -> void:
	if motivo == "rascador":
		_grabar(felipe)
		return
	if actividad != Actividad.REGANANDO:
		return
	var por := motivo_regano
	motivo_regano = ""
	actividad = Actividad.PERDONANDO
	_reloj = TIEMPO_PERDON
	if felipe and absf(felipe.global_position.x - global_position.x) > 1.0:
		mirando = signf(felipe.global_position.x - global_position.x)
	if travesuras:
		travesuras.decir_valeria("perdona", true)
		travesuras.contar_perdon()
	perdono.emit(por)


## Con el rascador delante de ella: saca el celular y lo graba 8 s, de espaldas al sofá.
func _grabar(felipe: Felipe) -> void:
	var lado := signf(felipe.global_position.x - global_position.x)
	if lado == 0.0:
		lado = 1.0
	var x := lugar_seguro(felipe.global_position.x - lado * 80.0)
	caminar_a(x, func() -> void:
		mirando = lado
		actividad = Actividad.GRABANDO
		_reloj = TIEMPO_GRABANDO
		if travesuras:
			travesuras.decir_valeria("grabando"))
	perdono.emit("rascador")


## Interfaz de los maullidos. En el mismo cuarto lo mira; con audífonos no oye nada.
func oir_maullido(felipe: Felipe) -> void:
	if audifonos or actividad == Actividad.FUERA:
		return
	var ahora := Time.get_ticks_msec() / 1000.0
	if ahora - _ultimo_maullido < 4.0:
		return
	_ultimo_maullido = ahora
	if Sala.habitacion_de(felipe.global_position) == cuarto and actividad in [Actividad.SENTADA, Actividad.DE_PIE]:
		mirando = signf(felipe.global_position.x - global_position.x) if absf(felipe.global_position.x - global_position.x) > 1.0 else mirando
		if travesuras:
			travesuras.decir_valeria("maullido")


## Felipe araña el sofá delante de ella: lo deja frente al rascador ("¡Ahí no, bebito, AQUÍ!").
func llevar_al_rascador(felipe: Felipe, x_rascador: float) -> void:
	if travesuras:
		travesuras.decir_valeria("sofa_atrapado", true)
	var antes := actividad
	actividad = Actividad.REGANANDO
	_reloj = 1.2
	motivo_regano = ""
	felipe.set_physics_process(false)
	var vuelo := felipe.create_tween()
	var desde := felipe.global_position
	var hasta := Vector2(x_rascador, Sala.SUELO)
	vuelo.tween_method(func(t: float) -> void:
		felipe.global_position = desde.lerp(hasta, t) + Vector2(0, -sin(t * PI) * 60.0), 0.0, 1.0, 0.55)
	vuelo.tween_callback(func() -> void:
		felipe.global_position = hasta
		felipe.velocity = Vector2.ZERO
		felipe.set_physics_process(true))
	if antes == Actividad.SENTADA:
		# Se queda sentada: solo señala un momento y vuelve a la serie.
		casa["actividad"] = Actividad.SENTADA


## ¿Se puede "Encantar"? Solo mientras regaña (el botón de acción junto a ella).
func disponible(_felipe_que_pregunta: Felipe) -> bool:
	return actividad == Actividad.REGANANDO and motivo_regano != ""


func punto_para(desde: Vector2) -> Vector2:
	return Vector2(global_position.x, Sala.SUELO) if desde.y > Sala.SUELO - 40.0 else Vector2(global_position.x, -9999)


func interactuar(felipe: Felipe) -> void:
	felipe.frotarse(self)


func verbo(_felipe_que_pregunta: Felipe) -> String:
	return "Encantar"


func primera_frase() -> String:
	return "{interactuar} Cara de bebito. Funciona siempre."


func rect_indicador() -> Rect2:
	return Rect2(global_position + Vector2(-26, -ALTO), Vector2(52, ALTO))


## Pose que corresponde a lo que hace.
func pose() -> String:
	match actividad:
		Actividad.SENTADA:
			return "serie"
		Actividad.CAMINANDO:
			return "caminar"
		Actividad.REGANANDO:
			return "enojada"
		Actividad.PERDONANDO:
			return "perdonando"
		Actividad.GRABANDO:
			return "grabando"
	return "neutra"


func _draw() -> void:
	if actividad == Actividad.FUERA:
		return
	var nombre := pose()
	var textura: Texture2D = _texturas.get(nombre)
	if textura == null:
		_dibujar_provisional()
		return
	var espejo := mirando < 0.0
	var region := Rect2(Vector2.ZERO, textura.get_size())
	if nombre == "caminar":
		var ancho := textura.get_width() / float(CUADROS_CAMINAR)
		var cuadro := int(_anim * FPS_CAMINAR) % CUADROS_CAMINAR
		region = Rect2(cuadro * ancho, 0, ancho, textura.get_height())
	var tam := region.size
	var base := 0.0 if nombre != "serie" else -tam.y + FILA_CADERA
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1 if espejo else 1, 1))
	draw_texture_rect_region(textura, Rect2(Vector2(-tam.x / 2.0, -tam.y - base), tam), region)
	draw_set_transform(Vector2.ZERO)
	var arriba := -tam.y - base
	if mascarilla:
		# Mascarilla para la caja de arena (dibujada: no está en las poses de Gemini).
		draw_rect(Rect2(Vector2(mirando * 4.0 - 8.0, arriba + 38.0), Vector2(16, 8)), Color(0.75, 0.88, 0.95))
		draw_rect(Rect2(Vector2(mirando * 4.0 - 8.0, arriba + 38.0), Vector2(16, 8)), Color(0.3, 0.4, 0.5), false, 1.0)
	if audifonos:
		draw_arc(Vector2(mirando * 2.0, arriba + 26.0), 15.0, PI, TAU, 10, Color(0.15, 0.15, 0.18), 3.0)
		draw_rect(Rect2(Vector2(mirando * 2.0 - 18.0, arriba + 22.0), Vector2(6, 10)), Color(0.15, 0.15, 0.18))
		draw_rect(Rect2(Vector2(mirando * 2.0 + 12.0, arriba + 22.0), Vector2(6, 10)), Color(0.15, 0.15, 0.18))
	if actividad == Actividad.REGANANDO and motivo_regano != "":
		_corazon_roto(Vector2(0, arriba - 14.0 + roundf(sin(_anim * 6.0) * 2.0)))
	if actividad == Actividad.GRABANDO and int(_anim * 3.0) % 2 == 0:
		var rec := Vector2(mirando * 26.0, arriba + 6.0)
		draw_circle(rec, 3.0, Color("e0483b"))
		draw_string(ThemeDB.fallback_font, rec + Vector2(5, 4), "REC", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("e0483b"))


## Corazón roto sobre la cabeza: lo que se arregla frotándose (propuesta v4, sección 5).
func _corazon_roto(centro: Vector2) -> void:
	var rojo := Color("e0483b")
	var oscuro := Color("6e1a22")
	for lado in [-1.0, 1.0]:
		var desplazado := centro + Vector2(lado * 2.0, 0)
		draw_circle(desplazado + Vector2(lado * 4.0, -3), 5.0, oscuro)
		draw_colored_polygon(PackedVector2Array([desplazado + Vector2(0, -6), desplazado + Vector2(lado * 9.5, -3), desplazado + Vector2(0, 9)]), oscuro)
		draw_circle(desplazado + Vector2(lado * 4.0, -3), 4.0, rojo)
		draw_colored_polygon(PackedVector2Array([desplazado + Vector2(0, -5), desplazado + Vector2(lado * 8.0, -3), desplazado + Vector2(0, 7)]), rojo)


func _dibujar_provisional() -> void:
	draw_rect(Rect2(-14, -ALTO, 28, ALTO), Color("3e7c7a"))
	draw_circle(Vector2(0, -ALTO + 14), 13.0, Color("d9a27c"))
