class_name BotonMenu
extends Button
## Botón base de los menús. Su aspecto sale del tema (variación BotonMenu); su comportamiento, de
## datos/ui/boton_menu.tres (DatosBoton):
## - al apretar se encoge un instante y vuelve con rebote;
## - con foco (teclado, mando) o con el mouse encima brilla y se mece como un péndulo colgado de arriba al centro;
##   la amplitud sube y baja con un tween (nunca de golpe);
## - entrada opcional: cae desde fuera del borde de arriba hasta su sitio, con rebote (MenuUI la escalona);
## - `principal`: un pulso de brillo sutil para destacarlo.
## Con Opciones.reducir_movimiento no se mece ni entra cayendo.
##
## Pixel art: el juego se dibuja a 640×360 con snap a píxel, así que un giro se ve con dientes. Por eso el vaivén es
## chico (6°), solo existe en los menús (con el juego en pausa) y el pivote cae en un píxel entero. No se usó un
## SubViewport: también rendiría a 640×360 y no suavizaría nada.

const DATOS := "res://datos/ui/boton_menu.tres"

## Botón principal del menú (se destaca con un pulso).
@export var principal := false

## Grados de vaivén que se permiten ahora (0 sin foco; sube a vaiven_grados con foco).
var amplitud := 0.0
var datos: DatosBoton

static var _datos: DatosBoton

var _t := 0.0
var _resaltado := false
var _tween_amplitud: Tween
var _tween_brillo: Tween
var _tween_escala: Tween
var _brillo := 1.0


func _ready() -> void:
	if _datos == null:
		_datos = load(DATOS)
	datos = _datos
	theme_type_variation = &"BotonMenu"
	focus_mode = Control.FOCUS_ALL
	button_down.connect(_al_apretar)
	button_up.connect(_al_soltar)
	focus_entered.connect(_resaltar.bind(true))
	focus_exited.connect(_resaltar_si_no_hay_mouse)
	mouse_entered.connect(_resaltar.bind(true))
	mouse_exited.connect(_resaltar_si_no_hay_foco)
	resized.connect(_poner_pivote)
	_poner_pivote()


func _poner_pivote() -> void:
	# Pivote arriba al centro, en un píxel entero.
	pivot_offset = Vector2(roundf(size.x / 2.0), 0.0)


func _process(delta: float) -> void:
	_t += delta
	var grados := 0.0 if Opciones.reducir_movimiento else amplitud * sin(_t * TAU / datos.vaiven_periodo)
	rotation = deg_to_rad(grados)
	var pulso := 0.0
	if principal:
		pulso = datos.pulso_principal * (0.5 + 0.5 * sin(_t * TAU / datos.periodo_pulso))
	var b := _brillo + pulso
	modulate.r = b
	modulate.g = b
	modulate.b = b


func _al_apretar() -> void:
	_tween_escala = _nuevo(_tween_escala)
	_tween_escala.tween_property(self, "scale", Vector2.ONE * datos.escala_apretado, datos.tiempo_apretar)


func _al_soltar() -> void:
	_tween_escala = _nuevo(_tween_escala)
	_tween_escala.tween_property(self, "scale", Vector2.ONE, datos.tiempo_soltar).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Con foco o encima: brillo y vaivén que suben suave; sin nada, bajan suave a 0.
func _resaltar(si: bool) -> void:
	if si == _resaltado:
		return
	_resaltado = si
	_tween_amplitud = _nuevo(_tween_amplitud)
	_tween_amplitud.tween_property(self, "amplitud", datos.vaiven_grados if si else 0.0, datos.vaiven_rampa).set_trans(Tween.TRANS_SINE)
	_tween_brillo = _nuevo(_tween_brillo)
	_tween_brillo.tween_property(self, "_brillo", datos.brillo_foco if si else 1.0, datos.tiempo_brillo)


func _resaltar_si_no_hay_mouse() -> void:
	if not is_hovered():
		_resaltar(false)


func _resaltar_si_no_hay_foco() -> void:
	if not has_focus():
		_resaltar(false)


## Cae desde fuera del borde de arriba hasta su sitio (después de `retraso` s). Sin efecto con reducir movimiento.
func entrar(retraso := 0.0) -> void:
	if Opciones.reducir_movimiento:
		return
	var destino := position.y
	position.y = -get_global_rect().end.y + position.y - 1.0
	var t := create_tween()
	t.tween_property(self, "position:y", destino, datos.tiempo_entrada).set_delay(retraso).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func _nuevo(anterior: Tween) -> Tween:
	if anterior and anterior.is_valid():
		anterior.kill()
	return create_tween()
