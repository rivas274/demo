class_name LuzCuarto
extends Node2D
## PRUEBA de luz y efectos (decisión "Luz y efectos" de la memoria 01, aprobada como prueba el 2026-10-19): la sala al
## atardecer. Todo vive en este script y se prende con UNA bandera, `Sala.luz_activa`; para quitar la prueba basta con
## apagarla (o borrar este archivo, `assets/luz/` y las dos líneas de `Sala._ready`).
##
## Qué pone, solo en la sala (en los demás cuartos el ambiente vuelve a blanco y las luces se apagan):
## - Ambiente cálido algo más oscuro (CanvasModulate). Afecta solo al mundo: la interfaz, el diálogo, los carteles y
##   las pantallas van en CanvasLayer (Capas.CAPA_*) y no lo reciben. El Indicador (burbuja y contorno, en el mundo)
##   queda sin sombrear.
## - Luces puntuales (PointLight2D) con textura EN ESCALONES (assets/luz/, `herramientas/texturas_luz.py`): el rayo de la
##   ventana (luz principal, desde la izquierda), el portátil de Valeria (frío, leve) y el LED del cargador. Felipe y
##   Valeria las reciben al pasar. Sin normales ni sombras.
## - La lámpara de la mesita NO es una luz redonda (pasada única, 2026-10-19, lección 26: el halo circular sobre el tapiz
##   se veía como un filtro): su luz cae en el tablero de la mesita y en el piso, en escalones de tono plano.
## - Brillo solo en lo que emite luz: el vidrio de la ventana, la pantalla de la lámpara y el LED se redibujan sin
##   sombrear (con su color de siempre) sobre el cuarto oscurecido.
## - Polvo en el rayo: motas de 1 px que suben y titilan dentro del rayo, en posiciones enteras.

const CUARTO := "sala"
## Ambiente del atardecer: cálido y algo más oscuro (R14: lo jugable se sigue leyendo).
const AMBIENTE := Color(0.84, 0.75, 0.67)
const RUTA := "res://assets/luz/%s.png"

## Ventana de la sala (arte `ventana_sala`): vidrio en coordenadas de la textura y del mundo.
const VIDRIO_TEXTURA := Rect2(27, 26, 126, 111)
## Pantalla de la lámpara en `mesita_sala` (coordenadas de la textura).
const PANTALLA_LAMPARA := Rect2(5, 0, 35, 23)
## LED del cargador (el que dibuja Sala._dibujar_ambiente).
const LED := Vector2(210, Sala.SUELO - 4)
## Entre la pantalla del portátil y la cara de Valeria sentada en el sofá, respecto de Sala.VALERIA_SOFA.
const PORTATIL := Vector2(-6, -80)
## Luz de la lámpara en escalones: [x izquierda, y, ancho, alto, alfa] en el tablero de la mesita (filas 38 a 57 de
## su arte, coordenadas de la textura) y en el piso delante de ella (coordenadas del mundo).
const LAMPARA_TABLERO := [[2, 39, 62, 13, 0.1], [9, 40, 46, 10, 0.1], [16, 41, 30, 7, 0.12]]
const LAMPARA_PISO := [[140, Sala.SUELO + 1, 124, 8, 0.07], [156, Sala.SUELO + 1, 92, 6, 0.07], [172, Sala.SUELO + 1, 60, 4, 0.08]]
const COLOR_LAMPARA := Color(1.0, 0.85, 0.55)
## Capa de luz propia de Valeria: la luz fría del portátil ilumina solo a ella (no la pared de atrás).
const MASCARA_VALERIA := 2

## Luces: [nombre, textura, posición en el mundo, escala de la textura, color, energía].
const LUCES := [
	["Sol de la ventana", "luz_rayo", Vector2.INF, 1.0, Color(1.0, 0.72, 0.42), 0.6],
	["Portátil de Valeria", "luz_escalones", Vector2.INF, 0.4, Color(0.55, 0.75, 1.0), 0.6],
	["LED del cargador", "luz_escalones", LED + Vector2(1, 0), 0.1, Color(0.4, 1.0, 0.5), 0.5],
]
const MOTAS := 14

var sala: Sala
var _ambiente: CanvasModulate
var _luces := {}
var _brillo_pared: Node2D
var _brillo_mueble: Node2D
var _polvo: Node2D
var _luz_piso: Node2D
var _vidrio := Rect2()
var _t := 0.0


func _init(de: Sala) -> void:
	sala = de
	name = "LuzCuarto"


func _ready() -> void:
	_ambiente = CanvasModulate.new()
	_ambiente.name = "Ambiente del cuarto"
	add_child(_ambiente)
	var ventana := ArteNivel.textura("ventana_sala")
	var arte: Array = Sala.ARTE[0]
	var origen := Vector2(arte[1].x, arte[1].y - (ventana.get_height() if ventana else 0))
	_vidrio = Rect2(origen + VIDRIO_TEXTURA.position, VIDRIO_TEXTURA.size)
	var rayo := _textura("luz_rayo")
	for datos: Array in LUCES:
		var luz := PointLight2D.new()
		luz.name = datos[0]
		luz.texture = _textura(datos[1])
		luz.texture_scale = datos[3]
		luz.color = datos[4]
		luz.energy = datos[5]
		luz.blend_mode = Light2D.BLEND_MODE_ADD
		luz.shadow_enabled = false
		luz.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var donde: Vector2 = datos[2]
		if datos[1] == "luz_rayo" and rayo:
			donde = _vidrio.position + rayo.get_size() / 2.0
		elif donde == Vector2.INF:
			donde = Sala.VALERIA_SOFA + PORTATIL
		luz.position = donde
		if datos[0] == "Portátil de Valeria":
			luz.range_item_cull_mask = MASCARA_VALERIA
		add_child(luz)
		_luces[datos[0]] = luz
	var sin_sombrear := CanvasItemMaterial.new()
	sin_sombrear.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	_brillo_pared = _lienzo("Brillo de la ventana", Capas.ARTE_PARED, _dibujar_brillo_pared, sin_sombrear)
	_brillo_mueble = _lienzo("Brillo de la lámpara", Capas.MUEBLES, _dibujar_brillo_mueble, sin_sombrear)
	_polvo = _lienzo("Polvo del rayo", Capas.LUZ, _dibujar_polvo, sin_sombrear)
	# Encima del piso y debajo de los muebles y de Felipe.
	_luz_piso = _lienzo("Luz de la lámpara en el piso", Capas.ARTE_PARED, _dibujar_luz_piso, sin_sombrear)
	# El Indicador está en el mundo (burbuja y contorno): no recibe ni el ambiente ni las luces.
	if sala.travesuras and sala.travesuras.indicador:
		_sin_sombrear(sala.travesuras.indicador, sin_sombrear)
	if sala.valeria:
		sala.valeria.light_mask |= MASCARA_VALERIA
	sala.habitacion_cambiada.connect(_al_cambiar_cuarto)
	_al_cambiar_cuarto(sala.habitacion)


func _lienzo(nombre: String, z: int, dibujo: Callable, material_lienzo: Material) -> Node2D:
	var lienzo := Node2D.new()
	lienzo.name = nombre
	lienzo.material = material_lienzo
	Capas.usar(lienzo, z)
	lienzo.draw.connect(dibujo)
	add_child(lienzo)
	return lienzo


static func _textura(nombre: String) -> Texture2D:
	var ruta := RUTA % nombre
	return load(ruta) if ResourceLoader.exists(ruta) else null


## Pone el material sin sombrear al nodo y hace que sus hijos sin material propio lo usen.
static func _sin_sombrear(nodo: CanvasItem, material_nodo: Material) -> void:
	if nodo.material == null:
		nodo.material = material_nodo
	for hijo in nodo.get_children():
		if hijo is CanvasItem:
			var item := hijo as CanvasItem
			if item.material == null:
				item.use_parent_material = true


## Solo en la sala: en otro cuarto el ambiente vuelve a blanco y todo se apaga (el negro de la puerta tapa el cambio).
func _al_cambiar_cuarto(cuarto: String) -> void:
	var activa := cuarto == CUARTO
	_ambiente.color = AMBIENTE if activa else Color.WHITE
	for luz: PointLight2D in _luces.values():
		luz.enabled = activa
	for lienzo: Node2D in [_brillo_pared, _brillo_mueble, _polvo, _luz_piso]:
		lienzo.visible = activa
	set_process(activa)


func _process(delta: float) -> void:
	_t += delta
	var led: PointLight2D = _luces["LED del cargador"]
	led.energy = 0.3 + 0.3 * sin(sala.tiempo * 3.0)
	var portatil: PointLight2D = _luces["Portátil de Valeria"]
	var valeria := sala.valeria
	portatil.enabled = valeria != null and valeria.visible and valeria.cuarto == CUARTO and valeria.actividad == Valeria.Actividad.SENTADA
	_polvo.queue_redraw()
	_brillo_mueble.queue_redraw()


func _dibujar_brillo_pared() -> void:
	var ventana := ArteNivel.textura("ventana_sala")
	if ventana:
		_brillo_pared.draw_texture_rect_region(ventana, _vidrio, VIDRIO_TEXTURA)


func _dibujar_brillo_mueble() -> void:
	var mesita := ArteNivel.textura("mesita_sala")
	if mesita:
		var origen := Vector2(Sala.MESITA_X, Sala.SUELO - mesita.get_height())
		_brillo_mueble.draw_texture_rect_region(mesita, Rect2(origen + PANTALLA_LAMPARA.position, PANTALLA_LAMPARA.size), PANTALLA_LAMPARA)
		# La luz de la lámpara cae en el tablero, bajo la pantalla, en tres escalones.
		for e: Array in LAMPARA_TABLERO:
			_brillo_mueble.draw_rect(Rect2(origen + Vector2(e[0], e[1]), Vector2(e[2], e[3])), Color(COLOR_LAMPARA, e[4]))
	# El LED con su color pleno (late como el de Sala) y un halo de 1 px a los lados.
	var pulso := 0.5 + 0.5 * sin(sala.tiempo * 3.0)
	_brillo_mueble.draw_rect(Rect2(LED, Vector2(2, 1)), Color(0.55, 1.0, 0.6, 0.55 + 0.45 * pulso))
	_brillo_mueble.draw_rect(Rect2(LED + Vector2(-1, 0), Vector2(1, 1)), Color(0.4, 1.0, 0.5, 0.3 * pulso))
	_brillo_mueble.draw_rect(Rect2(LED + Vector2(2, 0), Vector2(1, 1)), Color(0.4, 1.0, 0.5, 0.3 * pulso))


## Charco de luz de la lámpara en el piso delante de la mesita: tres franjas planas (no un degradado).
func _dibujar_luz_piso() -> void:
	for e: Array in LAMPARA_PISO:
		_luz_piso.draw_rect(Rect2(e[0], e[1], e[2], e[3]), Color(COLOR_LAMPARA, e[4]))


## Motas de 1 px que suben despacio dentro del rayo de la ventana y titilan en dos escalones (no un degradado).
func _dibujar_polvo() -> void:
	var piso := Sala.SUELO + 8.0
	for m in MOTAS:
		var subida := fmod(_t * (0.03 + 0.004 * (m % 4)) + m * 0.137, 1.0)
		var y := lerpf(piso - 10.0, _vidrio.position.y + 8.0, subida)
		var avance := (y - _vidrio.position.y) / (piso - _vidrio.position.y)
		var izquierda := _vidrio.position.x + 90.0 * avance + 10.0
		var derecha := _vidrio.end.x + 140.0 * avance - 10.0
		var x := lerpf(izquierda, derecha, fmod(m * 0.61 + 0.07, 1.0)) + sin(_t * 0.6 + m * 1.7) * 4.0
		var brilla := sin(_t * 2.0 + m * 2.3) > 0.6
		var alfa := 0.0 if subida < 0.06 or subida > 0.94 else (0.8 if brilla else 0.45)
		_polvo.draw_rect(Rect2(roundf(x), roundf(y), 1, 1), Color(1.0, 0.93, 0.75, alfa))
