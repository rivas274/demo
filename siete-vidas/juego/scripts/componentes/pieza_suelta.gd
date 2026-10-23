class_name PiezaSuelta
extends Node2D
## Una pieza que sale volando de una derrota (tornillo, resorte, engranaje, llave de cuerda, la carcasa del ratón) con
## física simple: gravedad, gira en el aire, rebota en el piso y se queda ahí (la marca que queda). La que `gira` sigue
## dando vueltas sola unos segundos en el piso (la llave de cuerda) y después para.
## Su dibujo es una imagen de assets/nivel1/ (ArteNivel) con base en el origen: el arte de Gemini
## (`arte/referencias/gemini/derrotas.png`, lo prepara `herramientas/preparar_arte_nivel.py derrotas`). La llave usa los
## cuadros `<nombre>_1` a `_5` para girar.

## Gira en el piso: avisa al parar.
signal paro
## Llegó al piso y se quedó quieta.
signal apoyada(pieza: PiezaSuelta)

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
## En el piso lleva su sombra de contacto (lección 22: lo que queda tirado se apoya en el piso).
var con_sombra := false
var en_piso := false
var girando := false
var _reloj := 0.0
var _cuadros: Array[Texture2D] = []

## Cuadros del giro de la llave de cuerda (de frente, de tres cuartos, de canto, del otro lado y de vuelta).
const CUADROS_GIRO := 5


static func crear(nombre_pieza: String, desde: Vector2, velocidad_inicial: Vector2, piso_y: float) -> PiezaSuelta:
	var pieza := PiezaSuelta.new()
	pieza.name = "Pieza " + nombre_pieza
	pieza.nombre = nombre_pieza
	pieza.position = desde
	pieza.velocidad = velocidad_inicial
	pieza.piso = piso_y
	return pieza


func _ready() -> void:
	for i in range(1, CUADROS_GIRO + 1):
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
	apoyada.emit(self)


func _draw() -> void:
	var t: Texture2D = null
	if girando and not _cuadros.is_empty():
		t = _cuadros[int(_reloj * 10.0) % _cuadros.size()]
	elif not _cuadros.is_empty():
		t = _cuadros[0]
	else:
		t = ArteNivel.textura(nombre)
	if t:
		if con_sombra and en_piso:
			ArteNivel.sombra(self, Vector2(0, 1), t.get_width() * 0.9 + 2.0, 0.45)
		draw_texture(t, Vector2(-roundf(t.get_width() / 2.0), -t.get_height()))
