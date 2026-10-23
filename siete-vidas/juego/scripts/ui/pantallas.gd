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
## La pausa de la interfaz v2 (escenas/ui/menu_pausa.tscn): el panel en toda la zona segura, la franja «PAUSA» y la
## lista a la izquierda; a la derecha, el bolsillo y la Ficha de Su Majestad (sin pergamino ni cojín).
var pausa: Control
## Menú de la pausa (Continuar, Bolsillo, Ficha, Opciones, Reiniciar, Salir): botones del kit v2.
var menu_pausa: MenuUI
## La Ficha de Su Majestad (el único lugar donde se ve el peso).
var ficha: FichaSuMajestad
## El bolsillo de la pausa: salud, snacks, calcetines y fotos (el HUD del juego solo deja la salud).
var bolsillo: PanelBolsillo
## Dónde va el bolsillo en la pausa: arriba a la derecha, sobre la Ficha.
const POS_BOLSILLO := Vector2(200, 28)
## Opciones (controles, reducir movimiento, volumen), encima de la pausa.
var opciones: PantallaOpciones


func _ready() -> void:
	name = "Pantallas"
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	pausa = (load(ESCENA_MENU_PAUSA) as PackedScene).instantiate()
	pausa.visible = false
	add_child(pausa)
	menu_pausa = pausa.get_node("%Menu")
	menu_pausa.elegido.connect(_al_elegir)
	ficha = pausa.get_node("%Ficha")
	bolsillo = PanelBolsillo.new()
	bolsillo.name = "Bolsillo"
	bolsillo.position = POS_BOLSILLO
	pausa.add_child(bolsillo)
	opciones = PantallaOpciones.crear()
	opciones.visible = false
	opciones.cerrada.connect(func() -> void:
		pausa.visible = modo == Modo.PAUSA
		menu_pausa.enfocar(&"Opciones"))
	add_child(opciones)
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
	if pausa:
		pausa.visible = modo == Modo.PAUSA
	queue_redraw()


## La ficha de la pausa muestra los kilos de este Felipe.
func conectar_felipe(felipe: Felipe) -> void:
	if ficha:
		ficha.conectar(felipe)


## Texto de un aviso con las teclas del dispositivo en uso: "{saltar} para saltar" -> "[Espacio] para saltar".
func etiquetar(texto: String) -> String:
	return Controles.etiquetar(texto)


func _input(evento: InputEvent) -> void:
	Controles.registrar_evento(evento)


func _process(_delta: float) -> void:
	# Con otra pantalla encima (opciones, libreta), las teclas son de ella.
	var arriba := GestorPantallas.de(self).arriba()
	if arriba != null and arriba != self:
		return
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


## Lo elegido en la pausa. «Bolsillo» y «Ficha» se ven siempre a la derecha: elegirlos los hace destellar.
func _al_elegir(opcion: StringName) -> void:
	match opcion:
		&"Continuar":
			modo = Modo.JUGANDO
		&"Bolsillo":
			bolsillo.resaltar()
		&"Ficha":
			ficha.resaltar()
		&"Opciones":
			pausa.visible = false
			opciones.abrir()
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
			Estilo.texto_centrado(self, tr("TITULO_JUEGO"), 92, &"titulo", acento)
			Estilo.texto_centrado(self, tr("TITULO_SUBTITULO"), 124, &"subtitulo", claro)
			Estilo.texto_centrado(self, tr("TITULO_DEMO"), 160, &"texto", claro)
			Estilo.texto_centrado(self, tr("UI_JUGAR") % aceptar, 250, &"texto", acento)
		Modo.INTRO:
			draw_rect(Rect2(Vector2.ZERO, tam), Estilo.color(&"fondo_pantalla"))
			for i in INTRO.size():
				Estilo.texto_centrado(self, tr(INTRO[i]), 130 + i * 26, &"texto_chico", claro if i < 2 else acento)
			Estilo.texto_centrado(self, tr("UI_CONTINUAR_TECLA") % aceptar, 280, &"nota", claro)
		Modo.PAUSA:
			draw_rect(Rect2(Vector2.ZERO, tam), Estilo.color(&"fondo_pantalla"))
		Modo.FIN:
			draw_rect(Rect2(Vector2.ZERO, tam), Estilo.color(&"fondo_pantalla"))
			Estilo.texto_centrado(self, tr("FIN_TITULO"), 80, &"fin", acento)
			Estilo.texto_centrado(self, tr("FIN_FRASE"), 112, &"nota", claro)
			var lineas := [
				tr("FIN_TIEMPO") % datos_fin.get("tiempo", "—"),
				tr("FIN_CALCETINES") % datos_fin.get("calcetines", "—"),
				tr("FIN_LOGROS") % datos_fin.get("logros", "—"),
				tr("FIN_SIESTAS") % datos_fin.get("siestas", "—"),
			]
			for i in lineas.size():
				Estilo.texto_centrado(self, lineas[i], 160 + i * 20, &"texto_chico", claro)
			Estilo.texto_centrado(self, tr("FIN_CONTINUARA") % aceptar, 290, &"nota", acento)
		Modo.JUGANDO:
			var mostrado := tr(aviso_fijo) if aviso_fijo != "" else tr(aviso)
			if mostrado != "":
				var texto := etiquetar(mostrado)
				var ancho := Estilo.ancho(texto, &"texto_chico") + 20.0
				var caja := Rect2((tam.x - ancho) / 2.0, tam.y - 44, ancho, 22)
				draw_rect(caja, Estilo.color(&"fondo_aviso"))
				Estilo.escribir(self, caja.position + Vector2(10, 16), texto, &"texto_chico", claro)
