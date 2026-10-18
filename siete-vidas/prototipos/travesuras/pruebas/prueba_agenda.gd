# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-18
extends "res://pruebas/comun.gd"
## Prueba de la v2: no hay contador de CAOS, cada travesura de la agenda se marca al cumplirse, las
## secretas se revelan, las recompensas suman, el camino (persiana) se abre de verdad y sale el resumen.
## También revisa los dos arreglos de la v1 (frase que llega tarde, florero repuesto encima de Felipe).
##   godot --headless --path . --fixed-fps 60 --script res://pruebas/prueba_agenda.gd
## Termina con código 0 si todo pasa.

var _fallas := 0


func _initialize() -> void:
	limite_cuadros = 60 * 240
	_correr.call_deferred()


func _comprobar(ok: bool, texto: String) -> void:
	print(("  OK    " if ok else "  FALLA ") + texto)
	if not ok:
		_fallas += 1


func _poner_felipe(x: float, y: float, lado: float) -> void:
	felipe.global_position = Vector2(x, y)
	felipe.velocity = Vector2.ZERO
	felipe.mirando = lado
	await esperar(20)


## Todos los textos visibles de la pantalla (etiquetas), para buscar "CAOS".
func _textos(nodo: Node) -> Array[String]:
	var lista: Array[String] = []
	if nodo is Label:
		lista.append((nodo as Label).text)
	for hijo in nodo.get_children():
		lista.append_array(_textos(hijo))
	return lista


func _hay_caos() -> bool:
	if "caos" in sala.jugo or "combo" in sala.jugo:
		return true
	return _textos(root).any(func(t: String) -> bool: return t.to_upper().contains("CAOS"))


## Lleva a Felipe encima de la recompensa suelta más nueva del tipo pedido.
func _recoger(tipo: String) -> void:
	var objetivo: Recogible = null
	for n in sala.get_children():
		if n is Recogible and n.tipo == tipo and not n.get("_recogido"):
			objetivo = n
	if objetivo == null:
		return
	await hasta(func() -> bool: return objetivo.quieto, 150)
	await _poner_felipe(objetivo.position.x, objetivo.position.y - 2.0, 1.0)
	await esperar(10)


func _tiene_cartel(titulo: String, id: String) -> bool:
	var nombre: String = sala.agenda.datos(id)["nombre"]
	return sala.hud.carteles.any(func(c: Array) -> bool: return c[0] == titulo and c[1] == nombre)


func _correr() -> void:
	await cargar()
	await esperar(10)
	var agenda := sala.agenda
	sala.valeria.umbral_ruido = 999.0

	print("Prueba: sin CAOS y agenda al empezar")
	_comprobar(not _hay_caos(), "no hay contador de CAOS ni combo en pantalla")
	_comprobar(agenda.total() == 6 and agenda.total_secretas() == 2, "la agenda tiene 6 travesuras, 2 secretas")
	var secretas := Agenda.TRAVESURAS.filter(func(t: Dictionary) -> bool: return t["secreta"])
	_comprobar(secretas.all(func(t: Dictionary) -> bool: return sala.libreta.nombre_visible(t) == "???"), "las secretas se ven como ??? antes de cumplirlas")
	await tocar("agenda")
	_comprobar(sala.libreta.abierta and paused, "Tab abre la agenda y pausa el juego")
	await tocar("agenda")
	_comprobar(not sala.libreta.abierta and not paused, "Tab otra vez la cierra")

	print("Prueba: arreglo de la v1, la frase en cola caduca")
	var dichas: Array[String] = []
	sala.dialogo.dicho.connect(func(_q: String, texto: String) -> void: dichas.append(texto))
	sala.dialogo.decir("valeria", "Esta es una frase larga de Valeria para que Felipe tenga que esperar su turno.", 0, true)
	sala.dialogo.decir("felipe", "FRASE TARDÍA", 0)
	await segundos(6.0)
	_comprobar(not dichas.has("FRASE TARDÍA"), "la frase de Felipe que esperó demasiado se descarta (no llega tarde)")

	print("Prueba: sofá nuevo")
	await _poner_felipe(100, Sofa.ASIENTO.position.y, -1.0)
	for i in 3:
		await tocar("accion")
		await segundos(1.2)
	_comprobar(agenda.esta_cumplida("sofa") and not sala.sofa.con_plastico, "arañar 6 veces rompe el plástico y marca la travesura")
	_comprobar(_tiene_cartel("¡TRAVESURA CUMPLIDA!", "sofa"), "sale el cartel ¡TRAVESURA CUMPLIDA! con su nombre")
	await _recoger("calcetin")
	_comprobar(sala.hud.calcetines == 1, "el calcetín del sofá suma (calcetines %d/3)" % sala.hud.calcetines)
	_comprobar(not _hay_caos(), "después de una travesura sigue sin aparecer CAOS")

	print("Prueba: perdón 1, tele y camino")
	sala.valeria.umbral_ruido = 3.0
	sala.valeria.oir(5.0)
	await hasta(func() -> bool: return sala.valeria.presente(), 600)
	await _poner_felipe(sala.valeria.position.x - 60.0, SalaProto.SUELO, 1.0)
	Input.action_press("ronronear")
	await hasta(func() -> bool: return sala.valeria.estado == Valeria.Estado.PERDONANDO, 120)
	Input.action_release("ronronear")
	_comprobar(sala.perdones == 1 and agenda.avance["perdon"] == 1 and not agenda.esta_cumplida("perdon"), "primer perdón: la travesura de 2 va 1/2")
	await _recoger("snack")
	_comprobar(sala.hud.snacks == 1, "el snack del perdón se guarda (snacks %d)" % sala.hud.snacks)
	var sento := await hasta(func() -> bool: return sala.valeria.viendo_tele(), 600)
	_comprobar(sento, "de buenas, Valeria se sienta a ver su serie")
	_comprobar(sala.persiana_abierta == 0.0 and sala._cuerpo_alfeizar.disabled, "antes: la persiana está cerrada y el alféizar no existe")
	await _poner_felipe(165, Sofa.ASIENTO.position.y, 1.0)
	await tocar("accion")
	await hasta(func() -> bool: return agenda.esta_cumplida("tele"), 120)
	_comprobar(agenda.esta_cumplida("tele"), "tirar el control con la tele encendida cumple la travesura")
	_comprobar(sala.valeria.presente(), "Valeria se para a regañar")
	await esperar(60)
	_comprobar(sala.persiana_abierta > 0.9 and not sala._cuerpo_alfeizar.disabled, "la persiana sube y el alféizar es una plataforma")
	await _poner_felipe(SalaProto.CALCETIN_ALFEIZAR_X - 40.0, SalaProto.ALFEIZAR.position.y - 1.0, 1.0)
	await esperar(20)
	_comprobar(felipe.is_on_floor() and absf(felipe.global_position.y - SalaProto.ALFEIZAR.position.y) < 2.0, "Felipe se para en el alféizar (camino abierto)")
	await ir_a(SalaProto.CALCETIN_ALFEIZAR_X)
	await esperar(10)
	_comprobar(sala.hud.calcetines == 2, "el calcetín del alféizar suma (calcetines %d/3)" % sala.hud.calcetines)

	print("Prueba: perdón 2")
	await _poner_felipe(sala.valeria.position.x + 60.0, SalaProto.SUELO, -1.0)
	Input.action_press("ronronear")
	await hasta(func() -> bool: return sala.valeria.estado == Valeria.Estado.PERDONANDO, 120)
	Input.action_release("ronronear")
	_comprobar(agenda.esta_cumplida("perdon") and sala.perdones == 2, "segundo perdón: travesura cumplida")
	await _recoger("snack")
	_comprobar(sala.hud.snacks == 2, "otro snack guardado (snacks %d)" % sala.hud.snacks)

	print("Prueba: secreta de la aspiradora")
	await _poner_felipe(240, SalaProto.SUELO, 1.0)
	await tocar("intimidar")
	await hasta(func() -> bool: return agenda.esta_cumplida("aspiradora"), 300)
	var t_asp := agenda.datos("aspiradora")
	_comprobar(agenda.esta_cumplida("aspiradora"), "intimidar a la aspiradora la hace escupir un calcetín y cumple la secreta")
	_comprobar(sala.libreta.nombre_visible(t_asp) == t_asp["nombre"], "la secreta se revela en la agenda con su nombre")
	_comprobar(_tiene_cartel("¡TRAVESURA SECRETA!", "aspiradora"), "sale el cartel ¡TRAVESURA SECRETA!")
	await _recoger("calcetin")
	_comprobar(sala.hud.calcetines == 3, "tercer calcetín (calcetines %d/3)" % sala.hud.calcetines)

	print("Prueba: florero heredado y foto")
	await _poner_felipe(434, SalaProto.REPISA.position.y, 1.0)
	await tocar("accion")
	await hasta(func() -> bool: return sala.florero.estado == Tirable.Estado.ROTO, 120)
	_comprobar(agenda.esta_cumplida("florero"), "romper el florero cumple la travesura")
	await _recoger("foto")
	_comprobar(sala.hud.fotos == 1, "la foto vergonzosa se recoge (fotos %d)" % sala.hud.fotos)

	print("Prueba: arreglo de la v1, el florero no reaparece encima de Felipe")
	await _poner_felipe(SalaProto.REPISA.position.x + 80.0, SalaProto.REPISA.position.y, 1.0)
	sala._al_irse(sala.valeria)
	await esperar(5)
	_comprobar(sala.florero.estado == Tirable.Estado.ROTO, "con Felipe en la repisa, el florero espera para reponerse")
	await _poner_felipe(300, SalaProto.SUELO, 1.0)
	await esperar(5)
	_comprobar(sala.florero.estado == Tirable.Estado.EN_SITIO, "cuando Felipe se va, el florero vuelve a su lugar")

	print("Prueba: secreta de tirarle algo encima a Valeria")
	await hasta(func() -> bool: return sala.valeria.estado == Valeria.Estado.FUERA, 1800)
	await _poner_felipe(306, SalaProto.MESA.position.y, 1.0)
	sala.valeria.oir(5.0)
	await hasta(func() -> bool: return sala.valeria.presente() and absf(sala.valeria.position.x - felipe.global_position.x) < 75.0, 600)
	await tocar("accion")
	await hasta(func() -> bool: return agenda.esta_cumplida("encima"), 120)
	_comprobar(agenda.esta_cumplida("encima"), "el vaso le cae encima a Valeria y cumple la secreta")
	_comprobar(agenda.secretas_cumplidas() == 2, "las 2 secretas cumplidas")
	var snacks_antes := sala.hud.snacks
	await _recoger("snack")
	_comprobar(sala.hud.snacks == snacks_antes + 1, "el snack de emergencia de Valeria se guarda (snacks %d)" % sala.hud.snacks)

	print("Prueba: resumen")
	var salio := await hasta(func() -> bool: return is_instance_valid(sala.resumen), 600)
	_comprobar(salio and agenda.completa(), "con la agenda completa y nada por recoger, sale el resumen solo")
	if salio:
		await hasta(func() -> bool: return sala.resumen.terminado, 900)
		var filas: Array = sala.resumen.filas
		_comprobar(filas[0][1] == 6 and filas[1][1] == 2 and filas[2][1] == 3 and filas[3][1] == 1 and filas[5][1] == 2, "el resumen cuenta travesuras 6/6, secretas 2/2, calcetines 3/3, fotos 1 y 2 perdones")
		_comprobar(not _hay_caos(), "el resumen no muestra CAOS ni puntaje")

	print("Resultado: %s (%d fallas)" % ["PASA" if _fallas == 0 else "FALLA", _fallas])
	quit(0 if _fallas == 0 else 1)
