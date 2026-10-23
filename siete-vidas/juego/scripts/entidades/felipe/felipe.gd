class_name Felipe
extends CharacterBody2D
## Controlador de Felipe: movimiento de plataformas con sensación moderna (margen de salto, salto recordado, altura
## variable, doble salto, zoomies), mañas de gato (maullar, arañar, tirar de un manotazo, comer, frotarse, subir
## escalones) y efectos de caricatura. Máquina de estados con el patrón Estado: un estado por clase en
## scripts/entidades/felipe/estados/ (entrar, fisica, salir); este script lee los controles, mueve y cambia de estado.
## Sus partes (scripts/felipe/): EfectosFelipe, AnimadorFelipe, ManasFelipe, AgachadoFelipe y TreparFelipe.
## Regla de las acciones: el efecto sale en el cuadro de impacto (frame_changed), nunca al apretar el botón.

signal aterrizo(fuerza: float)
## Pide un efecto de sonido (la sala lo reproduce).
signal sonido(nombre: String)
## La pata, la boca o las garras llegaron y el efecto ya salió: para congelar un instante, sacudir o sonar.
## tipo: "zarpazo", "manotazo", "aranar" o "comer".
signal impacto(tipo: String)
## Maulló, en el cuadro de la boca abierta. `boca` es la posición de la boca en el mundo.
signal maullo(boca: Vector2)
## Arañó algo, en el cuadro en que bajan las garras. `critico`: con las garras afiladas del rascador.
signal aranazo(objetivo: Node2D, critico: bool)
## Se comió un snack del bolsillo.
signal snack_comido
signal peso_cambiado(kilos: float)
signal snacks_cambiados(cantidad: int)
## Mantuvo el botón de acción para comer, pero el bolsillo está vacío.
signal sin_snacks
## Se puso el Collar de la Vergüenza (al tercer desmayo del nivel; para la interfaz).
signal collar_cambiado(tiene: bool)
## Escalera: terminó un escalón (contando desde 1) y terminó todos los pedidos.
signal escalon_subido(numero: int)
signal escalera_terminada
## Terminó de frotarse ronroneando contra alguien (Valeria): ese alguien recibe perdonar(felipe, "frotarse").
signal ronroneo_terminado(objetivo: Node2D)

enum Estado { SUELO, AIRE, ZOOMIES, ZARPAZO, COMIENDO, ATERRIZANDO, OCIO, DESMAYADO, ARANANDO, MAULLANDO, SUBIENDO_ESCALON, RONRONEANDO }

## Felipe mide unos 67 px de alto: Valeria (1,65 m) mide 3 Felipes. Ver la guía del personaje.
const ESCALA_SPRITE := 0.72
## Cuadros de la hoja "saltar" para cada fase (los mismos de la ficha de concepto).
## El cuadro 4 viene inclinado en diagonal y se ve raro: no se usa.
const CUADRO_AGACHADO := 1
const CUADRO_SUBIENDO := 2
const CUADRO_ARRIBA := 3
const CUADRO_ATERRIZAJE := 5
const CUADRO_ASENTARSE := 6
## Cuadros de la hoja "caer": un gato cae con las patas delanteras primero.
const CUADRO_CAYENDO := 3
const CUADRO_CONTACTO := 5
const INCLINACION_DOBLE_SALTO := -0.35
## Estirar y aplastar deforman la cabeza junto con el cuerpo: nunca más de ±8 % para que Felipe
## conserve sus proporciones (regla del creador).
const DEFORMACION_MAXIMA := 0.08
## Alto de la caja de colisión de pie y agachado.
## De pie mide 58 px de las orejas a las patas; agachado, unos 33 px.
## Pasa agachado bajo muebles con 30 cm libres (36 px).
const ALTO_DE_PIE := 58.0
const ALTO_AGACHADO := 32.0
## Capa de los muebles que se atraviesan desde abajo (agachado + saltar baja a través de ellos).
const CAPA_ATRAVESABLE := 2
## Animaciones de ocio: nombre -> vueltas del ciclo antes de volver a quieto.
## Todas salen de Felipe A en cuadros de 106 px y se dibujan con ESCALA_SPRITE, como las demás.
const OCIO := {
	"acicalarse": 3,
	"jugar": 3,
	"vueltas": 2,
	## Se sienta (transición «sentarse») y queda «sentado» estas vueltas del bucle.
	"sentarse": 4,
}
## Bola de estambre del ocio "jugar": objeto aparte (la animación es solo Felipe) que rueda frente a él.
const BOLA_ESTAMBRE := preload("res://assets/felipe/estambre-bola.png")
const DISTANCIA_ESTAMBRE := 28.0
## Acciones que, presionadas, cuentan como "estar jugando" (cortan el ocio y reinician la espera).
const ACCIONES := ["mover_izquierda", "mover_derecha", "saltar", "zoomies", "zarpazo", "interactuar", "agacharse", "maullar"]
## Salud: las 9 huellas (las 9 vidas del título SON la salud). Su pieza Vida (nodo hijo «Vida» de felipe.tscn) cuenta
## 18 medias huellas; las reglas (golpes, curar, desmayo, collar) están en SaludFelipe.
const HUELLAS_MAX := SaludFelipe.HUELLAS
const MEDIAS_MAX := SaludFelipe.MEDIAS_MAX
## Segundos sin recibir más daño después de un golpe (parpadea).
const TIEMPO_INVULNERABLE := 1.2
## Segundos desmayado antes de reaparecer.
const TIEMPO_DESMAYO := 1.8
## Peso en kilos: no cambia el dibujo ni el movimiento; se ve solo en la Ficha de Su Majestad (pausa).
const PESO_INICIAL := 8.0
const PESO_POR_COMIDA := 0.3
## Alcance del zarpazo frente a Felipe (horizontal, vertical).
const ALCANCE_ZARPAZO := Vector2(56, 40)
## Distancia (horizontal, vertical) a la que el botón de acción alcanza un objeto.
const ALCANCE := Vector2(48, 40)
## Cuadros de impacto (mirados en cada hoja): ahí sale el efecto, no al apretar el botón (hallazgo B5).
## Zarpazo y manotazo: la pata llega adelante en el cuadro 4; en el 2 suena el silbido.
const CUADRO_IMPACTO_ZARPAZO := 4
const CUADRO_SILBIDO_ZARPAZO := 2
## Comer: la boca llega a la comida en el cuadro 3.
const CUADRO_IMPACTO_COMER := 3
## Arañar: en los cuadros 3 y 5 baja una pata con las uñas afuera (dos arañazos por vez).
const CUADROS_IMPACTO_ARANAR := [3, 5]
## Maullar: la boca se abre del todo en el cuadro 3.
const CUADRO_MAULLIDO := 3
## Boca respecto de los pies (mirando a la derecha), para las ondas del maullido.
const BOCA := Vector2(18, -40)
## Las piezas OyeMaullido de este grupo a menos de RADIO_MAULLIDO px oyen el maullido (Valeria abre la puerta,
## A.S.P.I. gira hacia Felipe).
const GRUPO_OYENTES := "oyen_maullidos"
const RADIO_MAULLIDO := 320.0
## Bolsillo de snacks (decisión del creador, 2026-10-19): 5 como máximo, empieza con 3.
const SNACKS_MAX := 5
const SNACKS_INICIALES := 3
## Mantener el botón de acción este tiempo, sin nada cerca, come un snack del bolsillo.
const TIEMPO_COMER_SNACK := 0.6
## Escalera: segundos por escalón (7 escalones en 1,4 s) y altura del saltito.
const DURACION_ESCALON := 0.2
const SALTITO_ESCALON := 6.0
## Frotarse contra las piernas de un humano: lo que dura el ronroneo (un ciclo de "ronronear", 8 cuadros a 8 fps).
const DURACION_RONRONEO := 1.0

@export_group("Movimiento")
@export var velocidad_caminar := 120.0
@export var velocidad_correr := 190.0
@export var aceleracion := 1200.0
@export var friccion := 1450.0
@export var velocidad_gatear := 55.0
@export var velocidad_trepar := 140.0
@export_group("Salto")
## La subida (gravedad y velocidad_salto) fija la altura, unos 80 px; no se toca al ajustar la caída.
@export var gravedad := 1410.0
## Cae con más peso que sube (1,7 × gravedad): un gato de 8 kilos, no un globo (ajuste del salto, 2026-10-19).
@export var gravedad_cayendo := 2400.0
@export var velocidad_salto := -475.0
@export var velocidad_doble_salto := -420.0
## Tope de la caída: se llega en unos 0,31 s (unos 114 px), igual que antes del ajuste, para que no se sienta un freno.
@export var caida_maxima := 740.0
@export var corte_salto := 0.45
@export var margen_salto := 0.12
@export var salto_recordado := 0.15
@export_group("Zoomies")
@export var velocidad_zoomies := 380.0
@export var duracion_zoomies := 0.18
@export var espera_zoomies := 0.45
@export_group("Habilidades")
## Poderes que se ganan después (biblia): en el nivel 1 están apagados (decisión del creador, 2026-10-19).
## Doble Salto se gana en Neón, Zoomies en Downtown y trepar tela con Afilar Garras (Barrio Viejo).
@export var tiene_doble_salto := false
@export var tiene_zoomies := false
@export var puede_trepar := false
@export_group("Travesuras")
## Segundos que las garras quedan afiladas después del rascador (el siguiente arañazo es CRÍTICO).
@export var duracion_garras := 6.0
@export_group("Ocio")
## Segundos quieto y sin tocar nada antes de ponerse a acicalarse, jugar o dar vueltas.
@export var espera_ocio := 8.0

## Estado actual (su valor de Estado). Asignarlo cambia de estado con entrar y salir (`cambiar_estado`).
var estado: Estado:
	get:
		return _estado.id if _estado else Estado.SUELO
	set(nuevo):
		cambiar_estado(nuevo)
var mirando := 1.0
## El doble salto de este salto todavía no se usó (se recupera al tocar el piso). Requiere tiene_doble_salto.
var doble_salto_disponible := true
## Posturas que conviven con los estados (se puede estar en SUELO y agachado): las manejan AgachadoFelipe y TreparFelipe.
var agachado := false
var trepando := false
## Medias huellas que le quedan (atajo a su pieza Vida: 18 = las 9 huellas llenas).
var medias: int:
	get:
		return vida.actual if vida else MEDIAS_MAX
	set(valor):
		vida.fijar(valor)
## Kilos: solo los muestra la Ficha de Su Majestad (pausa), que escucha `peso_cambiado`.
var peso := PESO_INICIAL:
	set(valor):
		peso = valor
		peso_cambiado.emit(peso)
var tiene_collar := false:
	set(valor):
		tiene_collar = valor
		collar_cambiado.emit(tiene_collar)
## Poder que gana al escapar por el balcón (fin del tutorial).
var tiene_caer_de_pie := false
## Zonas donde puede trepar (cortinas), en coordenadas del mundo. Las pone el nivel.
var zonas_trepables: Array[Rect2] = []
var punto_reaparicion: Vector2
## Arrastre de afuera en px/s (la succión de A.S.P.I.); agachado se aferra con las uñas y no lo mueve.
var empuje := Vector2.ZERO
## Snacks en el bolsillo (se comen manteniendo el botón de acción sin nada cerca).
var snacks := SNACKS_INICIALES
## Segundos de garras afiladas que quedan (rascador).
var garras_afiladas := 0.0
## Último impacto que salió (para las pruebas): {"animacion": String, "cuadro": int}.
var ultimo_impacto := {}
## Segundos desde el último salto y lo que le queda al aterrizaje (los lee el animador).
var tiempo_desde_salto := 99.0
var tiempo_aterrizando := 0.0
## Dónde va el dibujo dentro de Felipe (el ocio lo devuelve ahí).
var posicion_sprite: Vector2
## Sus partes (scripts/felipe/).
var efectos: EfectosFelipe
var animador: AnimadorFelipe
var manas: ManasFelipe
var agachado_felipe: AgachadoFelipe
var trepar: TreparFelipe
## Sus 9 huellas: golpes, curar, desmayos y el Collar de la Vergüenza.
var salud: SaludFelipe

var _estado: EstadoFelipe
var _estados := {}
var _tiempo_fuera_del_suelo := 0.0
var _tiempo_salto_pedido := 99.0
var _espera_zoomies := 0.0
var _velocidad_al_caer := 0.0
var _tiempo_sin_tocar := 0.0
var _parpadeando := false
## Segundos manteniendo el botón de acción sin nada cerca (-1: ya se usó, hay que soltarlo).
var _tiempo_manteniendo := 0.0
var _chispas: Chispas

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var polvo: CPUParticles2D = $Polvo
@onready var cuerpo: CollisionShape2D = $Cuerpo
## Sus 9 huellas (18 medias), con 1,2 s invulnerable después de cada golpe.
@onready var vida: Vida = $Vida


func _ready() -> void:
	sprite.sprite_frames = AnimacionesFelipe.crear()
	sprite.scale = Vector2.ONE * ESCALA_SPRITE
	posicion_sprite = sprite.position
	efectos = EfectosFelipe.new(self)
	animador = AnimadorFelipe.new(self)
	manas = ManasFelipe.new(self)
	agachado_felipe = AgachadoFelipe.new(self)
	trepar = TreparFelipe.new(self)
	salud = SaludFelipe.new(self)
	_crear_estados()
	cuerpo.shape = cuerpo.shape.duplicate()
	# El tiempo invulnerable lo descuenta Felipe al empezar su cuadro (_actualizar_invulnerable): así se congela mientras
	# cruza una puerta o sube la escalera, cuando su física está apagada.
	vida.set_physics_process(false)
	set_collision_mask_value(CAPA_ATRAVESABLE, true)
	# Felipe va en su propia capa (3): los enemigos no chocan con él; el daño se calcula por distancia.
	collision_layer = 0
	set_collision_layer_value(3, true)
	sprite.animation_finished.connect(func() -> void: _estado.animacion_terminada())
	sprite.frame_changed.connect(manas.al_cambiar_cuadro)
	_chispas = Chispas.new()
	_chispas.name = "Chispas"
	add_child(_chispas)
	add_to_group("felipe")
	punto_reaparicion = global_position
	sprite.play("quieto")


func _crear_estados() -> void:
	var libre_suelo := EstadoLibre.new(self, Estado.SUELO)
	for nuevo: EstadoFelipe in [
		libre_suelo, EstadoLibre.new(self, Estado.AIRE), EstadoAterrizando.new(self, Estado.ATERRIZANDO),
		EstadoZoomies.new(self, Estado.ZOOMIES), EstadoAccion.new(self, Estado.ZARPAZO, "zarpazo"),
		EstadoAccion.new(self, Estado.COMIENDO, "comer"), EstadoAccion.new(self, Estado.ARANANDO, "aranar"),
		EstadoAccion.new(self, Estado.MAULLANDO, "maullar"), EstadoOcio.new(self, Estado.OCIO),
		EstadoDesmayado.new(self, Estado.DESMAYADO), EstadoEscalera.new(self, Estado.SUBIENDO_ESCALON),
		EstadoRonroneando.new(self, Estado.RONRONEANDO),
	]:
		_estados[nuevo.id] = nuevo
	_estado = libre_suelo


## Sale del estado actual y entra al nuevo (con `datos` para su entrar). Volver a entrar al mismo también vale.
func cambiar_estado(nuevo: Estado, datos := {}) -> void:
	if _estado:
		_estado.salir()
	_estado = _estados[nuevo]
	_estado.entrar(datos)


func _physics_process(delta: float) -> void:
	var direccion := Input.get_axis("mover_izquierda", "mover_derecha")
	_tiempo_salto_pedido += delta
	tiempo_desde_salto += delta
	_espera_zoomies = maxf(0.0, _espera_zoomies - delta)
	if Input.is_action_just_pressed("saltar"):
		_tiempo_salto_pedido = 0.0
	agachado_felipe.actualizar_bajada(delta)
	_actualizar_invulnerable(delta)
	garras_afiladas = maxf(0.0, garras_afiladas - delta)
	_chispas.restante = garras_afiladas
	_chispas.lado = mirando
	if estado == Estado.SUBIENDO_ESCALON:
		# Escalón por escalón: no lo mueve la física.
		_estado.fisica(delta, direccion)
		return
	if trepar.actualizar(direccion):
		return
	_actualizar_ocio(delta)
	agachado_felipe.actualizar()
	_estado.fisica(delta, direccion)

	var estaba_en_suelo := is_on_floor()
	_velocidad_al_caer = velocity.y
	var arrastre := Vector2.ZERO if agachado or estado == Estado.DESMAYADO else empuje
	velocity += arrastre
	move_and_slide()
	velocity -= arrastre
	_actualizar_suelo(estaba_en_suelo, delta)
	animador.actualizar(direccion)
	efectos.actualizar_estela(delta)


# --- Movimiento (lo usan los estados) ------------------------------------------------------------------------------

func mover(direccion: float, delta: float) -> void:
	var maxima := velocidad_correr if Input.is_action_pressed("zoomies") else velocidad_caminar
	if agachado:
		maxima = velocidad_gatear
	if direccion != 0.0:
		mirando = signf(direccion)
		velocity.x = move_toward(velocity.x, direccion * maxima, aceleracion * delta)
	else:
		frenar(delta)


func frenar(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, friccion * delta)


func aplicar_gravedad(delta: float) -> void:
	if is_on_floor():
		return
	var g := gravedad_cayendo if velocity.y > 0.0 else gravedad
	velocity.y = minf(velocity.y + g * delta, caida_maxima)
	# Altura variable: soltar el botón corta la subida.
	if velocity.y < 0.0 and Input.is_action_just_released("saltar"):
		velocity.y *= corte_salto


func intentar_saltar() -> void:
	if _tiempo_salto_pedido > salto_recordado:
		return
	if agachado:
		_tiempo_salto_pedido = 99.0
		if agachado_felipe.sobre_mueble_atravesable():
			agachado_felipe.bajar_por_mueble()
			return
		if not agachado_felipe.cabe_de_pie():
			return
		agachado_felipe.poner(false)
	if is_on_floor() or _tiempo_fuera_del_suelo < margen_salto:
		saltar(velocidad_salto)
		efectos.soltar_polvo(10)
		# Despegue: se ve agachado un instante y sale estirado (sin retrasar el salto).
		efectos.estirar(Vector2(0.94, 1.06), 0.2)
	elif tiene_doble_salto and doble_salto_disponible:
		doble_salto_disponible = false
		saltar(velocidad_doble_salto)
		efectos.soltar_polvo(8)
		efectos.inclinar(INCLINACION_DOBLE_SALTO, 0.28)


func saltar(fuerza: float) -> void:
	sonido.emit("salto")
	velocity.y = fuerza
	tiempo_desde_salto = 0.0
	sprite.rotation = 0.0
	_tiempo_salto_pedido = 99.0
	_tiempo_fuera_del_suelo = 99.0
	cambiar_estado(Estado.AIRE)


## Las acciones de los controles (zoomies, zarpazo, maullar, usar lo cercano o mantener para comer un snack).
func intentar_acciones(direccion: float, delta: float) -> void:
	if agachado:
		_tiempo_manteniendo = 0.0
		return
	if tiene_zoomies and Input.is_action_just_pressed("zoomies") and _espera_zoomies == 0.0:
		_espera_zoomies = espera_zoomies
		cambiar_estado(Estado.ZOOMIES, {"direccion": direccion})
	elif Input.is_action_just_pressed("zarpazo"):
		# El golpe sale cuando la pata llega (cuadro de impacto), no al apretar.
		manas.preparar_zarpazo()
		cambiar_estado(Estado.ZARPAZO)
	elif Input.is_action_just_pressed("maullar") and is_on_floor():
		cambiar_estado(Estado.MAULLANDO)
	elif Input.is_action_pressed("interactuar") and is_on_floor():
		if Input.is_action_just_pressed("interactuar"):
			_tiempo_manteniendo = 0.0
			var objeto := objeto_cercano()
			if objeto:
				_tiempo_manteniendo = -1.0
				objeto.call("interactuar", self)
				return
		_mantener_para_comer(delta)
	else:
		_tiempo_manteniendo = 0.0


func _actualizar_suelo(estaba_en_suelo: bool, delta: float) -> void:
	if is_on_floor():
		_tiempo_fuera_del_suelo = 0.0
		doble_salto_disponible = true
		if not estaba_en_suelo:
			_aterrizar()
	else:
		_tiempo_fuera_del_suelo += delta
		if estado in [Estado.SUELO, Estado.ATERRIZANDO]:
			cambiar_estado(Estado.AIRE)


## Un gato aterriza primero con las patas delanteras: llega inclinado con la nariz hacia abajo, se endereza sobre ellas
## y después se aplasta (EfectosFelipe).
func _aterrizar() -> void:
	var fuerza := clampf(_velocidad_al_caer / caida_maxima, 0.0, 1.0)
	aterrizo.emit(fuerza)
	if estado == Estado.AIRE:
		cambiar_estado(Estado.ATERRIZANDO)
	efectos.aterrizar(fuerza)


## Ocio: tras unos segundos quieto y sin tocar nada, elige al azar acicalarse, jugar con estambre o dar vueltas. Cualquier
## acción lo corta y vuelve a contar desde cero (EstadoOcio).
func _actualizar_ocio(delta: float) -> void:
	var tocando := ACCIONES.any(func(accion: String) -> bool: return Input.is_action_pressed(accion))
	if estado == Estado.OCIO:
		(_estado as EstadoOcio).seguir(delta, tocando)
		return
	if tocando or estado != Estado.SUELO or agachado or not is_on_floor() or absf(velocity.x) > 1.0:
		_tiempo_sin_tocar = 0.0
		return
	_tiempo_sin_tocar += delta
	if _tiempo_sin_tocar >= espera_ocio:
		_empezar_ocio(OCIO.keys().pick_random())


func _empezar_ocio(nombre: String) -> void:
	cambiar_estado(Estado.OCIO, {"nombre": nombre})


## La espera del ocio vuelve a contar desde cero (al terminar uno).
func reiniciar_espera_ocio() -> void:
	_tiempo_sin_tocar = 0.0


# --- Mañas y acciones que piden otros (objetos, el nivel, Valeria) -------------------------------------------------

## Mantener el botón de acción sin nada cerca come un snack del bolsillo (Felipe queda quieto: en la pelea es un riesgo
## que se elige, como curarse en Hollow Knight). Sin snacks, avisa con sin_snacks.
func _mantener_para_comer(delta: float) -> void:
	if _tiempo_manteniendo < 0.0:
		return
	if objeto_cercano():
		_tiempo_manteniendo = 0.0
		return
	_tiempo_manteniendo += delta
	if _tiempo_manteniendo >= TIEMPO_COMER_SNACK:
		_tiempo_manteniendo = -1.0
		if not comer_snack():
			sin_snacks.emit()


## Cuánto lleva manteniendo el botón para comer un snack, de 0 a 1 (para el Indicador).
func progreso_comer_snack() -> float:
	if _tiempo_manteniendo <= 0.0 or estado != Estado.SUELO:
		return 0.0
	return clampf(_tiempo_manteniendo / TIEMPO_COMER_SNACK, 0.0, 1.0)


## El objeto interactuable más cercano al alcance, o null si no hay ninguno (ManasFelipe.objeto_cercano).
func objeto_cercano() -> Node2D:
	return manas.objeto_cercano()


## Comer la comida del mundo: cura un corazón y suma peso cuando la boca llega (cuadro de impacto).
## Al llegar se le llama al_comido() a la comida, para que desaparezca.
func comer(alimento: Node2D = null) -> void:
	_empezar_a_comer(alimento, false)


## Come un snack del bolsillo (cura y engorda igual que la comida). Devuelve false si no quedan.
func comer_snack() -> bool:
	if snacks <= 0:
		return false
	_empezar_a_comer(null, true)
	return true


func _empezar_a_comer(alimento: Node2D, del_bolsillo: bool) -> void:
	manas.alimento = alimento
	manas.comiendo_snack = del_bolsillo
	cambiar_estado(Estado.COMIENDO)


## Deja el bolsillo con `hasta` snacks como mínimo (sin pasar de SNACKS_MAX): el plato de comida suma 1, un punto de
## descanso rellena hasta 3 (decisión del creador, 2026-10-20). Devuelve cuántos sumó.
func recargar_snacks(hasta: int) -> int:
	var nuevos := clampi(hasta, snacks, SNACKS_MAX)
	var sumados := nuevos - snacks
	if sumados > 0:
		snacks = nuevos
		snacks_cambiados.emit(snacks)
	return sumados


## Guarda un snack en el bolsillo. Devuelve false si ya tiene 5 (el bolsillo está lleno).
func guardar_snack() -> bool:
	if snacks >= SNACKS_MAX:
		return false
	snacks += 1
	snacks_cambiados.emit(snacks)
	return true


## Tirar algo de un manotazo (el vaso de la mesa, la caja de la mudanza): usa la animación del zarpazo y `al_impacto`
## se llama cuando la pata llega (cuadro de impacto), no al apretar.
func dar_manotazo(al_impacto := Callable()) -> void:
	manas.es_manotazo = true
	manas.al_impacto = al_impacto
	cambiar_estado(Estado.ZARPAZO)


## Araña algo (sofá, rascador, puerta entornada) de pie en dos patas. En cada cuadro de impacto se le llama
## al_aranar(felipe) al objetivo, que devuelve si el arañazo fue crítico.
func aranar(objetivo: Node2D) -> void:
	if not is_on_floor():
		return
	manas.objetivo = objetivo
	if objetivo:
		var punto: Vector2 = objetivo.call("punto_para", global_position) if objetivo.has_method("punto_para") else objetivo.global_position
		if absf(punto.x - global_position.x) > 2.0:
			mirando = signf(punto.x - global_position.x)
	sprite.flip_h = mirando < 0.0
	cambiar_estado(Estado.ARANANDO)


## Se frota ronroneando contra las piernas de alguien (Valeria enojada): un ciclo de "ronronear" y, al terminar,
## objetivo.perdonar(felipe, "frotarse"). Es el botón de acción junto a ella ("Encantar").
func frotarse(objetivo: Node2D) -> void:
	if not is_on_floor() or estado == Estado.DESMAYADO:
		return
	cambiar_estado(Estado.RONRONEANDO, {"objetivo": objetivo})


## Rascador: deja las garras afiladas unos segundos (chispitas en las patas).
func afilar_garras() -> void:
	garras_afiladas = duracion_garras
	_chispas.duracion = duracion_garras


## Gasta el filo, si lo hay: el arañazo es CRÍTICO. Devuelve si estaban afiladas.
func gastar_garras() -> bool:
	if garras_afiladas <= 0.0:
		return false
	garras_afiladas = 0.0
	return true


## Se lame la pata como si nada (al final de la pelea con A.S.P.I.) o se sienta a mirar (la baranda del balcón).
func acicalarse(ocio := "acicalarse") -> void:
	if is_on_floor() and estado == Estado.SUELO:
		_empezar_ocio(ocio)


## Escalera: sube (o baja) un escalón hasta `destino` (los pies, en el mundo) con un saltito (EstadoEscalera).
func subir_escalon(destino: Vector2, duracion := DURACION_ESCALON) -> void:
	var peldanos: Array[Vector2] = [destino]
	subir_escalera(peldanos, duracion)


## Sube escalón por escalón por la lista de peldaños (posiciones de los pies). Al terminar emite escalera_terminada.
func subir_escalera(peldanos: Array[Vector2], duracion := DURACION_ESCALON) -> void:
	if peldanos.is_empty() or estado == Estado.DESMAYADO:
		return
	cambiar_estado(Estado.SUBIENDO_ESCALON, {"peldanos": peldanos, "duracion": duracion})


## ¿Está subiendo o bajando escalones?
func en_escalera() -> bool:
	return estado == Estado.SUBIENDO_ESCALON


func terminar_escalera() -> void:
	velocity = Vector2.ZERO
	cambiar_estado(Estado.SUELO)
	sprite.play("quieto")
	escalera_terminada.emit()


# --- Daño ----------------------------------------------------------------------------------------------------------

## Daño (lo llaman las piezas HaceDano, en medias huellas): quita de su Vida lo que diga la opción «Golpes», empuja
## lejos de quien golpea y deja un rato invulnerable (parpadea), aunque no quite nada. Sin huellas, se desmaya
## (EstadoDesmayado) y vuelve al último descanso sin perder nada.
func recibir_dano(cantidad: int, desde_x: float) -> void:
	if not vida.puede_recibir() or estado == Estado.DESMAYADO:
		return
	if estado == Estado.SUBIENDO_ESCALON:
		terminar_escalera()
	if estado == Estado.OCIO:
		cambiar_estado(Estado.SUELO if is_on_floor() else Estado.AIRE)
	if agachado:
		agachado_felipe.poner(false)
	vida.danar(SaludFelipe.medias_del_golpe(cantidad))
	trepando = false
	sonido.emit("golpe")
	if vida.muerto:
		cambiar_estado(Estado.DESMAYADO)
		return
	var lado := signf(global_position.x - desde_x)
	velocity = Vector2((lado if lado != 0.0 else -mirando) * 220.0, -220.0)
	cambiar_estado(Estado.AIRE)


func _actualizar_invulnerable(delta: float) -> void:
	vida.avanzar(delta)
	var resta := vida.restante_invulnerable
	if resta <= 0.0:
		if _parpadeando:
			_parpadeando = false
			sprite.modulate.a = 1.0
		return
	_parpadeando = true
	sprite.modulate.a = 0.35 if int(resta * 12.0) % 2 == 0 else 1.0
