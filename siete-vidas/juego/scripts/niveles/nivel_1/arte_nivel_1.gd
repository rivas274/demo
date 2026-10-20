class_name ArteNivel1
extends RefCounted
## Arte del nivel 1 (Gemini, assets/nivel1/; ArteNivel lo carga): crea los lienzos por capa y dibuja lo que va en cada
## uno. Las piezas de la lista Nivel1.ARTE se dibujan con las funciones genéricas de ArteNivel (dibujar_capa, sombras de
## pared y de contacto); aquí queda solo lo propio de esta casa: la cortina del dormitorio, el armario bajo la escalera,
## la ventana del pasillo con la pizza afuera, las alfombras tendidas, el sofá que cambia al romper el plástico, la
## baranda con sus plantas, el grifo que gotea y el pasamanos delante de Felipe. El decorado sin colisión (pantalla,
## teclado, fachada, nido, pelos, cables) lo dibuja DecoradoNivel1. Nada de esto toca colisiones ni lógica.

## Lienzos del arte por capa ("pared", "escalera", "mueble"): se redibujan cuando algo cambia de imagen (G4).
var lienzos := {}
## Nodos de dibujo que se crean en su lugar del orden de dibujo.
var decorado: Node2D
var ambiente: Node2D
var grifo: Node2D
var sombras: SombrasVivas
var nido: Node2D
var pasamanos: Node2D
## Imagen del sofá que se dibujó por última vez (las pruebas ven que cambió al romper el plástico).
var sofa_dibujado := ""
## Jirones de plástico que vuelan al romperlo: [posición, velocidad, giro].
var jirones: Array = []
var _paso_brisa := -1

var nivel: Nivel
var guion: GuionNivel1
var tiempo: float:
	get:
		return nivel.tiempo


func _init(de: Nivel, con_guion: GuionNivel1) -> void:
	nivel = de
	guion = con_guion


## Antes de las piezas: el fondo en capas y los tres lienzos del arte (pared, escalera, muebles).
func crear_fondo() -> void:
	nivel.add_child(FondoApartamento.new(Nivel1.ANCHO, Nivel1.ALTO))
	for capa: Array in [["pared", Capas.ARTE_PARED], ["escalera", Capas.ESCALERA], ["mueble", Capas.MUEBLES]]:
		var lienzo := Node2D.new()
		lienzo.name = "Arte (%s)" % capa[0]
		lienzo.z_index = capa[1]
		lienzo.draw.connect(_dibujar_arte.bind(lienzo, capa[0]))
		nivel.add_child(lienzo)
		lienzos[capa[0]] = lienzo


## Después de la ropa y el oído de la cocina: fachada, decorado, ambiente, grifo, sombras en vivo y nido.
func crear_decorado() -> void:
	# Bajo el balcón: la fachada y el toldo de la panadería (solo se ven en el salto final, G1).
	var fachada := _nodo("Fachada", Capas.FACHADA)
	fachada.draw.connect(guion.decorado.dibujar_fachada.bind(fachada))
	decorado = _nodo("Decorado", Capas.MUEBLES)
	decorado.draw.connect(func() -> void: guion.decorado.dibujar_decorado(decorado))
	ambiente = _nodo("Ambiente", Capas.MUEBLES)
	ambiente.draw.connect(func() -> void: guion.decorado.dibujar_ambiente(ambiente))
	grifo = _nodo("Grifo", Capas.MARCAS)
	grifo.draw.connect(_dibujar_grifo)
	# Sombras de contacto de lo que se mueve (Felipe, Valeria, A.S.P.I., ratones, caja, comida): debajo de ellos y
	# encima de los muebles (se apoyan también arriba de un mueble).
	sombras = SombrasVivas.new(nivel.felipe)
	sombras.name = "Sombras"
	sombras.z_index = Capas.MUEBLES
	nivel.add_child(sombras)
	nido = _nodo("Nido", Capas.MUEBLES)
	nido.draw.connect(func() -> void: guion.decorado.dibujar_nido(nido))


## Al final: el pasamanos de la escalera, delante de Felipe (baja a 70 % de opacidad mientras sube).
func crear_pasamanos() -> void:
	pasamanos = Node2D.new()
	pasamanos.name = "Pasamanos"
	pasamanos.z_index = Capas.PRIMER_PLANO
	pasamanos.draw.connect(func() -> void:
		var datos: Array = Nivel1.PASAMANOS
		var textura := ArteNivel.textura(datos[0])
		if textura:
			ArteNivel.dibujar(pasamanos, datos[0], datos[1].x + textura.get_width() / 2.0, datos[1].y, datos[2])
		# Arañazos viejos en el poste de arranque, a la altura de Felipe (G9).
		ArteNivel.dibujar(pasamanos, "aranazo_3", 2333.0, Nivel1.SUELO - 24.0, false, Color(1, 1, 1, 0.7)))
	nivel.add_child(pasamanos)


func _nodo(nombre: String, z: int) -> Node2D:
	var nodo := Node2D.new()
	nodo.name = nombre
	nodo.z_index = z
	nivel.add_child(nodo)
	return nodo


## Lo que se mueve en el dibujo, cada cuadro.
func cada_cuadro(delta: float) -> void:
	var felipe := nivel.felipe
	var habitacion := nivel.habitacion
	ambiente.queue_redraw()
	grifo.queue_redraw()
	sombras.queue_redraw()
	# La cortina con brisa (D-4) y las plantas de la baranda (B-4) se mecen cada 0,5 s.
	var paso := int(tiempo * 2.0)
	if paso != _paso_brisa and habitacion in ["dormitorio", "balcon"]:
		_paso_brisa = paso
		redibujar_muebles()
	var en_escalera := felipe.en_escalera() or (habitacion == "recibidor" and felipe.global_position.x > Nivel1.CAJAS.end.x and felipe.global_position.y < Nivel1.SUELO - 4.0)
	pasamanos.modulate.a = Nivel1.OPACIDAD_PASAMANOS if en_escalera else 1.0
	if habitacion == "pasillo":
		# El vapor de la pizza se mueve.
		(lienzos["pared"] as Node2D).queue_redraw()
	if not guion.calcetines_volando.is_empty() or habitacion == "estudio":
		# En el estudio la serie del monitor titila.
		decorado.queue_redraw()
	if not jirones.is_empty():
		for j: Array in jirones:
			j[1].y += 600.0 * delta
			j[0] += j[1] * delta
		jirones = jirones.filter(func(j: Array) -> bool: return j[0].y < Nivel1.SUELO)
		decorado.queue_redraw()


## El sofá cambió de imagen (G4) o algo se mece: se redibuja la capa de los muebles.
func redibujar_muebles() -> void:
	(lienzos["mueble"] as Node2D).queue_redraw()


## Los jirones del plástico del sofá salen volando (G4).
func soltar_jirones(centro: Vector2) -> void:
	for i in 10:
		var x := centro.x + randf_range(-90.0, 90.0)
		jirones.append([Vector2(x, Nivel1.SUELO - randf_range(40.0, 95.0)), Vector2(randf_range(-80.0, 80.0), randf_range(-220.0, -120.0)), randf_range(-8.0, 8.0)])
	decorado.queue_redraw()


## Cada lienzo: lo de atrás, las piezas de Nivel1.ARTE de su capa y lo de adelante.
func _dibujar_arte(c: Node2D, capa: String) -> void:
	if capa == "mueble":
		# La cortina va detrás de la cómoda, la cesta y el ropero.
		_dibujar_cortina(c)
	elif capa == "pared":
		ArteNivel.sombras_de_pared(c, Nivel1.ARTE, Nivel1.SOMBRA_PARED)
	ArteNivel.dibujar_capa(c, Nivel1.ARTE, capa, Nivel1.APOYADOS, {"baranda": _dibujar_baranda})
	if capa == "escalera":
		_dibujar_armario_escalera(c)
	elif capa == "pared":
		_dibujar_ventana_pasillo(c)
		# Alfombras tendidas en el piso, en perspectiva (antes de las sombras de contacto).
		for alfombra: Array in Nivel1.ALFOMBRAS:
			_dibujar_alfombra(c, alfombra[0], alfombra[1])
		_dibujar_sombras_de_contacto(c)
	elif capa == "mueble":
		_dibujar_sofa(c)
		# Imanes del refrigerador.
		for iman: Array in [["iman_manzana", Vector2(Nivel1.REFRIGERADOR_X + 26.0, Nivel1.SUELO - 150)], ["iman_foto", Vector2(Nivel1.REFRIGERADOR_X + 48.0, Nivel1.SUELO - 166)], ["iman_pez", Vector2(Nivel1.REFRIGERADOR_X + 34.0, Nivel1.SUELO - 128)], ["iman_naranja", Vector2(Nivel1.REFRIGERADOR_X + 56.0, Nivel1.SUELO - 140)]]:
			ArteNivel.dibujar(c, iman[0], iman[1].x, iman[1].y)


## Lo que no deja sombra de contacto (es de fondo).
const SIN_SOMBRA := ["escalera_peldanos", "vano"]


## Sombras de contacto de los muebles apoyados en el piso (ArteNivel.sombras_de_contacto) y las propias de esta casa:
## el nido de Su Majestad, el armario bajo la escalera y el charco de luz de la lámpara de pie.
func _dibujar_sombras_de_contacto(c: Node2D) -> void:
	var piezas: Array = []
	for datos: Array in Nivel1.ARTE:
		if datos[3] == "mueble" and datos[1].y >= Nivel1.SUELO - 0.5 and not datos[0] in SIN_SOMBRA:
			piezas.append(datos)
	piezas.append_array(Nivel1.ARTE_EXTRA)
	ArteNivel.sombras_de_contacto(c, piezas, Nivel1.PARED_BASE)
	# Nido de Su Majestad (cesta de la sala) y armario bajo la escalera.
	ArteNivel.sombra(c, Vector2(70, Nivel1.SUELO), 64.0, 0.4)
	c.draw_rect(Rect2(2400, Nivel1.SUELO - 2.0, 240, 4), Color(ArteNivel.COLOR_SOMBRA, 0.3))
	# Charco de luz de la lámpara de pie, en franjas (no un degradado suave), tendido en el piso.
	var lampara := Vector2(1959, Nivel1.SUELO)
	for franja: Vector3 in [Vector3(80, -6, 0.06), Vector3(60, -3, 0.07), Vector3(38, 0, 0.09)]:
		c.draw_rect(Rect2(lampara.x - franja.x / 2.0, lampara.y + franja.y, franja.x, 12.0 - 2.0 * absf(franja.y) / 3.0), Color(1.0, 0.85, 0.5, franja.z))


## Alfombra tendida en el piso: el arte se estira en un trapecio que va de 12 px detrás de la línea de apoyo (más angosto,
## se aleja) a 6 px delante, así se ve acostada sobre el plano del piso y no parada contra la pared.
func _dibujar_alfombra(c: Node2D, nombre: String, x: float) -> void:
	var t := ArteNivel.textura(nombre)
	if t == null:
		return
	var w := float(t.get_width())
	var atras := Nivel1.SUELO - 12.0
	var delante := Nivel1.SUELO + 6.0
	var angosta := w * 0.04
	var puntos := PackedVector2Array([Vector2(x + angosta, atras), Vector2(x + w - angosta, atras), Vector2(x + w, delante), Vector2(x, delante)])
	c.draw_colored_polygon(PackedVector2Array([puntos[0] + Vector2(1, 2), puntos[1] + Vector2(1, 2), puntos[2] + Vector2(1, 2), puntos[3] + Vector2(1, 2)]), Color(ArteNivel.COLOR_SOMBRA, 0.3))
	c.draw_polygon(puntos, PackedColorArray([Color(0.82, 0.82, 0.82), Color(0.82, 0.82, 0.82), Color.WHITE, Color.WHITE]), PackedVector2Array([Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]), t)


## Gota del grifo de cuello de cisne del mesón (C-5; el grifo y el fregadero son arte de Gemini desde la cocina v2): se
## forma en la boca y cae a la cuba, cada 3 s. Va en su propia capa, delante del ratón del mesón.
func _dibujar_grifo() -> void:
	var c := grifo
	var caida := fmod(tiempo, 3.0)
	var gota := Nivel1.GRIFO
	var caida_total := 4.0
	if caida < 0.8:
		c.draw_rect(Rect2(gota.x, gota.y + 1.0, 1, 2), Color(0.6, 0.85, 1.0, caida / 0.8))
	elif caida < 1.0:
		var t := (caida - 0.8) / 0.2
		c.draw_rect(Rect2(gota.x, gota.y + 1.0 + t * t * caida_total, 1, 2), Color(0.6, 0.85, 1.0))


## Baranda del balcón con sus plantas que se mecen 1 px (B-4), cada maceta con su fase.
func _dibujar_baranda(c: Node2D, pos: Vector2) -> void:
	var t := ArteNivel.textura("baranda")
	if t == null:
		return
	var arriba := pos.y - t.get_height()
	var corte := 38.0
	var paso := int(tiempo * 2.0)
	c.draw_texture_rect_region(t, Rect2(pos.x, arriba + corte, t.get_width(), t.get_height() - corte), Rect2(0, corte, t.get_width(), t.get_height() - corte))
	for maceta: Vector3 in [Vector3(0, 95, 0), Vector3(95, t.get_width() - 95, 1)]:
		var vaiven := 1.0 if (paso + int(maceta.z)) % 2 == 0 else 0.0
		c.draw_texture_rect_region(t, Rect2(pos.x + maceta.x + vaiven, arriba, maceta.y, corte), Rect2(maceta.x, 0, maceta.y, corte))


## Armario bajo la escalera (pedido del creador, 2026-10-19: el faldón con una puertita no se entendía). Tablas
## verticales que cierran el hueco triangular bajo el larguero (siguen los peldaños) y el de bajo el descanso, con zócalo
## propio y moldura bajo el larguero; una puerta con la parte de arriba inclinada como la escalera, entreabierta, con su
## manilla, una caja adentro y la escoba que asoma con las cerdas en el piso. Arriba, el rellano grueso del descanso.
const ESCALERA_X := 2322.0


const ARMARIO_FIN := 2640.0


const PUERTA_ARMARIO := Rect2(2462, 0, 50, 0)


var _larguero: PackedFloat32Array = PackedFloat32Array()


## Borde de abajo del larguero en cada columna (en el mundo), medido en el arte de los peldaños (va en espejo).
func _borde_larguero() -> PackedFloat32Array:
	if not _larguero.is_empty():
		return _larguero
	var t := ArteNivel.textura("escalera_peldanos")
	if t == null:
		return _larguero
	var imagen := t.get_image()
	var ancho := imagen.get_width()
	for k in ancho:
		var columna := ancho - 1 - k
		var abajo := imagen.get_height()
		for y in range(imagen.get_height() - 1, -1, -1):
			if imagen.get_pixel(columna, y).a > 0.5:
				abajo = y + 1
				break
		_larguero.append(Nivel1.SUELO - imagen.get_height() + abajo)
	return _larguero


func _dibujar_armario_escalera(c: Node2D) -> void:
	var larguero := _borde_larguero()
	var arriba_rellano := Nivel1.SUELO - 150.0
	var rellano := Rect2(2532, arriba_rellano, ARMARIO_FIN - 2532, 14)
	var oscuro := Color("241c1a")
	var tabla := Color("6e4630")
	var junta := Color("553324")
	var luz := Color("8a5a3c")
	# Techo del armario en cada columna: bajo el larguero y, después de la escalera, bajo el rellano.
	var techo := func(x: float) -> float:
		var k := int(x - ESCALERA_X)
		if k >= 0 and k < larguero.size() and x < 2536.0:
			return larguero[k]
		return rellano.end.y
	# Tablas: columnas de 1 px desde el techo hasta el piso, con una junta cada 12 px y un bisel claro a su lado.
	var x := ESCALERA_X
	while x < ARMARIO_FIN:
		var y: float = techo.call(x)
		if Nivel1.SUELO - y > 6.0:
			var k := int(x - ESCALERA_X) % 12
			var color := junta if k == 0 else (luz if k == 1 else tabla)
			c.draw_rect(Rect2(x, y, 1, Nivel1.SUELO - y), color)
			# Moldura bajo el larguero (sigue los peldaños).
			c.draw_rect(Rect2(x, y, 1, 2), oscuro)
			c.draw_rect(Rect2(x, y + 2, 1, 1), Color("9a6a48"))
		x += 1.0
	# Zócalo del armario.
	c.draw_rect(Rect2(2340, Nivel1.SUELO - 7, ARMARIO_FIN - 2340, 7), Color("5a3626"))
	c.draw_rect(Rect2(2340, Nivel1.SUELO - 7, ARMARIO_FIN - 2340, 1), Color("9a6a48"))
	# Puerta: abajo recta, arriba inclinada como el larguero (6 px bajo él), entreabierta hacia la izquierda.
	var p0 := PUERTA_ARMARIO.position.x
	var p1 := PUERTA_ARMARIO.end.x
	var arriba0: float = techo.call(p0) + 6.0
	var arriba1: float = techo.call(p1) + 6.0
	var abajo := Nivel1.SUELO - 8.0
	var marco := PackedVector2Array([Vector2(p0 - 3, arriba0 - 3), Vector2(p1 + 3, arriba1 - 3), Vector2(p1 + 3, abajo + 1), Vector2(p0 - 3, abajo + 1)])
	c.draw_colored_polygon(marco, oscuro)
	# Adentro, oscuro, con una caja de cartón y el palo de la escoba.
	var hueco := PackedVector2Array([Vector2(p0, arriba0), Vector2(p1, arriba1), Vector2(p1, abajo), Vector2(p0, abajo)])
	c.draw_colored_polygon(hueco, Color("1a1312"))
	c.draw_rect(Rect2(p1 - 22, abajo - 16, 20, 16), Color("8a6a44"))
	c.draw_rect(Rect2(p1 - 22, abajo - 16, 20, 2), Color("a8845a"))
	c.draw_rect(Rect2(p1 - 13, abajo - 16, 2, 16), Color("6e5236"))
	# La escoba es arte de Gemini (tanda 3F, ARTE «escoba»), apoyada fuera del armario (lección 32).
	# Hoja abierta un poco: se angosta hacia la bisagra (izquierda) y deja ver el hueco a la derecha.
	var hoja_fin := p1 - 26.0
	var hoja := PackedVector2Array([Vector2(p0, arriba0), Vector2(hoja_fin, lerpf(arriba0, arriba1, (hoja_fin - p0) / (p1 - p0)) - 2.0), Vector2(hoja_fin, abajo + 1.0), Vector2(p0, abajo)])
	c.draw_colored_polygon(hoja, Color("7d5038"))
	c.draw_polyline(hoja + PackedVector2Array([hoja[0]]), Color("4a2c1e"), 1.0)
	c.draw_rect(Rect2(p0 + 3, abajo - 30, hoja_fin - p0 - 6, 22), Color("8a5a3c"))
	c.draw_rect(Rect2(p0 + 3, abajo - 30, hoja_fin - p0 - 6, 1), Color("a8744e"))
	# Manilla: pomo dorado con su brillo.
	c.draw_rect(Rect2(hoja_fin - 6, abajo - 40, 4, 4), Color("c9a24a"))
	c.draw_rect(Rect2(hoja_fin - 6, abajo - 40, 2, 1), Color("f2d98a"))
	# Rellano: tabla gruesa con canto claro y sombra abajo.
	c.draw_rect(rellano.grow(1), oscuro)
	c.draw_rect(rellano, Color("8a5a3c"))
	c.draw_rect(Rect2(rellano.position, Vector2(rellano.size.x, 3)), Color("b07a52"))
	c.draw_rect(Rect2(rellano.position.x, rellano.end.y - 3, rellano.size.x, 3), Color("6e3a26"))
	c.draw_rect(Rect2(rellano.position.x, rellano.end.y + 1, rellano.size.x, 3), Color(0, 0, 0, 0.3))


## Ventana del pasillo (G3): la caja de pizza está AFUERA, sobre el toldo del vecino, detrás del vidrio (el arte de
## Gemini la traía sobre el alféizar; la herramienta la borra). El vidrio con reflejos va encima de la caja.
func _dibujar_ventana_pasillo(c: Node2D) -> void:
	# Parte de arriba de la ventana (M7): sigue las columnas del arte hacia arriba (contorno, marco del muro, marco de
	# madera, panel de la izquierda, parante y vidrio), así la ventana es una sola y no una caja encima del arte.
	var arriba := Nivel1.VENTANA_PASILLO_ARRIBA
	var izq := arriba.position.x
	var oscuro := Color8(31, 8, 4)
	var columnas := [
		[4, 10, Color8(210, 179, 150)], [12, 2, Color8(222, 194, 173)], [14, 4, Color8(186, 124, 80)],
		[18, 48, Color8(212, 181, 152)], [66, 10, Color8(199, 157, 135)], [162, 4, Color8(149, 86, 51)],
		[167, 9, Color8(210, 179, 150)],
	]
	for columna: Array in columnas:
		c.draw_rect(Rect2(izq + columna[0], arriba.position.y, columna[1], arriba.size.y), columna[2])
	var cielo := Rect2(Nivel1.VIDRIO_PASILLO.position.x, arriba.position.y + 5, Nivel1.VIDRIO_PASILLO.size.x - 1, arriba.size.y - 3)
	for i in 6:
		c.draw_rect(Rect2(cielo.position.x, cielo.position.y + i * cielo.size.y / 6.0, cielo.size.x, cielo.size.y / 6.0 + 1), Color(0.98, 0.86, 0.66).lerp(Color(0.95, 0.72, 0.6), i / 6.0))
	# Techos lejanos del vecindario, pálidos.
	for techo: Vector3 in [Vector3(4720, 24, 14), Vector3(4742, 18, 22), Vector3(4772, 30, 10), Vector3(4784, 20, 18)]:
		c.draw_rect(Rect2(techo.x, arriba.end.y - techo.z, techo.y, techo.z), Color(0.83, 0.6, 0.55))
	# Contornos oscuros (afuera, junto al parante y al marco derecho) y el dintel de madera arriba.
	for x: float in [4.0, 76.0, 166.0, 175.0]:
		c.draw_rect(Rect2(izq + x, arriba.position.y, 1, arriba.size.y), oscuro)
	c.draw_rect(Rect2(izq + 4, arriba.position.y, 172, 5), Color8(185, 122, 81))
	c.draw_rect(Rect2(izq + 4, arriba.position.y + 4, 172, 1), Color8(143, 86, 57))
	c.draw_rect(Rect2(izq + 4, arriba.position.y, 172, 1), oscuro)
	# Caja de pizza AFUERA, sobre el toldo del vecino (G3), abierta: tapa levantada con la mancha de grasa, la pizza
	# adentro y vapor que sube (un poco azulada: está lejos y tras el vidrio).
	var caja := Nivel1.PIZZA
	var lejos := Color(0.9, 0.92, 1.0)
	var base := Rect2(caja.position.x, caja.end.y - 9, caja.size.x, 9)
	var tapa := PackedVector2Array([base.position + Vector2(3, 0), base.position + Vector2(caja.size.x - 3, 0), Vector2(caja.end.x - 6, caja.position.y + 3), Vector2(caja.position.x + 6, caja.position.y + 3)])
	c.draw_colored_polygon(tapa, Color("d9b074") * lejos)
	c.draw_polyline(tapa + PackedVector2Array([tapa[0]]), Color("6e4a2a") * lejos, 1.0)
	c.draw_circle(Vector2(caja.position.x + 13, caja.position.y + 9), 4.0, Color("a8763c") * lejos)
	c.draw_circle(Vector2(caja.position.x + 21, caja.position.y + 7), 2.5, Color("a8763c") * lejos)
	c.draw_rect(base, Color("e0b878") * lejos)
	c.draw_rect(Rect2(base.position.x + 2, base.position.y + 1, base.size.x - 4, 4), Color("f2c14e") * lejos)
	for p: Vector2 in [Vector2(7, 2), Vector2(15, 3), Vector2(24, 2), Vector2(11, 4), Vector2(28, 4)]:
		c.draw_rect(Rect2(base.position + p, Vector2(2, 2)), Color("c0392b") * lejos)
	c.draw_rect(Rect2(base.position.x, base.position.y + 5, base.size.x, 4), Color("b98a50") * lejos)
	c.draw_rect(Rect2(base.position.x, base.end.y, base.size.x, 1), Color(0, 0, 0, 0.35))
	var t := tiempo
	for i in 3:
		var x0 := caja.position.x + 8.0 + i * 9.0
		var puntos := PackedVector2Array()
		for k in 6:
			var y := caja.position.y - 2.0 - k * 3.0 - fmod(t * 6.0 + i * 4.0, 3.0)
			puntos.append(Vector2(x0 + sin(k * 1.3 + t * 3.0 + i) * 2.0, y))
		c.draw_polyline(puntos, Color(1, 1, 1, 0.55), 1.0)
	# Vidrio: tinte frío y dos reflejos en diagonal por encima de la caja y del toldo.
	var vidrio := Nivel1.VIDRIO_PASILLO
	c.draw_rect(vidrio, Color(0.75, 0.88, 1.0, 0.14))
	# Los reflejos quedan dentro del vidrio (no cruzan al panel de la izquierda).
	for desde: float in [34.0, 76.0]:
		c.draw_colored_polygon(PackedVector2Array([
			vidrio.position + Vector2(desde, 0), vidrio.position + Vector2(desde + 8, 0),
			vidrio.position + Vector2(desde - 22, vidrio.size.y), vidrio.position + Vector2(desde - 30, vidrio.size.y),
		]), Color(1, 1, 1, 0.16))


## Cortina del dormitorio (arte de Gemini, `dormitorio-cortina-alta`): dos paños, el derecho en espejo, colgados de
## una sola barra con un remate en cada punta, a los lados de la ventana que está sobre la cama; el tramo de barra entre
## los paños se estira desde una columna de la misma barra (`cortina_barra`). La barra va CORTINA_SOBRE_VENTANA px
## sobre el marco y la tela baja hasta el piso (lo que sobra del arte no se dibuja), detrás de la cama y la cómoda.
## Sin colisión: en el nivel 1 no se trepa (con Afilar Garras se subirá por la tela hasta la barra y, de ahí, a la
## repisa alta con la caja de recuerdos).
## Alto del ruedo de la cortina que se mueve con la brisa.
const RUEDO := 6.0


func _dibujar_cortina(c: Node2D) -> void:
	var textura := ArteNivel.textura("cortina")
	if textura == null:
		return
	var ancho := float(textura.get_width())
	var arriba := Nivel1.VENTANA_DORMITORIO.position.y - 3.0 - Nivel1.CORTINA_SOBRE_VENTANA
	var alto := minf(Nivel1.PARED_BASE + 3.0 - arriba, float(textura.get_height()))
	var izquierda := Nivel1.VENTANA_DORMITORIO.position.x + Nivel1.CORTINA_ADENTRO - Nivel1.CORTINA_FIN_TELA
	var derecha := Nivel1.VENTANA_DORMITORIO.end.x - Nivel1.CORTINA_ADENTRO + Nivel1.CORTINA_FIN_TELA
	var barra := ArteNivel.textura("cortina_barra")
	if barra:
		var desde := izquierda + ancho
		c.draw_texture_rect(barra, Rect2(desde, arriba + 1.0, derecha - ancho - desde, barra.get_height()), false)
	# Brisa (D-4): el ruedo (los últimos RUEDO px de cada paño) se corre 1 px de forma alterna cada 0,5 s, con otra
	# fase en cada paño (el derecho va en espejo). Antes se corría la mitad de abajo y dejaba un escalón a media
	# altura del paño (G10 de la revisión de consistencia).
	var medio := alto - RUEDO
	var paso := int(tiempo * 2.0)
	for pano in 2:
		var vaiven := 1.0 if (paso + pano) % 2 == 0 else 0.0
		if pano == 1:
			c.draw_set_transform(Vector2(derecha, 0.0), 0.0, Vector2(-1, 1))
		var x := izquierda if pano == 0 else 0.0
		c.draw_texture_rect_region(textura, Rect2(x, arriba, ancho, medio), Rect2(0, 0, ancho, medio))
		c.draw_texture_rect_region(textura, Rect2(x + vaiven, arriba + medio, ancho, alto - medio), Rect2(0, medio, ancho, alto - medio))
		c.draw_set_transform(Vector2.ZERO)


func _dibujar_sofa(c: Node2D) -> void:
	var nombre := "sofa_aranado" if guion.sofa_roto else "sofa_plastico"
	sofa_dibujado = nombre
	var textura := ArteNivel.textura(nombre)
	if textura:
		ArteNivel.dibujar(c, nombre, Nivel1.ARTE_EXTRA[0][1].x + textura.get_width() / 2.0, Nivel1.SUELO)
	# «NUEVO» va escrito sobre las etiquetas de Gemini que ya cuelgan del rascador (G3 de la revisión de
	# consistencia: antes era un rectángulo de código flotando al lado, y otro junto al sofá, que no trae etiqueta).
	var rascador := Vector2(Nivel1.RASCADOR_X - 50.0, Nivel1.SUELO - 165.0)
	for etiqueta: Rect2 in ETIQUETAS_RASCADOR:
		_escribir_nuevo(c, Rect2(rascador + etiqueta.position, etiqueta.size))


## Etiquetas blancas que cuelgan en el arte del rascador (en px de su imagen de 100 × 165).
const ETIQUETAS_RASCADOR := [Rect2(63, 29, 9, 14), Rect2(9, 78, 9, 14)]
const TINTA_NUEVO := Color(0.75, 0.1, 0.1)


## «NUEVO» en una etiqueta de 9 × 14 px: a ese tamaño no cabe la palabra con ninguna letra, así que se ve como una
## etiqueta de precio a escala de gato: renglones rojos de pixel (el chiste del sofá nuevo lo cuentan el Indicador y
## la agenda: «Arañar el sofá nuevo»).
func _escribir_nuevo(c: CanvasItem, etiqueta: Rect2) -> void:
	var x := etiqueta.position.x + 2.0
	c.draw_rect(Rect2(x, etiqueta.position.y + 5.0, 5.0, 1.0), TINTA_NUEVO)
	c.draw_rect(Rect2(x, etiqueta.position.y + 8.0, 3.0, 1.0), TINTA_NUEVO)
	c.draw_rect(Rect2(x + 4.0, etiqueta.position.y + 8.0, 1.0, 1.0), TINTA_NUEVO)
