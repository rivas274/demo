class_name PelusaAspi
extends Node
## Lo que A.S.P.I. devuelve al piso (pieza de BatallaAspi; revisiones del 2026-10-23): al apagarse o al vaciar el
## depósito se **sobrecarga** (0,6 s: vibra, se atraganta, humo y chispas) y recién ahí se le abre la tapa y **escupe
## con fuerza** una montaña de pelusa («¡BLORP!», nube, sacudida). La montaña (MontanaPelusa) se esparce con el
## manotazo y cada mota es una mancha. Lleva la cuenta de la pelusa en camino (la suciedad nunca se pierde).

## Segundos de la sobrecarga antes del «¡BLORP!» y distancia a la que cae la montaña.
const SOBRECARGA := 0.6
const DISTANCIA := 64.0

var b: BatallaAspi
var montanas: Array[MontanaPelusa] = []
## Motas que ya salieron del depósito pero todavía no son montaña (durante la sobrecarga).
var en_camino := 0
## Motas que va a escupir al apagarse, mientras espera a que se vaya el cartel de fase (v5): ya cuentan.
var prometidas := 0
## Cuándo escupió la última vez (s): mientras se ve el «¡BLORP!», no hay otro rótulo sobre ella.
var ultimo := -10.0
var _humo: CPUParticles2D


func _init(de: BatallaAspi) -> void:
	name = "Pelusa de A.S.P.I."
	b = de


func _ready() -> void:
	_humo = Particulas.polvo(18, 0.9, Vector2(0, -30), Vector2(10, 40), Vector2(2, 4), Color(0.55, 0.55, 0.58, 0.9), 40.0, 0.2)
	_humo.name = "Humo"
	_humo.material = b.sin_sombrear
	Profundidad.poner(_humo, Capas.Rol.EFECTO)
	add_child(_humo)


## Suciedad que guardan las montañas (sin esparcir o con motas volando) y la que está saliendo.
func pendientes() -> int:
	var total := en_camino + prometidas
	for montana in montanas:
		if is_instance_valid(montana):
			total += montana.pendientes()
	return total


## Sobrecarga (0,6 s) y escupe `motas` como montaña. `al_salir` corre cuando ya escupió (para cerrar la tapa, etc.).
func escupir(motas: int) -> void:
	if motas <= 0:
		return
	en_camino += motas
	var apariencia := b.apariencia
	apariencia.vibrando = true
	b.sonar_evento("atragantar")
	_humo.global_position = b.jefe.global_position + Vector2(0, -30)
	_humo.restart()
	_humo.emitting = true
	b.chispas(b.jefe.global_position + Vector2(0, -26), 10)
	var espera := b.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	espera.tween_interval(SOBRECARGA)
	espera.tween_callback(_soltar.bind(motas))


func _soltar(motas: int) -> void:
	en_camino = maxi(0, en_camino - motas)
	ultimo = Time.get_ticks_msec() / 1000.0
	if not is_instance_valid(b.jefe):
		return
	b.apariencia.vibrando = false
	var nivel := b.nivel
	var montana := MontanaPelusa.crear(motas, nivel.datos.suelo)
	montanas.append(montana)
	montana.mota_en_piso.connect(func(mota: PiezaSuelta) -> void: b.agregar_mancha(mota.global_position, "nodo", mota))
	montana.tree_exiting.connect(func() -> void: montanas.erase(montana))
	nivel.add_child(montana)
	var x := b.jefe.global_position.x
	var hacia := 1.0 if x < b.arena.get_center().x else -1.0
	var destino := clampf(x + hacia * DISTANCIA, b.jefe.patrulla.limite_izquierdo, b.jefe.patrulla.limite_derecho)
	# Sale con fuerza: más alto y con más sacudida que un simple «se le cayó».
	montana.escupir(b.jefe.global_position + Vector2(0, -BatallaAspi.ALTO_ARRIBA), destino, 70.0)
	b.apariencia.abrir_tapa()
	var tapa := b.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	tapa.tween_interval(0.6)
	tapa.tween_callback(func() -> void:
		if not b.llena:
			b.apariencia.cerrar_tapa())
	b.soltar_polvo(b.jefe.global_position + Vector2(0, -24))
	b.presentacion.destello(0.3)
	nivel.travesuras.jugo.palabra_en_mundo("PALABRA_BLORP", b.jefe.global_position + Vector2(0, -66), Color(0.86, 0.84, 0.8), 24)
	nivel.travesuras.jugo.sacudir(0.2, 0.8)
	b.sonar_evento("blorp")
	# Felipe lo comenta (la primera vez con su frase de siempre).
	if nivel.ya_dijo("devolucion"):
		nivel.travesuras.decir_felipe("devolucion_otra")
	else:
		nivel.decir("devolucion")
