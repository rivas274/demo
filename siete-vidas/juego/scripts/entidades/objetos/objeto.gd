class_name Objeto
extends Node2D
## Objeto que Felipe tira de un manotazo: el vaso (se rompe y da «La Gravedad Funciona»), la taza de café, las macetas
## y la planta (aturden a lo que esté debajo), las llaves y el portarretratos (no se rompen). Todo el comportamiento está en su
## pieza Tirable; este nodo solo lo dibuja: apoyado en el medio de la cubierta con su sombra de contacto, cayendo
## (gira) o roto en el piso. En la pelea lo roto vuelve a su lugar de a uno (Tirable.reponer, lo decide BatallaAspi).
## Escala de gato: vaso, taza, maceta y llaves al doble de su tamaño real (lado menor ≥ 24 px, R8).
## Escena: escenas/entidades/objeto_tirable.tscn; qué objeto es lo dicen sus datos (datos/objetos/vaso.tres...).

const ESCENA := "res://escenas/entidades/objeto_tirable.tscn"

@export var datos: DatosObjeto
var tirable: Tirable
## Lo roto: el charco crece en este tiempo; los pedazos van en este grupo (se borran al reponer).
const CRECER := 0.45
const GRUPO_PEDAZOS := "pedazos_rotos"
var _tiempo_roto := 0.0

## Qué es: "vaso", "taza", "maceta", "planta", "portarretratos" o "llaves" (también la imagen de assets/nivel1/).
var tipo: String:
	get:
		return datos.tipo if datos else ""


## Fábrica: un objeto tirable con estos datos, apoyado `hundido` px dentro de la cubierta, que cae hasta `piso`.
static func crear(datos_objeto: DatosObjeto, piso: float, hundido := 0.0) -> Objeto:
	var objeto: Objeto = load(ESCENA).instantiate()
	objeto.datos = datos_objeto
	objeto.name = datos_objeto.nombre_de_nodo()
	objeto.tirable = Componentes.de(objeto, Tirable) as Tirable
	objeto.tirable.piso = piso
	objeto.tirable.hundido = hundido
	objeto.tirable.configurar(datos_objeto)
	return objeto


## Puesto a mano en el editor (sin la fábrica): toma su pieza y sus datos al entrar.
func _ready() -> void:
	if tirable == null:
		tirable = Componentes.de(self, Tirable) as Tirable
		if datos:
			tirable.configurar(datos)
	tirable.caido.connect(_al_romperse)
	tirable.repuesto.connect(_al_reponer)


func _draw() -> void:
	var roto := tirable.roto
	var hundido := tirable.hundido
	if not roto and not tirable.cayendo:
		var t := ArteNivel.textura(tipo)
		if t:
			# Sombra de contacto (Gemini, tanda 3F): 1 px más ancha que la base a cada lado; el vaso, además, sobre un
			# posavasos de 1 px.
			var ancho := t.get_width() * 0.8 + 2.0
			if tipo == "vaso":
				draw_rect(Rect2(-ancho / 2.0 - 1.0, hundido - 1.0, ancho + 2.0, 1.0), Color("8a4a3a"))
			ArteNivel.sombra(self, Vector2(0, hundido), ancho + 2.0, 0.5)
			ArteNivel.dibujar(self, tipo, 0.0, hundido - (1.0 if tipo == "vaso" else 0.0))
			return
	if not roto or not datos.se_rompe:
		ArteNivel.dibujar(self, tipo, 0.0, 0.0)
		return
	# Roto: el charco (o la tierra) en escalones de 2 tonos que se extiende, y lo que queda apoyado. Los pedazos son
	# PiezaSuelta (rebotan y quedan quietos).
	_dibujar_charco()
	if datos.queda != "":
		ArteNivel.dibujar(self, datos.queda, 4.0, 1.0)


## Charco tendido en el piso: 3 filas (atrás más angosta, adelante más ancha), borde oscuro y el medio claro, sin
## degradado. Crece en 3 escalones en `CRECER` s.
func _dibujar_charco() -> void:
	if datos.charco_ancho <= 0.0:
		return
	var paso := ceilf(clampf(_tiempo_roto / CRECER, 0.0, 1.0) * 3.0) / 3.0
	var ancho := roundf(datos.charco_ancho * maxf(paso, 0.34))
	var alto := int(datos.charco_alto)
	# Tendido en el plano del piso: la fila de atrás (arriba) más angosta, la de adelante la más ancha.
	for fila in alto:
		var w := roundf(ancho * (0.6 + 0.4 * float(fila + 1) / float(alto)) / 2.0) * 2.0
		var y := float(fila) - 1.0
		draw_rect(Rect2(-w / 2.0, y, w, 1), datos.charco_oscuro)
		if fila < alto - 1 and w > 8.0:
			draw_rect(Rect2(-w / 2.0 + 3.0, y, w - 6.0, 1), datos.charco_claro)


func _process(delta: float) -> void:
	if tirable == null or not tirable.roto or not datos or not datos.se_rompe:
		return
	if _tiempo_roto < CRECER + 0.05:
		_tiempo_roto += delta
		queue_redraw()


## Se rompió en el piso: suelta sus pedazos (los mismos PiezaSuelta de las derrotas).
func _al_romperse(_donde: Vector2) -> void:
	if not datos or not datos.se_rompe:
		return
	_tiempo_roto = 0.0
	for nombre: String in datos.piezas_rotura:
		# Hacia los lados (entre 25° y 70° sobre el piso), para que se repartan alrededor del charco.
		var angulo := deg_to_rad(randf_range(25.0, 70.0))
		var lado := -1.0 if randi() % 2 == 0 else 1.0
		var vel := Vector2(cos(angulo) * lado, -sin(angulo)) * randf_range(datos.velocidad_piezas.x, datos.velocidad_piezas.y)
		var pieza := PiezaSuelta.crear(nombre, Vector2(0, -4), vel, 0.0)
		pieza.vueltas = randf_range(-2.0, 2.0)
		pieza.add_to_group(GRUPO_PEDAZOS)
		add_child(pieza)


## Vuelve entero (la pelea repone lo roto): se van los pedazos.
func _al_reponer() -> void:
	_tiempo_roto = 0.0
	for hijo in get_children():
		if hijo.is_in_group(GRUPO_PEDAZOS):
			hijo.queue_free()
