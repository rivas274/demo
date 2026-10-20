class_name DecoradoNivel1
extends RefCounted
## Decorado sin colisión del nivel 1 (lo que cuenta quién vive aquí y lo que se mueve): la pantalla y el teclado del
## escritorio de Valeria, los jirones del sofá y los calcetines que vuelan del cajón, la ropa doblada de la cama, la
## fachada y el toldo bajo el balcón, el nido que se llena de calcetines y el ambiente de cada cuarto (pelos, arañazos,
## polvo, enchufes, cables, croquetas, el segundero del reloj). Los nodos los crea ArteNivel1; aquí solo se dibuja.

var nivel: Nivel
var guion: GuionNivel1
var tiempo: float:
	get:
		return nivel.tiempo


func _init(de: Nivel, con_guion: GuionNivel1) -> void:
	nivel = de
	guion = con_guion


## Pantalla del monitor (en el mundo): ahí sale «jjjjjj» al pisar el teclado.
const PANTALLA_MONITOR := Rect2(7126 + 4, Nivel1.SUELO - 89 - 48 + 6, 36, 26)


## Decorado sin colisión: pantalla y teclado del escritorio, jirones del sofá, calcetines que vuelan.
func dibujar_decorado(c: Node2D) -> void:
	# Escritorio de Valeria: el monitor es arte (arriba-extra); la pantalla cambia al pisar el teclado.
	if not guion.teclado_pisado:
		_dibujar_serie(c)
	if guion.teclado_pisado:
		c.draw_rect(PANTALLA_MONITOR, Color("dfe8f2"))
		for fila in 3:
			Estilo.escribir(c, PANTALLA_MONITOR.position + Vector2(2, 9 + fila * 8), "jjjjjj", &"etiqueta", Color("2f2f6f"))
	_dibujar_teclado(c)
	# Jirones del plástico del sofá (G4): tiras brillantes que giran y caen.
	for j: Array in guion.arte.jirones:
		c.draw_set_transform(j[0], j[2] * tiempo)
		c.draw_rect(Rect2(-5, -2, 10, 4), Color(0.85, 0.93, 1.0, 0.85))
		c.draw_rect(Rect2(-5, -2, 10, 1), Color(1, 1, 1, 0.95))
		c.draw_set_transform(Vector2.ZERO)
	# Calcetines que vuelan del cajón.
	for v in guion.calcetines_volando:
		var t := fmod(v.z + tiempo * 1.2, 1.0)
		var punto := Vector2(v.x + (t - 0.5) * 80.0, v.y - sin(t * PI) * 90.0)
		ArteNivel.dibujar(c, "calcetin", punto.x, punto.y + 12)
	if guion.cajon_abierto:
		c.draw_rect(Rect2(Nivel1.CAJON.x - 8, Nivel1.CAJON.y - 8, 30, 10), Color("6e3a26"))
		c.draw_rect(Rect2(Nivel1.CAJON.x - 6, Nivel1.CAJON.y - 10, 26, 4), Color("e59aa2"))


## Pantalla del monitor de Valeria (crítica de Gemini: era un rectángulo azul plano). Su serie, en pixeles: noche
## azul en franjas, una lámpara, dos siluetas que se miran y un corazón que late; brillo que titila como una pantalla
## de verdad, un reflejo duro arriba a la izquierda y un poco de luz azul sobre el escritorio. El teclado (delante)
## tapa la mitad de abajo.
func _dibujar_serie(c: Node2D) -> void:
	var r := Rect2(PANTALLA_MONITOR.position + Vector2(0, 1), Vector2(PANTALLA_MONITOR.size.x - 1, 17))
	var bandas := [Color("1d2547"), Color("26355c"), Color("30486e"), Color("3a5a7c")]
	for i in bandas.size():
		c.draw_rect(Rect2(r.position.x, r.position.y + i * 4.0, r.size.x, 4.0 if i < bandas.size() - 1 else r.size.y - i * 4.0), bandas[i])
	# Lámpara de la escena y su halo.
	c.draw_rect(Rect2(r.position + Vector2(26, 3), Vector2(4, 4)), Color(1.0, 0.85, 0.45, 0.35))
	c.draw_rect(Rect2(r.position + Vector2(27, 4), Vector2(2, 2)), Color("ffe08a"))
	# Dos siluetas que se miran (cabeza, cuello y hombros), oscuras contra la noche.
	var sombra := Color("0d1020")
	for persona: Vector3 in [Vector3(7, 6, 1), Vector3(17, 5, -1)]:
		var p := r.position + Vector2(persona.x, persona.y)
		c.draw_rect(Rect2(p, Vector2(4, 4)), sombra)
		c.draw_rect(Rect2(p + Vector2(1 + persona.z, 1), Vector2(1, 1)), sombra)
		c.draw_rect(Rect2(p + Vector2(1, 4), Vector2(2, 1)), sombra)
		c.draw_rect(Rect2(p + Vector2(-1, 5), Vector2(6, 8)), sombra)
	# Corazón entre las dos (late con la escena).
	if int(tiempo * 2.0) % 2 == 0:
		var h := r.position + Vector2(13, 3)
		c.draw_rect(Rect2(h, Vector2(1, 1)), Color("ff7a9a"))
		c.draw_rect(Rect2(h + Vector2(2, 0), Vector2(1, 1)), Color("ff7a9a"))
		c.draw_rect(Rect2(h + Vector2(0, 1), Vector2(3, 1)), Color("ff7a9a"))
		c.draw_rect(Rect2(h + Vector2(1, 2), Vector2(1, 1)), Color("ff7a9a"))
	# Brillo de pantalla que titila y reflejo duro arriba a la izquierda.
	c.draw_rect(r, Color(0.7, 0.9, 1.0, 0.06 + 0.04 * sin(tiempo * 7.0)))
	c.draw_rect(Rect2(r.position + Vector2(1, 1), Vector2(6, 1)), Color(1, 1, 1, 0.45))
	c.draw_rect(Rect2(r.position + Vector2(1, 2), Vector2(2, 1)), Color(1, 1, 1, 0.3))
	# Luz azul de la pantalla sobre el escritorio, delante del monitor.
	c.draw_rect(Rect2(r.position.x - 6.0, Nivel1.SUELO - 89.0, r.size.x + 12.0, 2.0), Color(0.6, 0.85, 1.0, 0.12))


## Teclado de Valeria (arte de Gemini, consistencia-casa.png): del tamaño de TECLADO (52 × 24); pisado, las teclas se
## ven hundidas (más oscuro).
func _dibujar_teclado(c: Node2D) -> void:
	var teclado := ArteNivel.textura("teclado")
	if teclado == null:
		return
	var r := Nivel1.TECLADO
	var tinte := Color(0.75, 0.75, 0.8) if guion.teclado_pisado else Color.WHITE
	c.draw_texture(teclado, Vector2(r.position.x, r.end.y - teclado.get_height()), tinte)


## Ropa doblada de la cama (arriba-extra, 52 × 48): limpia y, después de que Felipe se acicala encima, con pelos.
## El arte está en 3/4 y termina en una punta (la esquina de adelante): apoyada en el borde del colchón se veía
## flotando (el creador, 2026-10-19). Se hunde ROPA_HUNDIDA px, así la fila ancha de abajo de la pila queda sobre el
## edredón y la punta, delante.


func dibujar_ropa(c: Interactivo) -> void:
	# El edredón se hunde bajo la pila: una sombra ancha y dos pliegues que salen hacia los lados.
	ArteNivel.sombra(c, Vector2(0, Nivel1.ROPA_HUNDIDA - 1.0), 58.0, 0.5)
	for lado: float in [-1.0, 1.0]:
		c.draw_line(Vector2(lado * 27.0, Nivel1.ROPA_HUNDIDA - 2.0), Vector2(lado * 36.0, Nivel1.ROPA_HUNDIDA - 5.0), Color(0.35, 0.12, 0.08, 0.45), 1.0)
		c.draw_line(Vector2(lado * 27.0, Nivel1.ROPA_HUNDIDA + 1.0), Vector2(lado * 34.0, Nivel1.ROPA_HUNDIDA + 3.0), Color(0.35, 0.12, 0.08, 0.35), 1.0)
	ArteNivel.dibujar(c, "ropa_pelos" if guion.ropa_firmada else "ropa_limpia", 0.0, Nivel1.ROPA_HUNDIDA)


## Fachada bajo el balcón y el toldo rayado de la panadería donde aterriza Felipe al saltar (G1). Simplificada al
## estilo del resto (M5): ladrillo terracota con hiladas suaves, ventanas con marco, alféizar y cortina, contorno oscuro
## como las piezas de Gemini, y el letrero PANADERÍA en el faldón del toldo (Felipe aterriza arriba: no lo tapa).
func dibujar_fachada(c: Node2D) -> void:
	var balcon := Nivel1.rect_de("balcon")
	# El tramo de fachada del edificio de Valeria alrededor de la puerta-ventana (B-1, tanda 3E).
	var fachada := ArteNivel.textura("fachada_balcon")
	if fachada:
		ArteNivel.dibujar(c, "fachada_balcon", Nivel1.FACHADA_BALCON.x + fachada.get_width() / 2.0, Nivel1.FACHADA_BALCON.y)
	var abajo := Nivel1.ALTO + Nivel1.CAIDA_BALCON + 40.0
	var oscuro := Color("241c1a")
	var muro := Rect2(balcon.position.x, Nivel1.ALTO, balcon.size.x, abajo - Nivel1.ALTO)
	c.draw_rect(muro, Color("a65a45"))
	# Hiladas de ladrillo, apenas marcadas (no compiten con Felipe, R14).
	var y := Nivel1.ALTO + 16.0
	var fila := 0
	while y < abajo:
		c.draw_rect(Rect2(muro.position.x, y, muro.size.x, 1), Color("94503d"))
		var x := muro.position.x + (0.0 if fila % 2 == 0 else 14.0)
		while x < muro.end.x:
			c.draw_rect(Rect2(x, y - 9, 1, 9), Color("94503d"))
			x += 28.0
		y += 10.0
		fila += 1
	# Losa del balcón (canto grueso) y su sombra.
	c.draw_rect(Rect2(balcon.position.x, Nivel1.ALTO, balcon.size.x, 12), Color("7d3f3f"))
	c.draw_rect(Rect2(balcon.position.x, Nivel1.ALTO, balcon.size.x, 2), Color("9a5b4c"))
	c.draw_rect(Rect2(balcon.position.x, Nivel1.ALTO + 12, balcon.size.x, 6), Color(0, 0, 0, 0.25))
	# Ventanas del piso de abajo: marco de madera, vidrio con luz, cortinas y alféizar.
	for x0: float in [7666.0, 7806.0]:
		var ventana := Rect2(x0, Nivel1.ALTO + 56, 70, 84)
		c.draw_rect(ventana.grow(6), oscuro)
		c.draw_rect(ventana.grow(5), Color("6e3a26"))
		c.draw_rect(ventana.grow(2), Color("8a5232"))
		c.draw_rect(ventana, Color("ffcf7a"))
		c.draw_rect(Rect2(ventana.position, Vector2(ventana.size.x, 20)), Color("ffe3a3"))
		c.draw_rect(Rect2(ventana.position.x, ventana.position.y, 14, ventana.size.y), Color("c0603f"))
		c.draw_rect(Rect2(ventana.end.x - 14, ventana.position.y, 14, ventana.size.y), Color("c0603f"))
		c.draw_rect(Rect2(ventana.position.x + 33, ventana.position.y, 4, ventana.size.y), Color("6e3a26"))
		c.draw_rect(Rect2(ventana.position.x, ventana.position.y + 40, ventana.size.x, 3), Color("6e3a26"))
		var alfeizar := Rect2(ventana.position.x - 10, ventana.end.y + 5, ventana.size.x + 20, 7)
		c.draw_rect(alfeizar.grow(1), oscuro)
		c.draw_rect(alfeizar, Color("c9b49a"))
		c.draw_rect(Rect2(alfeizar.position.x, alfeizar.end.y, alfeizar.size.x, 3), Color(0, 0, 0, 0.25))
	# Toldo de la panadería: rayas verdes y crema, faldón con el letrero y borde ondulado.
	var t := Nivel1.TOLDO
	var alto_rayas := 16.0
	var faldon := Rect2(t.position.x, t.position.y + alto_rayas, t.size.x, 16)
	for i in int(t.size.x / 20.0):
		var x := t.position.x + i * 20.0
		c.draw_rect(Rect2(x, t.position.y, 20, alto_rayas), Color("4f8a5b") if i % 2 == 0 else Color("efe4d0"))
	c.draw_rect(faldon, Color("efe4d0"))
	for i in int(t.size.x / 20.0):
		var x := t.position.x + i * 20.0
		c.draw_circle(Vector2(x + 10, faldon.end.y), 9.0, Color("4f8a5b") if i % 2 == 0 else Color("efe4d0"))
	c.draw_rect(Rect2(t.position.x, t.position.y, t.size.x, 3), Color("2e5a38"))
	c.draw_rect(Rect2(faldon.position.x, faldon.position.y, faldon.size.x, 1), oscuro)
	var letrero := "PANADERÍA"
	var ancho := roundf(Estilo.ancho(letrero, &"letrero"))
	Estilo.escribir(c, Vector2(t.get_center().x - ancho / 2.0, faldon.end.y - 3), letrero, &"letrero", Color("2e5a38"))
	c.draw_rect(Rect2(t.position.x, faldon.end.y + 10, t.size.x, 2), Color(0, 0, 0, 0.25))


## El nido de Su Majestad (la cesta de la sala): se llena a la vista con los calcetines del día.
func dibujar_nido(c: Node2D) -> void:
	var nombre := "cesta_vacia"
	if nivel.calcetines >= 3:
		nombre = "cesta_llena"
	elif nivel.calcetines >= 1:
		nombre = "cesta_3"
	ArteNivel.dibujar(c, nombre, 70.0, Nivel1.SUELO)


## Lo que cuenta quién vive aquí y lo que se mueve en cada cuarto (G9, G10 y las filas de cada cuarto del plan de
## ambientes). Todo es decorado sin colisión y de menos de 24 px; nada entra en un rectángulo sagrado.
const PELO_CREMA := Color("e8dccb")


const PELO_GRIS := Color("7a7470")


const POLVO := Color(0.55, 0.49, 0.43, 0.75)


func dibujar_ambiente(c: Node2D) -> void:
	# Pelos de Felipe (crema y gris, nunca blanco): sofá, edredón, cojín y alfombras.
	var asiento := nivel.pieza("Asiento del sofá")
	var y_sofa := asiento.position.y if asiento else Nivel1.SUELO - 49.0
	for x: float in [298.0, 318.0, 352.0, 384.0, 428.0, 440.0]:
		_pelo(c, Vector2(x, y_sofa), int(x) % 3)
	for x: float in [6040.0, 6070.0, 6112.0, 6198.0, 6214.0]:
		_pelo(c, Vector2(x, Nivel1.SUELO - 65.0), int(x) % 3)
	for x: float in [5374.0, 5388.0, 5412.0, 5424.0]:
		_pelo(c, Vector2(x, Nivel1.SUELO - 20.0), int(x) % 3)
	for alfombra: Array in Nivel1.ALFOMBRAS:
		var t := ArteNivel.textura(alfombra[0])
		if t:
			for k in 3:
				_pelo(c, Vector2(alfombra[1] + t.get_width() * (0.2 + k * 0.3), Nivel1.SUELO + 4.0), k)
	# Arañazos viejos a la altura de Felipe (marcas sueltas de la tanda 3C, al 70 %).
	var marca := Color(1, 1, 1, 0.7)
	var entornada: Puerta = nivel.puertas.get(Nivel1.PUERTA_DORMITORIO)
	if entornada:
		ArteNivel.dibujar(c, "aranazo_1", entornada.position.x - 63.0, Nivel1.PARED_BASE - 22.0, false, marca)
	ArteNivel.dibujar(c, "aranazo_2", 6406.0, Nivel1.SUELO - 22.0, false, marca)
	ArteNivel.dibujar(c, "aranazo_3", 754.0, Nivel1.SUELO - 20.0, false, marca)
	# Polvo en lo alto: ropero, refrigerador, librero y alacenas, y una pelusa sobre el refrigerador.
	for linea: Vector3 in [Vector3(6398, 6498, Nivel1.SUELO - 186), Vector3(Nivel1.REFRIGERADOR_X + 10.0, Nivel1.REFRIGERADOR_X + 74.0, Nivel1.SUELO - 217), Vector3(2164, 2264, Nivel1.SUELO - 219), Vector3(Nivel1.ALACENAS_X + 22.0, Nivel1.ALACENAS_X + 188.0, Nivel1.SUELO - 261)]:
		c.draw_rect(Rect2(linea.x, linea.z, linea.y - linea.x, 1), POLVO)
	_pelo(c, Vector2(Nivel1.REFRIGERADOR_X + 67.0, Nivel1.SUELO - 217), 2)
	# Sala (S-4): enchufe en la pared, sobre el zócalo, y el cable del cargador del portátil, con su luz que late.
	_enchufe(c, Vector2(140, Nivel1.PARED_BASE - 13))
	_cable(c, Vector2(143, Nivel1.PARED_BASE - 7), Vector2(208, Nivel1.SUELO - 2), 5.0)
	c.draw_rect(Rect2(210, Nivel1.SUELO - 4, 2, 1), Color(0.4, 1.0, 0.5, 0.35 + 0.35 * sin(tiempo * 3.0)))
	# Cocina: croquetas regadas junto al tazón (C-7), segundero del reloj (C-8) y la gota de la llave (C-5).
	for croqueta: Vector2 in [Vector2(3031, Nivel1.SUELO - 2), Vector2(3036, Nivel1.SUELO - 1), Vector2(3039, Nivel1.SUELO - 3), Vector2(2990, Nivel1.SUELO - 1), Vector2(2996, Nivel1.SUELO - 2)]:
		c.draw_rect(Rect2(croqueta, Vector2(2, 2)), Color("9a6a3a"))
		c.draw_rect(Rect2(croqueta, Vector2(1, 1)), Color("c08a52"))
	var angulo := floorf(tiempo) / 60.0 * TAU - PI / 2.0
	var centro := Vector2(3230, Nivel1.DINTEL + 22.0)
	c.draw_line(centro, centro + Vector2(cos(angulo), sin(angulo)) * 8.0, Color("c0392b"), 1.0)
	# Estudio (E-3, E-4): enchufe y cable de la base de carga y post-its en el monitor (la impresora y la regleta con
	# sus cables se quitaron: recargaban la mesa, lección 30).
	_enchufe(c, Vector2(7260, Nivel1.PARED_BASE - 13))
	_cable(c, Vector2(7248, Nivel1.SUELO - 4), Vector2(7263, Nivel1.PARED_BASE - 7), 6.0)
	for nota: Array in [[Vector2(7166, Nivel1.SUELO - 135), Color("ffd95a")], [Vector2(7167, Nivel1.SUELO - 129), Color("f29ab0")], [Vector2(7124, Nivel1.SUELO - 136), Color("ffd95a")]]:
		c.draw_rect(Rect2(nota[0], Vector2(4, 4)), nota[1])
		c.draw_rect(Rect2(nota[0] + Vector2(0, 3), Vector2(4, 1)), (nota[1] as Color).darkened(0.25))


## Mechón de pelo de 3 a 5 px en los dos tonos de Felipe.
func _pelo(c: CanvasItem, p: Vector2, forma: int) -> void:
	var y := p.y - 1.0
	match forma:
		0:
			c.draw_rect(Rect2(p.x, y, 3, 1), PELO_CREMA)
			c.draw_rect(Rect2(p.x + 1, y - 1, 2, 1), PELO_GRIS)
		1:
			c.draw_rect(Rect2(p.x, y, 4, 1), PELO_GRIS)
			c.draw_rect(Rect2(p.x + 2, y - 1, 2, 1), PELO_CREMA)
			c.draw_rect(Rect2(p.x + 4, y - 2, 1, 1), PELO_CREMA)
		_:
			c.draw_rect(Rect2(p.x, y, 2, 1), PELO_CREMA)
			c.draw_rect(Rect2(p.x + 2, y - 1, 3, 1), PELO_CREMA)
			c.draw_rect(Rect2(p.x + 1, y - 1, 1, 1), PELO_GRIS)


## Enchufe de 6 × 8 px en el zócalo.
func _enchufe(c: CanvasItem, p: Vector2) -> void:
	c.draw_rect(Rect2(p, Vector2(6, 8)), Color("3a2a22"))
	c.draw_rect(Rect2(p + Vector2(1, 1), Vector2(4, 6)), Color("e6e0d4"))
	c.draw_rect(Rect2(p + Vector2(2, 2), Vector2(1, 1)), Color("3a2a22"))
	c.draw_rect(Rect2(p + Vector2(2, 5), Vector2(1, 1)), Color("3a2a22"))


## Cable de 1 px en dos tonos (oscuro con un brillo cada tanto) que cuelga entre dos puntos.
func _cable(c: CanvasItem, desde: Vector2, hasta: Vector2, caida: float) -> void:
	var puntos := PackedVector2Array()
	for i in 9:
		var t := i / 8.0
		puntos.append(desde.lerp(hasta, t) + Vector2(0, sin(t * PI) * caida))
	c.draw_polyline(puntos, Color("2b2622"), 1.0)
	for i in range(1, 8, 3):
		c.draw_rect(Rect2(puntos[i].round(), Vector2(1, 1)), Color("6a5e56"))
