class_name DibujoBatallaAspi
extends RefCounted
## Dibujo de la pelea con A.S.P.I. (BatallaAspi): la imaginación de Felipe en la entrada (el estudio en llamas y la
## bestia gigante), las manchas que ella va a limpiar, lo que va delante de todo (viento de la succión, papeles, aviso
## del depósito lleno, barra de reinicio) y las bolas de pelo. Cada parte se dibuja en su nodo y su capa (Capas); aquí
## solo se lee el estado de la pelea, nunca se cambia.

var b: BatallaAspi


func _init(de: BatallaAspi) -> void:
	b = de


func bola(bola: Node2D) -> void:
	# Escala de gato: bolas de pelo grandes y legibles (el dibujo gira con el nodo).
	var arte := ArteNivel.textura("bola_pelo")
	bola.draw_texture(arte, -arte.get_size() / 2.0)


## La imaginación de Felipe en la entrada: el estudio en llamas y la bestia gigante, POR ENCIMA de todo el escenario
## (capa Capas.IMAGINACION; B1). El estudio real se desvanece con `transformacion` y vuelve al final del rugido.
## La gigante nace de la A.S.P.I. real (mismo lugar y ancho) y al final se encoge hasta ella.
func imaginacion(c: Node2D) -> void:
	var tiempo := Time.get_ticks_msec() / 1000.0
	if b.transformacion > 0.0:
		var a := b.transformacion
		c.draw_texture_rect(ArteNivel.textura("fin_del_mundo"), b.arena, false, Color(1, 1, 1, a))
		if b.rayo > 0.0:
			c.draw_rect(b.arena, Color(1, 0.9, 0.9, 0.18 * b.rayo * a))
	if b.gigante > 0.0:
		var arte := ArteNivel.textura("aspi_gigante")
		var tam := arte.get_size()
		var k := ease(b.gigante, 0.6)
		var escala := lerpf(b.aspi.datos.ancho / tam.x, 1.0, k)
		# Desde (y hacia) donde está la A.S.P.I. real ahora: los empujones la movieron.
		var origen := b.aspi.global_position + Vector2(0, -tam.y * escala / 2.0)
		var centro := origen.lerp(b.centro_gigante + Vector2(0, sin(tiempo * 2.0) * 5.0), k)
		if b.fase == BatallaAspi.Fase.ENTRADA and b.gigante < 1.0 and not b.desvaneciendo:
			# Temblor de sueño mientras crece.
			centro += Vector2(sin(tiempo * 40.0), cos(tiempo * 33.0)) * 2.0
		var mira := 1.0 if b.felipe.global_position.x >= centro.x else -1.0
		c.draw_set_transform(centro, sin(tiempo * 1.3) * 0.03 * k, Vector2(escala * mira, escala))
		c.draw_texture(arte, -tam / 2.0)
		# Luz de borde cálida del incendio (crítica de Gemini): la silueta oscura no se funde con el fondo. Late con
		# las llamas y crece con la imaginación (en la A.S.P.I. chica no se nota).
		var luz := ArteNivel.textura("aspi_gigante_luz")
		if luz:
			c.draw_texture(luz, -tam / 2.0, Color(1, 1, 1, k * (0.8 + 0.2 * sin(tiempo * 9.0))))
		c.draw_set_transform(Vector2.ZERO)


## Las manchas en el piso (tierra de maceta, agua, papel) que A.S.P.I. va a limpiar, y la pelusa que tiembla en la espera.
## Las de tipo "nodo" son una pieza que se dibuja sola (la nota, la mota de pelusa).
func manchas(c: Node2D) -> void:
	for i in b.manchas.size():
		match b.tipos_mancha[i]:
			"nodo":
				pass
			"papel":
				ArteNivel.dibujar(c, "papel", b.manchas[i], Nivel1.SUELO + 1.0)
			_:
				ArteNivel.dibujar(c, "mancha", b.manchas[i], Nivel1.SUELO + 2.0)
	if b.fase == BatallaAspi.Fase.ENTRADA and b.presentacion.paso_actual in ["espera", "revelar", "nombre", "barra", "musica", "tamano"]:
		var t := Time.get_ticks_msec() / 1000.0
		for i in 12:
			var x := b.arena.position.x + 60.0 + i * 46.0
			c.draw_circle(Vector2(x + sin(t * 30.0 + i) * 1.5, Nivel1.SUELO - 3), 3.0, Color(0.88, 0.85, 0.8, 0.9))


## Delante de todo: el viento de la succión, el cepillo que gira, papeles que vuelan y el aviso del depósito lleno.
func encima(c: Node2D) -> void:
	var tiempo := Time.get_ticks_msec() / 1000.0
	for p in b.papeles:
		var x := p.x + p.y * 160.0
		var y := Nivel1.SUELO - 40.0 - sin(p.y * 3.0 + p.z * 6.0) * 60.0 - p.y * 40.0
		c.draw_set_transform(Vector2(x, y), p.y * 6.0 + p.z)
		ArteNivel.dibujar(c, "papel_arrugado", 0.0, 10.0)
		c.draw_set_transform(Vector2.ZERO)
	if b.reinicio > 0.0 and b.fase == BatallaAspi.Fase.PELEA:
		# Barra de reinicio sobre la carcasa (no es un rótulo: no pisa al «¡CLIC!»); el texto sale cuando el «¡CLIC!» ya se fue.
		var barra := Rect2(b.aspi.global_position + Vector2(-18, -BatallaAspi.ALTO_ARRIBA - 12), Vector2(36, 4))
		c.draw_rect(barra.grow(1), Color(0.05, 0.1, 0.15, 0.9))
		c.draw_rect(Rect2(barra.position, Vector2(barra.size.x * (1.0 - b.reinicio / b.datos.reinicio), barra.size.y)), Color("9fd8ff"))
		if tiempo - b.tiempo_clic > BatallaAspi.DURA_CLIC and b.pelusa.en_camino == 0 and tiempo - b.pelusa.ultimo > 1.0:
			# Zonas de texto (2026-10-20): letra de 16 px con contorno de 1 px, no la chica de 8.
			var texto_reinicio := tr("JEFE_REINICIANDO") + ".".repeat(int(tiempo * 3.0) % 4)
			var punto := b.aspi.global_position + Vector2(-roundf(Estilo.ancho(tr("JEFE_REINICIANDO"), &"jefe_pista") / 2.0), -BatallaAspi.ALTO_ARRIBA - 18)
			Estilo.texto_con_contorno(c, punto, texto_reinicio, &"jefe_pista", Color("9fd8ff"), &"contorno_palabra", 2)
	if b.limpiar.reloj_aviso > 0.0 and not b.limpiando:
		# Anticipación de la succión: el cepillo gira y se ven líneas de aire.
		for i in 6:
			var angulo := tiempo * 18.0 + i * TAU / 6.0
			var centro := b.aspi.global_position + Vector2(0, -6)
			c.draw_line(centro, centro + Vector2(cos(angulo), sin(angulo) * 0.4) * 14.0, Color(0.9, 0.95, 1.0, 0.8), 1.0)
	_aviso_embestida(c, tiempo)
	_aviso_bolas(c)
	_charcos(c, tiempo)
	if b.llena:
		# Por encima de la tapa abierta (que sube unos 32 px).
		var arriba := b.aspi.global_position + Vector2(0, -BatallaAspi.ALTO_ARRIBA - 52)
		if int(tiempo * 4.0) % 2 == 0:
			c.draw_circle(b.aspi.global_position + Vector2(0, -BatallaAspi.ALTO_ARRIBA - 4), 5.0, Color("e0483b"))
		var texto := tr("JEFE_DEPOSITO_LLENO") if b.motivo != "charco" else tr("JEFE_EN_CORTO")
		var ancho := roundf(Estilo.ancho(texto, &"jefe_pista"))
		# El cartelito no se corta en el borde de la pantalla (lección 23): se corre adentro; la flecha sigue sobre ella.
		var vista := c.get_viewport().get_canvas_transform().affine_inverse() * Rect2(ZonasTexto.PANTALLA)
		var centro_x := clampf(arriba.x, vista.position.x + ancho / 2.0 + 8.0, vista.end.x - ancho / 2.0 - 8.0)
		c.draw_rect(Rect2(centro_x - ancho / 2.0 - 6, arriba.y - 13, ancho + 12, 18), Color(0.1, 0.05, 0.07, 0.85))
		Estilo.escribir(c, Vector2(centro_x - ancho / 2.0, arriba.y + 1), texto, &"jefe_pista", Color("ffe066"))
		# Flecha hacia abajo: hay que caerle encima.
		c.draw_colored_polygon(PackedVector2Array([arriba + Vector2(-6, 8), arriba + Vector2(6, 8), arriba + Vector2(0, 16)]), Color("ffe066"))
	if b.ataque == BatallaAspi.Ataque.SOPLIDO or b.ataque == BatallaAspi.Ataque.AVISO_SOPLIDO:
		for i in 8:
			var avance := fmod(tiempo * 2.0 + i * 0.13, 1.0)
			var x := b.aspi.global_position.x - 20.0 + i * 5.0
			c.draw_line(Vector2(x, b.aspi.global_position.y - 40.0 - avance * 120.0), Vector2(x, b.aspi.global_position.y - 52.0 - avance * 120.0), Color(1, 1, 0.8, 0.6 * (1.0 - avance)), 1.5)
	if not b.succionando:
		return
	var x_jefa := b.aspi.global_position.x
	var radio: float = DatosJefe.por_fase(b.limpiar.radio_succion, b.vencidas)
	for i in 16:
		var lado := -1.0 if i % 2 == 0 else 1.0
		var avance := fmod(tiempo * 1.4 + i * 0.37, 1.0)
		var x := x_jefa + lado * (1.0 - avance) * radio
		var y := Nivel1.SUELO - 6.0 - fmod(i * 23.0, 70.0)
		if b.arena.has_point(Vector2(x, y)):
			c.draw_line(Vector2(x, y), Vector2(x + lado * 18.0, y), Color(Color("dff3ff"), 0.7 * avance), 1.5)


## Aviso de embestida en el piso (crítica de Gemini): una línea roja de puntos desde A.S.P.I. hasta donde va a cargar,
## que parpadea mientras retrocede. Así se lee aunque ella esté lejos o el cuarto esté a oscuras.
func _aviso_embestida(c: Node2D, tiempo: float) -> void:
	if b.ataque != BatallaAspi.Ataque.AVISO_EMBESTIDA:
		return
	var embestida := b.conducta("embestida") as AtaqueEmbestida
	var y := b.aspi.global_position.y + b.aspi.datos.profundidad + 2.0
	var desde := b.aspi.global_position.x
	var hasta := embestida.destino
	var paso := 6.0 * signf(hasta - desde)
	if paso == 0.0:
		return
	var color := Color("e0483b") if int(tiempo * 8.0) % 2 == 0 else Color("ff9a7a")
	var x := desde + paso * 3.0
	while (hasta - x) * signf(paso) > 0.0:
		c.draw_rect(Rect2(roundf(x) - 1.0, y, 3.0, 2.0), color)
		x += paso
	# Y el círculo donde termina la carga (el tramo «telegrafiado», que se lee también en la penumbra).
	ReaccionesAspi.marca(c, Vector2(roundf(hasta), y), b.reacciones.datos.radio_marca, Color("e0483b"))


## Donde va a caer la bola de pelo (fase 3): la marca aparece con la tos y sigue hasta que la bola llega.
func _aviso_bolas(c: Node2D) -> void:
	var bola := b.conducta("bola") as AtaqueBolaPelo
	if bola == null or (b.ataque != BatallaAspi.Ataque.AVISO_BOLA and b.bolas.is_empty()):
		return
	ReaccionesAspi.marca(c, bola.objetivo + Vector2(0, 2), b.reacciones.datos.radio_marca, Color("ffd23f"))


## En el apagón, los charcos de agua y café brillan (1 px de reflejo que titila): son la clave de la fase 3.
func _charcos(c: Node2D, tiempo: float) -> void:
	if not b.apagon.activo:
		return
	var corto := b.conducta("cortocircuito") as ConductaCortocircuito
	if corto == null:
		return
	for charco in corto.charcos():
		var ancho := roundf(charco.y * 0.6)
		var x := roundf(charco.x - ancho / 2.0 + (int(tiempo * 3.0) % 3) * 2.0)
		c.draw_rect(Rect2(x, Nivel1.SUELO - 1.0, ancho, 1.0), Color(0.75, 0.95, 1.0, 0.85))
		c.draw_rect(Rect2(x + 3.0, Nivel1.SUELO, maxf(ancho - 8.0, 2.0), 1.0), Color(0.55, 0.85, 1.0, 0.6))
