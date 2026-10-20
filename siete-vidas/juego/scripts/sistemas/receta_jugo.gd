class_name RecetaJugo
extends RefCounted
## Pieza reutilizable de jugo (pilar 5): aplica la receta de una acción (DatosJugo, en datos/jugo/<accion>.tres) a
## quien la hace. No decide cuándo: el estado o la pieza que hace la acción la llama en su momento (anticipar al
## entrar, líneas mientras corre, impacto al chocar, polvo y derrape al frenar). La pausa de impacto y la sacudida
## las pone el sistema Jugo del nivel cuando el actor emite su señal de impacto (Travesuras, con impacto_de()).
##
## Receta: datos/jugo/<accion>.tres → RecetaJugo.de("<accion>") → llamar sus pasos (ver 07-arquitectura.md).

const CARPETA := "res://datos/jugo/%s.tres"

static var _cache := {}

## La receta (null si la acción no tiene).
var datos: DatosJugo
var actor: Node2D
var _reloj_lineas := 0.0


func _init(de: Node2D, receta: DatosJugo) -> void:
	actor = de
	datos = receta


## Los datos de jugo de una acción (null si no hay archivo).
static func datos_de(accion: String) -> DatosJugo:
	if not _cache.has(accion):
		var ruta := CARPETA % accion
		_cache[accion] = load(ruta) if ResourceLoader.exists(ruta) else null
	return _cache[accion]


## Una receta para ese actor y esa acción (con datos vacíos si la acción no tiene archivo: no hace nada).
static func de(quien: Node2D, accion: String) -> RecetaJugo:
	var receta := datos_de(accion)
	return RecetaJugo.new(quien, receta if receta else DatosJugo.new())


## Pausa de impacto y sacudida de la receta de esa acción, en el sistema Jugo del nivel. Devuelve la frase (evento
## de Frases) que va con el impacto, o "".
static func impacto_de(accion: String, jugo: Jugo) -> String:
	var receta := datos_de(accion)
	if receta == null or jugo == null:
		return ""
	if receta.pausa_impacto > 0.0:
		jugo.congelar(receta.pausa_impacto)
	if receta.sacudida > 0.0:
		jugo.sacudir(receta.sacudida, receta.fuerza_sacudida)
	return receta.frase_impacto


## Forma de la anticipación, siempre dentro de ±8 %.
func forma_anticipacion() -> Vector2:
	var limite := Felipe.DEFORMACION_MAXIMA
	return datos.forma_anticipacion.clamp(Vector2.ONE * (1.0 - limite), Vector2.ONE * (1.0 + limite))


## Líneas de velocidad mientras corre: llamar cada cuadro con la dirección (−1 o 1) y el alto del cuerpo.
func correr(delta: float, direccion: float, alto := 40.0) -> void:
	if datos.lineas_cada <= 0.0:
		return
	_reloj_lineas -= delta
	if _reloj_lineas > 0.0:
		return
	_reloj_lineas = datos.lineas_cada
	var lineas := LineasVelocidad.new(datos, direccion, alto)
	lineas.global_position = actor.global_position
	actor.get_parent().add_child(lineas)


## Adelanta la cámara hacia donde corre (sin zoom: el pixel art no se deforma) y la devuelve al centro.
func adelantar_camara(camara: Camera2D, direccion: float) -> void:
	if camara == null or datos.adelanto_camara <= 0.0:
		return
	var t := camara.create_tween()
	t.tween_property(camara, "offset:x", direccion * datos.adelanto_camara, datos.tiempo_camara).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(camara, "offset:x", 0.0, datos.tiempo_camara * 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_delay(datos.tiempo_camara)


## Velocidad inicial para patinar `derrape` px en `tiempo_derrape` s frenando parejo (0 si no derrapa).
func velocidad_derrape() -> float:
	if datos.derrape <= 0.0 or datos.tiempo_derrape <= 0.0:
		return 0.0
	return 2.0 * datos.derrape / datos.tiempo_derrape


## Nube de polvo y pelos en los pies (al frenar o chocar), hacia atrás de la dirección.
func polvo_y_pelos(direccion: float) -> void:
	var pies := actor.global_position
	if datos.polvo > 0:
		var nube := Particulas.polvo(datos.polvo, 0.45, Vector2(0, 160), Vector2(30, 80) * datos.empuje_polvo, Vector2(2, 4), datos.color_polvo, 70.0)
		_soltar(nube, pies, -direccion)
	if datos.pelos > 0:
		var pelos := Particulas.polvo(datos.pelos, 0.7, Vector2(0, 90), Vector2(20, 60), Vector2(1, 2), datos.color_pelos, 80.0)
		_soltar(pelos, pies + Vector2(0, -8), -direccion)


## Marca breve del derrape en el piso, desde donde empezó a patinar.
func marca(direccion: float) -> void:
	if datos.marca_derrape <= 0.0 or datos.derrape <= 0.0:
		return
	var huella := MarcaDerrape.new(datos, direccion)
	huella.global_position = actor.global_position.round()
	actor.get_parent().add_child(huella)


func _soltar(particulas: CPUParticles2D, donde: Vector2, hacia: float) -> void:
	particulas.direction = Vector2(hacia * 0.6, -1).normalized()
	particulas.z_index = Capas.PERSONAJES
	particulas.global_position = donde
	actor.get_parent().add_child(particulas)
	particulas.restart()
	particulas.emitting = true
	particulas.finished.connect(particulas.queue_free)
