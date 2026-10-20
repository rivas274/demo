class_name FichaSuMajestad
extends Control
## La «Ficha de Su Majestad» del menú de pausa (pilar 4): el retrato de Felipe en su marco (MarcoFicha), sus kilos y
## su humor, y una BarraEstadistica por estadística (defensa, carisma, ataque y peso) más el chiste de la velocidad.
## Es el único lugar donde se ve el peso (nunca en el HUD).
## Solo escucha: se conecta a Felipe.peso_cambiado, calcula las estadísticas con DatosFicha (datos/ui/ficha.tres) y
## avisa con `estadisticas_cambiadas`; cada barra escucha esa señal y toma lo suyo. Las estadísticas son solo de
## chiste: nada del juego las lee (decisión del creador, 2026-10-20).
## Escena: escenas/ui/ficha_su_majestad.tscn (las barras y sus íconos se arman ahí).

signal estadisticas_cambiadas(estadisticas: Dictionary)

const DATOS := "res://datos/ui/ficha.tres"
const RETRATOS := "res://assets/felipe/felipe-retratos.png"
## Cara del retrato (felipe-retratos.png, 3 × 3; 0 = de reojo) y su lado en la hoja.
const CARA := 0
const LADO_CARA := 66.0

@export var datos: DatosFicha

var felipe: Felipe
var kilos := Felipe.PESO_INICIAL
var ultimas := {}

@onready var marco: MarcoFicha = %Marco
@onready var retrato: TextureRect = %Retrato
@onready var barras: Container = %Barras
## Capa encima del marco donde se escriben los kilos y el humor.
@onready var placa: Control = %Placa


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	if datos == null:
		datos = load(DATOS)
	var cara := AtlasTexture.new()
	cara.atlas = load(RETRATOS)
	cara.region = Rect2((CARA % 3) * LADO_CARA, (CARA / 3) * LADO_CARA, LADO_CARA, LADO_CARA)
	retrato.texture = cara
	var ventana := marco.ventana()
	retrato.position = marco.position + Vector2(ventana.position.x + 4.0, ventana.position.y + roundf((ventana.size.y - LADO_CARA) / 2.0))
	retrato.size = Vector2(LADO_CARA, LADO_CARA)
	var cuerpo := marco.cuerpo()
	barras.position = marco.position + cuerpo.position + Vector2(6, 6)
	barras.size = Vector2(cuerpo.size.x - 12.0, cuerpo.size.y - 12.0)
	for barra in lista_barras():
		barra.escuchar(estadisticas_cambiadas)
		if not barra.con_barra:
			barra.frase = datos.frase_velocidad
	placa.draw.connect(_dibujar_placa)
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
	if placa:
		placa.queue_redraw()


## Al abrir la pausa, las barras se vuelven a llenar desde cero (un detalle de Balatro: los números se ganan).
func _al_mostrarse() -> void:
	if is_visible_in_tree():
		for barra in lista_barras():
			if barra.con_barra:
				barra.rellenar()


## A la derecha del retrato, dentro de la ventana: «Su Majestad», los kilos y el humor.
func _dibujar_placa() -> void:
	var ventana := marco.ventana()
	var x := marco.position.x + ventana.position.x + LADO_CARA + 10.0
	var y := marco.position.y + ventana.position.y
	Estilo.escribir(placa, Vector2(x, y + 20), tr("FICHA_SU_MAJESTAD"), &"ficha_nombre", Estilo.color(&"lacre"))
	Estilo.escribir(placa, Vector2(x, y + 40), DatosFicha.texto_kilos(kilos), &"ficha_peso", Estilo.color(&"tinta_decreto"))
	Estilo.escribir(placa, Vector2(x, y + 56), tr(datos.humor(kilos)), &"ficha_frase", Estilo.color(&"tinta_decreto_suave"))
