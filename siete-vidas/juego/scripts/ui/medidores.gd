class_name Medidores
extends Control
## Arriba a la izquierda (zona A del layout v2, dentro de la zona segura): la salud de Felipe, que es la pieza
## BarraVida en forma HUELLAS (la cara y las 9 huellas) conectada a su Vida, y el aviso de logro (la etiqueta del kit
## v2, a la derecha de la zona C). HUD mínimo: nada más; lo que se lleva se mira en la pausa. Solo escucha señales
## (Vida.cambio, Pantallas.modo_cambiado): no pregunta nada al juego.

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
## La salud: 9 huellas (pieza BarraVida).
var huellas: BarraVida
var _presentando := false
var _notificacion := ""
var _tiempo_notificacion := 0.0
var _aviso: Control
## La cola única de anuncios (G5): el logro espera su turno y su lugar (nunca al mismo tiempo que un cartel).
var anuncios: Anuncios
var _rect_aviso := Rect2()
var _entrada_logro := 0.0
const DURACION_LOGRO := 2.2
## El logro entra deslizando desde la derecha en 140 ms y rebota 4 px.
const ENTRADA_LOGRO := 0.14
const REBOTE := 4.0

## Capa del aviso de logro: por encima del diálogo (capa 7) y del HUD (capa 6).
const CAPA_AVISO := Capas.CAPA_AVISOS


func _ready() -> void:
	name = "Medidores"
	huellas = (load(ESCENA_BARRA) as PackedScene).instantiate()
	huellas.position = ZonasTexto.SALUD.position
	add_child(huellas)
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


## Medida de la etiqueta de un logro (normal o grande): ícono de 16 (32) px, el nombre y sus márgenes.
static func tam_logro(titulo: String, grande := Opciones.texto_grande) -> Vector2:
	var g := 2.0 if grande else 1.0
	var estilo := &"logro_nombre_grande" if grande else &"logro_nombre"
	return Vector2(12.0 + 16.0 * g + 10.0 + roundf(Estilo.ancho(TranslationServer.translate(titulo), estilo)) + 18.0, 16.0 * g + 8.0)


func mostrar_logro(titulo: String) -> void:
	if anuncios:
		anuncios.anunciar("logro", titulo, tam_logro(titulo), func(rect: Rect2) -> float:
			_notificacion = titulo
			_rect_aviso = rect
			_tiempo_notificacion = DURACION_LOGRO
			_entrada_logro = 0.0
			return DURACION_LOGRO, func() -> void: _tiempo_notificacion = 0.0)
		return
	_notificacion = titulo
	_rect_aviso = Rect2()
	_entrada_logro = 0.0
	_tiempo_notificacion = 3.5


func _process(delta: float) -> void:
	# En tiempo real (la cámara lenta de una derrota no estira el aviso).
	var real := delta / maxf(Engine.time_scale, 0.001)
	_tiempo_notificacion = maxf(0.0, _tiempo_notificacion - real)
	_entrada_logro = minf(1.0, _entrada_logro + real / ENTRADA_LOGRO)
	# Texto grande (opción de accesibilidad): la salud al doble.
	if huellas and huellas.grande != Opciones.texto_grande:
		huellas.grande = Opciones.texto_grande
	_aviso.queue_redraw()


func _conectar_felipe() -> void:
	if felipe == null or huellas == null:
		return
	huellas.conectar(felipe.vida)


## Mientras se presenta un jefe, la salud no se ve (M4).
func al_presentar_jefe(presentando: bool) -> void:
	_presentando = presentando
	_al_cambiar_modo(pantallas.modo if pantallas else Pantallas.Modo.JUGANDO)


func _al_cambiar_modo(modo: Pantallas.Modo) -> void:
	visible = modo == Pantallas.Modo.JUGANDO and not _presentando
	queue_redraw()


## Hay un aviso de logro en pantalla.
func mostrando_logro() -> bool:
	return _tiempo_notificacion > 0.0 and felipe != null and (pantallas == null or pantallas.modo == Pantallas.Modo.JUGANDO)


## Dónde va el aviso: en la zona C de ZonasTexto, a la derecha, donde lo puso la cola de anuncios.
func rect_logro() -> Rect2:
	return _rect_aviso if _rect_aviso.has_area() else ZonasTexto.logro(tam_logro(_notificacion))


func _dibujar_aviso() -> void:
	if not mostrando_logro():
		return
	var caja := rect_logro()
	var grande := caja.size.y > 30.0
	var g := 2.0 if grande else 1.0
	var sufijo := "-grande" if grande else ""
	# Entra deslizando desde la derecha y rebota 4 px (con «Reducir movimiento», aparece).
	var k := _entrada_logro
	var dx := 0.0 if Opciones.reducir_movimiento else (roundf((1.0 - k / 0.7) * (caja.size.x + 40.0)) if k < 0.7 else -roundf(REBOTE * sin(PI * (k - 0.7) / 0.3)))
	caja.position.x += dx
	KitUI.pieza(_aviso, "logro-etiqueta" + sufijo, caja)
	var icono := 16.0 * g
	var radio := icono / 2.0 + 2.0
	var centro := Vector2(caja.position.x + 10.0 + icono / 2.0, caja.position.y + caja.size.y / 2.0)
	KitUI.icono(_aviso, "logro-icono" + sufijo, (centro - Vector2(radio, radio)).floor())
	var estilo := &"logro_nombre_grande" if grande else &"logro_nombre"
	KitUI.escribir(_aviso, caja.position.x + 14.0 + icono + 8.0, caja.position.y + floorf((caja.size.y - KitUI.alto_mayuscula(estilo)) / 2.0), tr(_notificacion), estilo, Estilo.color(&"ui_texto"))
