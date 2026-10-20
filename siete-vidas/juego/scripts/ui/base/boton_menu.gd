class_name BotonMenu
extends Button
## Botón base de los menús. Su aspecto sale del tema (variación BotonMenu); su comportamiento, de
## datos/ui/boton_menu.tres (DatosBoton):
## - al apretar se encoge un instante y vuelve con rebote;
## - con foco (teclado, mando) o con el mouse encima brilla y se mece como un péndulo colgado de arriba al centro;
##   la amplitud sube y baja con un tween (nunca de golpe);
## - entrada opcional: cae desde fuera del borde de arriba hasta su sitio, con rebote (MenuUI la escalona);
## - `principal`: un pulso de brillo sutil para destacarlo;
## - golpear(fuerza): un manotazo (de Felipe, en el menú de estambre) suma un columpio fuerte que se apaga solo,
##   suelta motas de pelusa y avisa con `golpeado`.
## Menú de estambre (arte de Gemini, assets/ui/menu_*.png): si DatosBoton trae `hilo`, el botón es un letrero de
## madera (variaciones del tema BotonEstambre y BotonEstambrePrincipal, con la coronita) que cuelga de un hilo de
## `largo_hilo` px desde su argolla (`punto_cuelgue`); se balancea desde arriba del hilo. El texto lo pone el juego,
## centrado en la tabla, con la letra y el color del tema.
## Con Opciones.reducir_movimiento no se mece ni entra cayendo.
##
## Pixel art: el juego se dibuja a 640×360 con snap a píxel, así que un giro se ve con dientes. Por eso el vaivén es
## chico (6°), solo existe en los menús (con el juego en pausa) y el pivote cae en un píxel entero. No se usó un
## SubViewport: también rendiría a 640×360 y no suavizaría nada.

## Le dieron un manotazo (golpear): quien lo escucha suelta la pelusa, el sonido...
signal golpeado(fuerza: float)

const DATOS := "res://datos/ui/boton_menu.tres"

## Botón principal del menú (se destaca con un pulso).
@export var principal := false
## De dónde cuelga, como fracción del tamaño del botón (0,5; 0 = arriba al centro): pivote del balanceo.
@export var punto_cuelgue := Vector2(0.5, 0.0)

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
## Columpio del último manotazo: amplitud en grados (se amortigua) y su reloj.
var _golpe := 0.0
var _t_golpe := 0.0


func _ready() -> void:
	if _datos == null:
		_datos = load(DATOS)
	datos = _datos
	focus_mode = Control.FOCUS_ALL
	button_down.connect(_al_apretar)
	button_up.connect(_al_soltar)
	focus_entered.connect(_resaltar.bind(true))
	focus_exited.connect(_resaltar_si_no_hay_mouse)
	mouse_entered.connect(_resaltar.bind(true))
	mouse_exited.connect(_resaltar_si_no_hay_foco)
	if cuelga():
		theme_type_variation = &"BotonEstambrePrincipal" if principal else &"BotonEstambre"
		# Del tamaño del letrero (no se estira: la argolla y el marco quedan como en el dibujo), centrado en la columna.
		var letrero := get_theme_stylebox(&"normal") as StyleBoxTexture
		if letrero and letrero.texture:
			custom_minimum_size = letrero.texture.get_size()
		size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	else:
		theme_type_variation = &"BotonMenu"
	resized.connect(_poner_pivote)
	_poner_pivote()


## ¿Cuelga de un hilo de estambre? (hay arte para eso en los datos).
func cuelga() -> bool:
	return datos != null and datos.hilo != null


func _poner_pivote() -> void:
	# Pivote en el punto de cuelgue (la argolla, arriba al centro); colgado de estambre, arriba del hilo: el letrero
	# se mece como un péndulo. Siempre en un píxel entero.
	pivot_offset = (size * punto_cuelgue).round()
	if cuelga():
		pivot_offset.y -= datos.largo_hilo


## El hilo, de la argolla hacia arriba (se repite: sirve para cualquier largo).
func _draw() -> void:
	if not cuelga():
		return
	var ancho := float(datos.hilo.get_width())
	var x := roundf(size.x * punto_cuelgue.x - ancho / 2.0)
	draw_texture_rect(datos.hilo, Rect2(x, -datos.largo_hilo, ancho, datos.largo_hilo + 2.0), true)


func _process(delta: float) -> void:
	_t += delta
	var grados := 0.0 if Opciones.reducir_movimiento else amplitud * sin(_t * TAU / datos.vaiven_periodo)
	if _golpe > 0.01:
		_t_golpe += delta
		_golpe *= pow(datos.golpe_amortiguacion, delta)
		grados += _golpe * sin(_t_golpe * TAU / datos.golpe_periodo)
	else:
		_golpe = 0.0
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


## Manotazo: suma un columpio de `fuerza` (1 = normal) que se apaga solo y emite `golpeado`. Con reducir
## movimiento no se columpia, pero avisa igual (la pelusa y el sonido siguen).
func golpear(fuerza := 1.0) -> void:
	if not Opciones.reducir_movimiento:
		_golpe += datos.golpe_grados * fuerza
		_t_golpe = 0.0
	_soltar_pelusa()
	golpeado.emit(fuerza)


## Motas de pelusa que saltan del letrero hacia los lados, caen y se apagan (las motas no giran con el letrero).
func _soltar_pelusa() -> void:
	if datos.pelusas.is_empty():
		return
	var centro := get_global_rect().get_center()
	for i in datos.pelusa_cantidad:
		var mota := Sprite2D.new()
		mota.texture = datos.pelusas[i % datos.pelusas.size()]
		mota.top_level = true
		mota.scale = Vector2.ONE * datos.pelusa_escala
		mota.global_position = centro.round()
		add_child(mota)
		var lado := -1.0 if i % 2 == 0 else 1.0
		var hacia := centro + Vector2(lado * datos.pelusa_distancia * (0.6 + 0.4 * i), datos.pelusa_caida)
		var t := mota.create_tween().set_parallel()
		t.tween_property(mota, "global_position", hacia.round(), datos.pelusa_tiempo).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		t.tween_property(mota, "rotation", lado * PI, datos.pelusa_tiempo)
		t.tween_property(mota, "modulate:a", 0.0, datos.pelusa_tiempo).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		t.chain().tween_callback(mota.queue_free)


## Columpio que le queda al último manotazo (grados; 0 cuando ya paró).
func columpio() -> float:
	return _golpe


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
