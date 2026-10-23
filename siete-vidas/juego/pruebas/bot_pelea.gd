extends RefCounted
## La pelea con A.S.P.I. jugada por el bot de `partida.gd`, con los mismos botones que una persona (revisión del
## 2026-10-23: nada reaparece). Ensucia con lo que queda en las dos islas (objetos, el corcho, el estante del librero,
## los libros de la repisa del gato y de la caja), esparce la montaña de pelusa que ella escupe al terminar cada fase,
## baja cuando se llena y le cae encima desde el piso. Esquiva las embestidas y las bolas con los reflejos de la partida
## y se aferra cuando aspira cerca. Usa los movimientos de la partida (`_ir_a`, `_subir_a`, `_bajar`, `_tocar`...).

var p
var guion: GuionNivel1
var felipe: Felipe
var batalla: BatallaAspi
var _isla_anterior := ""


func _init(partida) -> void:
	p = partida
	guion = p.guion
	felipe = p.felipe
	batalla = guion.batalla


func jugar() -> void:
	await p._hasta(func() -> bool: return batalla.fase == BatallaAspi.Fase.PELEA, 12.0)
	p._paso("Entrada de la jefa (8 pasos)")
	var limite: int = p._cuadros + int(240.0 * p._fps)
	while batalla.fase == BatallaAspi.Fase.PELEA and p._cuadros < limite:
		if batalla.ausente:
			p._paso("Perdió una vida: vuelve desde el cojín")
			await p._hasta(func() -> bool: return felipe.estado != Felipe.Estado.DESMAYADO, 3.0)
			await p._entrar("pasillo>estudio")
			await p._hasta(func() -> bool: return not batalla.ausente, 4.0)
			continue
		if batalla.llena:
			await _apagar_de_un_salto()
			continue
		if _conviene_charco():
			await _atraer_al_charco()
			continue
		if batalla.manchas.is_empty() and not batalla.limpiando:
			await _ensuciar()
			continue
		await _esperar_en_el_piso()
	p._paso("Apaga a A.S.P.I." if batalla.fase == BatallaAspi.Fase.FIN else "No pudo con A.S.P.I.")
	# Como una persona: mira su obra (el estudio destruido) antes de salir al balcón.
	await p._hasta(func() -> bool: return batalla.nota >= 0, 12.0)
	await p._segundos(1.5)


## En el apagón (fase 3): si hay un charco y ella no ataca, se la lleva al charco maullando (cada tanto).
var _ultimo_charco := -1000


func _conviene_charco() -> bool:
	var corto := batalla.conducta("cortocircuito") as ConductaCortocircuito
	return corto != null and corto.hecho and batalla.apagon.activo and not corto.charcos().is_empty() and batalla.reinicio <= 0.0 \
		and batalla.ataque == BatallaAspi.Ataque.NINGUNO and corto.reloj_charco <= 0.0 and p._cuadros - _ultimo_charco > int(6.0 * p._fps)


## Se para del otro lado del charco más cercano a ella y maúlla: ella gira hacia él y pasa por encima.
func _atraer_al_charco() -> void:
	_ultimo_charco = p._cuadros
	var corto := batalla.conducta("cortocircuito") as ConductaCortocircuito
	var aspi := guion.aspi
	var mejor := Vector2.INF
	for charco in corto.charcos():
		if mejor == Vector2.INF or absf(charco.x - aspi.global_position.x) < absf(mejor.x - aspi.global_position.x):
			mejor = charco
	var lado := 1.0 if mejor.x >= aspi.global_position.x else -1.0
	await _bajar_al_piso()
	await p._ir_a(clampf(mejor.x + lado * 70.0, 6880.0, 7700.0), 3.0)
	if fuera_de_pelea():
		return
	await p._tocar("maullar")
	p._paso("Maúlla para llevarla al charco (x %.0f)" % mejor.x)
	await p._hasta(func() -> bool: return batalla.llena or batalla.ataque != BatallaAspi.Ataque.NINGUNO, 3.0)
	if batalla.llena and batalla.motivo == "charco":
		p._paso("¡En corto! Pasó por el charco")


func fuera_de_pelea() -> bool:
	return batalla.ausente or batalla.fase != BatallaAspi.Fase.PELEA or felipe.estado == Felipe.Estado.DESMAYADO or Nivel1.habitacion_de(felipe.global_position) != "estudio"


# --- Ensuciar -----------------------------------------------------------------------------------------------

## Tira lo que haga falta para llenarle el depósito. Si hay una montaña de pelusa en el piso, primero la esparce (es lo
## que tiene más a mano); si no, va a la otra isla que la última vez. Si no queda nada, pisa el teclado.
func _ensuciar() -> void:
	var tiro := false
	for vuelta in 3:
		if fuera_de_pelea():
			return
		var falta: int = DatosJefe.por_fase(batalla.datos.capacidad, batalla.apagados) - batalla.deposito - batalla.manchas.size()
		# Como una persona, tira una cosa de más (el estudio destruido es el trofeo).
		if falta < 0 or batalla.llena:
			break
		var montana := _montana()
		if montana:
			await _esparcir(montana)
			tiro = true
			continue
		var objetivo := _municion()
		if objetivo.is_empty():
			break
		await _ir_a_superficie(objetivo["superficie"])
		if fuera_de_pelea():
			return
		await p._ir_a(objetivo["pararse"], 2.0)
		felipe.mirando = objetivo["mirar"]
		await p._tocar("interactuar")
		await p._segundos(0.7)
		tiro = true
		p._paso("Ensucia con %s (depósito %d, apagados %d)" % [objetivo["nombre"], batalla.deposito, batalla.apagados])
		# En el escritorio, la secreta de la agenda: pisa el teclado una vez («jjjjjjjjjj»), como haría una persona.
		var agenda: Agenda = p.sala.travesuras.agenda
		if not agenda.esta_cumplida("teclado") and _superficie() == "escritorio":
			await p._ir_a(Nivel1.TECLADO.get_center().x, 1.5)
			await p._segundos(0.4)
			if agenda.esta_cumplida("teclado"):
				p._paso("Pisa el teclado de Valeria (secreta)")
	if not tiro and batalla.manchas.is_empty() and guion.desorden.apuntes.restantes() > 0:
		await _ir_a_superficie("escritorio")
		await p._ir_a(Nivel1.TECLADO.get_center().x, 2.0)
		await p._hasta(func() -> bool: return not batalla.manchas.is_empty(), 4.5)
		p._paso("Pisa el teclado: vuelan los apuntes (depósito %d)" % batalla.deposito)
	await _bajar_al_piso()


## La montaña de pelusa en el piso que se puede esparcir (o null).
func _montana() -> MontanaPelusa:
	for montana in batalla.montanas:
		if is_instance_valid(montana) and montana.en_piso and not montana.esparcida:
			return montana
	return null


## Al lado de la montaña, el botón de acción (burbuja «Esparcir»): un manotazo la deshace en motas.
func _esparcir(montana: MontanaPelusa) -> void:
	await _bajar_al_piso()
	var lado := -1.0 if felipe.global_position.x < montana.global_position.x else 1.0
	await p._ir_a(montana.global_position.x + lado * 24.0, 3.0)
	if fuera_de_pelea() or not is_instance_valid(montana):
		return
	felipe.mirando = -lado
	await p._tocar("interactuar")
	await p._segundos(0.7)
	if is_instance_valid(montana) and montana.esparcida:
		p._paso("Esparce la montaña de pelusa (depósito %d, apagados %d)" % [batalla.deposito, batalla.apagados])


## Lo que se puede tirar ahora, como un diccionario: nombre, superficie donde pararse, x donde pararse y hacia dónde
## mirar. Como una persona que reparte la pelea, va a la otra isla que la última vez si allá queda algo; dentro de una
## isla, lo más bajo primero.
func _municion() -> Dictionary:
	var opciones: Array[Dictionary] = []
	var librero := Nivel1.rect_pieza("Librero bajo")
	var caja := Nivel1.rect_pieza("Caja de los libros")
	var gato := Nivel1.rect_pieza("Repisa del gato")
	for objeto in batalla.municion:
		if not is_instance_valid(objeto) or objeto.tirable.roto or objeto.tirable.cayendo:
			continue
		var x := objeto.position.x
		var y := objeto.position.y
		if absf(y - gato.position.y) < 3.0 and x >= gato.position.x and x <= gato.end.x:
			opciones.append({"nombre": objeto.tipo, "superficie": "repisa_gato", "pararse": x - 18.0, "mirar": 1.0, "alto": y})
		elif absf(y - caja.position.y) < 3.0 and x >= caja.position.x and x <= caja.end.x:
			opciones.append({"nombre": objeto.tipo, "superficie": "caja", "pararse": x + 22.0, "mirar": -1.0, "alto": y})
		elif x >= librero.position.x:
			var lado := -1.0 if x < librero.get_center().x else 1.0
			opciones.append({"nombre": objeto.tipo, "superficie": "librero", "pararse": x - lado * 18.0, "mirar": lado, "alto": y})
		else:
			var lado := 1.0 if x > 7140.0 else -1.0
			opciones.append({"nombre": objeto.tipo, "superficie": "repisa_macetas" if y < Nivel1.SUELO - 120.0 else "escritorio", "pararse": x - lado * 18.0, "mirar": lado, "alto": y})
	for fuente in guion.desorden.fuentes:
		if fuente.restantes() <= 0:
			continue
		var punto := fuente.punto_para(felipe.global_position)
		if fuente.datos.arte == "pizarra":
			# Desde la punta derecha del escritorio (si la taza sigue ahí, la taza sale primero: también sirve).
			opciones.append({"nombre": "una nota del corcho", "superficie": "escritorio", "pararse": 7206.0, "mirar": 1.0, "alto": punto.y})
		else:
			opciones.append({"nombre": "un libro del estante", "superficie": "caja", "pararse": caja.end.x - 4.0, "mirar": 1.0, "alto": punto.y})
	var mejor := {}
	var mejor_otra := {}
	for opcion in opciones:
		var isla := _isla(opcion["superficie"])
		if mejor.is_empty() or opcion["alto"] > mejor["alto"]:
			mejor = opcion
		if isla != _isla_anterior and (mejor_otra.is_empty() or opcion["alto"] > mejor_otra["alto"]):
			mejor_otra = opcion
	var elegido := mejor_otra if not mejor_otra.is_empty() else mejor
	if not elegido.is_empty():
		_isla_anterior = _isla(elegido["superficie"])
	return elegido


func _isla(superficie: String) -> String:
	return "izquierda" if superficie in ["escritorio", "repisa_macetas"] else "derecha"


## Dónde está parado: piso, escritorio, repisa_macetas, caja, librero, repisa_gato o "" (otra cosa, en el aire).
func _superficie() -> String:
	if not felipe.is_on_floor():
		return ""
	var pie := felipe.global_position
	if pie.y > Nivel1.SUELO - 2.0:
		return "piso"
	for datos: Array in [["escritorio", "Escritorio"], ["repisa_macetas", "Repisa de las macetas"], ["caja", "Caja de los libros"], ["librero", "Librero bajo"], ["repisa_gato", "Repisa del gato"]]:
		var pieza := Nivel1.rect_pieza(datos[1])
		if absf(pie.y - pieza.position.y) < 3.0 and pie.x >= pieza.position.x - 12.0 and pie.x <= pieza.end.x + 12.0:
			return datos[0]
	return ""


## Sube a esa superficie por el camino de una persona. Izquierda: piso → silla → escritorio (→ repisa de las macetas).
## Derecha: piso → caja de los libros (→ librero bajo → repisa del gato). Si está en otra, primero baja al piso.
func _ir_a_superficie(destino: String) -> void:
	var actual := _superficie()
	if actual == destino:
		return
	var camino := {
		"escritorio": ["escritorio"], "repisa_macetas": ["escritorio", "repisa_macetas"],
		"caja": ["caja"], "librero": ["caja", "librero"], "repisa_gato": ["caja", "librero", "repisa_gato"],
	}
	var pasos: Array = camino.get(destino, [])
	var desde := pasos.find(actual)
	if desde < 0 and actual != "piso":
		await _bajar_al_piso()
	var caja := Nivel1.rect_pieza("Caja de los libros")
	var librero := Nivel1.rect_pieza("Librero bajo")
	for i in range(desde + 1, pasos.size()):
		if fuera_de_pelea():
			return
		match pasos[i]:
			"escritorio":
				await p._ir_a(7000, 4.0)
				if fuera_de_pelea():
					return
				await p._subir_a(7035, Nivel1.SUELO - 55)
				await p._subir_a(7105, Nivel1.SUELO - 98)
			"repisa_macetas":
				await p._ir_a(7195, 2.0)
				await p._subir_a(7280, Nivel1.SUELO - 170)
			"caja":
				await p._ir_a(caja.position.x - 24.0, 4.0)
				if fuera_de_pelea():
					return
				await p._subir_a(caja.get_center().x, caja.position.y)
			"librero":
				await p._subir_a(librero.position.x + 40.0, librero.position.y)
			"repisa_gato":
				var gato := Nivel1.rect_pieza("Repisa del gato")
				await p._ir_a(librero.position.x + 8.0, 1.5)
				await p._subir_a(gato.get_center().x - 6.0, gato.position.y)


## De cualquier mueble al piso: lo atraviesa hacia abajo (agachado + saltar).
func _bajar_al_piso() -> void:
	for intento in 4:
		if felipe.is_on_floor() and felipe.global_position.y > Nivel1.SUELO - 2.0:
			return
		await p._hasta(func() -> bool: return felipe.is_on_floor(), 1.0)
		await p._bajar()


# --- Esperar y apagarla -------------------------------------------------------------------------------------

## Mientras ella limpia: en el piso, cerca de la mancha pero sin dejarse arrastrar (si aspira, se aferra), listo para
## saltarle encima apenas se llene. Las embestidas las esquiva el reflejo de la partida.
func _esperar_en_el_piso() -> void:
	var aspi := guion.aspi
	var dx := felipe.global_position.x - aspi.global_position.x
	if batalla.succionando and absf(dx) < 270.0:
		Input.action_press("agacharse")
		await p._hasta(func() -> bool: return not batalla.succionando or batalla.llena, 4.0)
		Input.action_release("agacharse")
		return
	if felipe.corazones <= 2 and felipe.snacks > 0 and felipe.is_on_floor() and absf(dx) > 140.0 and batalla.ataque == BatallaAspi.Ataque.NINGUNO:
		# Come un snack del bolsillo (mantener la acción 0,6 s): cura, pero queda quieto.
		Input.action_press("interactuar")
		await p._segundos(0.75)
		Input.action_release("interactuar")
		await p._segundos(0.5)
		p._paso("Come un snack del bolsillo (corazones %d, snacks %d)" % [felipe.corazones, felipe.snacks])
		return
	if not batalla.limpiando and absf(dx) < 90.0 and felipe.is_on_floor():
		var lejos := clampf(aspi.global_position.x + (140.0 if dx > 0.0 else -140.0), 6880.0, 7696.0)
		await p._ir_a(lejos, 1.0)
		return
	await p._cuadro()


## Espera (hasta 1 s) a que A.S.P.I. no se mueva entre dos cuadros seguidos.
func _hasta_que_aspi_se_detenga() -> void:
	var anterior := INF
	for i in int(1.0 * p._fps):
		var x := guion.aspi.global_position.x
		if absf(x - anterior) < 0.1:
			return
		anterior = x
		await p._cuadro()


## Depósito lleno: al piso, junto a ella, y salta para caerle encima.
func _apagar_de_un_salto() -> void:
	var antes := batalla.apagados
	await _bajar_al_piso()
	for intento in 4:
		if not batalla.llena or batalla.apagados > antes:
			break
		# Al llenarse bajo la repisa sale disparada unos 80 px (EMPUJE_LLENA, 0,3 s): hay que esperar a que se quede
		# quieta antes de elegir el lado. Si no, va adonde estaba, queda del otro lado y salta alejándose de ella.
		await _hasta_que_aspi_se_detenga()
		var x := guion.aspi.global_position.x
		var lado := -1.0 if felipe.global_position.x < x else 1.0
		# A media carcasa de distancia (ella es sólida: más cerca, Felipe choca y el bot salta solo y pierde tiempo).
		# Si está lejos (se alejó para comer un snack), corre (Shift): llena espera solo 3 a 4 s.
		var lejos := absf(x + lado * 44.0 - felipe.global_position.x) > 150.0
		if lejos:
			Input.action_press("zoomies")
		await p._ir_a(x + lado * 44.0, 3.0)
		Input.action_release("zoomies")
		# Lado y blanco se miden de nuevo justo antes de saltar; si no quedó a tiro, se acerca otra vez.
		x = guion.aspi.global_position.x
		var dx := x - felipe.global_position.x
		if absf(dx) > 64.0:
			continue
		if absf(dx) < 24.0:
			# Quedó pegado a ella (se corrió al quedar vulnerable): un paso atrás para saltar en arco, como una persona.
			await p._ir_a(x - signf(dx if dx != 0.0 else 1.0) * 44.0, 0.6)
			x = guion.aspi.global_position.x
			dx = x - felipe.global_position.x
		await p._saltar(signf(dx), x)
		await p._hasta(func() -> bool: return batalla.apagados > antes or felipe.is_on_floor(), 1.5)
		if OS.get_cmdline_user_args().has("--detalle"):
			print("        intento %d de apagarla: dx %.0f, llena %s, apagados %d" % [intento + 1, dx, batalla.llena, batalla.apagados])
	await p._hasta(func() -> bool: return felipe.is_on_floor(), 2.0)
	p._paso("Le salta encima: apagados %d" % batalla.apagados)
