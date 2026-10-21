class_name Hud
extends CanvasLayer
## Arriba, discreto y sin báscula: la agenda (cuántas van y el ícono de Tab), calcetines del nido, fotos de la
## galería y snacks del bolsillo (x/5). Al centro, los carteles épicos "¡TRAVESURA CUMPLIDA!" y
## "¡TRAVESURA SECRETA!" en cola (como la franja de un jefe, en chico). Nada de puntos.
## Va a la derecha de los corazones y las vidas (Medidores, 6 a 136 px), todo en la zona A (y 0–26).

## Carteles que se mostraron (para las pruebas): [título, nombre].
var carteles: Array = []
## Segundos entre la travesura y el cartel: primero se ve el gag, después el cartel.
@export var retraso_cartel := 0.5

var agenda: Agenda
var recompensas: Recompensas:
	set(valor):
		recompensas = valor
		_actualizar_contadores()
## La cola única de anuncios (G5): si está, los carteles esperan su turno y su lugar ahí.
var anuncios: Anuncios
## Piezas ContadorRecurso por clave ("calcetin", "foto", "snack").
var contadores := {}
var _barra: Control
var _mostrando := false
var _golpe_agenda := 0.0
## Segundos que le quedan a la vista de cada uno ("agenda", "calcetin", "foto", "snack").
var _visible := {"agenda": 0.0, "calcetin": 0.0, "foto": 0.0, "snack": 0.0}
## Mientras devuelva true (la pelea con el jefe), el contador de snacks queda fijo. Lo pone el guion del nivel.
var snacks_fijos := Callable()

const ESCENA_CONTADOR := "res://escenas/ui/contador_recurso.tscn"
## Contadores de recursos: [clave, ancho, ícono del kit (vacío: lo dibuja Recogible)].
const CONTADORES := [["calcetin", 52.0, &"hud_calcetin"], ["foto", 52.0, &"hud_foto"], ["snack", 60.0, &""]]
## Todo en la zona A (ZonasTexto.HUD, y 0–26): los paneles van de y 4 a 26, a la derecha de los corazones (6 a 90).
const X0 := 98.0
const Y0 := 4.0
## HUD limpio (decisión del creador, 2026-10-21): la agenda y los contadores NO están siempre; aparecen solo cuando
## cambian, entran deslizando desde arriba, se quedan MOSTRAR s y se van. En la pelea con el jefe, el de snacks queda
## fijo (comer es una decisión de la pelea). Siempre están en la pausa (libreta y panel del bolsillo).
const MOSTRAR := 2.0
const DESLIZAR := 0.2
## Fuera de la pantalla (arriba) cuando no se muestra.
const Y_FUERA := -30.0
const ANCHO_AGENDA := 116.0
## Tamaño del cartel: toda la zona C de ZonasTexto (arriba, y 30–90).
const TAM_CARTEL := Vector2(640, 60)
## Entre 1,5 y 2,5 s (Gemini, 2026-10-20).
const DURACION_CARTEL := 2.2


func _ready() -> void:
	layer = Capas.CAPA_HUD
	process_mode = Node.PROCESS_MODE_ALWAYS
	# La barra se esconde mientras se presenta un jefe (M4: asomaba cortada bajo la franja de la imaginación).
	add_to_group(PresentacionJefe.GRUPO_OCULTAR)
	_barra = Control.new()
	_barra.name = "Barra"
	_barra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_barra.size = ZonasTexto.HUD.size
	_barra.draw.connect(_dibujar_agenda)
	add_child(_barra)
	# Recursos: una pieza ContadorRecurso por cada uno, a la derecha de la agenda.
	var x := X0 + ANCHO_AGENDA + 4.0
	for datos: Array in CONTADORES:
		var contador: ContadorRecurso = (load(ESCENA_CONTADOR) as PackedScene).instantiate()
		contador.name = "Contador " + String(datos[0])
		contador.clave = datos[0]
		contador.ancho = datos[1]
		contador.position = Vector2(x, Y_FUERA)
		contador.dibujar_icono = Recogible.dibujar_icono
		if datos[2] != &"":
			contador.icono = Estilo.icono(datos[2])
		_barra.add_child(contador)
		contadores[datos[0]] = contador
		x += float(datos[1]) + 4.0
	_actualizar_contadores()


func _process(delta: float) -> void:
	var real := delta / maxf(Engine.time_scale, 0.001)
	_golpe_agenda = maxf(0.0, _golpe_agenda - real * 3.0)
	var fijo_snack := snacks_fijos.is_valid() and bool(snacks_fijos.call())
	for clave: String in _visible:
		_visible[clave] = maxf(0.0, float(_visible[clave]) - real)
		if clave == "snack" and fijo_snack:
			_visible[clave] = maxf(float(_visible[clave]), DESLIZAR + 0.01)
		if contadores.has(clave):
			(contadores[clave] as ContadorRecurso).position.y = y_de(clave)
	_barra.queue_redraw()


## Dónde está ahora (y en pantalla) lo que muestra esa clave: entra deslizando, se queda y sale.
func y_de(clave: String) -> float:
	var t := float(_visible.get(clave, 0.0))
	if t <= 0.0:
		return Y_FUERA
	var dentro := minf(t / DESLIZAR, 1.0)
	var entrando := minf((MOSTRAR - t) / DESLIZAR, 1.0) if t > MOSTRAR - DESLIZAR else 1.0
	var k := minf(dentro, entrando)
	return roundf(lerpf(Y_FUERA, Y0, k))


## ¿Se ve ahora? (para las pruebas y las zonas).
func mostrando(clave: String) -> bool:
	return y_de(clave) > Y_FUERA + 0.5


func al_presentar_jefe(presentando: bool) -> void:
	if _barra:
		_barra.visible = not presentando


## Un recurso cambió ("calcetin", "snack", "foto" o "agenda"): muestra el valor nuevo y lo hace saltar.
func golpear(clave: String) -> void:
	if _visible.has(clave):
		_visible[clave] = MOSTRAR
	if clave == "agenda":
		_golpe_agenda = 1.0
		_barra.queue_redraw()
		return
	_actualizar_contadores()
	if contadores.has(clave):
		(contadores[clave] as ContadorRecurso).dar_golpe()


## Lee los valores de Recompensas y los pone en los contadores (sin golpe).
func _actualizar_contadores() -> void:
	if contadores.is_empty():
		return
	var calcetines := recompensas.calcetines if recompensas else 0
	var fotos := recompensas.fotos if recompensas else 0
	var snacks := recompensas.snacks() if recompensas else 0
	(contadores["calcetin"] as ContadorRecurso).fijar(str(calcetines), calcetines > 0, false)
	(contadores["foto"] as ContadorRecurso).fijar(str(fotos), fotos > 0, false)
	(contadores["snack"] as ContadorRecurso).fijar("%d/%d" % [snacks, Felipe.SNACKS_MAX], snacks > 0, false)


## La libreta: "AGENDA 2/8" y la tecla para abrirla, en un pergamino del kit «Decreto real».
func _dibujar_agenda() -> void:
	if agenda == null:
		return
	var g := _golpe_agenda
	var y0 := y_de("agenda")
	if y0 <= Y_FUERA:
		return
	Estilo.panel(_barra, Rect2(X0, y0, ANCHO_AGENDA, Estilo.medida(&"alto_hud")), &"panel")
	_barra.draw_texture(Estilo.icono(&"hud_libreta"), Vector2(X0 + 1, y0 + 1 - roundf(g * 2.0)))
	var texto := tr("UI_AGENDA_CONTADOR") % [agenda.cumplidas(), agenda.total()]
	Estilo.escribir(_barra, Vector2(X0 + 24, y0 + 16 - roundf(g * 2.0)), texto, &"hud", Estilo.color(&"tinta_decreto").lerp(Estilo.color(&"lacre"), g))
	IconosBotones.dibujar(_barra, "agenda", Vector2(X0 + ANCHO_AGENDA - IconosBotones.ancho("agenda", 12.0) - 3, y0 + 5), 12.0)


## Cartel épico: título grande y el nombre de la travesura en una línea. Pasa por la cola única de anuncios (G5): sale
## en la zona C cuando le toca (después del diálogo). Sin cola de anuncios (pruebas sueltas del HUD), sale enseguida.
func cartel(titulo: String, nombre: String, secreta: bool) -> void:
	titulo = tr(titulo)
	nombre = tr(nombre)
	carteles.append([titulo, nombre])
	golpear("agenda")
	var datos := [titulo, nombre, secreta]
	if anuncios:
		anuncios.anunciar("cartel", titulo, TAM_CARTEL, func(rect: Rect2) -> float: return _mostrar_cartel(datos, rect),
			_ocultar_cartel, false, retraso_cartel)
		return
	_mostrando = true
	create_tween().tween_callback(func() -> void:
		_mostrar_cartel(datos, ZonasTexto.cartel(TAM_CARTEL))
		create_tween().tween_callback(func() -> void: _mostrando = false).set_delay(DURACION_CARTEL)).set_delay(retraso_cartel)


func ocupado() -> bool:
	return _mostrando or (anuncios != null and anuncios.ocupado())


var _actual: Cartel


## Muestra el cartel en ese rectángulo de la zona C y devuelve cuánto dura.
func _mostrar_cartel(datos: Array, rect: Rect2) -> float:
	_actual = Cartel.crear(datos[0], datos[1], datos[2], rect)
	add_child(_actual)
	_actual.animar(DURACION_CARTEL)
	return DURACION_CARTEL


func _ocultar_cartel() -> void:
	if is_instance_valid(_actual):
		_actual.ocultar()
