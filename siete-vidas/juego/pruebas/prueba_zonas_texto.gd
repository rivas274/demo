extends SceneTree
## Zonas de texto (plan de estabilización 2026-10-20, decisión 3; tabla en ZonasTexto): recorre todos los anuncios,
## carteles y palabras posibles y comprueba que sus rectángulos no pisen las zonas prohibidas ni se salgan de 640×360,
## que el HUD quepa en su franja, que el nombre del jefe no se corte y que todos los caracteres de textos.csv existan
## en las letras del tema. Sin ventana:
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_zonas_texto.gd
## Termina con código 0 si todo pasa y 1 si algo falla.

var _fallos: Array[String] = []


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	_probar_tabla()
	_probar_letras()
	_probar_caracteres()
	var sala: Nivel = load("res://escenas/nivel_1.tscn").instantiate()
	sala.mostrar_titulo = false
	(sala.guion as GuionNivel1).batalla_con_jefe = false
	root.add_child(sala)
	await _esperar(30)
	_probar_hud(sala)
	await _probar_dialogo(sala)
	await _probar_anuncios(sala)
	await _probar_palabras(sala)
	_probar_barra_jefe()
	for fallo in _fallos:
		print("FALLA: ", fallo)
	print("Resultado: %d fallos" % _fallos.size())
	quit(1 if _fallos.size() > 0 else 0)


func _probar_tabla() -> void:
	_comprobar(ZonasTexto.HUD.end.y <= 27.0 and ZonasTexto.DIALOGO.position.y >= 30.0 and ZonasTexto.DIALOGO.end.y <= 81.0 and ZonasTexto.CARTELES.end.y <= 91.0, "Tabla: A y 0–26, B y 30–80, C y 30–90")
	_comprobar(ZonasTexto.en_zona_c(ZonasTexto.cartel(Hud.TAM_CARTEL)) and ZonasTexto.en_zona_c(ZonasTexto.cartel(Medidores.TAM_AVISO)), "Tabla: el cartel de travesura y el aviso de logro caben en la zona C")
	_comprobar(ZonasTexto.en_zona_c(ZonasTexto.cartel(Vector2(640, 52))), "Tabla: la franja de fase del jefe con su pista cabe en la zona C")


## Carteles y palabras con letra de 16 px o más (8 px de alto de mayúscula como mínimo).
func _probar_letras() -> void:
	var chicos := []
	for estilo: StringName in ZonasTexto.ESTILOS_C_Y_D:
		if Estilo.letra(estilo) < ZonasTexto.LETRA_MINIMA:
			chicos.append(estilo)
	_comprobar(chicos.is_empty(), "Letras: carteles y palabras con letra de %d px o más %s" % [ZonasTexto.LETRA_MINIMA, chicos])


## Todo carácter de textos.csv existe en todas las letras del tema (antes «♪» salía como «J» y las flechas, vacías).
func _probar_caracteres() -> void:
	var archivo := FileAccess.open("res://traducciones/textos.csv", FileAccess.READ)
	var caracteres := {}
	archivo.get_csv_line()
	while not archivo.eof_reached():
		var fila := archivo.get_csv_line()
		if fila.size() < 2:
			continue
		for i in fila[1].length():
			caracteres[fila[1].unicode_at(i)] = true
	var fuentes := {}
	var tema := Estilo.tema()
	for nombre in tema.get_font_list(Estilo.TIPO):
		var f := tema.get_font(nombre, Estilo.TIPO) as FontFile
		if f:
			fuentes[f.resource_path] = f
	if tema.default_font is FontFile:
		fuentes[tema.default_font.resource_path] = tema.default_font
	var faltan := []
	for ruta: String in fuentes:
		var fuente: FontFile = fuentes[ruta]
		for codigo: int in caracteres:
			if codigo > 32 and not fuente.has_char(codigo):
				faltan.append("%s:%s" % [ruta.get_file(), String.chr(codigo)])
	_comprobar(faltan.is_empty() and fuentes.size() >= 3, "Caracteres: los de textos.csv existen en las %d letras del tema %s" % [fuentes.size(), faltan])


func _probar_hud(sala: Nivel) -> void:
	var t := sala.travesuras
	var fuera := []
	var medidores := sala.get_node("Interfaz/Medidores") as Medidores
	if not ZonasTexto.HUD.encloses(Medidores.PANEL):
		fuera.append("corazones")
	var corazones := Rect2(medidores.corazones.position + Vector2(-7, -7), Vector2(Medidores.PASO_CORAZONES * 5.0, 15))
	if not ZonasTexto.HUD.encloses(corazones):
		fuera.append("corazones dibujados")
	if not ZonasTexto.HUD.encloses(Rect2(Hud.X0, Hud.Y0, Hud.ANCHO_AGENDA, Estilo.medida(&"alto_hud"))):
		fuera.append("agenda")
	var ultimo := 0.0
	for clave: String in t.hud.contadores:
		var c: ContadorRecurso = t.hud.contadores[clave]
		var r := Rect2(c.position, c.size)
		ultimo = maxf(ultimo, r.end.x)
		if not ZonasTexto.HUD.encloses(r):
			fuera.append(clave)
	var barra := Rect2(PresentacionJefe.POS_BARRA, Vector2(_ancho_barra_jefe(), BarraVida.ALTO_MARCO))
	if not ZonasTexto.HUD.encloses(barra):
		fuera.append("barra del jefe")
	_comprobar(fuera.is_empty(), "Zona A: corazones, agenda, contadores y barra del jefe caben en y 0–26 %s" % [fuera])
	_comprobar(ultimo < barra.position.x and Medidores.PANEL.end.x < Hud.X0, "Zona A: nada se monta (corazones < agenda; contadores hasta %.0f < barra del jefe en %.0f)" % [ultimo, barra.position.x])


func _ancho_barra_jefe() -> float:
	var barra: BarraVida = (load(PresentacionJefe.ESCENA_BARRA) as PackedScene).instantiate()
	var ancho := barra.tam_barra.x + BarraVida.HUECO_LADO * 2.0
	barra.free()
	return ancho


func _probar_dialogo(sala: Nivel) -> void:
	var d := sala.travesuras.dialogo
	d.limpiar()
	sala.felipe.global_position = Vector2(300, Nivel1.SUELO)
	await _esperar(20)
	d.decir("felipe", "Una frase de prueba para la zona B, de dos líneas si hace falta: así se ve dónde cae el cuadro.", 0, true)
	await _esperar(2)
	_comprobar(ZonasTexto.DIALOGO.encloses(d.rect_en_pantalla()), "Zona B: el cuadro de diálogo cabe en y 30–80 (%s)" % d.rect_en_pantalla())
	d.limpiar()


func _probar_anuncios(sala: Nivel) -> void:
	var t := sala.travesuras
	var a := t.anuncios
	var medidores := sala.get_node("Interfaz/Medidores") as Medidores
	a.limpiar()
	t.dialogo.limpiar()
	a.mostrados.clear()
	# Un cartel con diálogo en pantalla: espera su turno.
	t.dialogo.decir("felipe", "Una frase cualquiera.", 0, true)
	t.hud.cartel("UI_TRAVESURA_CUMPLIDA", "AGENDA_ROBAR_EL_ALMUERZO_DE", false)
	await _esperar(45)
	_comprobar(a.actual.is_empty(), "Zona C: con diálogo en pantalla, el cartel espera su turno")
	t.dialogo.limpiar()
	await _esperar_que(func() -> bool: return not a.actual.is_empty(), 120)
	_comprobar(not a.actual.is_empty() and not t.dialogo.ocupado(), "Zona C: al terminar el diálogo sale el cartel")
	# Mientras se ve el cartel, una frase normal espera (no se monta).
	t.dialogo.decir("felipe", "Otra frase que espera.", 0)
	await _esperar(2)
	_comprobar(not t.dialogo.ocupado(), "Zona C: mientras se ve un cartel, el diálogo espera (misma franja)")
	await _esperar_que(func() -> bool: return t.dialogo.ocupado(), 400)
	_comprobar(t.dialogo.ocupado() and t.dialogo.texto_actual == "Otra frase que espera.", "Zona C: la frase que esperaba sale después del cartel (no se pierde)")
	t.dialogo.limpiar()
	# Todos los tipos: travesura, secreta, poder nuevo, logro y fase del jefe (urgente).
	t.hud.cartel("UI_TRAVESURA_SECRETA", "AGENDA_ROBAR_EL_ALMUERZO_DE", true)
	t.hud.cartel("CARTEL_PODER_NUEVO", "CARTEL_CAER_DE_PIE", false)
	medidores.mostrar_logro("Coleccionista de Calcetines")
	a.anunciar("fase", "¡DEPÓSITO LLENO!", Vector2(640, 52), func(_r: Rect2) -> float: return 1.0, Callable(), true)
	var a_la_vez := 0
	for i in 1500:
		var en_pantalla := 0
		for hijo in t.hud.get_children():
			if hijo is Cartel and not hijo.is_queued_for_deletion():
				en_pantalla += 1
		if medidores.mostrando_logro():
			en_pantalla += 1
		a_la_vez = maxi(a_la_vez, en_pantalla)
		if not a.ocupado():
			break
		await physics_frame
	var malos := []
	var tipos := {}
	for m: Array in a.mostrados:
		tipos[m[0]] = true
		if not ZonasTexto.en_zona_c(m[2]):
			malos.append("%s %s" % [m[1], m[2]])
	_comprobar(malos.is_empty() and tipos.size() == 3, "Zona C: carteles, logro y fase (%s) salen todos en y 30–90, sin tocar el HUD %s" % [tipos.keys(), malos])
	_comprobar(a_la_vez <= 1, "Zona C: uno a la vez (máximo visto: %d)" % a_la_vez)
	# El final de un jefe (lo que se vio mal en el video): franja de fase urgente («¡APAGADA!») con cámara lenta y una
	# frase urgente de Felipe al mismo tiempo, y después un cartel de travesura. Nunca dos textos en la franja a la vez y
	# la cámara lenta no estira la franja (antes no se probaba con frases urgentes ni con cámara lenta).
	t.dialogo.limpiar()
	a.limpiar()
	await _esperar(2)
	t.dialogo.decir("felipe", "Una frase que estaba en pantalla.", 0, true)
	a.anunciar("fase", "¡APAGADA!", Vector2(640, 32), func(_r: Rect2) -> float: return 1.2, Callable(), true)
	Engine.time_scale = 0.3
	var montados := 0
	var reloj := 0
	var dijo_despues := false
	for i in 900:
		await process_frame
		if not a.actual.is_empty() and a.actual.get("tipo", "") == "fase":
			reloj = i
			if i == 5:
				t.dialogo.decir("felipe", "Una frase urgente durante la franja.", 0, true)
			if i == 8:
				t.hud.cartel("UI_TRAVESURA_CUMPLIDA", "AGENDA_ROBAR_EL_ALMUERZO_DE", false)
		if not a.actual.is_empty() and t.dialogo.ocupado():
			montados += 1
		if a.actual.is_empty() and t.dialogo.texto_actual == "Una frase urgente durante la franja.":
			dijo_despues = true
		if i > 30 and not a.ocupado() and not t.dialogo.ocupado():
			break
	Engine.time_scale = 1.0
	_comprobar(montados == 0, "Zona C: con la franja de fase del jefe, en cámara lenta y con frases urgentes, nunca se ven diálogo y cartel a la vez (%d cuadros montados)" % montados)
	_comprobar(dijo_despues, "Zona C: la frase urgente que llegó durante la franja sale después (no se pierde)")
	t.dialogo.limpiar()
	a.limpiar()
	# El cartel dibujado (cinta, pergamino y letras) queda dentro de su rectángulo.
	var cartel := Cartel.crear("¡TRAVESURA CUMPLIDA!", "Coleccionista de calcetines", false, ZonasTexto.cartel(Hud.TAM_CARTEL))
	var dentro := true
	for hijo in cartel.get_children():
		var c := hijo as Control
		var r := Rect2(cartel.position + c.position, c.size)
		if hijo is Label:
			# Lo que se ve de la letra: su alto de línea (no la caja con aire de abajo).
			r.size.y = (hijo as Label).get_line_height()
		dentro = dentro and ZonasTexto.en_zona_c(r)
	cartel.free()
	_comprobar(dentro, "Zona C: la cinta, el pergamino y las letras del cartel no se salen de y 30–90")


func _probar_palabras(sala: Nivel) -> void:
	var j := sala.travesuras.jugo
	var claves: Array[String] = []
	var archivo := FileAccess.open("res://traducciones/textos.csv", FileAccess.READ)
	while not archivo.eof_reached():
		var fila := archivo.get_csv_line()
		if fila.size() >= 2 and fila[0].begins_with("PALABRA_"):
			claves.append(fila[0])
	var malas := []
	var puntos := [Vector2(320, 10), Vector2(5, 50), Vector2(630, 200), Vector2(320, 355), Vector2(100, 120), Vector2(600, 30)]
	for clave in claves:
		for punto: Vector2 in puntos:
			for tamano in [14, 22]:
				j.palabra(clave, punto, Color.WHITE, tamano)
				if not ZonasTexto.palabra_valida(j.ultima_caja):
					malas.append("%s en %s → %s" % [clave, punto, j.ultima_caja])
	_comprobar(malas.is_empty() and claves.size() > 15, "Zona D: las %d palabras, en cualquier punto, quedan fuera de A, B y C y dentro de la pantalla %s" % [claves.size(), malas.slice(0, 4)])
	await _esperar(2)
	var vivas := 0
	for hijo in j.get_children():
		if hijo.name.begins_with("Palabra") and not hijo.is_queued_for_deletion():
			vivas += 1
	_comprobar(vivas <= 1, "Zona D: como máximo una palabra a la vez (%d)" % vivas)
	# Sobre Felipe: no lo tapa; si está la burbuja del Indicador, la palabra va por encima o por debajo, nunca encima.
	var felipe := sala.felipe
	felipe.global_position = Vector2(1000, Nivel1.SUELO)
	await _esperar(30)
	var lienzo := root.get_viewport().get_canvas_transform()
	j.palabra_en_mundo("PALABRA_CRITICO", felipe.global_position + Vector2(0, -40), Color.WHITE, 22)
	var pies := lienzo * felipe.global_position
	var felipe_ocupa := Rect2(pies + Vector2(-38, -74), Vector2(76, 76))
	_comprobar(not j.ultima_caja.intersects(felipe_ocupa) and ZonasTexto.palabra_valida(j.ultima_caja), "Zona D: «¡CRÍTICO!» sobre Felipe no lo tapa (%s)" % j.ultima_caja)
	var indicador := sala.travesuras.indicador
	indicador.verbo = "Degustar"
	var burbuja := indicador.rect_burbuja()
	var burbuja_pantalla := Rect2(lienzo * burbuja.position, burbuja.size)
	j.palabra_en_mundo("PALABRA_NAM", burbuja.get_center(), Color.WHITE, 15)
	_comprobar(not j.ultima_caja.intersects(burbuja_pantalla) and ZonasTexto.palabra_valida(j.ultima_caja), "Zona E: una palabra que cae en la burbuja del Indicador se mueve (%s, burbuja %s)" % [j.ultima_caja, burbuja_pantalla])
	indicador.verbo = ""
	# Una palabra que cae en la cara de Valeria (el chiste es su reacción) se corre.
	var valeria: Valeria = (sala.guion as GuionNivel1).valeria
	felipe.global_position = Vector2(300, Nivel1.SUELO)
	await _esperar(30)
	lienzo = root.get_viewport().get_canvas_transform()
	var cara := valeria.rect_dibujado()
	cara.size.y = minf(cara.size.y, 90.0)
	var cara_pantalla := Rect2(lienzo * cara.position, cara.size)
	j.palabra_en_mundo("PALABRA_GARRAS_AFILADAS", cara.get_center(), Color.WHITE, 13)
	_comprobar(valeria.visible and not j.ultima_caja.intersects(cara_pantalla) and ZonasTexto.palabra_valida(j.ultima_caja), "Zona D: una palabra no le tapa la cara a Valeria (%s, cara %s)" % [j.ultima_caja, cara_pantalla])


func _probar_barra_jefe() -> void:
	var barra: BarraVida = (load(PresentacionJefe.ESCENA_BARRA) as PackedScene).instantiate()
	barra.forma = BarraVida.Forma.BARRA
	barra.titulo = "A.S.P.I. — Devoradora de Pelos · Nivel 99"
	barra.titulo_corto = "A.S.P.I."
	var texto := barra.titulo_visible()
	_comprobar(not texto.ends_with("…") and Estilo.ancho(texto, &"jefe_barra") <= barra.tam_barra.x, "Zona A: el nombre del jefe se abrevia hasta caber entero («%s», nunca «N…»)" % texto)
	barra.free()


func _esperar_que(condicion: Callable, maximo: int) -> void:
	for i in maximo:
		if condicion.call():
			return
		await process_frame


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("OK    " if condicion else "FALLA ") + descripcion)
	if not condicion:
		_fallos.append(descripcion)
