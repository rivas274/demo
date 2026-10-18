class_name Pantallas
extends Control
## Pantallas de la demo: título, introducción, pausa y final, más los avisos del tutorial.
## Sigue funcionando con el juego en pausa. Los avisos muestran la tecla o el botón del mando
## según lo último que se usó. Arte provisional dibujado con código.

signal empezar
signal reiniciar

enum Modo { TITULO, INTRO, JUGANDO, PAUSA, FIN }

## acción -> [tecla, botón del mando Xbox]
const ETIQUETAS := {
	"mover_izquierda": ["A", "←"],
	"mover_derecha": ["D", "→"],
	"mover_arriba": ["W", "↑"],
	"agacharse": ["S", "↓"],
	"saltar": ["Espacio", "A"],
	"zoomies": ["Shift", "RB"],
	"zarpazo": ["J", "X"],
	"interactuar": ["E", "Y"],
	"pausa": ["Esc", "Start"],
}
const INTRO := [
	"Valeria subió a internet el video de Su Majestad atorado en una caja de zapatos.",
	"Doce millones de vistas. Cero disculpas.",
	"\"Me voy de esta casa.\" — Felipe Ron con Pasas I",
]
const FONDO := Color(0.13, 0.09, 0.1, 0.88)
const CLARO := Color("f3efe8")
const ACENTO := Color("ffd58a")

var modo := Modo.JUGANDO
var aviso := ""
## Aviso que manda sobre el del tutorial (por ejemplo, al mostrar la meta).
var aviso_fijo := ""
var usa_mando := false
var datos_fin := {}


func _ready() -> void:
	name = "Pantallas"
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func mostrar_titulo() -> void:
	modo = Modo.TITULO
	get_tree().paused = true


func mostrar_fin(datos: Dictionary) -> void:
	datos_fin = datos
	modo = Modo.FIN
	get_tree().paused = true


## Texto de un aviso con las teclas del dispositivo en uso: "{saltar} para saltar" -> "[Espacio] para saltar".
func etiquetar(texto: String) -> String:
	for accion: String in ETIQUETAS:
		texto = texto.replace("{%s}" % accion, "[%s]" % ETIQUETAS[accion][1 if usa_mando else 0])
	return texto


func _input(evento: InputEvent) -> void:
	if evento is InputEventJoypadButton or (evento is InputEventJoypadMotion and absf(evento.axis_value) > 0.5):
		usa_mando = true
	elif evento is InputEventKey:
		usa_mando = false


func _process(_delta: float) -> void:
	var aceptar := Input.is_action_just_pressed("ui_accept")
	match modo:
		Modo.TITULO:
			if aceptar:
				modo = Modo.INTRO
		Modo.INTRO:
			if aceptar:
				modo = Modo.JUGANDO
				get_tree().paused = false
				empezar.emit()
		Modo.JUGANDO:
			if Input.is_action_just_pressed("pausa"):
				modo = Modo.PAUSA
				get_tree().paused = true
		Modo.PAUSA:
			if Input.is_action_just_pressed("pausa") or aceptar:
				modo = Modo.JUGANDO
				get_tree().paused = false
			elif Input.is_physical_key_pressed(KEY_R):
				get_tree().paused = false
				reiniciar.emit()
			elif Input.is_physical_key_pressed(KEY_Q):
				get_tree().quit()
		Modo.FIN:
			if aceptar:
				get_tree().paused = false
				reiniciar.emit()
	queue_redraw()


func _draw() -> void:
	var fuente := ThemeDB.fallback_font
	var tam := get_viewport_rect().size
	match modo:
		Modo.TITULO:
			draw_rect(Rect2(Vector2.ZERO, tam), FONDO)
			_centrado(fuente, "FELIPE", 92, 34, ACENTO)
			_centrado(fuente, "Nueve Vidas, Cero Disculpas", 124, 16, CLARO)
			_centrado(fuente, "Demo: La Gran Fuga", 160, 12, CLARO)
			_centrado(fuente, "[%s] Jugar" % ("A" if usa_mando else "Enter"), 250, 12, ACENTO)
		Modo.INTRO:
			draw_rect(Rect2(Vector2.ZERO, tam), FONDO)
			for i in INTRO.size():
				_centrado(fuente, INTRO[i], 130 + i * 26, 11, CLARO if i < 2 else ACENTO)
			_centrado(fuente, "[%s] Continuar" % ("A" if usa_mando else "Enter"), 280, 10, CLARO)
		Modo.PAUSA:
			draw_rect(Rect2(Vector2.ZERO, tam), FONDO)
			_centrado(fuente, "Pausa", 140, 20, ACENTO)
			_centrado(fuente, "[%s] Continuar   ·   [R] Reiniciar   ·   [Q] Salir" % ETIQUETAS["pausa"][1 if usa_mando else 0], 180, 11, CLARO)
		Modo.FIN:
			draw_rect(Rect2(Vector2.ZERO, tam), FONDO)
			_centrado(fuente, "Demo completada", 80, 22, ACENTO)
			_centrado(fuente, "\"No me caí. Aterricé con estilo.\" — Poder nuevo: Caer de Pie", 112, 10, CLARO)
			var lineas := [
				"Tiempo: %s" % datos_fin.get("tiempo", "—"),
				"Calcetines: %s" % datos_fin.get("calcetines", "—"),
				"Logros: %s" % datos_fin.get("logros", "—"),
				"Vidas perdidas: %s" % datos_fin.get("vidas", "—"),
			]
			for i in lineas.size():
				_centrado(fuente, lineas[i], 160 + i * 20, 11, CLARO)
			_centrado(fuente, "Continuará en La Cuadra...   [%s] Jugar de nuevo" % ("A" if usa_mando else "Enter"), 290, 10, ACENTO)
		Modo.JUGANDO:
			var mostrado := aviso_fijo if aviso_fijo != "" else aviso
			if mostrado != "":
				var texto := etiquetar(mostrado)
				var ancho := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x + 20.0
				var caja := Rect2((tam.x - ancho) / 2.0, tam.y - 44, ancho, 22)
				draw_rect(caja, Color(0.13, 0.09, 0.1, 0.75))
				draw_string(fuente, caja.position + Vector2(10, 15), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, CLARO)


func _centrado(fuente: Font, texto: String, y: float, tam_fuente: int, color: Color) -> void:
	var ancho := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam_fuente).x
	draw_string(fuente, Vector2((get_viewport_rect().size.x - ancho) / 2.0, y), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam_fuente, color)
