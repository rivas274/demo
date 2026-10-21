class_name PanelBolsillo
extends Control
## Pieza de interfaz: «el bolsillo» de la pausa (HUD limpio, decisión del creador 2026-10-21). Como en el juego el HUD
## solo deja los corazones, lo que se lleva se mira aquí: las vidas, los calcetines del nido, las fotos y los snacks,
## cada uno en un ContadorRecurso, en un pergamino del kit. Con el Collar de la Vergüenza, lo dice debajo.
## Solo escucha: Felipe.vidas_cambiadas y collar_cambiado, y Recompensas.cambio.

const TAM := Vector2(170, 56)
## [clave, ícono del kit (vacío: lo dibuja Recogible)], en 2 columnas.
const FILAS := [["vidas", &"hud_corazon"], ["calcetin", &"hud_calcetin"], ["foto", &"hud_foto"], ["snack", &""]]
const ANCHO_CONTADOR := 76.0
const ESCENA_CONTADOR := "res://escenas/ui/contador_recurso.tscn"

var felipe: Felipe
var recompensas: Recompensas
var contadores := {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = TAM
	for i in FILAS.size():
		var datos: Array = FILAS[i]
		var contador: ContadorRecurso = (load(ESCENA_CONTADOR) as PackedScene).instantiate()
		contador.name = "Bolsillo " + String(datos[0])
		contador.clave = datos[0]
		contador.ancho = ANCHO_CONTADOR
		contador.dibujar_icono = Recogible.dibujar_icono
		if datos[1] != &"":
			contador.icono = Estilo.icono(datos[1])
		contador.position = Vector2(6 + (i % 2) * (ANCHO_CONTADOR + 6.0), 6 + (i / 2) * 24)
		add_child(contador)
		contadores[datos[0]] = contador
	actualizar()


## Escucha a este Felipe y estas recompensas.
func conectar(de: Felipe, con: Recompensas) -> void:
	felipe = de
	recompensas = con
	if felipe:
		for senal: Signal in [felipe.vidas_cambiadas, felipe.collar_cambiado]:
			if not senal.is_connected(_al_cambiar):
				senal.connect(_al_cambiar)
	if recompensas and not recompensas.cambio.is_connected(_al_cambiar):
		recompensas.cambio.connect(_al_cambiar)
	actualizar()


func _al_cambiar(_valor: Variant = null) -> void:
	actualizar()


func actualizar() -> void:
	if contadores.is_empty():
		return
	var vidas := felipe.vidas if felipe else 0
	(contadores["vidas"] as ContadorRecurso).fijar(tr("UI_VIDAS") % vidas, vidas > 0, false)
	var calcetines := recompensas.calcetines if recompensas else 0
	var fotos := recompensas.fotos if recompensas else 0
	var snacks := recompensas.snacks() if recompensas else 0
	(contadores["calcetin"] as ContadorRecurso).fijar(str(calcetines), calcetines > 0, false)
	(contadores["foto"] as ContadorRecurso).fijar(str(fotos), fotos > 0, false)
	(contadores["snack"] as ContadorRecurso).fijar("%d/%d" % [snacks, Felipe.SNACKS_MAX], snacks > 0, false)
	queue_redraw()


func _draw() -> void:
	Estilo.panel(self, Rect2(Vector2(-4, -4), TAM + Vector2(8, 8 + (12 if _con_collar() else 0))), &"panel")
	if _con_collar():
		Estilo.escribir(self, Vector2(8, TAM.y + 4), Estilo.recortar(tr("UI_COLLAR"), &"medidor_collar", TAM.x - 12), &"medidor_collar", Estilo.color(&"rojo"))


func _con_collar() -> bool:
	return felipe != null and felipe.tiene_collar
