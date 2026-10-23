class_name Objeto
extends Node2D
## Objeto que Felipe tira de un manotazo: el vaso (se rompe y da «La Gravedad Funciona»), la taza de café, las macetas
## y la planta (aturden a lo que esté debajo), las llaves y el portarretratos (no se rompen). Todo el comportamiento está en su
## pieza Tirable; este nodo solo lo dibuja: apoyado en el medio de la cubierta con su sombra de contacto, cayendo
## (gira) o caído en el piso, donde queda hasta el final con su sombra (nada vuelve a su lugar: decisión del creador,
## 2026-10-23; lo roto es el trofeo de Felipe).
## Escala de gato: vaso, taza, maceta y llaves al doble de su tamaño real (lado menor ≥ 24 px, R8).
## Escena: escenas/entidades/objeto_tirable.tscn; qué objeto es lo dicen sus datos (datos/objetos/vaso.tres...).

const ESCENA := "res://escenas/entidades/objeto_tirable.tscn"

@export var datos: DatosObjeto
var tirable: Tirable
## Lo roto: el charco crece en este tiempo; los pedazos van en este grupo.
const CRECER := 0.45
const GRUPO_PEDAZOS := "pedazos_rotos"
var _tiempo_roto := 0.0
## Cuántos pedazos deja al romperse como mucho (-1 = todos los de sus datos; la pelea con A.S.P.I. pide menos, v5).
var max_pedazos := -1

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
	# Profundidad por rol: apoyado sobre su mueble; al caer, lo que se toca; en el piso, resto.
	var nivel := Componentes.nivel(self)
	var donde := nivel.superficie_en(global_position) if nivel else "piso"
	Profundidad.poner(self, datos.rol if datos else Capas.Rol.APOYADO, PackedStringArray([donde]))
	tirable.empujado.connect(func(_f: Felipe) -> void: Profundidad.poner(self, Capas.Rol.OBJETO_JUEGO))
	tirable.caido.connect(func(_donde: Vector2) -> void: Profundidad.poner(self, Capas.Rol.RESTO_PISO))


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
		if roto:
			# Caído entero (el portarretratos, las llaves): queda en el piso con su sombra.
			var arte := ArteNivel.textura(tipo)
			if arte:
				ArteNivel.sombra(self, Vector2(0, 1), arte.get_width() * 0.9 + 2.0, 0.45)
		ArteNivel.dibujar(self, tipo, 0.0, 0.0, false, PiezaSuelta.tinte_resto if roto else Color.WHITE)
		return
	# Roto: el charco (o la tierra) en escalones de 2 tonos que se extiende, y lo que queda apoyado. Los pedazos son
	# PiezaSuelta (rebotan y quedan quietos).
	_dibujar_charco()
	if datos.queda != "":
		var queda := ArteNivel.textura(datos.queda)
		if queda:
			ArteNivel.sombra(self, Vector2(4, 2), queda.get_width() * 0.8 + 2.0, 0.4)
		ArteNivel.dibujar(self, datos.queda, 4.0, 1.0, false, PiezaSuelta.tinte_resto)


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
	var piezas := datos.piezas_rotura
	if max_pedazos >= 0 and piezas.size() > max_pedazos:
		piezas = piezas.slice(0, max_pedazos)
	for nombre: String in piezas:
		# Hacia los lados (entre 25° y 70° sobre el piso), para que se repartan alrededor del charco.
		var angulo := deg_to_rad(randf_range(25.0, 70.0))
		var lado := -1.0 if randi() % 2 == 0 else 1.0
		var vel := Vector2(cos(angulo) * lado, -sin(angulo)) * randf_range(datos.velocidad_piezas.x, datos.velocidad_piezas.y)
		var pieza := PiezaSuelta.crear(nombre, Vector2(0, -4), vel, 0.0)
		pieza.vueltas = randf_range(-2.0, 2.0)
		pieza.con_sombra = true
		pieza.add_to_group(GRUPO_PEDAZOS)
		add_child(pieza)
