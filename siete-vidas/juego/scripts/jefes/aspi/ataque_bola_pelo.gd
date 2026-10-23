class_name AtaqueBolaPelo
extends ConductaJefe
## Bolas de pelo en arco (furia), en 4 tiempos (v4): **preparación** (tose: vibra, se hincha y aparece la marca roja
## donde va a caer, sin «¡COF!»), **peligro** (la bola vuela en arco hacia la marca; llega a la repisa y al escritorio,
## así que acampar arriba no salva; lastima al tocar, pieza HaceDano), **impacto** (cae: polvo de pelusa y un temblor
## chico) y **recuperación** (queda mareada, quieta e inofensiva: ReaccionesAspi.marear).

@export var espera := 2.2
@export var aviso := 0.5
@export var gravedad := 600.0
@export var vuelo := 0.9
@export var radio := 22.0

## Dónde va a caer la bola (los pies de Felipe al empezar la tos): lo marca el piso (DibujoBatallaAspi).
var objetivo := Vector2.ZERO
var bolas: Array[Node2D] = []
## Segundos que faltan para la próxima tos.
var reloj_espera := 0.0
var _reloj := 0.0


func nombre() -> String:
	return "bola"


func al_cambiar_fase(_fase: int) -> void:
	reloj_espera = espera


## En furia, la tos cuenta siempre (también si Felipe acampa arriba): la bola en arco es justo lo que llega al escritorio
## y a la repisa (M8 de la revisión 3). Solo tose si no hay manchas que limpiar.
func intentar(delta: float) -> bool:
	var b := pelea as BatallaAspi
	reloj_espera -= delta
	if reloj_espera > 0.0 or not b.manchas.is_empty():
		return false
	b.empezar_ataque(self)
	_reloj = 0.0
	# Apunta adonde está Felipe AHORA (a sus pies): ahí se marca el piso y ahí cae, aunque se mueva (es justo).
	objetivo = b.felipe.global_position
	b.jefe.patrulla.quieta = true
	b.jefe.patrulla.destino = INF
	b.apariencia.vibrando = true
	b.sonar_evento("atragantar")
	return true


func actualizar(delta: float) -> bool:
	var b := pelea as BatallaAspi
	_reloj += delta
	if _reloj < aviso:
		# Se hincha para toser (tope ±8 %).
		b.apariencia.inflado = b.reacciones.datos.inflado * _reloj / aviso
		return true
	b.apariencia.inflado = 0.0
	b.terminar_ataque()
	_escupir()
	b.reacciones.marear()
	reloj_espera = espera
	return false


## Bola de pelo en arco hacia donde está Felipe.
func _escupir() -> void:
	var b := pelea as BatallaAspi
	var bola := Node2D.new()
	bola.name = "Bola de pelo"
	Capas.usar(bola, Capas.EFECTOS)
	var desde := b.jefe.global_position + Vector2(0, -30)
	var hasta := objetivo + Vector2(0, -20)
	var velocidad := Vector2((hasta.x - desde.x) / vuelo, (hasta.y - desde.y) / vuelo - 0.5 * gravedad * vuelo)
	bola.set_meta("velocidad", velocidad)
	bola.global_position = desde
	bola.draw.connect(b.dibujo.bola.bind(bola))
	# Se ve también en el apagón.
	bola.material = b.sin_sombrear
	# Lastima al tocar a Felipe (HaceDano, circular); la revisa mover() a mano para mirar antes que el piso.
	var dano := HaceDano.new()
	dano.radio = radio
	dano.desfase_felipe = Vector2(0, -24)
	dano.set_physics_process(false)
	bola.add_child(dano)
	b.add_child(bola)
	bolas.append(bola)
	b.nivel.sonar("caja")


## Cada cuadro, pase lo que pase: las bolas vuelan; se van al tocar a Felipe, el piso o fuera de la arena.
func mover(delta: float) -> void:
	var b := pelea as BatallaAspi
	for bola: Node2D in bolas.duplicate():
		var velocidad: Vector2 = bola.get_meta("velocidad")
		velocidad.y += gravedad * delta
		bola.set_meta("velocidad", velocidad)
		bola.global_position += velocidad * delta
		bola.rotation += velocidad.x * delta * 0.05
		bola.queue_redraw()
		if (Componentes.de(bola, HaceDano) as HaceDano).revisar():
			quitar(bola)
		elif bola.global_position.y > b.nivel.datos.suelo - 6.0:
			# Impacto en el piso: polvo de pelusa y un temblor chico.
			b.soltar_polvo(Vector2(bola.global_position.x, b.nivel.datos.suelo - 4.0))
			b.nivel.travesuras.jugo.temblar(1, 0.1)
			quitar(bola)
		elif not b.arena.grow(20).has_point(bola.global_position) or b.fase == PeleaJefe.Fase.FIN:
			quitar(bola)


func quitar(bola: Node2D) -> void:
	bolas.erase(bola)
	bola.queue_free()


func quitar_todas() -> void:
	for bola in bolas.duplicate():
		quitar(bola)
