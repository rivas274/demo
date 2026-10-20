class_name ValeriaPorLaCasa
extends Node
## Escenas de Valeria por la casa del nivel 1: una a la vez, en cola (una escena nunca pisa a otra). Valeria camina de
## verdad, abre cada puerta antes de pasar y no cambia de cuarto sin cruzar una (G2, G3 de la revisión 3).
##   "a_la_cocina": Felipe sale al recibidor; Valeria deja la serie y se encierra en la cocina («Y tú no entras: dieta.»).
##   "maullido": Felipe maúlla del otro lado de la puerta de la cocina; Valeria la abre (R19: maullar es llave).
##   "bolsas": popo táctico; Valeria sale con mascarilla, mira la caja y vuelve por bolsas dejando la puerta abierta.

## Hay una escena en curso (o esperando), y cuál.
var en_escena := false
var actual := ""
var _cola: Array[String] = []

var guion: GuionNivel1
var nivel: Nivel
var valeria: Valeria:
	get:
		return guion.valeria
var felipe: Felipe:
	get:
		return nivel.felipe
var travesuras: Travesuras:
	get:
		return nivel.travesuras
var puertas: Dictionary:
	get:
		return nivel.puertas


func _init(de: GuionNivel1) -> void:
	guion = de
	nivel = de.nivel
	name = "Valeria por la casa"


## Pide una escena (si ya hay otra, espera su turno).
func escena(nombre: String) -> void:
	if nombre in _cola:
		return
	_cola.append(nombre)
	if en_escena:
		return
	en_escena = true
	while not _cola.is_empty():
		var siguiente: String = _cola.pop_front()
		actual = siguiente
		match siguiente:
			"a_la_cocina":
				await _valeria_a_la_cocina()
			"maullido":
				await _valeria_abre_la_cocina()
			"bolsas":
				await _valeria_sale_por_bolsas()
	en_escena = false
	actual = ""


## Valeria camina hasta x en su cuarto y espera a llegar.
func _valeria_camina(x: float) -> void:
	valeria.caminar_a(x)
	await nivel.esperar_que(func() -> bool: return valeria.actividad != Valeria.Actividad.CAMINANDO, 30.0)


## Valeria sale por una puerta (camina, la abre, entra al vano) y espera a que haya salido.
func _valeria_sale(puerta: Puerta, soltar := false) -> void:
	valeria.salir_por(puerta, Callable(), soltar)
	await nivel.esperar_que(func() -> bool: return valeria.actividad == Valeria.Actividad.FUERA, 30.0)


## Valeria entra por una puerta a ese cuarto y espera a que esté afuera del vano.
func _valeria_entra(puerta: Puerta, cuarto: String, hacia: float) -> void:
	await valeria.entrar_por(puerta, cuarto, hacia)


## Felipe sale al recibidor: Valeria deja la serie, camina a la puerta de la sala, entra al recibidor detrás de él
## («Y tú no entras: dieta.»), cruza a la cocina abriendo y cerrando la puerta, y se queda adentro (G2, G3).
func _valeria_a_la_cocina() -> void:
	valeria.interrumpir()
	await _valeria_sale(puertas["sala>recibidor"])
	await _valeria_entra(puertas["recibidor<sala"], "recibidor", 1.0)
	travesuras.decir_valeria("cocina_dieta", true)
	await _valeria_sale(puertas[Nivel1.PUERTA_COCINA])
	await _valeria_entra(puertas["cocina<recibidor"], "cocina", 1.0)
	await _valeria_camina(Nivel1.VALERIA_COCINA.x)
	valeria.fijar_casa()


## Valeria va a la puerta, la abre y se asoma en el vano (la puerta se ve abrirse con ella adentro, no sola) para
## decir su frase; deja la puerta abierta y vuelve a su café (G2).
func _valeria_abre_la_cocina() -> void:
	var puerta: Puerta = puertas[Nivel1.PUERTA_COCINA]
	if not puerta.cerrada or valeria.cuarto != "cocina":
		return
	await _valeria_sale(puertas["cocina<recibidor"])
	await valeria.asomarse(puerta, "recibidor", -1.0 if felipe.global_position.x < puerta.global_position.x else 1.0)
	travesuras.decir_valeria("cocina_abre", true)
	guion.abrir_cocina()
	await get_tree().create_timer(1.4, false).timeout
	await valeria.volver_adentro(puerta)
	await _valeria_entra(puertas["cocina<recibidor"], "cocina", 1.0)
	await _valeria_camina(Nivel1.VALERIA_COCINA.x)
	valeria.fijar_casa()


## Popo táctico: Valeria sale con mascarilla por la puerta, mira la caja y vuelve a la cocina por bolsas... dejando la
## puerta abierta (es un efecto, no la recompensa: la recompensa es la foto, G6).
func _valeria_sale_por_bolsas() -> void:
	if valeria.cuarto != "cocina" or valeria.audifonos:
		return
	valeria.mascarilla = true
	await _valeria_sale(puertas["cocina<recibidor"])
	await _valeria_entra(puertas[Nivel1.PUERTA_COCINA], "recibidor", -1.0)
	travesuras.decir_valeria("popo", true)
	await _valeria_camina(valeria.lugar_seguro(Nivel1.DESCANSOS[0].end.x + 70.0))
	valeria.girar(-1.0, true)
	await get_tree().create_timer(1.2, false).timeout
	await _valeria_sale(puertas[Nivel1.PUERTA_COCINA])
	guion.abrir_cocina()
	await _valeria_entra(puertas["cocina<recibidor"], "cocina", 1.0)
	valeria.mascarilla = false
	await _valeria_camina(Nivel1.VALERIA_COCINA.x)
	valeria.fijar_casa()
