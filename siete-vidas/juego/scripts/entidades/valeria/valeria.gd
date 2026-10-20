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
## Distancia a la que se para para regañar (no encima de Felipe).
const DISTANCIA_REGANO := 58.0
const ALTO := 200.0
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

## Giro: de qué lado venía y cuánto va (0 a 1). Opacidad en el vano de una puerta (0 a 1) y hacia dónde va.
## Los lee su aspecto (AspectoValeria) y los mueve su ruta (RutaValeria).
var giro := 1.0
var mirando_antes := 1.0
var vano := 1.0
var vano_objetivo := 1.0
## Reloj para respirar, el corazón y el "REC".
var tiempo := 0.0
## Cómo se ve (poses, fundidos, accesorios) y cómo cruza puertas.
var aspecto := AspectoValeria.new(self)
var ruta := RutaValeria.new(self)
## Pose y lugar con que se dibujó por última vez (las pruebas comparan con el estado: nada se dibuja viejo).
var pose_dibujada: String:
	get:
		return aspecto.pose_dibujada
var pos_dibujada: Vector2:
	get:
		return aspecto.pos_dibujada

var _destino := Vector2.INF
var _al_llegar := Callable()
var _reloj := 0.0
var _felipe: Felipe
var _ultimo_maullido := -10.0
## Espera antes de moverse (pararse del sofá, sentarse).
var _espera := 0.0
## Tiempo desde el último giro.
var _desde_giro := 10.0
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
	aspecto.cargar()
	_felipe = get_tree().get_first_node_in_group("felipe")
	_poner_silueta.call_deferred()


## Valeria va delante de Felipe (Capas.PERSONAJES): donde lo tapa se ve su contorno (pieza SiluetaTapada).
func _poner_silueta() -> void:
	if _felipe == null:
		_felipe = get_tree().get_first_node_in_group("felipe")
	if _felipe == null or has_node("SiluetaTapada"):
		return
	var silueta := SiluetaTapada.new()
	add_child(silueta)
	silueta.seguir(_felipe.sprite)


## Se pone en un lugar sin caminar (al empezar, o en las pruebas). En el juego, de un cuarto a otro se pasa con
## salir_por() y entrar_por().
func poner(lugar: Vector2, en_cuarto: String, hacia := 1.0, que := Actividad.DE_PIE) -> void:
	aparecer_en(lugar, en_cuarto, hacia, que)
	visible = que != Actividad.FUERA
	vano = 1.0
	vano_objetivo = 1.0
	_pies_en_el_piso()
	queue_redraw()


## Cambia de lugar sin caminar, sin fundido desde la pose anterior (lo usan poner() y la ruta al entrar por una puerta).
func aparecer_en(lugar: Vector2, en_cuarto: String, hacia: float, que := Actividad.PUERTA) -> void:
	_destino = Vector2.INF
	_al_llegar = Callable()
	global_position = lugar
	cuarto = en_cuarto
	cruces += 1
	mirando = hacia
	mirando_antes = hacia
	giro = 1.0
	actividad = que
	aspecto.reiniciar()


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
	ruta.salir_por(puerta, al_salir, soltar)


## Entra a `en_cuarto` por esa puerta: la puerta se abre, aparece en el vano (desde la oscuridad) y queda de pie
## delante del vano. La puerta se cierra detrás cuando ella ya se alejó (si era una puerta cerrada).
func entrar_por(puerta: Puerta, en_cuarto: String, hacia := 1.0, al_entrar := Callable(), quedarse_en_vano := false) -> void:
	await ruta.entrar_por(puerta, en_cuarto, hacia, al_entrar, quedarse_en_vano)


## Se asoma en el vano de esa puerta (desde el otro lado): la puerta se abre con ella adentro y queda ahí, en el vano
## (actividad PUERTA), hasta volver_adentro().
func asomarse(puerta: Puerta, en_cuarto: String, hacia := 1.0) -> void:
	await ruta.entrar_por(puerta, en_cuarto, hacia, Callable(), true)


## Vuelve a meterse por la puerta en la que está asomada (se desvanece en el vano) y queda FUERA.
func volver_adentro(puerta: Puerta) -> void:
	await ruta.volver_adentro(puerta)


## Gira hacia `hacia` con su transición (la figura se angosta y se da vuelta). Sin `ya`, respeta la espera entre
## giros (M6).
func girar(hacia: float, ya := false) -> void:
	if hacia == 0.0 or hacia == mirando:
		return
	if not ya and _desde_giro < ESPERA_GIRO:
		return
	mirando_antes = mirando
	mirando = hacia
	giro = 0.0
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
	return ruta.lugar_seguro(x)


func _physics_process(delta: float) -> void:
	tiempo += delta
	_desde_giro += delta
	audifono_afuera = maxf(0.0, audifono_afuera - delta)
	giro = minf(1.0, giro + delta / GIRO)
	aspecto.avanzar(delta)
	vano = move_toward(vano, vano_objetivo, delta / VANO)
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
	return "VERBO_ENCANTAR"


func primera_frase() -> String:
	return "PRIMERA_INTERACTUAR_CARA_DE_BEBITO"


## Contorno del Indicador con la silueta de la pose que se ve.
func arte_indicador() -> Dictionary:
	return aspecto.arte_indicador()


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
	return aspecto.rect_dibujado()


func _draw() -> void:
	aspecto.dibujar()
