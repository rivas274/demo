extends SceneTree
## Prueba de la munición de la pelea con A.S.P.I. sin reposición (revisión del 2026-10-23,
## `diseno/revisiones/2026-10-23-pelea-aspi-sin-reposicion.md`): cuántas fuentes de desorden hay y en qué islas; que
## nada reaparece; que la suciedad nunca se pierde (solo baja al apagarla); y el PEOR CASO: Felipe tira todo en la
## fase 1, nunca la apaga a tiempo hasta que ella limpió todo el piso (solo queda pelusa), y pierde una vida en cada
## fase. Aun así se gana, solo con lo que hay. Sin ventana:
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_municion.gd
## Termina con código 0 si todo pasa y 1 si algo falla.

var _fallos: Array[String] = []
var sala: Nivel
var guion: GuionNivel1
var felipe: Felipe
var batalla: BatallaAspi
var aspi: Enemigo


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	sala = load("res://escenas/nivel_1.tscn").instantiate()
	guion = sala.guion
	sala.mostrar_titulo = false
	root.add_child(sala)
	felipe = sala.get_node("Felipe")
	batalla = guion.batalla
	aspi = guion.aspi
	var arena := Nivel1.rect_de("estudio")
	await _esperar(30)

	# Cuenta: 14 manchas en 11 fuentes, repartidas en las dos islas; el mínimo que hay que tirar es 4 de 8.
	var total := batalla.suciedad_total()
	var izquierda := 0
	var derecha := 0
	for objeto in batalla.municion:
		if objeto.position.x < Nivel1.CAJA_LIBROS_X:
			izquierda += 1
		else:
			derecha += 1
	for fuente in batalla.fuentes:
		if fuente.global_position.x < Nivel1.CAJA_LIBROS_X:
			izquierda += fuente.restantes()
		else:
			derecha += fuente.restantes()
	var pide := 0
	var minimo := 0
	for f in batalla.datos.fases:
		pide += DatosJefe.por_fase(batalla.datos.capacidad, f)
		minimo += DatosJefe.por_fase(batalla.datos.capacidad, f) - (DatosJefe.por_fase(batalla.datos.devuelve, f - 1) if f > 0 else 0)
	_comprobar(total == 14 and batalla.municion.size() + batalla.fuentes.size() == 11, "El estudio tiene 14 manchas en 11 fuentes (hay %d en %d)" % [total, batalla.municion.size() + batalla.fuentes.size()])
	_comprobar(izquierda >= 5 and derecha >= 5, "Repartidas en las dos islas (izquierda %d, derecha y centro %d)" % [izquierda, derecha])
	_comprobar(pide == 8 and minimo == 4 and total >= minimo * 3, "La pelea pide %d; tirando lo mínimo bastan %d (la pelusa pone el resto): hay %d, más del triple" % [pide, minimo, total])

	# Entra a la pelea (sin daño, sin embestidas ni bolas: se prueba la munición, no la esquiva).
	felipe.vida.restante_invulnerable = 99999.0
	await _poner_en(Vector2(arena.position.x + 120, Nivel1.SUELO))
	await _esperar_que(func() -> bool: return batalla.fase != PeleaJefe.Fase.ESPERANDO, 60)
	batalla.saltar_entrada()
	await _esperar_que(func() -> bool: return batalla.fase == PeleaJefe.Fase.PELEA, 300)
	_sin_ataques()

	# Peor caso 1: tira TODO en la fase 1.
	felipe.mirando = 1.0
	for objeto in batalla.municion:
		objeto.tirable.empujar(felipe)
	for fuente in batalla.fuentes:
		while fuente.restantes() > 0:
			fuente.soltar(1.0)
	await _esperar(150)
	_comprobar(batalla.suciedad_total() == 14 and batalla.manchas.size() + batalla.deposito == 14, "Tirado todo: las 14 manchas llegan al piso (nada se pierde al caer: %d)" % batalla.suciedad_total())
	var tirados := batalla.municion.filter(func(o: Objeto) -> bool: return o.tirable.roto and o.visible and o.position.y >= Nivel1.SUELO - 1.0).size()
	_comprobar(tirados == batalla.municion.size(), "Todo lo tirado queda en el piso, visible (%d de %d)" % [tirados, batalla.municion.size()])

	# Peor caso 2: nunca la apaga a tiempo hasta que ella limpió todo el piso: todo queda en montañas de pelusa.
	var vacios := 0
	var se_perdio := false
	for vuelta in 12:
		if batalla.manchas.is_empty() and batalla.deposito == 0:
			break
		await _esperar_que(func() -> bool: return batalla.llena or (batalla.manchas.is_empty() and not batalla.limpiando), 60 * 30)
		if not batalla.llena:
			break
		await _esperar_que(func() -> bool: return not batalla.llena, 60 * 6)
		vacios += 1
		await _esperar(40)
		se_perdio = se_perdio or batalla.suciedad_total() != 14
	_comprobar(vacios >= 3 and not se_perdio and batalla.suciedad_total() == 14, "Sin apagarla nunca (%d veces), lo vacía en el piso: la suciedad sigue siendo 14" % vacios)
	var pelusa := 0
	for montana in batalla.montanas:
		pelusa += montana.pendientes()
	_comprobar(batalla.manchas.is_empty() and pelusa + batalla.deposito == 14, "Peor caso: el piso quedó limpio y todo está en montañas de pelusa (%d) o en el depósito (%d)" % [pelusa, batalla.deposito])

	# Fase 1 con lo único que queda (pelusa): esparcir, esperar que se llene y apagarla.
	await _jugar_fase(0)
	_comprobar(batalla.apagados == 1, "Fase 1 ganada solo con pelusa")
	await _esperar(90)
	_comprobar(batalla.suciedad_total() == 14 - (2 - batalla.datos.devuelve[0]), "Apagarla devuelve lo que tragó (%d de 2): la suciedad queda en %d" % [batalla.datos.devuelve[0], batalla.suciedad_total()])

	# Fase 2: pierde una vida a la mitad (con manchas en el piso y pelusa sin esparcir) y vuelve desde el cojín.
	await _perder_una_vida_y_volver("fase 2")
	await _jugar_fase(1)
	_comprobar(batalla.apagados == 2, "Fase 2 ganada después de perder una vida")
	await _esperar(90)
	_comprobar(batalla.suciedad_total() == 14 - (2 - batalla.datos.devuelve[0]) - (3 - batalla.datos.devuelve[1]), "La suciedad solo baja al apagarla (queda %d)" % batalla.suciedad_total())

	# Fase 3: pierde otra vida y aun así gana.
	await _perder_una_vida_y_volver("fase 3")
	await _jugar_fase(2)
	await _esperar_que(func() -> bool: return batalla.fase == PeleaJefe.Fase.FIN, 120)
	_comprobar(aspi.vida.muerto and batalla.fase == PeleaJefe.Fase.FIN, "Fase 3 ganada: con todo tirado al principio, sin apagarla a tiempo y perdiendo una vida por fase, se gana igual")

	# El estudio queda destruido: nada volvió a su lugar.
	await _esperar(200)
	var en_el_piso := batalla.municion.filter(func(o: Objeto) -> bool: return o.tirable.roto and o.visible and o.position.y >= Nivel1.SUELO - 1.0).size()
	var huecos := batalla.fuentes.filter(func(f: FuenteDesorden) -> bool: return f.restantes() == 0 and f.usadas == f.datos.piezas.size()).size()
	_comprobar(en_el_piso == batalla.municion.size() and huecos == batalla.fuentes.size(), "Al final todo sigue tirado (%d objetos en el piso, %d fuentes vacías)" % [en_el_piso, huecos])
	await _esperar_que(func() -> bool: return _dijo("Estudio redecorado"), 60 * 15)
	_comprobar(_dijo("Estudio redecorado"), "Felipe mira su obra: «Estudio redecorado. Estilo: Su Majestad.»")

	for fallo in _fallos:
		printerr("FALLO: " + fallo)
	print("Resultado: %d fallos" % _fallos.size())
	quit(1 if _fallos.size() > 0 else 0)


## Sin embestidas, soplidos ni bolas: la prueba es de munición.
func _sin_ataques() -> void:
	for nombre: String in ["embestida", "bola"]:
		var c := batalla.conducta(nombre)
		c.set("reloj_espera", 9999.0)
		if nombre == "embestida":
			(c as AtaqueEmbestida).espera = PackedFloat32Array([9999.0])
		else:
			(c as AtaqueBolaPelo).espera = 9999.0


## Juega una fase solo con lo que hay: si el piso está limpio, esparce una montaña; cuando se llena, le cae encima.
func _jugar_fase(numero: int) -> void:
	for intento in 40:
		if batalla.apagados > numero or batalla.fase != PeleaJefe.Fase.PELEA:
			return
		if batalla.llena:
			await _esperar(20)
			felipe.global_position = aspi.global_position + Vector2(0, -62)
			felipe.velocity = Vector2.ZERO
			await _esperar(60)
			continue
		if batalla.manchas.is_empty() and not batalla.limpiando:
			var montana := _montana()
			if montana:
				await _esparcir(montana)
				continue
		await _poner_en(Vector2(clampf(aspi.global_position.x + 150.0, 6880.0, 7700.0), Nivel1.SUELO), 30)
	_comprobar(false, "La fase %d se pudo jugar (se trabó: depósito %d, manchas %d, montañas %d)" % [numero + 1, batalla.deposito, batalla.manchas.size(), batalla.montanas.size()])


func _montana() -> MontanaPelusa:
	for montana in batalla.montanas:
		if is_instance_valid(montana) and montana.en_piso and not montana.esparcida:
			return montana
	return null


## Como un jugador: al lado de la montaña, el botón de acción (burbuja «Esparcir»).
func _esparcir(montana: MontanaPelusa) -> void:
	await _poner_en(montana.global_position + Vector2(-22, 0), 40)
	felipe.mirando = 1.0
	if felipe.manas.objeto_cercano() != montana:
		_comprobar(false, "Junto a la montaña se ofrece «Esparcir» (había otra cosa más cerca)")
		montana.esparcir()
	else:
		await _tocar("interactuar")
	await _esperar_que(func() -> bool: return montana.esparcida and montana.motas_en_vuelo == 0, 120)
	await _esperar(10)


## Felipe pierde una vida (reaparece en el cojín): manchas, montañas y depósito se conservan; vuelve por la puerta.
func _perder_una_vida_y_volver(cuando: String) -> void:
	var antes := batalla.suciedad_total()
	var manchas := batalla.manchas.size()
	var deposito := batalla.deposito
	var fase := batalla.apagados
	var cojin: Rect2 = Nivel1.DESCANSOS[1]
	felipe.punto_reaparicion = Vector2(cojin.get_center().x, cojin.position.y + 10)
	felipe.global_position = felipe.punto_reaparicion
	await _esperar(40)
	_comprobar(batalla.ausente and batalla.suciedad_total() == antes and batalla.manchas.size() == manchas and batalla.deposito == deposito and batalla.apagados == fase, "Perder una vida en la %s conserva todo (suciedad %d, manchas %d, depósito %d)" % [cuando, antes, manchas, deposito])
	sala.puertas["pasillo>estudio"].interactuar(felipe)
	await _esperar_que(func() -> bool: return not batalla.ausente and not batalla.presentacion.presentando, 400)
	_comprobar(not batalla.ausente and batalla.apagados == fase and batalla.suciedad_total() == antes, "Al volver sigue la %s con la misma suciedad (%d)" % [cuando, batalla.suciedad_total()])


func _dijo(texto: String) -> bool:
	for linea: Array in sala.travesuras.dialogo.historial:
		if texto in String(linea[1]):
			return true
	return false


func _poner_en(posicion: Vector2, cuadros := 45) -> void:
	felipe.global_position = posicion
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


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("OK    " if condicion else "FALLA ") + descripcion)
	if not condicion:
		_fallos.append(descripcion)
