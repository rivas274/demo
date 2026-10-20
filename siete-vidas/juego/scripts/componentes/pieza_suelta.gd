class_name PiezaSuelta
extends Node2D
## Una pieza que sale volando de una derrota (tornillo, resorte, engranaje, llave de cuerda, la carcasa del ratón) con
## física simple: gravedad, gira en el aire, rebota en el piso y se queda ahí (la marca que queda). La que `gira` sigue
## dando vueltas sola unos segundos en el piso (la llave de cuerda) y después para.
## Su dibujo es una imagen de assets/nivel1/ (ArteNivel) con base en el origen; si falta, un provisional de pixel con
## ese nombre (hasta que llegue el arte de Gemini, `arte/referencias/gemini/derrotas.png`). La llave usa, si existen,
## los cuadros `<nombre>_1` a `_4` para girar.

## Gira en el piso: avisa al parar.
signal paro

var nombre := ""
var velocidad := Vector2.ZERO
var gravedad := 900.0
var rebote := 0.35
## Y del piso (en coordenadas del padre): ahí se apoya.
var piso := 0.0
## Vueltas por segundo mientras vuela.
var vueltas := 2.0
## Segundos que gira sola al quedar en el piso (0 = no gira).
var gira_segundos := 0.0
var en_piso := false
var girando := false
var _reloj := 0.0
var _cuadros: Array[Texture2D] = []

## Colores de los provisionales (hasta que llegue el arte).
const METAL := Color("b8bec6")
const METAL_OSCURO := Color("5d636b")
const ORO := Color("d9a65b")
const ORO_OSCURO := Color("8a5a2b")
const CONTORNO := Color("2a1d1a")


static func crear(nombre_pieza: String, desde: Vector2, velocidad_inicial: Vector2, piso_y: float) -> PiezaSuelta:
	var pieza := PiezaSuelta.new()
	pieza.name = "Pieza " + nombre_pieza
	pieza.nombre = nombre_pieza
	pieza.position = desde
	pieza.velocidad = velocidad_inicial
	pieza.piso = piso_y
	return pieza


func _ready() -> void:
	for i in range(1, 5):
		var cuadro := ArteNivel.textura("%s_%d" % [nombre, i])
		if cuadro:
			_cuadros.append(cuadro)


func _physics_process(delta: float) -> void:
	if en_piso:
		if girando:
			_reloj += delta
			if _reloj >= gira_segundos:
				girando = false
				scale.x = 1.0
				paro.emit()
			queue_redraw()
		return
	velocidad.y += gravedad * delta
	position += velocidad * delta
	rotation += vueltas * TAU * delta
	if position.y >= piso:
		position.y = piso
		if velocidad.y > 70.0:
			velocidad = Vector2(velocidad.x * 0.6, -velocidad.y * rebote)
		else:
			_apoyar()


## Se queda en el piso, derecha, y empieza a girar si le toca.
func _apoyar() -> void:
	en_piso = true
	velocidad = Vector2.ZERO
	rotation = 0.0
	position = position.round()
	if gira_segundos > 0.0:
		girando = true
		_reloj = 0.0
	queue_redraw()


func _draw() -> void:
	var t: Texture2D = null
	if girando and not _cuadros.is_empty():
		t = _cuadros[int(_reloj * 10.0) % _cuadros.size()]
	elif not _cuadros.is_empty():
		t = _cuadros[0]
	else:
		t = ArteNivel.textura(nombre)
	if t:
		draw_texture(t, Vector2(-roundf(t.get_width() / 2.0), -t.get_height()))
		return
	_provisional()


## Provisionales de pixel (se reemplazan solos al aparecer la imagen con el mismo nombre en assets/nivel1/).
func _provisional() -> void:
	if nombre.contains("tornillo"):
		draw_rect(Rect2(-3, -6, 6, 2), METAL_OSCURO)
		draw_rect(Rect2(-1, -4, 2, 4), METAL)
	elif nombre.contains("engranaje"):
		for i in 6:
			var a := i * TAU / 6.0
			draw_rect(Rect2(Vector2(cos(a), sin(a)) * 5.0 + Vector2(-1, -7), Vector2(2, 2)), METAL_OSCURO)
		draw_circle(Vector2(0, -6), 4.0, METAL)
		draw_circle(Vector2(0, -6), 1.5, METAL_OSCURO)
	elif nombre.contains("llave"):
		# Gira «de canto» achicándose a lo ancho (con el arte de Gemini serán 4 cuadros).
		var ancho := absf(cos(_reloj * 9.0)) if girando else 1.0
		var mitad := maxf(1.0, roundf(6.0 * ancho))
		draw_rect(Rect2(-mitad, -12, mitad * 2.0, 6), ORO)
		draw_rect(Rect2(-1, -6, 2, 6), ORO_OSCURO)
		draw_rect(Rect2(-mitad, -12, mitad * 2.0, 1), CONTORNO)
	elif nombre.contains("resorte"):
		for i in 5:
			draw_line(Vector2(-4, -2 - i * 3), Vector2(4, -4 - i * 3), METAL, 2.0)
		if nombre.contains("alma"):
			draw_rect(Rect2(-3, -12, 1, 2), CONTORNO)
			draw_rect(Rect2(2, -12, 1, 2), CONTORNO)
			draw_line(Vector2(-2, -8), Vector2(2, -8), CONTORNO, 1.0)
	elif nombre.contains("pelusa"):
		# Montaña de pelusa con un calcetín y una croqueta asomando.
		draw_colored_polygon(PackedVector2Array([Vector2(-30, 0), Vector2(-22, -14), Vector2(-8, -22), Vector2(8, -21), Vector2(22, -13), Vector2(30, 0)]), Color("9b958f"))
		draw_colored_polygon(PackedVector2Array([Vector2(-20, -10), Vector2(-6, -18), Vector2(10, -17), Vector2(20, -9), Vector2(4, -6)]), Color("c4beb6"))
		ArteNivel.dibujar(self, "calcetin", -12.0, -6.0)
		draw_rect(Rect2(12, -10, 6, 4), Color("a8673a"))
	else:
		draw_rect(Rect2(-4, -6, 8, 6), METAL_OSCURO)
