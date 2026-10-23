class_name ResumenDia
extends CanvasLayer
## Resumen del día al terminar un nivel, tipo Balatro: las filas aparecen una a una y sus números suben contando
## con un golpe; al final, una frase de Felipe con su retrato. Pausa el juego; Enter (o A, o Tab) cierra.
## Interfaz v2 («A + C»): el panel de la pausa en toda la zona segura, la franja del título, una fila del bolsillo por
## dato (nombre y nota a la izquierda, número a la derecha) y la frase con el retrato sobre su fondo inclinado.

signal cerrado

## Filas: dónde empieza la primera, cuánto mide cada una y su paso.
const X_FILA := 118.0
const ANCHO_FILA := 404.0
const Y_FILAS := 66.0
const PASO_FILA := 26.0
## La frase final, abajo.
const Y_FRASE := 258.0

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
## `siestas`: los desmayos del nivel (salud de 9 huellas: un chiste, no un castigo).
static func filas_de(agenda: Agenda, recompensas: Recompensas, perdones := 0, siestas := 0) -> Array:
	return [
		[TranslationServer.translate("RESUMEN_AGENDA"), agenda.cumplidas(), agenda.total(), ""],
		[TranslationServer.translate("RESUMEN_SECRETAS"), agenda.secretas_cumplidas(), agenda.total_secretas(), ""],
		[TranslationServer.translate("RESUMEN_CALCETINES"), recompensas.calcetines, -1, recompensas.texto_ranura()],
		[TranslationServer.translate("RESUMEN_FOTOS"), recompensas.fotos, -1, TranslationServer.translate("RESUMEN_FOTOS_NOTA")],
		[TranslationServer.translate("RESUMEN_SNACKS"), recompensas.snacks(), Felipe.SNACKS_MAX, ""],
		[TranslationServer.translate("RESUMEN_PERDONES"), perdones, -1, TranslationServer.translate("RESUMEN_PERDONES_NOTA")],
		[TranslationServer.translate("RESUMEN_SIESTAS"), siestas, -1, TranslationServer.translate("RESUMEN_SIESTAS_NOTA")],
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
	KitUI.pieza(c, "pausa-panel", ZonasTexto.SEGURA)
	var x0 := ZonasTexto.SEGURA.position.x + 14.0
	var y0 := ZonasTexto.SEGURA.position.y
	var ancho := KitUI.franja_texto(c, "titulo-franja", Vector2(x0, y0 + 10.0), 18.0, tr("RESUMEN_TITULO"), &"cartel_kit", Estilo.color(&"ui_contorno"))
	KitUI.escribir(c, x0 + ancho + 10.0, y0 + 14.0, tr("RESUMEN_SUBTITULO"), &"resumen_subtitulo", Estilo.color(&"resumen_subtitulo"))
	var y := Y_FILAS
	for i in _mostradas:
		var fila: Array = filas[i]
		var g := _golpes[i]
		KitUI.pieza(c, "bolsillo-fila", Rect2(X_FILA, y, ANCHO_FILA, 22.0))
		KitUI.escribir(c, X_FILA + 14.0, y + 7.0, String(fila[0]), &"resumen_fila", Estilo.color(&"resumen_texto"))
		var nota := String(fila[3]) if fila.size() > 3 else ""
		if nota != "":
			var x_nota := X_FILA + 22.0 + Estilo.ancho(String(fila[0]), &"resumen_fila")
			KitUI.escribir(c, x_nota, y + 7.0, nota, &"resumen_nota", Estilo.color(&"resumen_nota"))
		var numero := str(int(_valores[i]))
		if int(fila[2]) >= 0:
			numero += "/%d" % fila[2]
		var completo := int(fila[2]) >= 0 and int(_valores[i]) >= int(fila[2])
		# El golpe hace saltar el número 2 px (la letra pixel va siempre a su tamaño).
		var x_num := X_FILA + ANCHO_FILA - 16.0 - Estilo.ancho(numero, &"resumen_numero")
		KitUI.escribir(c, x_num, y + 6.0 - roundf(2.0 * g), numero, &"resumen_numero", Estilo.color(&"resumen_titulo") if completo or g > 0.5 else Estilo.color(&"resumen_texto"))
		y += PASO_FILA
	if _frase_visible > 0.0:
		var a := _frase_visible
		var fondo := Vector2(X_FILA, Y_FRASE)
		KitUI.icono(c, "retrato-fondo-felipe", fondo, Estilo.color(&"blanco", a))
		var cara := KitUI.textura("cara-dialogo-felipe-%d" % clampi(int(frase[1]), 0, 8))
		if cara:
			c.draw_texture(cara, Vector2(fondo.x + 3.0, fondo.y + 58.0 - cara.get_height()), Estilo.color(&"blanco", a))
		var x_texto := X_FILA + 72.0
		KitUI.franja_texto(c, "nombre-franja-felipe", Vector2(x_texto, Y_FRASE), 15.0, tr("NOMBRE_felipe"), &"dialogo_nombre", Estilo.color(&"ui_contorno"))
		c.draw_multiline_string(Estilo.fuente(&"resumen_frase"), Vector2(x_texto, Y_FRASE + 32.0), tr(String(frase[0])), HORIZONTAL_ALIGNMENT_LEFT, ANCHO_FILA - 72.0, Estilo.letra(&"resumen_frase"), 2, Estilo.color(&"resumen_texto", a))
		if terminado and fmod(_tiempo, 1.0) < 0.7:
			IconosBotones.dibujar(c, "saltar_dialogo", Vector2(X_FILA + ANCHO_FILA - 70.0, 322), 14.0)
			KitUI.escribir(c, X_FILA + ANCHO_FILA - 52.0, 324.0, tr("RESUMEN_SEGUIR"), &"resumen_pista", Estilo.color(&"resumen_pista"))
