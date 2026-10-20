class_name Medidores
extends Control
## Arriba a la izquierda, con estilo de red social: los corazones de Felipe (pieza BarraVida conectada a su Vida), sus
## vidas restantes, el Collar de la Vergüenza y el aviso de logro. Solo escucha señales (Vida.cambio,
## Felipe.vidas_cambiadas y collar_cambiado, Pantallas.modo_cambiado): no pregunta nada en cada cuadro.

const ESCENA_BARRA := "res://escenas/ui/barra_vida.tscn"

var felipe: Felipe:
	set(valor):
		felipe = valor
		_conectar_felipe()
## Si hay pantallas (título, pausa, final), los medidores solo se ven mientras se juega.
var pantallas: Pantallas:
	set(valor):
		pantallas = valor
		if pantallas and not pantallas.modo_cambiado.is_connected(_al_cambiar_modo):
			pantallas.modo_cambiado.connect(_al_cambiar_modo)
		_al_cambiar_modo(pantallas.modo if pantallas else Pantallas.Modo.JUGANDO)
## El cuadro de diálogo (si hay): el aviso de logro nunca queda debajo ni encima de él (M3).
var dialogo: Dialogo
## Los corazones (pieza BarraVida).
var corazones: BarraVida
var _presentando := false
var _notificacion := ""
var _tiempo_notificacion := 0.0
var _aviso: Control
## La cola única de anuncios (G5): el logro espera su turno y su lugar (nunca al mismo tiempo que un cartel).
var anuncios: Anuncios
var _rect_aviso := Rect2()
const DURACION_LOGRO := 2.6

## Capa del aviso de logro: por encima del diálogo (capa 7) y del HUD (capa 6).
const CAPA_AVISO := Capas.CAPA_AVISOS
const TAM_AVISO := Vector2(208, 34)


func _ready() -> void:
	name = "Medidores"
	corazones = (load(ESCENA_BARRA) as PackedScene).instantiate()
	corazones.position = Vector2(16, 16)
	add_child(corazones)
	_conectar_felipe()
	add_to_group(PresentacionJefe.GRUPO_OCULTAR)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	var capa := CanvasLayer.new()
	capa.name = "Avisos de logros"
	capa.layer = CAPA_AVISO
	add_child(capa)
	_aviso = Control.new()
	_aviso.name = "Aviso de logro"
	_aviso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_aviso.set_anchors_preset(Control.PRESET_FULL_RECT)
	_aviso.draw.connect(_dibujar_aviso)
	capa.add_child(_aviso)


func mostrar_logro(titulo: String) -> void:
	if anuncios:
		anuncios.anunciar("logro", titulo, TAM_AVISO, TAM_AVISO, func(rect: Rect2, _chico: bool) -> float:
			_notificacion = titulo
			_rect_aviso = rect
			_tiempo_notificacion = DURACION_LOGRO
			return DURACION_LOGRO, func() -> void: _tiempo_notificacion = 0.0, false, 0.0, true,
			func(rect: Rect2) -> void: _rect_aviso = rect)
		return
	_notificacion = titulo
	_tiempo_notificacion = 3.5


func _process(delta: float) -> void:
	_tiempo_notificacion = maxf(0.0, _tiempo_notificacion - delta)
	_aviso.queue_redraw()


func _conectar_felipe() -> void:
	if felipe == null or corazones == null:
		return
	corazones.conectar(felipe.vida)
	for senal: Signal in [felipe.vidas_cambiadas, felipe.collar_cambiado]:
		if not senal.is_connected(_redibujar):
			senal.connect(_redibujar)
	queue_redraw()


func _redibujar(_valor: Variant = null) -> void:
	queue_redraw()


## Mientras se presenta un jefe, los corazones y las vidas no se ven (M4).
func al_presentar_jefe(presentando: bool) -> void:
	_presentando = presentando
	_al_cambiar_modo(pantallas.modo if pantallas else Pantallas.Modo.JUGANDO)


func _al_cambiar_modo(modo: Pantallas.Modo) -> void:
	visible = modo == Pantallas.Modo.JUGANDO and not _presentando
	queue_redraw()


## Hay un aviso de logro en pantalla.
func mostrando_logro() -> bool:
	return _tiempo_notificacion > 0.0 and felipe != null and (pantallas == null or pantallas.modo == Pantallas.Modo.JUGANDO)


## Dónde va el aviso: arriba a la derecha, bajo la barra del jefe (M4 de la revisión 1); si el diálogo está arriba,
## justo debajo de él (M3).
func rect_logro() -> Rect2:
	if _rect_aviso.has_area():
		return _rect_aviso
	var ancho_pantalla := get_viewport_rect().size.x
	var caja := Rect2(Vector2(ancho_pantalla - TAM_AVISO.x - 8, 44), TAM_AVISO)
	if dialogo and is_instance_valid(dialogo):
		var ocupa := dialogo.rect_en_pantalla()
		if ocupa.has_area() and ocupa.intersects(caja):
			caja.position.y = ocupa.end.y + 4.0
	return caja


func _draw() -> void:
	if not felipe:
		return
	draw_rect(Rect2(6, 6, 92, 34), Estilo.color(&"fondo_medidor"))
	Estilo.escribir(self, Vector2(12, 36), tr("UI_VIDAS") % felipe.vidas, &"medidor_vidas", Estilo.color(&"texto_oscuro"))
	if felipe.tiene_collar:
		Estilo.escribir(self, Vector2(104, 20), tr("UI_COLLAR"), &"medidor_collar", Estilo.color(&"rojo"))


func _dibujar_aviso() -> void:
	if not mostrando_logro():
		return
	var caja := rect_logro()
	_aviso.draw_rect(caja, Estilo.color(&"fondo_medidor", 1.0))
	_aviso.draw_rect(caja, Estilo.color(&"rojo"), false, 1.0)
	Estilo.escribir(_aviso, caja.position + Vector2(8, 12), tr("UI_LOGRO_NUEVO"), &"logro_titulo", Estilo.color(&"texto_apagado"))
	Estilo.escribir(_aviso, caja.position + Vector2(8, 28), _notificacion, &"logro_nombre", Estilo.color(&"texto_oscuro"))


## Peso con personalidad: el humor de Felipe según los kilos (no cambia su dibujo ni su movimiento).
const NIVELES_PESO := [[8.5, "Atlético"], [9.5, "Esponjoso"], [11.0, "Modo Invierno"], [INF, "Modo Buda"]]


static func nivel_de_peso(kilos: float) -> String:
	for nivel: Array in NIVELES_PESO:
		if kilos < nivel[0]:
			return nivel[1]
	return NIVELES_PESO[-1][1]
