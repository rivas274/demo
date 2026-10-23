class_name MontanaPelusa
extends Node2D
## La montaña de pelusa que escupe A.S.P.I. al vaciar el depósito (al terminar cada fase o si nadie la apagó a tiempo):
## todo lo que limpió vuelve al piso. Sale en arco desde su tapa y se apoya con su sombra. Felipe la **esparce** con el
## manotazo de siempre (botón de acción, burbuja «Esparcir»): se deshace en una nube («¡FUP!») y suelta `cantidad` motas
## de pelusa que caen alrededor; cada una avisa con `mota_en_piso` (en la pelea, cada mota es una mancha).
## Arte: `pelusa_montana`, `pelusa_1` y `pelusa_2`, de la misma hoja de las derrotas (`derrotas.png`, Gemini), con
## `herramientas/preparar_arte_nivel.py desorden`. Lado menor ≥ 24 px (R8).

## Llegó al piso: ya se puede esparcir.
signal apoyada
## Una mota de pelusa quedó en el piso.
signal mota_en_piso(mota: PiezaSuelta)

const ARTE := "pelusa_montana"
const MOTAS := ["pelusa_1", "pelusa_2"]
const GRUPO := "montanas_pelusa"
const COLOR_NUBE := Color(0.72, 0.7, 0.68, 0.95)
## Vuelo desde la tapa hasta el piso (segundos) y altura del arco.
const VUELO := 0.45
const ARCO := 46.0

## Cuántas motas suelta al esparcirla (cada una, una mancha).
var cantidad := 2
## Línea del piso (y en el mundo) donde se apoya ella y sus motas.
var piso := 0.0
var en_piso := false
var esparcida := false
## Motas que van volando (cuentan como suciedad en camino).
var motas_en_vuelo := 0


static func crear(motas: int, piso_y: float) -> MontanaPelusa:
	var montana := MontanaPelusa.new()
	montana.name = "Montaña de pelusa"
	montana.cantidad = motas
	montana.piso = piso_y
	return montana


func _ready() -> void:
	add_to_group(GRUPO)
	Profundidad.poner(self, Capas.Rol.OBJETO_JUEGO)


## Sale de `desde` (la tapa de A.S.P.I.) y cae en arco (de `arco` px de alto) hasta `x` sobre el piso.
func escupir(desde: Vector2, x: float, arco := ARCO) -> void:
	global_position = desde
	scale = Vector2(0.4, 0.4)
	var vuelo := create_tween().set_parallel()
	vuelo.tween_property(self, "global_position:x", x, VUELO)
	vuelo.tween_method(func(t: float) -> void:
		global_position.y = lerpf(desde.y, piso, t) - sin(t * PI) * arco, 0.0, 1.0, VUELO)
	vuelo.tween_property(self, "scale", Vector2.ONE, VUELO).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	vuelo.chain().tween_callback(_apoyar)


func _apoyar() -> void:
	global_position = Vector2(roundf(global_position.x), piso)
	scale = Vector2.ONE
	en_piso = true
	add_to_group(Componentes.INTERACTUABLES)
	_nube(14)
	apoyada.emit()
	queue_redraw()


## Suciedad que todavía guarda: las motas sin soltar más las que van volando.
func pendientes() -> int:
	return (0 if esparcida else cantidad) + motas_en_vuelo


func disponible(_felipe: Felipe) -> bool:
	return en_piso and not esparcida


func verbo(_felipe: Felipe) -> String:
	return "VERBO_ESPARCIR"


func interactuar(felipe: Felipe) -> void:
	if disponible(felipe):
		felipe.dar_manotazo(esparcir.bind(felipe.mirando))


## La pata llega: se deshace en una nube y las motas salen volando a los dos lados (más hacia donde mira Felipe).
func esparcir(hacia := 1.0) -> void:
	if esparcida:
		return
	esparcida = true
	remove_from_group(Componentes.INTERACTUABLES)
	_nube(30)
	var nivel := Componentes.nivel(self)
	if nivel:
		nivel.sonar("puf")
		if nivel.travesuras and nivel.travesuras.jugo:
			nivel.travesuras.jugo.palabra_en_mundo("PALABRA_FUP", global_position + Vector2(0, -44), Color(0.92, 0.9, 0.86), 16)
			nivel.travesuras.jugo.sacudir(0.08, 0.4)
			nivel.travesuras.decir_felipe("esparcir")
	for i in cantidad:
		var lado := (1.0 if i % 2 == 0 else -1.0) * (signf(hacia) if hacia != 0.0 else 1.0)
		var mota := PiezaSuelta.crear(MOTAS[i % MOTAS.size()], global_position + Vector2(lado * 8.0, -10.0), Vector2(lado * randf_range(90.0, 150.0) * (1.0 + i * 0.25), randf_range(-210.0, -160.0)), piso)
		mota.vueltas = randf_range(-1.5, 1.5)
		mota.rebote = 0.2
		mota.con_sombra = true
		motas_en_vuelo += 1
		mota.apoyada.connect(_al_apoyarse_mota)
		get_parent().add_child(mota)
	visible = false
	# Se va cuando ya cayeron las motas (las motas no son hijas: quedan en el piso).
	var adios := create_tween()
	adios.tween_interval(3.0)
	adios.tween_callback(queue_free)


func _al_apoyarse_mota(mota: PiezaSuelta) -> void:
	motas_en_vuelo = maxi(0, motas_en_vuelo - 1)
	mota_en_piso.emit(mota)


func _nube(granos: int) -> void:
	var nube := Particulas.polvo(granos, 0.8, Vector2(0, 50), Vector2(30, 90), Vector2(2, 4), COLOR_NUBE, 80.0)
	nube.position = position + Vector2(0, -8)
	Profundidad.poner(nube, Capas.Rol.EFECTO)
	get_parent().add_child(nube)
	nube.restart()
	nube.emitting = true
	nube.finished.connect(nube.queue_free)


func _draw() -> void:
	var arte := ArteNivel.textura(ARTE)
	if arte == null:
		return
	if en_piso:
		ArteNivel.sombra(self, Vector2(0, 1), arte.get_width() * 0.9 + 2.0, 0.45)
	ArteNivel.dibujar(self, ARTE, 0.0, 0.0)


func _process(_delta: float) -> void:
	if not en_piso:
		queue_redraw()


## Para el contorno del Indicador y el lado menor (R8).
func arte_indicador() -> Dictionary:
	return ArteNivel.arte_en(self, ARTE, 0.0, 0.0)


func rect_dibujo() -> Rect2:
	var arte := ArteNivel.textura(ARTE)
	var tam := arte.get_size() if arte else Vector2(24, 24)
	return Rect2(global_position + Vector2(-tam.x / 2.0, -tam.y), tam)
