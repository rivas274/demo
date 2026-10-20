class_name Pantallas
extends Control
## Pantallas de la demo: título, introducción, pausa y final, más los avisos del tutorial.
## Sigue funcionando con el juego en pausa. Los avisos muestran la tecla o el botón del mando
## según lo último que se usó. Arte provisional dibujado con código.

signal empezar
signal reiniciar
## Cambió el modo (título, intro, juego, pausa, final): el nivel esconde o muestra su interfaz (G7).
signal modo_cambiado(modo: Modo)

enum Modo { TITULO, INTRO, JUGANDO, PAUSA, FIN }

const INTRO := ["INTRO_1", "INTRO_2", "INTRO_3"]
const ESCENA_MENU_PAUSA := "res://escenas/ui/menu_pausa.tscn"

var modo := Modo.JUGANDO:
	set(valor):
		if valor == modo:
			return
		modo = valor
		_al_cambiar_modo()
		modo_cambiado.emit(modo)
var aviso := ""
## Aviso que manda sobre el del tutorial (por ejemplo, al mostrar la meta).
var aviso_fijo := ""
var datos_fin := {}
## Menú de la pausa (Continuar, Reiniciar, Salir), armado en escenas/ui/menu_pausa.tscn.
var menu_pausa: MenuUI
## Felipe que asoma y le da un manotazo al letrero elegido (después se hace lo elegido).
var felipe_asomado: FelipeAsomado


func _ready() -> void:
	name = "Pantallas"
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_pausa = (load(ESCENA_MENU_PAUSA) as PackedScene).instantiate()
	menu_pausa.visible = false
	menu_pausa.elegido.connect(_al_elegir)
	add_child(menu_pausa)
	felipe_asomado = FelipeAsomado.new()
	add_child(felipe_asomado)
	_al_cambiar_modo()


func mostrar_titulo() -> void:
	modo = Modo.TITULO


func mostrar_fin(datos: Dictionary) -> void:
	datos_fin = datos
	modo = Modo.FIN


## Fuera del juego (título, intro, pausa, fin) esta pantalla está en la pila del gestor: el juego queda en pausa.
func _al_cambiar_modo() -> void:
	if not is_inside_tree():
		return
	var gestor := GestorPantallas.de(self)
	if modo == Modo.JUGANDO:
		gestor.cerrar(self)
	else:
		gestor.abrir(self)
	if menu_pausa:
		menu_pausa.visible = modo == Modo.PAUSA
	queue_redraw()


## Texto de un aviso con las teclas del dispositivo en uso: "{saltar} para saltar" -> "[Espacio] para saltar".
func etiquetar(texto: String) -> String:
	return Controles.etiquetar(texto)


func _input(evento: InputEvent) -> void:
	Controles.registrar_evento(evento)


func _process(_delta: float) -> void:
	var aceptar := Input.is_action_just_pressed("ui_accept")
	match modo:
		Modo.TITULO:
			if aceptar:
				modo = Modo.INTRO
		Modo.INTRO:
			if aceptar:
				modo = Modo.JUGANDO
				empezar.emit()
		Modo.JUGANDO:
			if Input.is_action_just_pressed("pausa"):
				modo = Modo.PAUSA
		Modo.PAUSA:
			# Enter o A los toma el botón con foco del menú; la tecla de pausa también continúa.
			if Input.is_action_just_pressed("pausa"):
				modo = Modo.JUGANDO
		Modo.FIN:
			if aceptar:
				_reiniciar()
	queue_redraw()


func _al_elegir(opcion: StringName) -> void:
	if felipe_asomado.ocupado:
		return
	var boton := menu_pausa.get_node_or_null(NodePath(opcion)) as Button
	var hueco := menu_pausa.colocar_hueco(boton) if boton else null
	if hueco:
		var fuerza := (boton as BotonMenu).datos.fuerza_manotazo if boton is BotonMenu else 1.0
		await felipe_asomado.manotazo(boton, hueco, menu_pausa.lado_felipe, fuerza)
	match opcion:
		&"Continuar":
			modo = Modo.JUGANDO
		&"Reiniciar":
			_reiniciar()
		&"Salir":
			get_tree().quit()


func _reiniciar() -> void:
	GestorPantallas.de(self).cerrar(self)
	get_tree().paused = false
	reiniciar.emit()


func _draw() -> void:
	var tam := get_viewport_rect().size
	var claro := Estilo.color(&"pantalla_texto")
	var acento := Estilo.color(&"pantalla_acento")
	var aceptar := Controles.texto("ui_accept")
	match modo:
		Modo.TITULO:
			draw_rect(Rect2(Vector2.ZERO, tam), Estilo.color(&"fondo_pantalla"))
			Estilo.texto_centrado(self, tr("TITULO_JUEGO"), 92, Estilo.letra(&"titulo"), acento)
			Estilo.texto_centrado(self, tr("TITULO_SUBTITULO"), 124, Estilo.letra(&"subtitulo"), claro)
			Estilo.texto_centrado(self, tr("TITULO_DEMO"), 160, Estilo.letra(&"texto"), claro)
			Estilo.texto_centrado(self, tr("UI_JUGAR") % aceptar, 250, Estilo.letra(&"texto"), acento)
		Modo.INTRO:
			draw_rect(Rect2(Vector2.ZERO, tam), Estilo.color(&"fondo_pantalla"))
			for i in INTRO.size():
				Estilo.texto_centrado(self, tr(INTRO[i]), 130 + i * 26, Estilo.letra(&"texto_chico"), claro if i < 2 else acento)
			Estilo.texto_centrado(self, tr("UI_CONTINUAR_TECLA") % aceptar, 280, Estilo.letra(&"nota"), claro)
		Modo.PAUSA:
			draw_rect(Rect2(Vector2.ZERO, tam), Estilo.color(&"fondo_pantalla"))
			Estilo.texto_centrado(self, tr("PAUSA_TITULO"), 52, Estilo.letra(&"pausa"), acento)
		Modo.FIN:
			draw_rect(Rect2(Vector2.ZERO, tam), Estilo.color(&"fondo_pantalla"))
			Estilo.texto_centrado(self, tr("FIN_TITULO"), 80, Estilo.letra(&"fin"), acento)
			Estilo.texto_centrado(self, tr("FIN_FRASE"), 112, Estilo.letra(&"nota"), claro)
			var lineas := [
				tr("FIN_TIEMPO") % datos_fin.get("tiempo", "—"),
				tr("FIN_CALCETINES") % datos_fin.get("calcetines", "—"),
				tr("FIN_LOGROS") % datos_fin.get("logros", "—"),
				tr("FIN_VIDAS") % datos_fin.get("vidas", "—"),
			]
			for i in lineas.size():
				Estilo.texto_centrado(self, lineas[i], 160 + i * 20, Estilo.letra(&"texto_chico"), claro)
			Estilo.texto_centrado(self, tr("FIN_CONTINUARA") % aceptar, 290, Estilo.letra(&"nota"), acento)
		Modo.JUGANDO:
			var mostrado := aviso_fijo if aviso_fijo != "" else aviso
			if mostrado != "":
				var texto := etiquetar(mostrado)
				var tamano := Estilo.letra(&"texto_chico")
				var ancho := Estilo.fuente().get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano).x + 20.0
				var caja := Rect2((tam.x - ancho) / 2.0, tam.y - 44, ancho, 22)
				draw_rect(caja, Estilo.color(&"fondo_aviso"))
				draw_string(Estilo.fuente(), caja.position + Vector2(10, 15), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, claro)
