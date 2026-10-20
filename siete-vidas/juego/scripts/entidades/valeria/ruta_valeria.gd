class_name RutaValeria
extends RefCounted
## Cómo pasa Valeria de un cuarto a otro sin atravesar una puerta cerrada ni teletransportarse (G2, G3): camina hasta
## la puerta, la abre, entra al vano y se desvanece; del otro lado aparece en el vano con la puerta abierta y sale.
## También elige dónde pararse sin quedar en una puerta (lugar_seguro).

## Se abre la puerta cuando ella está a esta distancia (la mano en la manilla) y se suelta cuando se alejó a esta otra.
const ABRIR_A := 60.0
const SOLTAR_A := 70.0
## Margen desde las paredes del cuarto y desde el rectángulo sagrado de cada puerta.
const MARGEN_PARED := 40.0
const MARGEN_PUERTA := 34.0
const LADO_PUERTA := 36.0

var _v: Valeria


func _init(de: Valeria) -> void:
	_v = de


## Ver Valeria.salir_por().
func salir_por(puerta: Puerta, al_salir: Callable, soltar: bool) -> void:
	_v.caminar_a(puerta.global_position.x, func() -> void:
		# Solo esta cara: la del otro cuarto se abre cuando ella aparece allá (nunca sola y vacía, G2).
		puerta.abrir_para_paso(false)
		_v.actividad = Valeria.Actividad.PUERTA
		await esperar_que(func() -> bool: return puerta.abierta_del_todo(), 1.0)
		_v.vano_objetivo = 0.0
		await esperar_que(func() -> bool: return _v.vano <= 0.0, 1.0)
		if soltar:
			puerta.soltar_paso()
		_quedar_fuera()
		if al_salir.is_valid():
			al_salir.call())
	# Se abre un poco antes de que llegue (la mano en la manilla), no cuando ya está encima.
	_abrir_al_acercarse(puerta)


## Ver Valeria.entrar_por().
func entrar_por(puerta: Puerta, en_cuarto: String, hacia: float, al_entrar: Callable, quedarse_en_vano: bool) -> void:
	_v.aparecer_en(Vector2(puerta.global_position.x, Nivel1.SUELO), en_cuarto, hacia)
	# La puerta se abre con ella ya en el vano: aparece desde la oscuridad mientras la hoja gira (G2).
	puerta.abrir_para_paso()
	_v.vano = 0.0
	_v.vano_objetivo = 1.0
	_v.visible = true
	await esperar_que(func() -> bool: return _v.vano >= 1.0 and puerta.abierta_del_todo(), 1.0)
	if quedarse_en_vano:
		return
	_v.actividad = Valeria.Actividad.DE_PIE
	_v.cruzo_puerta.emit()
	_cerrar_al_alejarse(puerta)
	if al_entrar.is_valid():
		al_entrar.call()


## Ver Valeria.volver_adentro().
func volver_adentro(puerta: Puerta) -> void:
	_v.actividad = Valeria.Actividad.PUERTA
	puerta.abrir_para_paso()
	_v.vano_objetivo = 0.0
	await esperar_que(func() -> bool: return _v.vano <= 0.0, 1.0)
	puerta.soltar_paso()
	_quedar_fuera()


func _quedar_fuera() -> void:
	_v.actividad = Valeria.Actividad.FUERA
	_v.visible = false
	_v.cruzo_puerta.emit()


func _abrir_al_acercarse(puerta: Puerta) -> void:
	await esperar_que(func() -> bool: return absf(_v.global_position.x - puerta.global_position.x) < ABRIR_A or _v.actividad != Valeria.Actividad.CAMINANDO, 30.0)
	if _v.actividad in [Valeria.Actividad.CAMINANDO, Valeria.Actividad.PUERTA]:
		puerta.abrir_para_paso(false)


func _cerrar_al_alejarse(puerta: Puerta) -> void:
	await esperar_que(func() -> bool: return absf(_v.global_position.x - puerta.global_position.x) > SOLTAR_A or not _v.visible or _v.actividad == Valeria.Actividad.PUERTA, 8.0)
	if _v.actividad != Valeria.Actividad.PUERTA:
		puerta.soltar_paso()


## Espera cuadros de física hasta que se cumpla la condición (o pasen `maximo` segundos).
func esperar_que(condicion: Callable, maximo: float) -> void:
	var t := 0.0
	while t < maximo and not condicion.call():
		await _v.get_tree().physics_frame
		t += _v.get_physics_process_delta_time()


## Una x donde pararse que no esté en ninguna puerta (rectángulo sagrado) ni fuera del cuarto.
func lugar_seguro(x: float) -> float:
	var rect := Nivel1.rect_de(_v.cuarto)
	x = clampf(x, rect.position.x + MARGEN_PARED, rect.end.x - MARGEN_PARED)
	for centro in _v.puertas_x:
		if absf(x - centro) < Nivel1.MEDIO_RECT_PUERTA + MARGEN_PUERTA and Nivel1.habitacion_de(Vector2(centro, Nivel1.SUELO)) == _v.cuarto:
			var izquierda := centro - Nivel1.MEDIO_RECT_PUERTA - LADO_PUERTA
			var derecha := centro + Nivel1.MEDIO_RECT_PUERTA + LADO_PUERTA
			x = izquierda if absf(x - izquierda) < absf(x - derecha) else derecha
			if x < rect.position.x + MARGEN_PARED or x > rect.end.x - MARGEN_PARED:
				x = derecha if x == izquierda else izquierda
	return x
