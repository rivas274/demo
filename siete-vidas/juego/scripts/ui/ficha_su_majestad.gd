class_name FichaSuMajestad
extends Control
## La «Ficha de Su Majestad» del menú de pausa (pilar 4), en el lenguaje de la interfaz v2 («A + C», kit
## assets/ui/v2/): el panel con la sombra ámbar, el retrato presumido sobre su fondo inclinado con fragmentos,
## «SU MAJESTAD · 8,2 kg» y su humor, y una BarraEstadistica por estadística (carisma, defensa, ataque y peso, con
## puntas en diagonal) más el chiste de la velocidad. Es el único lugar donde se ve el peso (nunca en el HUD).
## Solo escucha: se conecta a Felipe.peso_cambiado, calcula las estadísticas con DatosFicha (datos/ui/ficha.tres) y
## avisa con `estadisticas_cambiadas`; cada barra escucha esa señal y toma lo suyo. Las estadísticas son solo de
## chiste: nada del juego las lee (decisión del creador, 2026-10-20).
## Escena: escenas/ui/ficha_su_majestad.tscn (las barras se arman ahí).

signal estadisticas_cambiadas(estadisticas: Dictionary)

const DATOS := "res://datos/ui/ficha.tres"
## Medidas de la lámina: panel de 394×166; texto desde x 74.
const TAM := Vector2(394, 166)
const X_TEXTO := 74.0

@export var datos: DatosFicha

var felipe: Felipe
var kilos := Felipe.PESO_INICIAL
var ultimas := {}
## 0 a 1: el destello al elegir «Ficha» en la pausa.
var resalto := 0.0:
	set(valor):
		resalto = valor
		queue_redraw()

@onready var barras: Container = %Barras


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	size = TAM
	if datos == null:
		datos = load(DATOS)
	for barra in lista_barras():
		barra.escuchar(estadisticas_cambiadas)
		if not barra.con_barra:
			barra.frase = datos.frase_velocidad
	visibility_changed.connect(_al_mostrarse)
	_al_cambiar_peso(kilos)


## Escucha los kilos de este Felipe.
func conectar(de: Felipe) -> void:
	if felipe and felipe.peso_cambiado.is_connected(_al_cambiar_peso):
		felipe.peso_cambiado.disconnect(_al_cambiar_peso)
	felipe = de
	if felipe:
		felipe.peso_cambiado.connect(_al_cambiar_peso)
		_al_cambiar_peso(felipe.peso)


func lista_barras() -> Array[BarraEstadistica]:
	var lista: Array[BarraEstadistica] = []
	for hijo in barras.get_children():
		if hijo is BarraEstadistica:
			lista.append(hijo)
	return lista


func _al_cambiar_peso(kg: float) -> void:
	kilos = kg
	ultimas = datos.estadisticas(kg)
	estadisticas_cambiadas.emit(ultimas)
	queue_redraw()


## Al abrir la pausa, las barras se vuelven a llenar desde cero (un detalle de Balatro: los números se ganan).
func _al_mostrarse() -> void:
	if is_visible_in_tree():
		for barra in lista_barras():
			if barra.con_barra:
				barra.rellenar()


## Un destello corto del borde (al elegir «Ficha» en la pausa).
func resaltar() -> void:
	resalto = 1.0
	create_tween().tween_property(self, "resalto", 0.0, 0.5)


func _draw() -> void:
	KitUI.pieza(self, "ficha-panel", Rect2(Vector2.ZERO, TAM), Color.WHITE.lerp(Estilo.color(&"personaje_felipe"), resalto * 0.5))
	KitUI.icono(self, "ficha-retrato-fondo", Vector2(8, 8))
	KitUI.fragmentos(self, &"ficha", Vector2(12, 10))
	var cara := KitUI.textura("cara-ficha-felipe")
	if cara:
		draw_texture(cara, Vector2(12, 60 - cara.get_height()))
	var titulo := "%s · %s" % [tr("FICHA_SU_MAJESTAD").to_upper(), DatosFicha.texto_kilos(kilos)]
	KitUI.escribir(self, X_TEXTO, 10, titulo, &"ficha_nombre", Estilo.color(&"personaje_felipe"))
	var x_humor := X_TEXTO + Estilo.ancho(titulo, &"ficha_nombre") + 8.0
	KitUI.escribir(self, x_humor, 10, Estilo.recortar(tr(datos.humor(kilos)), &"ficha_frase", TAM.x - x_humor - 12.0), &"ficha_frase", Estilo.color(&"ui_apagado"))
