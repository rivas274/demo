class_name Hud
extends CanvasLayer
## Los carteles épicos «¡TRAVESURA CUMPLIDA!», «¡TRAVESURA SECRETA!» y «PODER NUEVO», en cola (zona C). HUD mínimo
## (interfaz v2, decisión del creador del 2026-10-23): en pantalla queda solo la salud (Medidores). La agenda, los
## calcetines, las fotos y los snacks NO tienen contador en el HUD: al recoger algo sale «+1» sobre Felipe y lo que se
## lleva se mira en la pausa (el bolsillo y la libreta). Nada de puntos.

## Carteles que se mostraron (para las pruebas): [título, nombre].
var carteles: Array = []
## Segundos entre la travesura y el cartel: primero se ve el gag, después el cartel.
@export var retraso_cartel := 0.5

## La cola única de anuncios (G5): si está, los carteles esperan su turno y su lugar ahí.
var anuncios: Anuncios
var _mostrando := false

## Tamaño máximo del cartel: la zona C (franja de 22 px y su línea de 19, más sombras).
const TAM_CARTEL := Vector2(576, 50)
## Entre 1,5 y 2,5 s (Gemini, 2026-10-20).
const DURACION_CARTEL := 2.2


func _ready() -> void:
	layer = Capas.CAPA_HUD
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group(PresentacionJefe.GRUPO_OCULTAR)


func al_presentar_jefe(_presentando: bool) -> void:
	pass


## Cartel épico: título grande y el nombre de la travesura en una línea. Pasa por la cola única de anuncios (G5): sale
## en la zona C cuando le toca (después del diálogo). Sin cola de anuncios (pruebas sueltas del HUD), sale enseguida.
func cartel(titulo: String, nombre: String, secreta: bool) -> void:
	titulo = tr(titulo)
	nombre = tr(nombre)
	carteles.append([titulo, nombre])
	var datos := [titulo, nombre, secreta]
	if anuncios:
		anuncios.anunciar("cartel", titulo, Cartel.medida(titulo, nombre), func(rect: Rect2) -> float: return _mostrar_cartel(datos, rect),
			_ocultar_cartel, false, retraso_cartel)
		return
	_mostrando = true
	create_tween().tween_callback(func() -> void:
		_mostrar_cartel(datos, ZonasTexto.cartel(Cartel.medida(titulo, nombre)))
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
