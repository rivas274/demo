# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-18
extends "res://pruebas/comun.gd"
## Prueba mínima: cada acción dispara su efecto en el cuadro de impacto (no al apretar) y Valeria
## perdona con el ronroneo.
##   godot --headless --path . --fixed-fps 60 --script res://pruebas/prueba_impacto.gd
## Termina con código 0 si todo pasa.

var _fallas := 0


func _initialize() -> void:
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


## Aprieta la acción y anota en qué cuadro de la animación cambió el objeto por primera vez.
## Devuelve [animación, cuadro, cambió antes de llegar al cuadro de impacto].
func _medir(condicion_cambio: Callable, cuadro_impacto: int) -> Array:
	Input.action_press("accion")
	var resultado := ["", -1, false]
	for i in 90:
		await cuadro()
		if i == 1:
			Input.action_release("accion")
		if condicion_cambio.call():
			resultado = [String(felipe.sprite.animation), felipe.sprite.frame, felipe.sprite.frame < cuadro_impacto]
			break
	Input.action_release("accion")
	await esperar(40)
	return resultado


func _correr() -> void:
	await cargar()
	await esperar(10)
	# Valeria no interrumpe las primeras pruebas.
	sala.valeria.umbral_ruido = 999.0
	print("Prueba: efectos en el cuadro de impacto")

	await _poner_felipe(314, SalaProto.MESA.position.y, 1.0)
	var vaso := sala.vaso
	var r := await _medir(func() -> bool: return vaso.estado != Tirable.Estado.EN_SITIO, FelipeProto.CUADRO_IMPACTO_ZARPAZO)
	_comprobar(r[0] == "zarpazo" and r[1] == FelipeProto.CUADRO_IMPACTO_ZARPAZO, "tirar el vaso: sale volando en el cuadro %d de %s (esperado %d de zarpazo)" % [r[1], r[0], FelipeProto.CUADRO_IMPACTO_ZARPAZO])
	await hasta(func() -> bool: return vaso.estado == Tirable.Estado.ROTO, 120)
	_comprobar(vaso.estado == Tirable.Estado.ROTO, "el vaso cae al piso y se rompe")

	await _poner_felipe(90, Sofa.ASIENTO.position.y, -1.0)
	var marcas_antes := sala.sofa.marcas.size()
	r = await _medir(func() -> bool: return sala.sofa.marcas.size() > marcas_antes, FelipeProto.CUADRO_IMPACTO_ZARPAZO)
	_comprobar(r[0] == "zarpazo" and r[1] == FelipeProto.CUADRO_IMPACTO_ZARPAZO, "arañar el sofá: la primera marca sale en el cuadro %d de %s" % [r[1], r[0]])
	await esperar(30)
	_comprobar(sala.sofa.marcas.size() == marcas_antes + felipe.aranazos_por_accion, "arañar deja %d marcas por pulsación (%d)" % [felipe.aranazos_por_accion, sala.sofa.marcas.size() - marcas_antes])

	await _poner_felipe(436, SalaProto.SUELO, 1.0)
	var porciones := sala.plato.porciones
	r = await _medir(func() -> bool: return sala.plato.porciones < porciones, FelipeProto.CUADRO_IMPACTO_COMER)
	_comprobar(r[0] == "comer" and r[1] == FelipeProto.CUADRO_IMPACTO_COMER, "comer: la comida baja en el cuadro %d de %s (esperado %d de comer)" % [r[1], r[0], FelipeProto.CUADRO_IMPACTO_COMER])

	# Maullar: ondas desde la boca y deformación dentro de ±8 %.
	var maullo := [false]
	felipe.maullo.connect(func(_b: Vector2) -> void: maullo[0] = true, CONNECT_ONE_SHOT)
	var deformacion := 0.0
	Input.action_press("maullar")
	for i in 50:
		await cuadro()
		if i == 1:
			Input.action_release("maullar")
		var forma := felipe.sprite.scale / FelipeProto.ESCALA_SPRITE
		deformacion = maxf(deformacion, maxf(absf(forma.x - 1.0), absf(forma.y - 1.0)))
	var hay_ondas := sala.get_children().any(func(n: Node) -> bool: return n is Ondas)
	_comprobar(maullo[0] and hay_ondas, "maullar: abre la boca y salen ondas")
	_comprobar(deformacion <= FelipeProto.DEFORMACION_MAXIMA + 0.001, "maullar: deformación máxima %.3f (≤ 0,08)" % deformacion)
	await esperar(30)

	var intimido := [false]
	felipe.intimido.connect(func(_c: Vector2) -> void: intimido[0] = true, CONNECT_ONE_SHOT)
	deformacion = 0.0
	Input.action_press("intimidar")
	for i in 60:
		await cuadro()
		if i == 1:
			Input.action_release("intimidar")
		var forma := felipe.sprite.scale / FelipeProto.ESCALA_SPRITE
		deformacion = maxf(deformacion, maxf(absf(forma.x - 1.0), absf(forma.y - 1.0)))
	_comprobar(intimido[0], "intimidar: lomo erizado con su efecto")
	_comprobar(deformacion <= FelipeProto.DEFORMACION_MAXIMA + 0.001, "intimidar: deformación máxima %.3f (≤ 0,08)" % deformacion)
	await esperar(40)

	print("Prueba: Valeria perdona con ronroneo")
	sala.valeria.umbral_ruido = 3.0
	sala.valeria.oir(5.0)
	var llego := await hasta(func() -> bool: return sala.valeria.presente(), 600)
	_comprobar(llego, "Valeria entra al oír ruido y regaña")
	await _poner_felipe(sala.valeria.position.x - 60.0, SalaProto.SUELO, 1.0)
	Input.action_press("ronronear")
	var perdono := await hasta(func() -> bool: return sala.valeria.estado == Valeria.Estado.PERDONANDO, 120)
	Input.action_release("ronronear")
	_comprobar(perdono, "ronronear cerca de Valeria la hace perdonar")
	await esperar(30)
	_comprobar(is_instance_valid(sala.snack) or sala.hud.snacks > 0, "Valeria deja un snack")
	# v2: de buenas, ve su serie un rato antes de irse.
	var se_fue := await hasta(func() -> bool: return sala.valeria.estado == Valeria.Estado.FUERA, 1800)
	_comprobar(se_fue and sala.vaso.estado == Tirable.Estado.EN_SITIO, "Valeria se va y repone el vaso")

	print("Resultado: %s (%d fallas)" % ["PASA" if _fallas == 0 else "FALLA", _fallas])
	quit(0 if _fallas == 0 else 1)
