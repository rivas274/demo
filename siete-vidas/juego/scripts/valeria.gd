class_name Valeria
extends Node2D
## Valeria, la dueña de Felipe (decisiones del creador, 2026-10-19): 4 poses fijas de Gemini (enojada, perdonando,
## grabando con el celular, viendo la serie) más una de pie y su caminar de SpriteCook (las piernas alternan), todo a
## una sola escala (de pie, 200 px).
## Vive en la planta baja y va donde hay ruido: regaña señalando (5 s, corazón roto encima), perdona si Felipe se
## frota contra ella (botón de acción: "Encantar"), graba el rascador con el celular (8 s, de espaldas al sofá), abre
## la puerta de la cocina si Felipe maúlla del otro lado. Arriba no oye nada (audífonos de la reunión).
##
## Cómo se mueve (revisión 3):
## - Camina de verdad (B2): el cuadro del ciclo sale de la distancia recorrida (PASO_CUADRO px por cuadro, medido en la
##   hoja), así el pie apoyado no patina. Al empezar a caminar el ciclo vuelve al cuadro 0.
## - Nunca cambia de pose de golpe (G1): fundido cruzado de TRANSICION s entre la pose anterior (en su lugar) y la
##   nueva; al pararse del sofá o sentarse espera a que termine antes de moverse. Al girar, la figura se angosta y se
##   da vuelta (GIRO s), y no vuelve a girar antes de ESPERA_GIRO s (M6).
## - Nunca atraviesa una puerta cerrada ni se teletransporta (G2, G3): salir_por() camina hasta la puerta, la abre,
##   entra al vano y se desvanece en la oscuridad; entrar_por() aparece en el vano con la puerta abierta y sale.
## - Quieta respira (1 px) y cada tanto mira alrededor (M6).
##
## Cumple la interfaz de testigo del rascador (grupo Rascador.GRUPO_TESTIGOS: ve(punto), visita, perdonar) y la de
## los maullidos (pieza OyeMaullido: oir_maullido). Sus frases van por Travesuras.decir_valeria().
## La posición son sus pies (al centro). Nunca se para en una puerta (destinos con lugar_seguro()). Solo sentada
## está sobre un mueble (el asiento del sofá): de pie siempre pisa el piso.

## Perdonó a Felipe: `motivo` es lo que lo tenía enojado ("rotura", "almuerzo", ...) o "rascador".
signal perdono(motivo: String)
## Llegó a donde iba (para encadenar escenas en el nivel).
signal llego
## Terminó de cruzar una puerta (salió por ella o ya entró por ella).
signal cruzo_puerta

enum Actividad { SENTADA, DE_PIE, CAMINANDO, REGANANDO, PERDONANDO, GRABANDO, FUERA, PUERTA }

const RUTA := "res://assets/personajes/valeria_%s.png"
## Caminar de SpriteCook: 8 cuadros alineados por los pies (preparar_arte_nivel.py). El pie apoyado retrocede
## PASO_CUADRO px por cuadro (medido en la hoja: 9, 10, 9, 10 y 8 px en los pares con los pies separados); la
## velocidad sale de ahí: VELOCIDAD = PASO_CUADRO × FPS_CAMINAR (B2). prueba_nivel vuelve a medir la hoja.
const CUADROS_CAMINAR := 8
const PASO_CUADRO := 9.2
const FPS_CAMINAR := 12.0
const VELOCIDAD := PASO_CUADRO * FPS_CAMINAR
const TIEMPO_REGANO := 5.0
const TIEMPO_PERDON := 1.6
const TIEMPO_GRABANDO := 8.0
## Fundido cruzado entre dos poses (G1) y lo que tarda en darse vuelta (M6).
const TRANSICION := 0.2
const GIRO := 0.14
const ESPERA_GIRO := 0.4
## No gira si Felipe está casi debajo de ella (M6: giraba en cada cuadro cuando él le pasaba por delante).
const ZONA_SIN_GIRO := 12.0
## Lo que tarda en aparecer o desvanecerse en el vano de una puerta.
const VANO := 0.35
## Lo que ve hacia donde mira (y un poco hacia atrás: la visión de reojo).
const VISTA := 560.0
const DE_REOJO := 30.0
## Sentada en el sofá siente todo lo que pasa a su lado (el sofá es suyo).
const SIENTE_SOFA := 170.0
## Grabando, solo ve lo que tiene enfrente del celular.
const VISTA_CELULAR := 150.0
## Fila del arte "serie" que queda sobre el asiento. Crítica de Gemini (2026-10-19): con 148 se veía flotando sobre
## el cojín (los muslos 18 px sobre el asiento y los pies 10 px sobre el piso). Con 139 los pies tocan el piso (la
## última fila del arte cae en SUELO) y el muslo queda sobre el cojín, que se hunde (sombra en _draw).
const FILA_CADERA := 139
## Distancia a la que se para para regañar (no encima de Felipe).
const DISTANCIA_REGANO := 58.0
const ALTO := 200.0
## Mascarilla (G6): rectángulo de nariz y boca en la imagen de cada pose mirando a la derecha y la oreja donde se
## engancha el elástico. El caminar sube y baja la cabeza: CABEZA_CAMINAR da el desfase de cada cuadro.
const MASCARILLA := {
	"neutra": [Rect2(27, 47, 26, 10), Vector2(19, 45)],
	"caminar": [Rect2(54, 50, 26, 10), Vector2(46, 47)],
}
const CABEZA_CAMINAR := [0, -4, -2, 0, -1, -3, -1, -1]

var actividad := Actividad.DE_PIE:
	set(valor):
		if valor != actividad:
			actividad = valor
			queue_redraw()
## Habitación donde está (Nivel1.habitacion_de no sirve cuando está FUERA).
var cuarto := ""
## Hacia dónde mira (1 derecha, -1 izquierda). Para girar con transición, girar().
var mirando := 1.0
## Sube cada vez que Felipe vuelve a entrar al cuarto donde está ella (el bis del rascador no se cobra dos veces).
var visita := 0
var audifonos := false
## Segundos que le quedan con un audífono afuera (un ruido tan fuerte que se lo saca para escuchar; después se lo
## vuelve a poner: sigue sin oír lo de arriba).
var audifono_afuera := 0.0
var mascarilla := false:
	set(valor):
		mascarilla = valor
		queue_redraw()
## Por qué está enojada ("rotura", "almuerzo", "sofa", ...).
var motivo_regano := ""
## Quien le pone la voz (frases) y cuenta los perdones.
var travesuras: Travesuras
## Las puertas del nivel, para no pararse en una: [x de centro] (las pone el nivel).
var puertas_x: Array[float] = []
## A dónde vuelve después de cada escena: {"x", "y", "actividad", "mirando", "cuarto"}.
var casa := {}
## Distancia caminada desde que empezó a caminar (decide el cuadro del ciclo).
var recorrido := 0.0
## Veces que cambió de lugar sin caminar (al cruzar una puerta o al ponerla): las pruebas los cuentan aparte.
var cruces := 0

var _texturas := {}
var _destino := Vector2.INF
var _al_llegar := Callable()
var _reloj := 0.0
var _tiempo := 0.0
var _felipe: Felipe
var _ultimo_maullido := -10.0
## Pose dibujada antes del último cambio: {"pose", "pos", "mirando", "cuadro"} y cuánto va del fundido (0 a 1).
var _previa := {}
var _mezcla := 1.0
var _pose_actual := ""
var _cuadro_actual := 0
var _ultima_pos := Vector2.ZERO
var _ultimo_mirando := 1.0
## Espera antes de moverse (pararse del sofá, sentarse).
var _espera := 0.0
## Giro: de qué lado venía y cuánto va (0 a 1); tiempo desde el último giro.
var _giro := 1.0
var _mirando_antes := 1.0
var _desde_giro := 10.0
## Opacidad en el vano de una puerta (0 a 1) y hacia dónde va.
var _vano := 1.0
var _vano_objetivo := 1.0
var _tiempo_quieta := 0.0


func _init(nombre := "Valeria") -> void:
	name = nombre


func _ready() -> void:
	add_to_group(Rascador.GRUPO_TESTIGOS)
	# Oye los maullidos con su pieza OyeMaullido (pilar 2: maullar es llave).
	var oido := OyeMaullido.new()
	oido.oyo.connect(oir_maullido)
	add_child(oido)
	add_to_group(Componentes.INTERACTUABLES)
	z_index = Capas.PERSONAJES
	for pose_inicial in ["neutra", "enojada", "perdonando", "grabando", "serie", "caminar"]:
		var ruta := RUTA % pose_inicial
		_texturas[pose_inicial] = load(ruta) if ResourceLoader.exists(ruta) else null
	_felipe = get_tree().get_first_node_in_group("felipe")


## Se pone en un lugar sin caminar (al empezar, o en las pruebas). En el juego, de un cuarto a otro se pasa con
## salir_por() y entrar_por().
func poner(lugar: Vector2, en_cuarto: String, hacia := 1.0, que := Actividad.DE_PIE) -> void:
	global_position = lugar
	cuarto = en_cuarto
	mirando = hacia
	_mirando_antes = hacia
	_giro = 1.0
	actividad = que
	visible = que != Actividad.FUERA
	_vano = 1.0
	_vano_objetivo = 1.0
	_pies_en_el_piso()
	_destino = Vector2.INF
	_al_llegar = Callable()
	_previa = {}
	_mezcla = 1.0
	_pose_actual = pose()
	cruces += 1
	queue_redraw()


## Guarda el lugar actual como "su casa": ahí vuelve después de regañar, perdonar o grabar.
func fijar_casa() -> void:
	casa = {"x": global_position.x, "y": global_position.y, "actividad": actividad, "mirando": mirando, "cuarto": cuarto}


func volver_a_casa() -> void:
	if casa.is_empty() or casa["cuarto"] != cuarto:
		actividad = Actividad.DE_PIE
		return
	caminar_a(casa["x"], func() -> void:
		global_position.y = casa["y"]
		girar(casa["mirando"], true)
		actividad = casa["actividad"]
		# Sentarse también es un cambio de pose: espera el fundido antes de hacer otra cosa.
		_espera = TRANSICION)


## Deja lo que estaba haciendo (por ejemplo, Felipe se fue del cuarto y ella sigue con su vida).
func interrumpir() -> void:
	_destino = Vector2.INF
	_al_llegar = Callable()
	motivo_regano = ""
	_reloj = 0.0
	if actividad != Actividad.FUERA and actividad != Actividad.SENTADA:
		actividad = Actividad.DE_PIE


## Camina hasta x (en su cuarto) y al llegar llama `al_llegar`. Si estaba sentada, primero se para (fundido).
func caminar_a(x: float, al_llegar := Callable()) -> void:
	# Desde una pose distinta de estar de pie (sentada, enojada, agachada, grabando), primero cambia de pose en su
	# lugar (fundido) y recién después echa a andar: el fundido nunca se arrastra detrás de ella.
	if actividad not in [Actividad.CAMINANDO, Actividad.DE_PIE, Actividad.PUERTA, Actividad.FUERA]:
		_espera = maxf(_espera, TRANSICION)
	global_position.y = Nivel1.SUELO
	_destino = Vector2(x, Nivel1.SUELO)
	_al_llegar = al_llegar
	if actividad != Actividad.CAMINANDO:
		recorrido = 0.0
	actividad = Actividad.CAMINANDO
	visible = true
	if absf(x - global_position.x) > 1.0:
		girar(signf(x - global_position.x), true)
	queue_redraw()


## Sale del cuarto por esa puerta: camina hasta ella, la abre (la hoja gira), entra al vano y se desvanece; la puerta
## vuelve a quedar como estaba. Al terminar queda FUERA (invisible), emite cruzo_puerta y llama `al_salir`.
## Con `soltar` en false la puerta queda abierta (va a entrar enseguida por la otra cara de la misma puerta).
func salir_por(puerta: Puerta, al_salir := Callable(), soltar := true) -> void:
	caminar_a(puerta.global_position.x, func() -> void:
		# Solo esta cara: la del otro cuarto se abre cuando ella aparece allá (nunca sola y vacía, G2).
		puerta.abrir_para_paso(false)
		actividad = Actividad.PUERTA
		await _esperar_que(func() -> bool: return puerta.abierta_del_todo(), 1.0)
		_vano_objetivo = 0.0
		await _esperar_que(func() -> bool: return _vano <= 0.0, 1.0)
		if soltar:
			puerta.soltar_paso()
		actividad = Actividad.FUERA
		visible = false
		cruzo_puerta.emit()
		if al_salir.is_valid():
			al_salir.call())
	# Se abre un poco antes de que llegue (la mano en la manilla), no cuando ya está encima.
	_abrir_al_acercarse(puerta)


## Entra a `en_cuarto` por esa puerta: la puerta se abre, aparece en el vano (desde la oscuridad) y queda de pie
## delante del vano. La puerta se cierra detrás cuando ella ya se alejó (si era una puerta cerrada).
func entrar_por(puerta: Puerta, en_cuarto: String, hacia := 1.0, al_entrar := Callable(), quedarse_en_vano := false) -> void:
	_destino = Vector2.INF
	_al_llegar = Callable()
	global_position = Vector2(puerta.global_position.x, Nivel1.SUELO)
	cuarto = en_cuarto
	cruces += 1
	mirando = hacia
	_mirando_antes = hacia
	_giro = 1.0
	_previa = {}
	_mezcla = 1.0
	actividad = Actividad.PUERTA
	_pose_actual = pose()
	# La puerta se abre con ella ya en el vano: aparece desde la oscuridad mientras la hoja gira (G2).
	puerta.abrir_para_paso()
	_vano = 0.0
	_vano_objetivo = 1.0
	visible = true
	await _esperar_que(func() -> bool: return _vano >= 1.0 and puerta.abierta_del_todo(), 1.0)
	if quedarse_en_vano:
		return
	actividad = Actividad.DE_PIE
	cruzo_puerta.emit()
	_cerrar_al_alejarse(puerta)
	if al_entrar.is_valid():
		al_entrar.call()


## Se asoma en el vano de esa puerta (desde el otro lado): la puerta se abre con ella adentro y queda ahí, en el vano
## (actividad PUERTA), hasta volver_adentro().
func asomarse(puerta: Puerta, en_cuarto: String, hacia := 1.0) -> void:
	await entrar_por(puerta, en_cuarto, hacia, Callable(), true)


## Vuelve a meterse por la puerta en la que está asomada (se desvanece en el vano) y queda FUERA.
func volver_adentro(puerta: Puerta) -> void:
	actividad = Actividad.PUERTA
	puerta.abrir_para_paso()
	_vano_objetivo = 0.0
	await _esperar_que(func() -> bool: return _vano <= 0.0, 1.0)
	puerta.soltar_paso()
	actividad = Actividad.FUERA
	visible = false
	cruzo_puerta.emit()


func _abrir_al_acercarse(puerta: Puerta) -> void:
	await _esperar_que(func() -> bool: return absf(global_position.x - puerta.global_position.x) < 60.0 or actividad != Actividad.CAMINANDO, 30.0)
	if actividad in [Actividad.CAMINANDO, Actividad.PUERTA]:
		puerta.abrir_para_paso(false)


func _cerrar_al_alejarse(puerta: Puerta) -> void:
	await _esperar_que(func() -> bool: return absf(global_position.x - puerta.global_position.x) > 70.0 or not visible or actividad == Actividad.PUERTA, 8.0)
	if actividad != Actividad.PUERTA:
		puerta.soltar_paso()


func _esperar_que(condicion: Callable, maximo: float) -> void:
	var t := 0.0
	while t < maximo and not condicion.call():
		await get_tree().physics_frame
		t += get_physics_process_delta_time()


## Gira hacia `hacia` con su transición (la figura se angosta y se da vuelta). Sin `ya`, respeta la espera entre
## giros (M6).
func girar(hacia: float, ya := false) -> void:
	if hacia == 0.0 or hacia == mirando:
		return
	if not ya and _desde_giro < ESPERA_GIRO:
		return
	_mirando_antes = mirando
	mirando = hacia
	_giro = 0.0
	_desde_giro = 0.0
	queue_redraw()


## Mira a Felipe, salvo que esté casi debajo de ella (no gira en cada cuadro cuando él le pasa por delante).
func _girar_hacia_felipe() -> void:
	if _felipe == null:
		return
	var dx := _felipe.global_position.x - global_position.x
	if absf(dx) > ZONA_SIN_GIRO:
		girar(signf(dx))


## Una x donde pararse que no esté en ninguna puerta (rectángulo sagrado) ni fuera del cuarto.
func lugar_seguro(x: float) -> float:
	var rect := Nivel1.rect_de(cuarto)
	x = clampf(x, rect.position.x + 40.0, rect.end.x - 40.0)
	for centro in puertas_x:
		if absf(x - centro) < Nivel1.MEDIO_RECT_PUERTA + 34.0 and Nivel1.habitacion_de(Vector2(centro, Nivel1.SUELO)) == cuarto:
			var izquierda := centro - Nivel1.MEDIO_RECT_PUERTA - 36.0
			var derecha := centro + Nivel1.MEDIO_RECT_PUERTA + 36.0
			x = izquierda if absf(x - izquierda) < absf(x - derecha) else derecha
			if x < rect.position.x + 40.0 or x > rect.end.x - 40.0:
				x = derecha if x == izquierda else izquierda
	return x


func _physics_process(delta: float) -> void:
	_tiempo += delta
	_desde_giro += delta
	audifono_afuera = maxf(0.0, audifono_afuera - delta)
	_giro = minf(1.0, _giro + delta / GIRO)
	_mezcla = minf(1.0, _mezcla + delta / TRANSICION)
	_vano = move_toward(_vano, _vano_objetivo, delta / VANO)
	_pies_en_el_piso()
	queue_redraw()
	if _espera > 0.0:
		_espera -= delta
		return
	match actividad:
		Actividad.CAMINANDO:
			if _destino == Vector2.INF:
				actividad = Actividad.DE_PIE
				return
			var falta := _destino.x - global_position.x
			if absf(falta) <= VELOCIDAD * delta:
				recorrido += absf(falta)
				global_position.x = _destino.x
				_destino = Vector2.INF
				actividad = Actividad.DE_PIE
				var accion := _al_llegar
				_al_llegar = Callable()
				llego.emit()
				if accion.is_valid():
					accion.call()
			else:
				girar(signf(falta), true)
				global_position.x += signf(falta) * VELOCIDAD * delta
				recorrido += VELOCIDAD * delta
		Actividad.REGANANDO:
			_reloj -= delta
			_girar_hacia_felipe()
			if _reloj <= 0.0:
				motivo_regano = ""
				volver_a_casa()
		Actividad.PERDONANDO, Actividad.GRABANDO:
			_reloj -= delta
			if _reloj <= 0.0:
				volver_a_casa()
		Actividad.DE_PIE:
			# Con vida (M6): cada tanto mira para el otro lado y vuelve.
			_tiempo_quieta += delta
			if _tiempo_quieta > 6.0:
				_tiempo_quieta = 0.0
				girar(-mirando)
	if actividad != Actividad.DE_PIE:
		_tiempo_quieta = 0.0


## Si cambió la pose desde el último dibujo, empieza el fundido cruzado desde la anterior, en el lugar donde SE DIBUJÓ
## (no donde está ahora: así la pose sentada nunca se dibuja bajada al piso, G1). Se decide al dibujar, porque el
## cambio puede llegar por una señal en cualquier momento del cuadro.
func _seguir_pose(nueva: String) -> void:
	if nueva == _pose_actual:
		return
	# Entre estar de pie y caminar no hay fundido: es la misma figura, el ciclo empieza en el cuadro de contacto.
	var de_pie := ["neutra", "caminar"]
	if _pose_actual != "" and visible and not (_pose_actual in de_pie and nueva in de_pie):
		_previa = {"pose": _pose_actual, "pos": _ultima_pos, "mirando": _ultimo_mirando, "cuadro": _cuadro_actual}
		_mezcla = 0.0
	_pose_actual = nueva


## De pie (regañando, caminando, grabando...) nunca queda encima de un mueble: los pies van al piso (G2).
func _pies_en_el_piso() -> void:
	if actividad != Actividad.SENTADA and actividad != Actividad.FUERA:
		global_position.y = Nivel1.SUELO


## ¿Está mirando ese punto? (interfaz de testigo del rascador; también la usa el nivel para el sofá).
func ve(punto: Vector2) -> bool:
	if actividad in [Actividad.FUERA, Actividad.PERDONANDO, Actividad.PUERTA] or not visible:
		return false
	if Nivel1.habitacion_de(punto) != cuarto:
		return false
	var dx := punto.x - global_position.x
	if actividad == Actividad.GRABANDO:
		return dx * mirando > 0.0 and absf(dx) < VISTA_CELULAR
	if actividad == Actividad.SENTADA and absf(dx) < SIENTE_SOFA:
		return true
	return dx * mirando > -DE_REOJO and absf(dx) < VISTA


## ¿Está libre para una escena nueva (quieta, sin cruzar una puerta ni ir a ningún lado)?
func libre() -> bool:
	return actividad in [Actividad.DE_PIE, Actividad.SENTADA] and _destino == Vector2.INF


## Algo se rompió o Felipe hizo una travesura donde ella lo ve: se para, va hacia él y lo regaña 5 s.
func reganar(felipe: Felipe, motivo: String, evento := "regana") -> void:
	if actividad in [Actividad.FUERA, Actividad.PERDONANDO, Actividad.PUERTA] or audifonos:
		return
	motivo_regano = motivo
	if travesuras:
		travesuras.decir_valeria(evento, true)
	var lado := signf(global_position.x - felipe.global_position.x)
	var x := lugar_seguro(felipe.global_position.x + (lado if lado != 0.0 else 1.0) * DISTANCIA_REGANO)
	caminar_a(x, func() -> void:
		actividad = Actividad.REGANANDO
		_reloj = TIEMPO_REGANO
		if _felipe and absf(_felipe.global_position.x - global_position.x) > 1.0:
			girar(signf(_felipe.global_position.x - global_position.x), true))


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
	if felipe and absf(felipe.global_position.x - global_position.x) > ZONA_SIN_GIRO:
		girar(signf(felipe.global_position.x - global_position.x), true)
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
		girar(lado, true)
		actividad = Actividad.GRABANDO
		_reloj = TIEMPO_GRABANDO
		if travesuras:
			travesuras.decir_valeria("grabando"))
	perdono.emit("rascador")


## Un ruido que se oye aunque tenga audífonos (la caja de la mudanza contra el piso): se saca uno unos segundos.
func sacar_audifono(segundos := 3.0) -> void:
	audifono_afuera = segundos
	queue_redraw()


## Oyó maullar (su OyeMaullido). En el mismo cuarto lo mira; con audífonos no oye nada.
func oir_maullido(felipe: Felipe) -> void:
	if audifonos or actividad == Actividad.FUERA:
		return
	var ahora := Time.get_ticks_msec() / 1000.0
	if ahora - _ultimo_maullido < 4.0:
		return
	_ultimo_maullido = ahora
	if Nivel1.habitacion_de(felipe.global_position) == cuarto and actividad in [Actividad.SENTADA, Actividad.DE_PIE]:
		_girar_hacia_felipe()
		if travesuras:
			travesuras.decir_valeria("maullido")


## Felipe araña el sofá delante de ella: lo deja frente al rascador ("¡Ahí no, bebito, AQUÍ!").
func llevar_al_rascador(felipe: Felipe, x_rascador: float) -> void:
	if travesuras:
		travesuras.decir_valeria("sofa_atrapado", true)
	var antes := actividad
	actividad = Actividad.REGANANDO
	# Se para del sofá: baja al piso, delante del sofá, antes de señalar (G2); el fundido evita el corte (G1).
	_pies_en_el_piso()
	_reloj = 1.2
	motivo_regano = ""
	felipe.set_physics_process(false)
	var vuelo := felipe.create_tween()
	var desde := felipe.global_position
	var hasta := Vector2(x_rascador, Nivel1.SUELO)
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
	return Vector2(global_position.x, Nivel1.SUELO) if desde.y > Nivel1.SUELO - 40.0 else Vector2(global_position.x, -9999)


func interactuar(felipe: Felipe) -> void:
	felipe.frotarse(self)


func verbo(_felipe_que_pregunta: Felipe) -> String:
	return "Encantar"


func primera_frase() -> String:
	return "{interactuar} Cara de bebito. Funciona siempre."


## Contorno del Indicador con la silueta de la pose que se ve (el cuadro de la hoja, volteado si mira a la izquierda).
func arte_indicador() -> Dictionary:
	if pose_dibujada == "":
		return {}
	var datos := _datos_pose(pose_dibujada, _cuadro_actual)
	if datos.is_empty():
		return {}
	var region: Rect2 = datos["region"]
	var pos := pos_dibujada + Vector2(-region.size.x / 2.0, -region.size.y - float(datos["base"]))
	return {"textura": datos["textura"], "rect": Rect2(pos, region.size), "region": region, "espejo": mirando < 0.0}


func rect_indicador() -> Rect2:
	return Rect2(global_position + Vector2(-26, -ALTO), Vector2(52, ALTO))


## Pose que corresponde a lo que hace.
func pose() -> String:
	match actividad:
		Actividad.SENTADA:
			return "serie"
		Actividad.CAMINANDO:
			# Mientras termina de pararse (fundido), todavía no camina.
			return "neutra" if _espera > 0.0 else "caminar"
		Actividad.REGANANDO:
			return "enojada"
		Actividad.PERDONANDO:
			return "perdonando"
		Actividad.GRABANDO:
			return "grabando"
	return "neutra"


## Cuadro del ciclo de caminar: sale de lo caminado, no del reloj (el pie apoyado no patina).
func cuadro_caminar() -> int:
	return int(recorrido / PASO_CUADRO) % CUADROS_CAMINAR


## Rectángulo (en el mundo) que ocupa la pose actual: sus pies nunca quedan bajo el piso (G1).
func rect_dibujado() -> Rect2:
	var datos := _datos_pose(pose())
	if datos.is_empty():
		return Rect2(global_position + Vector2(-14, -ALTO), Vector2(28, ALTO))
	var tam: Vector2 = (datos["region"] as Rect2).size
	return Rect2(global_position + Vector2(-tam.x / 2.0, -tam.y - float(datos["base"])), tam)


func _datos_pose(nombre: String, cuadro := -1) -> Dictionary:
	var textura: Texture2D = _texturas.get(nombre)
	if textura == null:
		return {}
	var region := Rect2(Vector2.ZERO, textura.get_size())
	if nombre == "caminar":
		var ancho := textura.get_width() / float(CUADROS_CAMINAR)
		var i := cuadro if cuadro >= 0 else cuadro_caminar()
		region = Rect2(i * ancho, 0, ancho, textura.get_height())
	var base := 0.0 if nombre != "serie" else -region.size.y + FILA_CADERA
	return {"textura": textura, "region": region, "base": base}


## Pose y lugar con que se dibujó por última vez (las pruebas comparan con el estado: nada se dibuja viejo).
var pose_dibujada := ""
var pos_dibujada := Vector2.ZERO


func _draw() -> void:
	pose_dibujada = ""
	pos_dibujada = global_position
	if actividad == Actividad.FUERA:
		_pose_actual = ""
		return
	var nombre := pose()
	_seguir_pose(nombre)
	_ultima_pos = global_position
	_ultimo_mirando = mirando
	pose_dibujada = nombre
	_cuadro_actual = cuadro_caminar()
	var alfa := _vano
	if nombre == "serie" and _mezcla >= 1.0:
		_cojin_hundido(alfa)
	var hay_previa := _mezcla < 1.0 and not _previa.is_empty()
	if hay_previa:
		var desplazado: Vector2 = _previa["pos"] - global_position
		_dibujar_pose(_previa["pose"], desplazado, _previa["mirando"], 1.0, alfa * (1.0 - _mezcla), _previa["cuadro"])
	# Al girar, la figura se angosta hasta casi una línea y se abre del otro lado.
	var ancho := absf(cos(_giro * PI)) if _giro < 1.0 else 1.0
	var lado := mirando if _giro >= 0.5 else _mirando_antes
	# Respira: 1 px de alto (bien dentro de ±8 %) cuando está quieta.
	var respira := 1.0
	if actividad in [Actividad.DE_PIE, Actividad.SENTADA]:
		respira = 1.0 + 0.005 * sin(_tiempo * 2.4)
	_dibujar_pose(nombre, Vector2.ZERO, lado, maxf(ancho, 0.12), alfa * (_mezcla if hay_previa else 1.0), _cuadro_actual, respira)
	var datos := _datos_pose(nombre)
	var arriba := -ALTO
	if not datos.is_empty():
		arriba = -(datos["region"] as Rect2).size.y - float(datos["base"])
	if audifonos:
		draw_arc(Vector2(mirando * 2.0, arriba + 26.0), 15.0, PI, TAU, 10, Color(0.15, 0.15, 0.18), 3.0)
		draw_rect(Rect2(Vector2(mirando * 2.0 - 18.0, arriba + 22.0), Vector2(6, 10)), Color(0.15, 0.15, 0.18))
		# El de adelante, afuera: corrido sobre la sien mientras escucha (sacar_audifono).
		var afuera := Vector2(4.0, -10.0) if audifono_afuera > 0.0 else Vector2.ZERO
		draw_rect(Rect2(Vector2(mirando * 2.0 + 12.0, arriba + 22.0) + afuera, Vector2(6, 10)), Color(0.15, 0.15, 0.18))
	if actividad == Actividad.REGANANDO and motivo_regano != "":
		_corazon_roto(Vector2(0, arriba - 14.0 + roundf(sin(_tiempo * 6.0) * 2.0)))
	if actividad == Actividad.GRABANDO and int(_tiempo * 3.0) % 2 == 0:
		var rec := Vector2(mirando * 26.0, arriba + 6.0)
		draw_circle(rec, 3.0, Color("e0483b"))
		draw_string(ThemeDB.fallback_font, rec + Vector2(5, 4), "REC", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("e0483b"))


func _dibujar_pose(nombre: String, desplazado: Vector2, lado: float, ancho: float, alfa: float, cuadro: int, alto := 1.0) -> void:
	if alfa <= 0.0:
		return
	var datos := _datos_pose(nombre, cuadro)
	if datos.is_empty():
		_dibujar_provisional()
		return
	var region: Rect2 = datos["region"]
	var tam := region.size
	var base: float = datos["base"]
	# Los pies quedan en el origen: estirar o girar no los mueve.
	draw_set_transform(desplazado + Vector2(0, -base), 0.0, Vector2((-1.0 if lado < 0.0 else 1.0) * ancho, alto))
	# Al aparecer o desaparecer en un vano se ve desde la oscuridad (más oscura cuanto más adentro).
	var tinte := Color(1, 1, 1, alfa).lerp(Color(0.15, 0.1, 0.1, alfa), (1.0 - _vano) * 0.7)
	draw_texture_rect_region(datos["textura"], Rect2(Vector2(-tam.x / 2.0, -tam.y), tam), region, tinte)
	if mascarilla and MASCARILLA.has(nombre):
		_dibujar_mascarilla(nombre, tam, cuadro, alfa)
	draw_set_transform(Vector2.ZERO)


## Mascarilla quirúrgica sobre nariz y boca, con pliegues y el elástico a la oreja (G6). Va dentro de la transformación
## de la pose: sigue la cara, el espejo y el giro.
func _dibujar_mascarilla(nombre: String, tam: Vector2, cuadro: int, alfa: float) -> void:
	var datos: Array = MASCARILLA[nombre]
	var cara: Rect2 = datos[0]
	var oreja: Vector2 = datos[1]
	var dy := float(CABEZA_CAMINAR[cuadro % CABEZA_CAMINAR.size()]) if nombre == "caminar" else 0.0
	var origen := Vector2(-tam.x / 2.0, -tam.y + dy)
	var r := Rect2(origen + cara.position, cara.size)
	var tela := Color(0.80, 0.91, 0.96, alfa)
	var borde := Color(0.30, 0.42, 0.52, alfa)
	var forma := PackedVector2Array([
		r.position + Vector2(0, 2), r.position + Vector2(r.size.x * 0.5, 0), r.position + Vector2(r.size.x, 1),
		r.end + Vector2(-1, -3), r.position + Vector2(r.size.x * 0.62, r.size.y + 1), r.position + Vector2(3, r.size.y - 2),
	])
	draw_line(origen + oreja, r.position + Vector2(1, 3), borde, 1.0)
	draw_line(origen + oreja + Vector2(0, 3), r.position + Vector2(2, r.size.y - 3), borde, 1.0)
	draw_colored_polygon(forma, tela)
	draw_polyline(forma + PackedVector2Array([forma[0]]), borde, 1.0)
	for pliegue in 2:
		var y := r.position.y + 4.0 + pliegue * 3.0
		draw_line(Vector2(r.position.x + 3, y), Vector2(r.end.x - 3, y), Color(0.55, 0.68, 0.76, alfa), 1.0)


## Sombra del cojín hundido bajo Valeria sentada (crítica de Gemini: que no flote sobre el sofá). En pixeles: dos
## franjas, la de abajo más oscura, sin degradado suave.
func _cojin_hundido(alfa: float) -> void:
	var lado := mirando
	draw_rect(Rect2(-24.0 + lado * 4.0, -9.0, 50.0, 4.0), Color(0.25, 0.08, 0.06, 0.18 * alfa))
	draw_rect(Rect2(-20.0 + lado * 4.0, -5.0, 42.0, 5.0), Color(0.25, 0.08, 0.06, 0.30 * alfa))


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
