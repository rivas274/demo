class_name LuzCuarto
extends Node2D
## PRUEBA de luz y efectos (decisión "Luz y efectos" de la memoria 01, aprobada como prueba el 2026-10-19): la sala al
## atardecer. Todo vive en este script y se prende con UNA bandera, `GuionNivel1.luz_activa`; para quitar la prueba basta con
## apagarla (o borrar este archivo, `assets/luz/` y las dos líneas de `GuionNivel1.al_terminar_de_armar`).
##
## Qué pone en la sala (en los cuartos sin lámpara el ambiente vuelve a blanco y las luces se apagan):
## - Ambiente cálido algo más oscuro (CanvasModulate). Afecta solo al mundo: la interfaz, el diálogo, los carteles y
##   las pantallas van en CanvasLayer (Capas.CAPA_*) y no lo reciben. El Indicador (burbuja y contorno, en el mundo)
##   queda sin sombrear.
## - Luces puntuales (PointLight2D) con textura EN ESCALONES (assets/luz/, `herramientas/texturas_luz.py`): el rayo de la
##   ventana (luz principal, desde la izquierda), el portátil de Valeria (frío, leve) y el LED del cargador. Felipe y
##   Valeria las reciben al pasar. Sin normales ni sombras.
## - Lámparas encendidas de toda la casa (Nivel1.LAMPARAS; plan de estabilización 2026-10-20, decisión 4): ninguna es
##   una luz redonda (lección 26: el halo circular sobre el tapiz se veía como un filtro). Cada una tiene la pantalla
##   encendida (más clara y cálida, con contorno claro de 1 px), un cono de luz en 3 escalones de bordes duros (6 a
##   10 % cada uno) que baja de la pantalla y se abre, y una franja iluminada en escalones en lo que toca (tablero o
##   piso). Los cuartos con lámpara se oscurecen un poco (Nivel1.AMBIENTE_CUARTOS) para que la luz resalte.
## - Brillo solo en lo que emite luz: el vidrio de la ventana y el LED se redibujan sin sombrear (con su color de
##   siempre) sobre el cuarto oscurecido.
## - Polvo en el rayo: motas de 1 px que suben y titilan dentro del rayo, en posiciones enteras.

const CUARTO := "sala"
const RUTA := "res://assets/luz/%s.png"

## Ventana de la sala (arte `ventana_sala`): vidrio en coordenadas de la textura y del mundo.
const VIDRIO_TEXTURA := Rect2(27, 26, 126, 111)
## LED del cargador (el que dibuja DecoradoNivel1.dibujar_ambiente).
const LED := Vector2(210, Nivel1.SUELO - 4)
## Entre la pantalla del portátil y la cara de Valeria sentada en el sofá, respecto de Nivel1.VALERIA_SOFA.
const PORTATIL := Vector2(-6, -80)
## Alto de cada escalón de la franja iluminada (de afuera hacia adentro) en el piso y en un tablero.
const FRANJA_PISO := [12.0, 8.0, 5.0]
const FRANJA_TABLERO := [9.0, 6.0, 4.0]
## Lo que se suma a la pantalla encendida (más clara y cálida) y su contorno claro.
const PANTALLA_SUMA := Color(0.32, 0.24, 0.1)
const CONTORNO_PANTALLA := Color(1.0, 0.93, 0.72, 0.9)
## Capa de luz propia de Valeria: la luz fría del portátil ilumina solo a ella (no la pared de atrás).
const MASCARA_VALERIA := 2

## Luces: [nombre, textura, posición en el mundo, escala de la textura, color, energía].
const LUCES := [
	["Sol de la ventana", "luz_rayo", Vector2.INF, 1.0, Color(1.0, 0.72, 0.42), 0.6],
	["Portátil de Valeria", "luz_escalones", Vector2.INF, 0.4, Color(0.55, 0.75, 1.0), 0.6],
	["LED del cargador", "luz_escalones", LED + Vector2(1, 0), 0.1, Color(0.4, 1.0, 0.5), 0.5],
]
const MOTAS := 14

var sala: Nivel
var valeria: Valeria
var _ambiente: CanvasModulate
var _luces := {}
var _brillo_pared: Node2D
var _brillo_mueble: Node2D
var _polvo: Node2D
var _conos: Node2D
var _pantallas: Node2D
var _pantallas_suma: Node2D
var _apoyos_piso: Node2D
var _apoyos_mueble: Node2D
## Por lámpara: {"origen", "pantalla" (rect del mundo), "bordes" ([y, x izquierda, x derecha] por fila)}.
var _lamparas: Array = []
var _vidrio := Rect2()
var _t := 0.0


func _init(de: Nivel, con_valeria: Valeria = null) -> void:
	sala = de
	valeria = con_valeria
	name = "LuzCuarto"


func _ready() -> void:
	_ambiente = CanvasModulate.new()
	_ambiente.name = "Ambiente del cuarto"
	add_child(_ambiente)
	var ventana := ArteNivel.textura("ventana_sala")
	var arte: Array = Nivel1.ARTE[0]
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
			donde = Nivel1.VALERIA_SOFA + PORTATIL
		luz.position = donde
		if datos[0] == "Portátil de Valeria":
			luz.range_item_cull_mask = MASCARA_VALERIA
		add_child(luz)
		_luces[datos[0]] = luz
	var sin_sombrear := CanvasItemMaterial.new()
	sin_sombrear.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	_brillo_pared = _lienzo("Brillo de la ventana", Capas.Rol.ARTE_PARED, _dibujar_brillo_pared, sin_sombrear)
	_brillo_mueble = _lienzo("Brillo de la lámpara", Capas.Rol.DECORADO, _dibujar_brillo_mueble, sin_sombrear)
	_polvo = _lienzo("Polvo del rayo", Capas.Rol.LUZ, _dibujar_polvo, sin_sombrear)
	# Lámparas: la luz suma (se ve como luz, no como pintura) y no la oscurece el ambiente.
	var suma := CanvasItemMaterial.new()
	suma.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	suma.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_armar_lamparas()
	# El cono va detrás de los muebles y los personajes (sobre la pared); la franja del piso, encima del piso y debajo
	# de los muebles; la del tablero y la pantalla, sobre el mueble.
	_conos = _lienzo("Conos de las lámparas", Capas.Rol.ARTE_PARED, _dibujar_conos, suma)
	_apoyos_piso = _lienzo("Luz de las lámparas en el piso", Capas.Rol.ARTE_PARED, _dibujar_apoyos.bind(false), suma)
	_apoyos_mueble = _lienzo("Luz de las lámparas en el tablero", Capas.Rol.DECORADO, _dibujar_apoyos.bind(true), suma)
	_pantallas = _lienzo("Pantallas encendidas", Capas.Rol.DECORADO, _dibujar_pantallas, sin_sombrear)
	_pantallas_suma = _lienzo("Pantallas encendidas (brillo)", Capas.Rol.DECORADO, _dibujar_pantallas_suma, suma)
	# El Indicador está en el mundo (burbuja y contorno): no recibe ni el ambiente ni las luces.
	if sala.travesuras and sala.travesuras.indicador:
		_sin_sombrear(sala.travesuras.indicador, sin_sombrear)
	if valeria:
		valeria.light_mask |= MASCARA_VALERIA
	sala.habitacion_cambiada.connect(_al_cambiar_cuarto)
	_al_cambiar_cuarto(sala.habitacion)


func _lienzo(nombre: String, rol: int, dibujo: Callable, material_lienzo: Material) -> Node2D:
	var lienzo := Node2D.new()
	lienzo.name = nombre
	lienzo.material = material_lienzo
	Profundidad.poner(lienzo, rol)
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


## Ambiente del cuarto (atardecer si tiene lámpara, blanco si no) y las luces de la sala solo en la sala (el negro de
## la puerta tapa el cambio). Las lámparas se dibujan siempre: cada una está en su cuarto.
func _al_cambiar_cuarto(cuarto: String) -> void:
	var activa := cuarto == CUARTO
	_ambiente.color = Nivel1.AMBIENTE_CUARTOS.get(cuarto, Color.WHITE)
	for luz: PointLight2D in _luces.values():
		luz.enabled = activa
	for lienzo: Node2D in [_brillo_pared, _brillo_mueble, _polvo]:
		lienzo.visible = activa
	set_process(activa)


## Lee de cada lámpara dónde está su pantalla en el mundo y su borde fila por fila (para el contorno claro).
func _armar_lamparas() -> void:
	for datos: Array in Nivel1.LAMPARAS:
		var t := ArteNivel.textura(datos[1])
		if t == null:
			continue
		var origen := Vector2.ZERO
		for pieza: Array in Nivel1.ARTE:
			if pieza[0] == datos[1]:
				origen = Vector2(pieza[1].x, pieza[1].y - t.get_height())
		var region: Rect2 = datos[2]
		var imagen := t.get_image()
		var bordes: Array = []
		for y in range(int(region.position.y), int(region.end.y)):
			var izquierda := -1
			var derecha := -1
			for x in range(int(region.position.x), int(region.end.x)):
				if imagen.get_pixel(x, y).a > 0.5:
					if izquierda < 0:
						izquierda = x
					derecha = x
			if izquierda >= 0:
				bordes.append([y, izquierda, derecha])
		_lamparas.append({"textura": t, "origen": origen, "region": region, "bordes": bordes, "apoyo": datos[3], "ancho": datos[4],
			"alto_arriba": datos[5], "ancho_arriba": datos[6], "alfa_arriba": datos[7]})


## Cono de luz: 3 trapecios de bordes duros, de la boca de la pantalla al apoyo, cada uno más angosto y del 6 al 10 %.
func _dibujar_conos() -> void:
	for l: Dictionary in _lamparas:
		var bordes: Array = l["bordes"]
		if bordes.is_empty():
			continue
		var origen: Vector2 = l["origen"]
		var boca: Array = bordes[-1]
		var y0 := origen.y + float(boca[0]) + 1.0
		var cx := origen.x + (float(boca[1]) + float(boca[2]) + 1.0) / 2.0
		var arriba := float(boca[2]) - float(boca[1]) + 1.0
		var y1: float = l["apoyo"]
		for k in Nivel1.ESCALONES_CONO.size():
			var e: float = Nivel1.ESCALONES_CONO[k]
			var a := roundf(arriba * e / 2.0)
			var b := roundf(float(l["ancho"]) * e / 2.0)
			var puntos := PackedVector2Array([Vector2(cx - a, y0), Vector2(cx + a, y0), Vector2(cx + b, y1), Vector2(cx - b, y1)])
			_conos.draw_colored_polygon(puntos, Color(Nivel1.COLOR_LAMPARA, Nivel1.ALFA_CONO[k]))
		# Hacia arriba: de la boca de arriba de la pantalla, más corto y más tenue, y termina en una franja en la pared.
		var tope: Array = bordes[0]
		var ya := origen.y + float(tope[0]) - 1.0
		var cxa := origen.x + (float(tope[1]) + float(tope[2]) + 1.0) / 2.0
		var boca_arriba := float(tope[2]) - float(tope[1]) + 1.0
		var yb := ya - float(l["alto_arriba"])
		var alfa: float = l["alfa_arriba"]
		for k in Nivel1.ESCALONES_CONO.size():
			var e: float = Nivel1.ESCALONES_CONO[k]
			var a := roundf(boca_arriba * e / 2.0)
			var b := roundf(float(l["ancho_arriba"]) * e / 2.0)
			var color := Color(Nivel1.COLOR_LAMPARA, Nivel1.ALFA_CONO[k] * alfa)
			_conos.draw_colored_polygon(PackedVector2Array([Vector2(cxa - a, ya), Vector2(cxa + a, ya), Vector2(cxa + b, yb), Vector2(cxa - b, yb)]), color)
			# Franja iluminada donde llega (en escalones, nunca un círculo).
			var alto_franja: float = FRANJA_TABLERO[k]
			_conos.draw_rect(Rect2(roundf(cxa - b), roundf(yb - alto_franja), b * 2.0, alto_franja), color)


## Franja iluminada donde cae la luz: escalones planos centrados bajo la lámpara (en el piso o en el tablero).
func _dibujar_apoyos(en_mueble: bool) -> void:
	var lienzo := _apoyos_mueble if en_mueble else _apoyos_piso
	for l: Dictionary in _lamparas:
		var y: float = l["apoyo"]
		var sobre_mueble := y < Nivel1.SUELO - 1.0
		if sobre_mueble != en_mueble:
			continue
		var bordes: Array = l["bordes"]
		var boca: Array = bordes[-1]
		var cx := (l["origen"] as Vector2).x + (float(boca[1]) + float(boca[2]) + 1.0) / 2.0
		var altos: Array = FRANJA_TABLERO if sobre_mueble else FRANJA_PISO
		for k in altos.size():
			var ancho := roundf(float(l["ancho"]) * Nivel1.ESCALONES_CONO[k])
			var alto: float = altos[k]
			lienzo.draw_rect(Rect2(roundf(cx - ancho / 2.0), roundf(y - alto / 2.0), ancho, alto), Color(Nivel1.COLOR_LAMPARA, Nivel1.ALFA_CONO[k] + 0.02))


## Pantalla encendida: contorno claro de 1 px por fuera de su borde y la pantalla sin sombrear (no la oscurece el
## ambiente del cuarto).
func _dibujar_pantallas() -> void:
	for l: Dictionary in _lamparas:
		var origen: Vector2 = l["origen"]
		var bordes: Array = l["bordes"]
		for fila: Array in bordes:
			var y := origen.y + float(fila[0])
			_pantallas.draw_rect(Rect2(origen.x + float(fila[1]) - 1.0, y, 1, 1), CONTORNO_PANTALLA)
			_pantallas.draw_rect(Rect2(origen.x + float(fila[2]) + 1.0, y, 1, 1), CONTORNO_PANTALLA)
		if not bordes.is_empty():
			var primera: Array = bordes[0]
			_pantallas.draw_rect(Rect2(origen.x + float(primera[1]), origen.y + float(primera[0]) - 1.0, float(primera[2]) - float(primera[1]) + 1.0, 1), CONTORNO_PANTALLA)
		var region: Rect2 = l["region"]
		_pantallas.draw_texture_rect_region(l["textura"], Rect2(origen + region.position, region.size), region)


## Lo que se suma a la pantalla: más clara y cálida.
func _dibujar_pantallas_suma() -> void:
	for l: Dictionary in _lamparas:
		var region: Rect2 = l["region"]
		_pantallas_suma.draw_texture_rect_region(l["textura"], Rect2((l["origen"] as Vector2) + region.position, region.size), region, PANTALLA_SUMA)


func _process(delta: float) -> void:
	_t += delta
	var led: PointLight2D = _luces["LED del cargador"]
	led.energy = 0.3 + 0.3 * sin(sala.tiempo * 3.0)
	var portatil: PointLight2D = _luces["Portátil de Valeria"]
	portatil.enabled = valeria != null and valeria.visible and valeria.cuarto == CUARTO and valeria.actividad == Valeria.Actividad.SENTADA
	_polvo.queue_redraw()
	_brillo_mueble.queue_redraw()


func _dibujar_brillo_pared() -> void:
	var ventana := ArteNivel.textura("ventana_sala")
	if ventana:
		_brillo_pared.draw_texture_rect_region(ventana, _vidrio, VIDRIO_TEXTURA)


func _dibujar_brillo_mueble() -> void:
	# El LED con su color pleno (late como el de Sala) y un halo de 1 px a los lados.
	var pulso := 0.5 + 0.5 * sin(sala.tiempo * 3.0)
	_brillo_mueble.draw_rect(Rect2(LED, Vector2(2, 1)), Color(0.55, 1.0, 0.6, 0.55 + 0.45 * pulso))
	_brillo_mueble.draw_rect(Rect2(LED + Vector2(-1, 0), Vector2(1, 1)), Color(0.4, 1.0, 0.5, 0.3 * pulso))
	_brillo_mueble.draw_rect(Rect2(LED + Vector2(2, 0), Vector2(1, 1)), Color(0.4, 1.0, 0.5, 0.3 * pulso))


## Motas de 1 px que suben despacio dentro del rayo de la ventana y titilan en dos escalones (no un degradado).
func _dibujar_polvo() -> void:
	var piso := Nivel1.SUELO + 8.0
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
