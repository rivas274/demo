class_name ResumenDia
extends CanvasLayer
## Resumen del día al terminar un nivel, tipo Balatro: las filas aparecen una a una y sus números suben contando
## con un golpe; al final, una frase de Felipe con su retrato. Pausa el juego; Enter (o A, o Tab) cierra.

signal cerrado

const RETRATOS := preload("res://assets/felipe/felipe-retratos.png")
const LADO_RETRATO := 200.0 / 3.0

@export var pausa_entre_filas := 0.5
@export var duracion_conteo := 0.5

## Filas: [texto, valor, total (-1 si no tiene), nota chica opcional].
var filas: Array = []
var frase: Array = ["", 0]
var terminado := false
var _mostradas := 0
var _valores: Array[float] = []
var _golpes: Array[float] = []
var _tiempo := 0.0
var _lienzo: Control
var _frase_visible := 0.0


## Filas a partir de la agenda y las recompensas (más los perdones de Valeria, que cuenta el nivel).
static func filas_de(agenda: Agenda, recompensas: Recompensas, perdones := 0) -> Array:
	return [
		[TranslationServer.translate("RESUMEN_AGENDA"), agenda.cumplidas(), agenda.total(), ""],
		[TranslationServer.translate("RESUMEN_SECRETAS"), agenda.secretas_cumplidas(), agenda.total_secretas(), ""],
		[TranslationServer.translate("RESUMEN_CALCETINES"), recompensas.calcetines, -1, recompensas.texto_ranura()],
		[TranslationServer.translate("RESUMEN_FOTOS"), recompensas.fotos, -1, TranslationServer.translate("RESUMEN_FOTOS_NOTA")],
		[TranslationServer.translate("RESUMEN_SNACKS"), recompensas.snacks(), Felipe.SNACKS_MAX, ""],
		[TranslationServer.translate("RESUMEN_PERDONES"), perdones, -1, TranslationServer.translate("RESUMEN_PERDONES_NOTA")],
	]


func mostrar(datos: Array, frase_final: Array) -> void:
	filas = datos
	frase = frase_final
	_valores.clear()
	_golpes.clear()
	for f in filas:
		_valores.append(0.0)
		_golpes.append(0.0)


func _ready() -> void:
	name = "ResumenDia"
	layer = Capas.CAPA_RESUMEN
	process_mode = Node.PROCESS_MODE_ALWAYS
	_lienzo = Control.new()
	_lienzo.size = Vector2(640, 360)
	_lienzo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lienzo.draw.connect(_dibujar)
	add_child(_lienzo)
	GestorPantallas.de(self).abrir(self)


func _process(delta: float) -> void:
	delta = delta / maxf(Engine.time_scale, 0.001)
	_tiempo += delta
	var objetivo := mini(int(_tiempo / pausa_entre_filas), filas.size())
	if objetivo > _mostradas:
		_mostradas = objetivo
		_golpes[_mostradas - 1] = 1.0
	for i in _mostradas:
		var meta := float(filas[i][1])
		if _valores[i] < meta:
			var antes := int(_valores[i])
			_valores[i] = minf(meta, _valores[i] + maxf(meta, 1.0) / duracion_conteo * delta)
			if int(_valores[i]) != antes:
				_golpes[i] = 1.0
		_golpes[i] = maxf(0.0, _golpes[i] - delta * 4.0)
	if _tiempo > filas.size() * pausa_entre_filas + duracion_conteo + 0.3:
		_frase_visible = minf(1.0, _frase_visible + delta * 3.0)
		terminado = true
	_lienzo.queue_redraw()
	if terminado and (_apretado("saltar_dialogo") or _apretado("agenda") or _apretado("ui_accept")):
		cerrar()


func _apretado(accion: String) -> bool:
	return InputMap.has_action(accion) and Input.is_action_just_pressed(accion)


func cerrar() -> void:
	GestorPantallas.de(self).cerrar(self)
	cerrado.emit()
	queue_free()


func _dibujar() -> void:
	var c := _lienzo
	var entrada := minf(_tiempo * 4.0, 1.0)
	c.draw_rect(Rect2(0, 0, 640, 360), Estilo.color(&"resumen_velo", Estilo.color(&"resumen_velo").a * entrada))
	# Paño verde con borde dorado.
	var panel := Rect2(110, 14, 420, 334)
	c.draw_rect(panel.grow(3), Estilo.color(&"resumen_borde"))
	c.draw_rect(panel, Estilo.color(&"resumen_pano"))
	_texto(c, Vector2(320, 42), tr("RESUMEN_TITULO"), &"resumen_titulo", Estilo.color(&"resumen_titulo"), true)
	_texto(c, Vector2(320, 56), tr("RESUMEN_SUBTITULO"), &"resumen_subtitulo", Estilo.color(&"resumen_subtitulo"), true)
	var y := 66.0
	for i in _mostradas:
		var fila: Array = filas[i]
		var g := _golpes[i]
		var caja := Rect2(126, y, 388, 30)
		c.draw_rect(caja, Estilo.color(&"resumen_fila"))
		c.draw_rect(Rect2(caja.position, Vector2(5, caja.size.y)), Estilo.color(&"resumen_marca_a") if i % 2 == 0 else Estilo.color(&"resumen_marca_b"))
		_texto(c, Vector2(138, y + 15), String(fila[0]), &"resumen_fila", Estilo.color(&"resumen_texto"), false)
		var nota := String(fila[3]) if fila.size() > 3 else ""
		if nota != "":
			_texto(c, Vector2(138, y + 26), nota, &"resumen_nota", Estilo.color(&"resumen_nota"), false)
		var numero := str(int(_valores[i]))
		if int(fila[2]) >= 0:
			numero += "/%d" % fila[2]
		var completo := int(fila[2]) >= 0 and int(_valores[i]) >= int(fila[2])
		# El golpe pasa el número a la letra grande (24 px) un instante: la letra pixel va siempre a su tamaño.
		var estilo := &"resumen_numero_golpe" if g > 0.5 else &"resumen_numero"
		var ancho := Estilo.ancho(numero, estilo)
		_texto(c, Vector2(504 - ancho, y + 22 - roundf(3.0 * g)), numero, estilo, Estilo.color(&"resumen_titulo") if completo else Estilo.color(&"blanco"), false)
		y += 34.0
	if _frase_visible > 0.0:
		var a := _frase_visible
		var caja := Rect2(126, 274, 388, 50)
		c.draw_rect(caja, Estilo.color(&"resumen_frase_fondo", 0.95 * a))
		c.draw_rect(caja, Estilo.color(&"borde_dorado", a), false, 2.0)
		var animo := int(frase[1])
		var cara := Rect2(animo % 3 * LADO_RETRATO, animo / 3 * LADO_RETRATO, LADO_RETRATO, LADO_RETRATO)
		c.draw_texture_rect_region(RETRATOS, Rect2(130, 278, 42, 42), cara, Estilo.color(&"blanco", a))
		Estilo.escribir(c, Vector2(180, 288), tr("NOMBRE_felipe"), &"resumen_nombre", Estilo.color(&"nombre_hablante", a))
		c.draw_multiline_string(Estilo.fuente(&"resumen_frase"), Vector2(180, 302), String(frase[0]), HORIZONTAL_ALIGNMENT_LEFT, 326, Estilo.letra(&"resumen_frase"), 2, Estilo.color(&"texto_claro", a))
		if terminado and fmod(_tiempo, 1.0) < 0.7:
			IconosBotones.dibujar(c, "saltar_dialogo", Vector2(268, 330), 12.0)
			_texto(c, Vector2(286, 340), tr("RESUMEN_SEGUIR"), &"resumen_pista", Estilo.color(&"resumen_pista"), false)


func _texto(c: Control, pos: Vector2, texto: String, estilo: StringName, color: Color, centrado: bool) -> void:
	var p := pos
	if centrado:
		p.x -= roundf(Estilo.ancho(texto, estilo) / 2.0)
	Estilo.texto_con_contorno(c, p, texto, estilo, color, &"resumen_contorno")
