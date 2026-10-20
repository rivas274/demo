class_name Hud
extends CanvasLayer
## Arriba, discreto y sin báscula: la agenda (cuántas van y el ícono de Tab), calcetines del nido, fotos de la
## galería y snacks del bolsillo (x/5). Al centro, los carteles épicos "¡TRAVESURA CUMPLIDA!" y
## "¡TRAVESURA SECRETA!" en cola (como la franja de un jefe, en chico). Nada de puntos.
## Va a la derecha de los corazones y las vidas (Medidores, 6 a 98 px).

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

const ESCENA_CONTADOR := "res://escenas/ui/contador_recurso.tscn"
## Contadores de recursos: [clave, ancho, ícono del kit (vacío: lo dibuja Recogible)].
const CONTADORES := [["calcetin", 52.0, &"hud_calcetin"], ["foto", 52.0, &"hud_foto"], ["snack", 60.0, &""]]
const X0 := 104.0
const ANCHO_AGENDA := 116.0
## Alto del cartel y alturas posibles (bajo el diálogo de arriba, al medio, abajo).
const ALTO_CARTEL := 96.0
const Y_CARTEL := 104.0
const ALTURAS_CARTEL := [104.0, 180.0, 252.0]
## Versión chica del cartel (cuando no hay hueco para la franja sin tapar el chiste): una tarjeta en una esquina.
const TAM_CHICO := Vector2(260, 54)
const DURACION_CARTEL := 2.45


func _ready() -> void:
	layer = Capas.CAPA_HUD
	process_mode = Node.PROCESS_MODE_ALWAYS
	# La barra se esconde mientras se presenta un jefe (M4: asomaba cortada bajo la franja de la imaginación).
	add_to_group(PresentacionJefe.GRUPO_OCULTAR)
	_barra = Control.new()
	_barra.name = "Barra"
	_barra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_barra.size = Vector2(640, 40)
	_barra.draw.connect(_dibujar_agenda)
	add_child(_barra)
	# Recursos: una pieza ContadorRecurso por cada uno, a la derecha de la agenda.
	var x := X0 + ANCHO_AGENDA + 4.0
	for datos: Array in CONTADORES:
		var contador: ContadorRecurso = (load(ESCENA_CONTADOR) as PackedScene).instantiate()
		contador.name = "Contador " + String(datos[0])
		contador.clave = datos[0]
		contador.ancho = datos[1]
		contador.position = Vector2(x, 6)
		contador.dibujar_icono = Recogible.dibujar_icono
		if datos[2] != &"":
			contador.icono = Estilo.icono(datos[2])
		_barra.add_child(contador)
		contadores[datos[0]] = contador
		x += float(datos[1]) + 4.0
	_actualizar_contadores()
	set_process(false)


func _process(delta: float) -> void:
	_golpe_agenda = maxf(0.0, _golpe_agenda - delta * 3.0)
	if _golpe_agenda <= 0.0:
		set_process(false)
	_barra.queue_redraw()


func al_presentar_jefe(presentando: bool) -> void:
	if _barra:
		_barra.visible = not presentando


## Un recurso cambió ("calcetin", "snack", "foto" o "agenda"): muestra el valor nuevo y lo hace saltar.
func golpear(clave: String) -> void:
	if clave == "agenda":
		_golpe_agenda = 1.0
		set_process(true)
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
	Estilo.panel(_barra, Rect2(X0, 6, ANCHO_AGENDA, Estilo.medida(&"alto_hud")), &"panel")
	_barra.draw_texture(Estilo.icono(&"hud_libreta"), Vector2(X0 + 1, 7 - roundf(g * 2.0)))
	var texto := tr("UI_AGENDA_CONTADOR") % [agenda.cumplidas(), agenda.total()]
	Estilo.escribir(_barra, Vector2(X0 + 24, 22 - roundf(g * 2.0)), texto, &"hud", Estilo.color(&"tinta_decreto").lerp(Estilo.color(&"lacre"), g))
	IconosBotones.dibujar(_barra, "agenda", Vector2(X0 + ANCHO_AGENDA - IconosBotones.ancho("agenda", 12.0) - 3, 11), 12.0)


## Cartel épico: título grande, nombre de la travesura y la recompensa. Pasa por la cola única de anuncios (G5): sale
## cuando le toca, donde no tapa a Felipe, al diálogo ni a quien reacciona; si no hay hueco, en chico en una esquina.
## `y_cartel` solo se usa sin cola de anuncios (pruebas sueltas del HUD).
func cartel(titulo: String, nombre: String, recompensa: String, secreta: bool, y_cartel := -1.0) -> void:
	titulo = tr(titulo)
	nombre = tr(nombre)
	recompensa = tr(recompensa)
	carteles.append([titulo, nombre])
	golpear("agenda")
	var datos := [titulo, nombre, recompensa, secreta]
	if anuncios:
		anuncios.anunciar("cartel", titulo, Vector2(640, ALTO_CARTEL), TAM_CHICO,
			func(rect: Rect2, chico: bool) -> float: return _mostrar_cartel(datos, rect, chico),
			_ocultar_cartel, false, retraso_cartel, false, _mover_cartel)
		return
	_mostrando = true
	create_tween().tween_callback(func() -> void:
		_mostrar_cartel(datos, Rect2(0, y_cartel if y_cartel >= 0.0 else Y_CARTEL, 640, ALTO_CARTEL), false)
		create_tween().tween_callback(func() -> void: _mostrando = false).set_delay(DURACION_CARTEL)).set_delay(retraso_cartel)


func ocupado() -> bool:
	return _mostrando or (anuncios != null and anuncios.ocupado())


var _actual: Cartel


## Muestra el cartel en ese rectángulo (franja completa o tarjeta chica) y devuelve cuánto dura.
func _mostrar_cartel(datos: Array, rect: Rect2, chico: bool) -> float:
	_actual = Cartel.crear(datos[0], datos[1], datos[2], datos[3], rect, chico)
	add_child(_actual)
	_actual.animar(DURACION_CARTEL)
	return DURACION_CARTEL


func _mover_cartel(rect: Rect2) -> void:
	if is_instance_valid(_actual):
		_actual.mover_a(rect)


func _ocultar_cartel() -> void:
	if is_instance_valid(_actual):
		_actual.ocultar()
