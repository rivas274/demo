class_name Enemigo
extends CharacterBody2D
## Enemigo de piso armado con piezas (patrón «6 enemigos, 1 solo script»): el ratón de cuerda y A.S.P.I. son este mismo
## script con otros datos (DatosEnemigo, un .tres) y otra apariencia. No hereda de nadie: junta piezas que hacen un
## solo trabajo y las conecta con señales.
##   Vida (cuántos zarpazos aguanta) · RecibeGolpes (el zarpazo llega aquí) · HaceDano (lastima a Felipe al tocarlo) ·
##   MovimientoPatrulla (va y viene, persigue) · OyeMaullido · Asustable · SombraContacto · Apariencia (el dibujo) ·
##   ReaccionDerrota (la derrota jugosa, si sus datos traen `derrota`).
## Si la escena ya trae una pieza (puesta en el editor), usa esa; si no, la crea con los números de `datos`.
## Escenas: escenas/entidades/raton.tscn y aspi.tscn. Receta para uno nuevo: siete-vidas/memoria/07-arquitectura.md.

## Empujón de un zarpazo que dolió y de uno que rebotó: velocidad (px/s) y segundos.
const RETROCESO_GOLPE := Vector2(160, 0.3)
const RETROCESO_REBOTE := Vector2(60, 0.15)
## Capa de física de los enemigos (choca con el piso y los muebles, capa 1; con Felipe no).
const CAPA := 4

## Lo vencieron (A.S.P.I. «apagada», el ratón patas arriba).
signal vencido(enemigo: Enemigo)

@export var datos: DatosEnemigo
## Entre qué x patrulla (en el mundo).
@export var limite_izquierdo := -INF
@export var limite_derecho := INF

var vida: Vida
var recibe_golpes: RecibeGolpes
var dano: HaceDano
var patrulla: MovimientoPatrulla
var oido: OyeMaullido
var asustable: Asustable
var sombra: SombraContacto
## El dibujo (Apariencia, o la que pida `datos.apariencia`, como AparienciaAspi).
var apariencia: Node2D
## La derrota jugosa (null si sus datos no la piden).
var derrota: ReaccionDerrota
var _armado := false


## Fábrica: un enemigo listo para agregar al nivel, con sus piezas ya puestas (se pueden ajustar antes de agregarlo).
static func crear(datos_enemigo: DatosEnemigo, izquierda := -INF, derecha := INF) -> Enemigo:
	var enemigo := Enemigo.new()
	enemigo.datos = datos_enemigo
	enemigo.limite_izquierdo = izquierda
	enemigo.limite_derecho = derecha
	enemigo.armar()
	return enemigo


## Fábrica desde una escena (escenas/entidades/raton.tscn, aspi.tscn): la instancia con sus datos y sus piezas.
static func desde_escena(ruta: String, izquierda := -INF, derecha := INF) -> Enemigo:
	var enemigo: Enemigo = load(ruta).instantiate()
	enemigo.limite_izquierdo = izquierda
	enemigo.limite_derecho = derecha
	enemigo.armar()
	return enemigo


func _ready() -> void:
	armar()
	add_to_group(Componentes.ENEMIGOS)
	# Profundidad por rol (sus datos): delante de los muebles; contra Felipe en el piso, según delante_de_felipe.
	if datos:
		var profundidad := Profundidad.poner(self, datos.rol)
		profundidad.delante = datos.delante_de_felipe
		profundidad.aplicar()


## Pone las piezas que falten y las conecta (una sola vez; la fábrica lo llama antes de agregarlo).
func armar() -> void:
	if _armado or datos == null:
		return
	_armado = true
	name = datos.nombre
	# Choca con el piso y los muebles sólidos, pero no con Felipe (el daño se calcula por distancia).
	collision_layer = 0
	set_collision_layer_value(CAPA, true)
	collision_mask = 1
	var forma := CollisionShape2D.new()
	var caja := RectangleShape2D.new()
	caja.size = Vector2(datos.ancho, datos.alto)
	forma.shape = caja
	forma.position = Vector2(0, -datos.alto / 2.0)
	add_child(forma)
	# El orden importa: lo que mira si está aturdida o vencida va antes de moverse, y el dibujo al final.
	vida = _pieza(Vida, func() -> Node: return Vida.new(datos.golpes))
	recibe_golpes = _pieza(RecibeGolpes, func() -> Node: return RecibeGolpes.new())
	recibe_golpes.solo_aturdido = datos.solo_aturdido
	if datos.dano > 0:
		dano = _pieza(HaceDano, func() -> Node:
			var nueva := HaceDano.new()
			nueva.dano = datos.dano
			nueva.medio_ancho = datos.ancho / 2.0 + datos.alcance_dano
			return nueva)
	patrulla = _pieza(MovimientoPatrulla, func() -> Node:
		var nueva := MovimientoPatrulla.new()
		nueva.velocidad_patrulla = datos.velocidad_patrulla
		nueva.velocidad_persecucion = datos.velocidad_persecucion
		nueva.vision = datos.vision
		return nueva)
	patrulla.limite_izquierdo = limite_izquierdo
	patrulla.limite_derecho = limite_derecho
	if datos.oye_maullido:
		oido = _pieza(OyeMaullido, func() -> Node: return OyeMaullido.new())
	if datos.asustable:
		asustable = _pieza(Asustable, func() -> Node: return Asustable.new())
	sombra = _pieza(SombraContacto, func() -> Node: return SombraContacto.new(datos.sombra.x, datos.sombra.y))
	var tipo_apariencia: Script = datos.apariencia if datos.apariencia else Apariencia
	apariencia = _pieza(tipo_apariencia, func() -> Node: return tipo_apariencia.new())
	if datos.derrota:
		derrota = _pieza(ReaccionDerrota, func() -> Node: return ReaccionDerrota.new(datos.derrota))
		if derrota.datos == null:
			derrota.datos = datos.derrota
	# Las piezas no se conocen: el enemigo las conecta.
	vida.murio.connect(_al_vencerlo)
	if derrota:
		vida.murio.connect(derrota.reaccionar)
	recibe_golpes.golpeado.connect(func(felipe: Felipe) -> void: patrulla.retroceder(felipe.mirando, RETROCESO_GOLPE.x, RETROCESO_GOLPE.y))
	recibe_golpes.rebotado.connect(func(felipe: Felipe) -> void: patrulla.retroceder(felipe.mirando, RETROCESO_REBOTE.x, RETROCESO_REBOTE.y))
	recibe_golpes.aturdido.connect(patrulla.detener)
	recibe_golpes.golpeado.connect(func(_felipe: Felipe) -> void: apariencia.queue_redraw())
	recibe_golpes.aturdido.connect(func(_segundos: float) -> void: apariencia.queue_redraw())
	if dano:
		recibe_golpes.aturdido.connect(dano.pausar)
	if asustable:
		asustable.asustado.connect(func(quien: Node2D) -> void: patrulla.huir(quien.global_position.x, asustable.segundos))


## La pieza del tipo pedido: la que ya trae la escena o una nueva hecha con `nueva`.
func _pieza(tipo: Script, nueva: Callable) -> Node:
	var pieza := Componentes.de(self, tipo)
	if pieza == null:
		pieza = nueva.call()
		add_child(pieza)
	return pieza


func _al_vencerlo() -> void:
	patrulla.apagar()
	if dano:
		dano.apagar()
	var nivel := Componentes.nivel(self)
	if nivel and datos.sonido_al_vencer != "":
		nivel.sonar(datos.sonido_al_vencer)
	if nivel and datos.frase_al_vencer != "" and nivel.travesuras:
		nivel.travesuras.decir_felipe(datos.frase_al_vencer)
	vencido.emit(self)


## Lo que ocupa en el mundo (los anuncios no lo tapan): lo que diga su apariencia.
func rect_dibujado() -> Rect2:
	return apariencia.call("rect_dibujado") if apariencia else Rect2(global_position, Vector2.ZERO)
