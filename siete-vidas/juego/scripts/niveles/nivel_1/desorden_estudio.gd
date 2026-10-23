class_name DesordenEstudio
extends Node
## El desorden del estudio en la pelea con A.S.P.I. (revisión del 2026-10-23: nada vuelve a su lugar). Arma las fuentes
## que sueltan cosas de a una (Nivel1.FUENTES: el corcho y el estante del librero) y los apuntes que vuelan al pisar el
## teclado (Nivel1.APUNTES_TECLADO: dos, de a uno cada 4 s), y las conecta a la pelea: lo que cae deja una mancha.
## También el teclado de Valeria: pisarlo es una secreta de la Agenda ("jjjjjjjjjj") y, en la pelea, vuelan los apuntes.
## Los objetos tirables (vaso, taza, macetas, planta, portarretratos, libros) los arma el guion con los demás.

var fuentes: Array[FuenteDesorden] = []
var apuntes: FuenteDesorden
var _nivel: Nivel
var _guion: GuionNivel1
var _espera := 0.0


func _init(de_nivel: Nivel, guion: GuionNivel1) -> void:
	name = "Desorden del estudio"
	_nivel = de_nivel
	_guion = guion


## Crea las fuentes en el nivel (después del decorado: dibujan su versión con el hueco encima del arte de siempre) y,
## si hay pelea, las conecta a ella.
func armar(batalla: BatallaAspi) -> void:
	for datos: Array in Nivel1.FUENTES:
		var fuente := FuenteDesorden.crear(load("res://datos/fuentes/%s.tres" % datos[0]), datos[1], Nivel1.SUELO)
		_nivel.add_child(fuente)
		fuentes.append(fuente)
	apuntes = FuenteDesorden.crear(load("res://datos/fuentes/%s.tres" % Nivel1.APUNTES_TECLADO[0]), Nivel1.APUNTES_TECLADO[1], Nivel1.SUELO)
	_nivel.add_child(apuntes)
	if batalla:
		for fuente in fuentes:
			batalla.agregar_fuente(fuente)
		batalla.agregar_fuente(apuntes)


func _process(delta: float) -> void:
	_espera = maxf(0.0, _espera - delta)


## Cada cuadro (lo llama el guion): si Felipe está parado en el teclado, la secreta y, en la pelea, un apunte.
func actualizar_teclado() -> void:
	var felipe := _nivel.felipe
	if not (felipe.is_on_floor() and Nivel1.TECLADO.grow_individual(0, 6, 0, 6).has_point(felipe.global_position)):
		return
	if not _guion.teclado_pisado:
		_guion.teclado_pisado = true
		_guion.arte.decorado.queue_redraw()
		_nivel.travesuras.cumplir("teclado", Vector2(7146, Nivel1.SUELO - 120))
	if _guion.batalla and _guion.batalla.fase == PeleaJefe.Fase.PELEA:
		pisar_teclado()


## Felipe pisa el teclado en la pelea: vuela un apunte (de a uno cada ESPERA_APUNTES s, hasta que se acaban).
func pisar_teclado() -> void:
	if _espera > 0.0 or apuntes == null or apuntes.restantes() <= 0:
		return
	_espera = Nivel1.ESPERA_APUNTES
	apuntes.soltar(-1.0 if randf() < 0.5 else 1.0)
	_nivel.travesuras.jugo.palabra_en_mundo("PALABRA_FIUU", Vector2(Nivel1.TECLADO.get_center().x, Nivel1.SUELO - 130), Color(1, 1, 1), 16)
