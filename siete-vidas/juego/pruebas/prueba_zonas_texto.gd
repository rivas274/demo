extends SceneTree
## Zonas de texto (tabla en ZonasTexto; layout v2 aprobado el 2026-10-23): recorre todos los anuncios, carteles y
## palabras posibles y comprueba que sus rectángulos no pisen las zonas prohibidas ni se salgan de la zona segura (90 %),
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
	await _probar_hud_limpio(sala)
	await _probar_dialogo(sala)
	await _probar_anuncios(sala)
	await _probar_palabras(sala)
	_probar_barra_jefe()
	for fallo in _fallos:
		print("FALLA: ", fallo)
	print("Resultado: %d fallos" % _fallos.size())
	quit(1 if _fallos.size() > 0 else 0)


func _probar_tabla() -> void:
	_comprobar(ZonasTexto.SEGURA == Rect2(32, 18, 576, 324), "Tabla: zona segura de títulos del 90 % (de 32, 18 a 608, 342)")
	_comprobar(ZonasTexto.SEGURA.encloses(ZonasTexto.SALUD) and ZonasTexto.SEGURA.encloses(ZonasTexto.SALUD_GRANDE) and ZonasTexto.SEGURA.encloses(ZonasTexto.JEFE) and ZonasTexto.SALUD.end.x < ZonasTexto.JEFE.position.x and ZonasTexto.SALUD_GRANDE.end.x < ZonasTexto.JEFE.position.x, "Tabla: la salud (A) y la barra del jefe (A2) dentro de la zona segura y sin tocarse, también con texto grande")
	_comprobar(ZonasTexto.techo() == 44.0 and ZonasTexto.techo(true) == 64.0, "Tabla: diálogo y carteles desde y 44 (texto grande: 64)")
	ZonasTexto.jefe_visible = true
	var bajo_jefe := ZonasTexto.techo()
	ZonasTexto.jefe_visible = false
	_comprobar(bajo_jefe >= ZonasTexto.JEFE.end.y, "Tabla: con la barra del jefe a la vista, diálogo y carteles bajan (y %.0f)" % bajo_jefe)
	_comprobar(ZonasTexto.en_zona_c(ZonasTexto.cartel(Cartel.medida("¡TRAVESURA CUMPLIDA!", "Robar el almuerzo de Valeria"))) and ZonasTexto.en_zona_c(ZonasTexto.logro(Medidores.tam_logro("Coleccionista de Calcetines"))), "Tabla: el cartel de travesura y el logro caben en la zona C")
	var logro := ZonasTexto.logro(Medidores.tam_logro("Coleccionista de Calcetines"))
	_comprobar(logro.end.x == ZonasTexto.SEGURA.end.x, "Tabla: el logro va a la derecha (hasta x 608)")
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
	var medidores := sala.get_node("Interfaz/Medidores") as Medidores
	var salud := Rect2(medidores.huellas.position, medidores.huellas.medida())
	_comprobar(salud == ZonasTexto.SALUD and ZonasTexto.HUD.encloses(salud), "Zona A: la salud (cara y 9 huellas) en su lugar, de (32, 18), 152×20 (%s)" % salud)
	var barra := Rect2(PresentacionJefe.POS_BARRA, Vector2(BarraVida.ANCHO_JEFE, 44))
	_comprobar(ZonasTexto.JEFE.encloses(barra) and barra.end.x == ZonasTexto.SEGURA.end.x, "Zona A2: la barra del jefe arriba a la derecha, hasta x 608 (%s)" % barra)


## HUD mínimo (interfaz v2, decisión del creador del 2026-10-23): en pantalla solo la salud. Los snacks, las vidas, la
## agenda, los calcetines y las fotos NO están en el HUD; al recoger sale «+1» y se ven en la pausa (el bolsillo).
func _probar_hud_limpio(sala: Nivel) -> void:
	var hud := sala.travesuras.hud
	await _esperar(30)
	var visibles := []
	for hijo in hud.get_children():
		if hijo is Control and (hijo as Control).visible:
			visibles.append(hijo.name)
	_comprobar(visibles.is_empty(), "HUD mínimo: sin carteles, el HUD no muestra nada fijo (ni snacks ni vidas) %s" % [visibles])
	var palabras := sala.travesuras.jugo.palabras.size()
	sala.travesuras.recompensas.dar({"tipo": "calcetin", "cantidad": 1})
	await _esperar(2)
	_comprobar(sala.travesuras.jugo.palabras.size() > palabras and sala.travesuras.jugo.palabras[-1] == "+1", "HUD mínimo: al recoger algo sale «+1» sobre Felipe")
	var bolsillo := sala.pantallas.bolsillo
	bolsillo.actualizar()
	_comprobar(bolsillo != null and bolsillo.valores.has("snack") and bolsillo.valores["salud"] == "9 de 9" and bolsillo.valores["calcetin"] == str(sala.travesuras.recompensas.calcetines), "HUD mínimo: la salud, los snacks, los calcetines y las fotos están en el bolsillo de la pausa (%s)" % bolsillo.valores)


func _probar_dialogo(sala: Nivel) -> void:
	var d := sala.travesuras.dialogo
	d.limpiar()
	sala.felipe.global_position = Vector2(300, Nivel1.SUELO)
	await _esperar(20)
	d.decir("felipe", "Una frase de prueba para la zona B, de dos líneas si hace falta: así se ve dónde cae el cuadro.", 0, true)
	await _esperar(2)
	var cuadro := d.rect_en_pantalla()
	_comprobar(cuadro.position.y >= 44.0 and cuadro.end.y <= 103.0 and ZonasTexto.SEGURA.encloses(cuadro), "Zona B: el cuadro de diálogo va de y 44 a 103 (más su sombra), dentro de la zona segura (%s)" % cuadro)
	var caja: CuadroDialogo = d._caja
	_comprobar(caja.texto.position.x - caja.rect_caja().position.x == 24.0 and caja.ancho_texto() == 480.0, "Zona B: el texto empieza a 24 px del borde de la caja (13 px libres después del retrato)")
	d.limpiar()
	# Texto grande: diálogo de y 64 a 163, letra de 32 y la frase larga paginada.
	Opciones.texto_grande = true
	d.decir("valeria", "¿Quién dejó abierta la puerta del balcón? Felipe, si fuiste tú, hoy no hay atún para nadie.", 1, true)
	await _esperar(2)
	cuadro = d.rect_en_pantalla()
	_comprobar(cuadro.position.y >= 64.0 and cuadro.end.y <= 163.0 and d.paginas.size() == 2 and Estilo.letra(caja.estilo_texto()) == 32, "Texto grande: el diálogo va de y 64 a 163, con letra de 32 y paginado en 2 (%s, %d páginas)" % [cuadro, d.paginas.size()])
	d.saltar()
	d.saltar()
	_comprobar(d.ocupado() and d.pagina == 1, "Texto grande: saltar pasa a la página 2")
	d.limpiar()
	Opciones.texto_grande = false
	# Felipe arriba (repisa alta): el cuadro sale abajo, hasta el borde de la zona segura.
	sala.felipe.global_position = Vector2(300, Nivel1.SUELO - 250)
	await _esperar(3)
	if d.va_abajo():
		d.decir("felipe", "Desde aquí arriba se ve todo mi reino.", 0, true)
		await _esperar(2)
		cuadro = d.rect_en_pantalla()
		_comprobar(cuadro.end.y <= ZonasTexto.SEGURA.end.y and cuadro.position.y > 200.0, "Zona B: con Felipe arriba, el cuadro sale abajo dentro de la zona segura (%s)" % cuadro)
		d.limpiar()
	sala.felipe.global_position = Vector2(300, Nivel1.SUELO)
	await _esperar(10)


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
	_comprobar(malos.is_empty() and tipos.size() == 3, "Zona C: carteles, logro y fase (%s) salen todos desde y 44, dentro de la zona segura y sin tocar la salud %s" % [tipos.keys(), malos])
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
	# El cartel (franja, sello, fragmentos y línea) queda dentro de su rectángulo de la zona C.
	var rect := ZonasTexto.cartel(Cartel.medida("¡TRAVESURA CUMPLIDA!", "Coleccionista de calcetines"))
	var sello := Rect2(rect.get_center().x - Cartel.ancho_franja("¡TRAVESURA CUMPLIDA!") / 2.0 - 6.0, rect.position.y - 4.0, 29, 31)
	_comprobar(rect.size.x >= Cartel.ancho_franja("¡TRAVESURA CUMPLIDA!") + 12.0 and rect.size.y >= Cartel.ALTO_FRANJA + 2.0 + Cartel.ALTO_LINEA and ZonasTexto.en_zona_c(rect) and sello.position.y >= ZonasTexto.SALUD.end.y and sello.position.x >= ZonasTexto.SEGURA.position.x, "Zona C: la franja, el sello y la línea del cartel caben en su lugar de la zona C sin tocar la salud")


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
	# Zona E: con Felipe en el cojín junto a Valeria, la burbuja («Firmar») no le tapa la cara.
	felipe.global_position = Vector2(400, Nivel1.SUELO - 49)
	await _esperar(30)
	lienzo = root.get_viewport().get_canvas_transform()
	cara = valeria.rect_dibujado()
	cara.size.y = minf(cara.size.y, 90.0)
	indicador.verbo = "Firmar"
	var burbuja_cojin := indicador.rect_burbuja()
	_comprobar(not burbuja_cojin.intersects(cara), "Zona E: con Felipe en el cojín, la burbuja del Indicador no tapa la cara de Valeria (%s, cara %s)" % [burbuja_cojin, cara])
	indicador.verbo = ""


func _probar_barra_jefe() -> void:
	var barra: BarraVida = (load(PresentacionJefe.ESCENA_BARRA) as PackedScene).instantiate()
	barra.forma = BarraVida.Forma.BARRA
	barra.titulo = "A.S.P.I. — Devoradora de Pelos · Nivel 99"
	barra.titulo_corto = "A.S.P.I."
	var texto := barra.titulo_visible()
	_comprobar(not texto.ends_with("…") and Estilo.ancho(texto, &"jefe_barra") <= BarraVida.ANCHO_JEFE - BarraVida.X_BARRA - 16.0, "Zona A2: el nombre del jefe se abrevia hasta caber entero («%s», nunca «N…»)" % texto)
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
