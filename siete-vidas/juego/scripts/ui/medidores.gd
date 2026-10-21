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
const DURACION_LOGRO := 2.2

## Capa del aviso de logro: por encima del diálogo (capa 7) y del HUD (capa 6).
const CAPA_AVISO := Capas.CAPA_AVISOS
const TAM_AVISO := Vector2(300, 44)
## Panel de los corazones y las vidas, en una sola fila dentro de la zona A del HUD (ZonasTexto.HUD, y 0–26).
const PANEL := Rect2(6, 4, 84, 22)
const POS_CORAZONES := Vector2(15, 15)
const PASO_CORAZONES := 14.0
## Donde empieza el texto en la etiqueta de logro (después del sello).
const X_TEXTO_LOGRO := 52.0


func _ready() -> void:
	name = "Medidores"
	corazones = (load(ESCENA_BARRA) as PackedScene).instantiate()
	corazones.position = POS_CORAZONES
	corazones.paso = PASO_CORAZONES
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
		anuncios.anunciar("logro", titulo, TAM_AVISO, func(rect: Rect2) -> float:
			_notificacion = titulo
			_rect_aviso = rect
			_tiempo_notificacion = DURACION_LOGRO
			return DURACION_LOGRO, func() -> void: _tiempo_notificacion = 0.0)
		return
	_notificacion = titulo
	_tiempo_notificacion = 3.5


func _process(delta: float) -> void:
	# En tiempo real (la cámara lenta de una derrota no estira el aviso).
	_tiempo_notificacion = maxf(0.0, _tiempo_notificacion - delta / maxf(Engine.time_scale, 0.001))
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


## Dónde va el aviso: en la zona C de ZonasTexto (arriba al centro), donde lo puso la cola de anuncios.
func rect_logro() -> Rect2:
	return _rect_aviso if _rect_aviso.has_area() else ZonasTexto.cartel(TAM_AVISO)


func _draw() -> void:
	if not felipe:
		return
	# HUD limpio (2026-10-21): solo los corazones. Las 9 vidas se ven en la pausa (panel del bolsillo) y en el momento
	# en que se pierde una (la vida fantasma).
	Estilo.panel(self, PANEL, &"panel")


func _dibujar_aviso() -> void:
	if not mostrando_logro():
		return
	var caja := rect_logro()
	# La etiqueta de logro del kit: el sello de la huella a la izquierda y el texto en la cinta de pergamino.
	Estilo.panel(_aviso, caja, &"etiqueta_logro")
	var x := caja.position.x + X_TEXTO_LOGRO
	var ancho := caja.size.x - X_TEXTO_LOGRO - 30.0
	# Una sola línea (zonas de texto, 2026-10-20): el sello ya dice «logro»; el nombre, a 16 px, centrado en la cinta.
	Estilo.escribir(_aviso, Vector2(x, caja.position.y + 27), Estilo.recortar(tr(_notificacion), &"logro_nombre", ancho), &"logro_nombre", Estilo.color(&"tinta_decreto"))
