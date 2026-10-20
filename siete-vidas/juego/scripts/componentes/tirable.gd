class_name Tirable
extends Node2D
## Pieza para lo que Felipe tira de un manotazo (maña «Tirar», pilar 2: es llave y travesura). La llevan el vaso, la taza
## de café, las macetas, las llaves y la caja de arriba de la mudanza. Responde al botón de acción («Liberar»): Felipe da
## el manotazo y, cuando la pata llega (cuadro de impacto), la pieza emite `empujado`. Si `cae` es true, además hace caer
## a su padre: sale hacia donde mira Felipe, gira, llega al piso, suena y, si `aturde`, aturde a lo que tenga debajo (lo
## que lleve RecibeGolpes). Si `cae` es false (la caja de la mudanza), quien la lleva anima la caída por su cuenta.
## Una maña nueva que tire cosas (un coletazo) funciona con todo lo que lleve esta pieza: basta llamar `empujar(felipe)`.

## La pata llegó: empieza a caer.
signal empujado(felipe: Felipe)
## Se rompió en el piso (en la pelea deja una mancha que A.S.P.I. va a limpiar).
signal caido(posicion: Vector2)
## Se cayó sin romperse (el soplido de A.S.P.I.): no deja mancha.
signal tirado(objeto: Node2D)

## Segundos que queda aturdido lo que recibe el golpe, y a qué distancia horizontal.
const ATURDIR := 3.0
const RADIO_IMPACTO := 44.0

## Imagen de quien la lleva (para el contorno del Indicador y el rectángulo de las reglas).
@export var arte := "vaso"
## Verbo de Felipe en la burbuja del Indicador.
@export var verbo_indicador := "Liberar"
## Si la pieza hace caer a su padre (false: la caída la anima la entidad).
@export var cae := true
## Si se ofrece sola al botón de acción (false: la entidad decide cuándo y llama a `empujar`).
@export var ofrecer := true
## Al caer, aturde a lo que tenga debajo (la taza y la maceta sí; el vaso no: se rompe y da su logro).
@export var aturde := true
## Logro al caer ("" para ninguno) y sonido del nivel al romperse.
@export var logro := ""
@export var sonido := "vidrio"
## Cuánto se hunde el dibujo bajo la posición (la línea de atrás del mueble) hasta el medio de la cara de arriba que se
## ve en el arte (lección 29). Negativo: sube (la repisa dibujada). La posición (alcance, caída) no cambia.
@export var hundido := 0.0
## Línea del piso (y en el mundo) donde termina la caída.
var piso := 0.0

var roto := false
var cayendo := false
var _velocidad := Vector2.ZERO
var _inicio := Vector2.ZERO
var _sin_romper := false


func _init() -> void:
	name = "Tirable"


## Toma lo que dicen los datos del objeto (imagen, verbo, si aturde, logro y sonido).
func configurar(datos: DatosObjeto) -> void:
	arte = datos.tipo
	verbo_indicador = datos.verbo
	aturde = datos.aturde
	logro = datos.logro
	sonido = datos.sonido


func _ready() -> void:
	_inicio = _cuerpo().position
	if ofrecer:
		add_to_group(Componentes.INTERACTUABLES)


func _cuerpo() -> Node2D:
	return get_parent() as Node2D


## Felipe da el manotazo; sale volando cuando la pata llega (cuadro de impacto, hallazgo B5).
func interactuar(felipe: Felipe) -> void:
	felipe.dar_manotazo(empujar.bind(felipe))


## La pata lo toca: avisa y, si cae solo, sale hacia donde mira Felipe.
func empujar(felipe: Felipe) -> void:
	if cayendo or roto:
		return
	empujado.emit(felipe)
	if not cae:
		return
	remove_from_group(Componentes.INTERACTUABLES)
	_velocidad = Vector2(felipe.mirando * 90.0, -90.0)
	_empezar_caida()


## Un soplido lo tira sin romperlo: cae al piso y desaparece hasta que lo repongan.
func caer_sin_romper(hacia := 1.0) -> void:
	if cayendo or roto:
		return
	remove_from_group(Componentes.INTERACTUABLES)
	_velocidad = Vector2(hacia * 120.0, -140.0)
	_empezar_caida()
	_sin_romper = true


func _empezar_caida() -> void:
	cayendo = true
	_cuerpo().position.y += hundido
	_cuerpo().queue_redraw()


## Vuelve a su lugar, entero (las macetas de la pelea, de a una).
func reponer() -> void:
	var cuerpo := _cuerpo()
	cuerpo.position = _inicio
	cuerpo.rotation = 0.0
	roto = false
	cayendo = false
	cuerpo.visible = true
	if ofrecer and not is_in_group(Componentes.INTERACTUABLES):
		add_to_group(Componentes.INTERACTUABLES)
	cuerpo.queue_redraw()


func verbo(_felipe: Felipe) -> String:
	return verbo_indicador


## Rectángulo del dibujo (para medir el lado menor en las pruebas y el contorno).
func rect_dibujo() -> Rect2:
	var t := ArteNivel.textura(arte)
	var tam := t.get_size() if t else Vector2(24, 24)
	return Rect2(global_position + Vector2(-tam.x / 2.0, -tam.y), tam)


## Para el contorno del Indicador: la imagen y dónde se dibuja.
func arte_indicador() -> Dictionary:
	return ArteNivel.arte_en(_cuerpo(), arte, 0.0, hundido)


func _physics_process(delta: float) -> void:
	if not cayendo:
		return
	var cuerpo := _cuerpo()
	_velocidad.y += 900.0 * delta
	cuerpo.position += _velocidad * delta
	cuerpo.rotation += _velocidad.x * 0.04 * delta
	if cuerpo.position.y >= piso:
		cuerpo.position.y = piso
		cuerpo.rotation = 0.0
		cayendo = false
		roto = true
		cuerpo.queue_redraw()
		_al_caer()


func _al_caer() -> void:
	var nivel := Componentes.nivel(self)
	if _sin_romper:
		_sin_romper = false
		_cuerpo().visible = false
		tirado.emit(_cuerpo())
		if nivel:
			nivel.sonar("caja")
		return
	caido.emit(global_position)
	if nivel:
		nivel.sonar(sonido)
		if logro != "":
			nivel.desbloquear_logro(logro)
	if not aturde:
		return
	for enemigo: Node in get_tree().get_nodes_in_group(Componentes.ENEMIGOS):
		var golpes := Componentes.de(enemigo, RecibeGolpes) as RecibeGolpes
		var donde := (enemigo as Node2D).global_position
		if golpes and absf(donde.x - global_position.x) < RADIO_IMPACTO and absf(donde.y - global_position.y) < 20.0:
			golpes.aturdir(ATURDIR)
