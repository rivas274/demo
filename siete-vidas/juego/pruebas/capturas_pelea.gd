extends SceneTree
## Capturas de la pelea con A.S.P.I. sin reposición (revisión del 2026-10-23): el estudio al principio (entero), cada
## fase con su desorden, el «¡BLORP!» de la montaña de pelusa, Felipe esparciéndola y el estudio destruido al final
## (las dos mitades del cuarto, y ampliado ×3 donde queda el desorden). Cada captura es la pantalla de 640 × 360.
## Necesita pantalla:
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/capturas_pelea.gd -- <carpeta>

var _carpeta := "user://pelea"
var sala: Nivel
var felipe: Felipe
var batalla: BatallaAspi
var aspi: Enemigo


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_carpeta = args[0]
	DirAccess.make_dir_recursive_absolute(_carpeta)
	_correr.call_deferred()


func _correr() -> void:
	sala = load("res://escenas/nivel_1.tscn").instantiate()
	sala.mostrar_titulo = false
	root.add_child(sala)
	felipe = sala.get_node("Felipe")
	var guion: GuionNivel1 = sala.guion
	batalla = guion.batalla
	aspi = guion.aspi
	felipe.vida.restante_invulnerable = 99999.0
	await _esperar(30)
	# 1. El estudio al principio, entero (desde la puerta: la pelea todavía duerme).
	await _parar(Vector2(6842, Nivel1.SUELO), 60)
	_capturar("01-principio-izquierda")
	# Entra: la pelea empieza; se salta la entrada (ya tiene sus capturas en capturas_aspi.gd).
	await _parar(Vector2(6990, Nivel1.SUELO), 10)
	await _esperar_que(func() -> bool: return batalla.fase != PeleaJefe.Fase.ESPERANDO, 60)
	batalla.saltar_entrada()
	await _esperar_que(func() -> bool: return batalla.fase == PeleaJefe.Fase.PELEA, 300)
	for nombre: String in ["embestida", "bola"]:
		batalla.conducta(nombre).set("reloj_espera", 9999.0)
	(batalla.conducta("embestida") as AtaqueEmbestida).espera = PackedFloat32Array([9999.0])
	(batalla.conducta("bola") as AtaqueBolaPelo).espera = 9999.0
	# Sin ataques no hay daño: sin invulnerabilidad, Felipe no parpadea en las capturas.
	felipe.vida.restante_invulnerable = 0.0
	await _parar(Vector2(7620, Nivel1.SUELO), 60)
	_capturar("02-principio-derecha")
	# Aviso de embestida (v3): la línea roja en el piso hasta donde va a cargar.
	var embestida := batalla.conducta("embestida") as AtaqueEmbestida
	embestida.espera = PackedFloat32Array([0.0])
	embestida.reloj_espera = 0.0
	for i in 300:
		if batalla.ataque == BatallaAspi.Ataque.AVISO_EMBESTIDA:
			break
		if felipe.is_on_floor():
			felipe.global_position.x = clampf(aspi.global_position.x + 130.0, 6900.0, 7680.0)
		await physics_frame
	await _esperar(12)
	_capturar("04b-aviso-embestida")
	felipe.vida.restante_invulnerable = 99999.0
	embestida.espera = PackedFloat32Array([9999.0])
	embestida.reloj_espera = 9999.0
	await _esperar(60)
	felipe.vida.restante_invulnerable = 0.0
	# 2. Fase 1: tira la taza y los libros de la caja; ella va a limpiar.
	felipe.mirando = 1.0
	for objeto in batalla.municion:
		if objeto.tipo in ["taza", "libros_pila_b"]:
			objeto.tirable.empujar(felipe)
	await _parar(Vector2(7300, Nivel1.SUELO), 100)
	_capturar("03-fase1-desorden")
	await _esperar_que(func() -> bool: return batalla.limpiando, 600)
	await _esperar(40)
	_capturar("04-fase1-limpia")

	await _esperar_que(func() -> bool: return batalla.llena, 900)
	await _esperar(30)
	_capturar("05-fase1-llena")
	await _caerle_encima()
	# 3. ¡BLORP!: se le abre el depósito y escupe la montaña.
	await _esperar_que(func() -> bool: return not batalla.montanas.is_empty(), 120)
	await _esperar(8)
	_capturar("06-blorp")
	await _esperar_que(func() -> bool: return batalla.montanas[0].en_piso, 60)
	await _esperar(40)
	_capturar("07-montana-en-el-piso")
	var montana: MontanaPelusa = batalla.montanas[0]
	await _parar(montana.global_position + Vector2(-24, 0), 30)
	felipe.mirando = 1.0
	_capturar("08-esparcir-burbuja")
	await _tocar("interactuar")
	await _esperar(26)
	_capturar("09-fup")
	# 4. Fase 2: notas del corcho y libros del estante.
	for fuente in batalla.fuentes:
		if fuente.datos.arte in ["pizarra", "librero_bajo"]:
			fuente.soltar(-1.0)
	for objeto in batalla.municion:
		if objeto.tipo in ["maceta", "planta"]:
			objeto.tirable.empujar(felipe)
	await _parar(Vector2(7380, Nivel1.SUELO), 120)
	_capturar("10-fase2-desorden")
	await _esperar_que(func() -> bool: return batalla.llena, 60 * 30)
	await _caerle_encima()
	await _esperar_que(func() -> bool: return not batalla.montanas.is_empty() and batalla.montanas[-1].en_piso, 200)
	# 5. Fase 3: corre contra el enchufe, cortocircuito y apagón.
	var corto := batalla.conducta("cortocircuito") as ConductaCortocircuito
	await _parar(Vector2(7120, Nivel1.SUELO), 1)
	await _esperar_que(func() -> bool: return corto.corriendo, 400)
	await _esperar(20)
	_capturar("10b-corre-al-enchufe")
	await _esperar_que(func() -> bool: return corto.hecho, 300)
	await _esperar(3)
	_capturar("10c-bzzzt")
	await _esperar(60)
	_capturar("10d-apagon")
	# Todo lo demás al piso.
	for objeto in batalla.municion:
		if not objeto.tirable.roto:
			objeto.tirable.empujar(felipe)
	for fuente in batalla.fuentes:
		while fuente.restantes() > 0:
			fuente.soltar(1.0)
	await _parar(Vector2(7100, Nivel1.SUELO), 120)
	_capturar("11-fase3-izquierda")
	await _parar(Vector2(7560, Nivel1.SUELO), 30)
	_capturar("12-fase3-derecha")
	# Bola de pelo: la marca en el piso donde va a caer.
	var bola := batalla.conducta("bola") as AtaqueBolaPelo
	await _esperar_que(func() -> bool: return not batalla.llena and batalla.reinicio <= 0.0 and batalla.reacciones.despertando <= 0.0, 600)
	batalla.manchas.clear()
	batalla.tipos_mancha.clear()
	batalla.nodos_mancha.clear()
	await _parar(Vector2(aspi.global_position.x + 160.0, Nivel1.SUELO), 2)
	bola.reloj_espera = 0.0
	await _esperar_que(func() -> bool: return batalla.ataque == BatallaAspi.Ataque.AVISO_BOLA, 300)
	await _esperar(20)
	_capturar("12a-marca-bola")
	bola.reloj_espera = 9999.0
	await _esperar(60)
	# Un charco la deja en corto.
	await _esperar_que(func() -> bool: return not batalla.llena and batalla.reinicio <= 0.0, 600)
	var charco: Vector2 = corto.charcos()[0]
	corto.reloj_charco = 0.0
	aspi.global_position = Vector2(charco.x - 90.0, Nivel1.SUELO)
	await _parar(Vector2(charco.x + 80.0, Nivel1.SUELO), 2)
	aspi.patrulla.destino = charco.x + 60.0
	felipe.vida.restante_invulnerable = 0.0
	await _esperar_que(func() -> bool: return batalla.llena, 300)
	await _esperar(6)
	_capturar("12b-charco-en-corto")
	for vuelta in 6:
		if batalla.fase != PeleaJefe.Fase.PELEA:
			break
		await _esperar_que(func() -> bool: return batalla.llena or batalla.fase != PeleaJefe.Fase.PELEA, 60 * 30)
		if batalla.llena:
			await _caerle_encima()
		elif batalla.manchas.is_empty():
			for m in batalla.montanas.duplicate():
				if is_instance_valid(m) and m.en_piso and not m.esparcida:
					m.esparcir()
	# 6. Final: el estudio destruido, el trofeo de Felipe.
	await _esperar(240)
	await _parar(Vector2(6990, Nivel1.SUELO), 60)
	_capturar("13-final-izquierda", Rect2(6960, Nivel1.SUELO - 190, 330, 200))
	await _parar(Vector2(7560, Nivel1.SUELO), 60)
	_capturar("14-final-derecha", Rect2(7300, Nivel1.SUELO - 190, 330, 200))
	await _esperar_que(func() -> bool: return batalla.nota >= 0, 60 * 15)
	await _esperar(70)
	_capturar("15-final-nota")
	await _esperar(90)
	_capturar("16-final-valeria")
	quit()


func _caerle_encima() -> void:
	await _esperar(20)
	var antes := batalla.apagados
	felipe.global_position = aspi.global_position + Vector2(0, -62)
	felipe.velocity = Vector2.ZERO
	for i in 60:
		await physics_frame
		if batalla.apagados > antes:
			break
	# El piso tiembla: onda de choque, polvo y lo tirado que brinca (2 o 3 cuadros). Secuencia cuadro a cuadro.
	for cuadro in 4:
		await process_frame
		_capturar("golpe-%d-%d" % [batalla.apagados, cuadro])
	await _esperar(1)
	_capturar("golpe-%d" % batalla.apagados)
	await _esperar(30)
	if batalla.apagados < batalla.datos.fases:
		# Se despierta después del «¡BLORP!»: luz roja, «!» y la marca hacia Felipe.
		await _esperar_que(func() -> bool: return batalla.reacciones.despertando > 0.0, 300)
		await _esperar(4)
		_capturar("despertar-%d" % batalla.apagados)


func _parar(donde: Vector2, cuadros: int) -> void:
	felipe.global_position = donde
	felipe.velocity = Vector2.ZERO
	await _esperar(cuadros)


func _tocar(accion: String) -> void:
	Input.action_press(accion)
	await physics_frame
	await physics_frame
	Input.action_release(accion)
	await physics_frame


func _esperar_que(condicion: Callable, maximo: int) -> void:
	for i in maximo:
		if condicion.call():
			return
		await physics_frame


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame
	await process_frame


## Guarda la pantalla (640 × 360) y, si se da `zona` (en el mundo), esa parte ampliada ×3.
func _capturar(nombre: String, zona := Rect2()) -> void:
	var imagen := root.get_texture().get_image()
	imagen.save_png("%s/%s.png" % [_carpeta, nombre])
	if zona.has_area():
		var lienzo := sala.get_viewport().get_canvas_transform()
		var escala := float(imagen.get_width()) / 640.0
		var r := Rect2(lienzo * zona.position, zona.size)
		var rect := Rect2i(Vector2i(r.position * escala), Vector2i(r.size * escala)).intersection(Rect2i(Vector2i.ZERO, imagen.get_size()))
		var parte := imagen.get_region(rect)
		parte.resize(parte.get_width() * 3, parte.get_height() * 3, Image.INTERPOLATE_NEAREST)
		parte.save_png("%s/%s-x3.png" % [_carpeta, nombre])
