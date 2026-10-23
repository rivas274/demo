class_name PanelBolsillo
extends Control
## Pieza de interfaz: «el bolsillo» de la pausa (interfaz v2 «A + C»). Como el HUD solo deja la salud, lo que se lleva
## se mira aquí, en filas del kit (ícono, nombre y valor a la derecha): la salud («6 y media de 9»), los snacks
## («3 de 5»), los calcetines del nido y las fotos. Con el Collar de la Vergüenza, lo dice en rojo junto al título.
## Solo escucha: Felipe.collar_cambiado y snacks_cambiados, su Vida y Recompensas.cambio.

const ANCHO := 394.0
## La franja del título arriba y una fila cada PASO px desde Y_FILAS.
const Y_FILAS := 28.0
const PASO := 26.0
const ALTO_FILA := 22.0
## [clave, ícono del kit, nombre (clave de traducción)].
const FILAS := [["salud", "huella-llena", "BOLSILLO_SALUD"], ["snack", "icono-snack", "BOLSILLO_SNACKS"],
	["calcetin", "icono-calcetin", "BOLSILLO_CALCETINES"], ["foto", "icono-foto", "BOLSILLO_FOTOS"]]

var felipe: Felipe
var recompensas: Recompensas
## Lo que dice cada fila ahora: {clave: texto} (para las pruebas).
var valores := {}
## 0 a 1: el destello al elegir «Bolsillo» en la pausa.
var resalto := 0.0:
	set(valor):
		resalto = valor
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(ANCHO, Y_FILAS + PASO * FILAS.size())
	actualizar()


## Escucha a este Felipe y estas recompensas.
func conectar(de: Felipe, con: Recompensas) -> void:
	felipe = de
	recompensas = con
	if felipe:
		for senal: Signal in [felipe.collar_cambiado, felipe.snacks_cambiados, felipe.vida.cambio]:
			if not senal.is_connected(_al_cambiar):
				senal.connect(_al_cambiar)
	if recompensas and not recompensas.cambio.is_connected(_al_cambiar):
		recompensas.cambio.connect(_al_cambiar)
	actualizar()


func _al_cambiar(_a: Variant = null, _b: Variant = null) -> void:
	actualizar()


## Las huellas como se leen: «9», «6 y media».
static func texto_huellas(medias: int) -> String:
	var enteras := medias / SaludFelipe.MEDIAS_POR_HUELLA
	if medias % SaludFelipe.MEDIAS_POR_HUELLA == 0:
		return str(enteras)
	return TranslationServer.translate("BOLSILLO_Y_MEDIA") % enteras


func actualizar() -> void:
	var de := TranslationServer.translate("BOLSILLO_DE")
	var medias := felipe.medias if felipe else SaludFelipe.MEDIAS_MAX
	valores["salud"] = de % [texto_huellas(medias), str(SaludFelipe.HUELLAS)]
	var snacks := recompensas.snacks() if recompensas else (felipe.snacks if felipe else 0)
	valores["snack"] = de % [str(snacks), str(Felipe.SNACKS_MAX)]
	valores["calcetin"] = str(recompensas.calcetines if recompensas else 0)
	valores["foto"] = str(recompensas.fotos if recompensas else 0)
	queue_redraw()


## Un destello corto del borde (al elegir «Bolsillo» en la pausa).
func resaltar() -> void:
	resalto = 1.0
	create_tween().tween_property(self, "resalto", 0.0, 0.5)


func _con_collar() -> bool:
	return felipe != null and felipe.tiene_collar


func _draw() -> void:
	var ancho := KitUI.franja_texto(self, "titulo-franja", Vector2.ZERO, 18.0, tr("BOLSILLO_TITULO"), &"cartel_kit", Estilo.color(&"ui_contorno"))
	if _con_collar():
		KitUI.escribir(self, ancho + 10.0, 4.0, tr("UI_COLLAR"), &"texto", Estilo.color(&"personaje_aspi"))
	for i in FILAS.size():
		var fila: Array = FILAS[i]
		var y := Y_FILAS + i * PASO
		var tinte := Color.WHITE.lerp(Estilo.color(&"personaje_felipe"), resalto * 0.5)
		KitUI.pieza(self, "bolsillo-fila", Rect2(0, y, ANCHO, ALTO_FILA), tinte)
		var icono := KitUI.textura(String(fila[1]))
		if icono:
			draw_texture(icono, Vector2(12, y + floorf((ALTO_FILA - icono.get_height()) / 2.0)))
		KitUI.escribir(self, 34, y + 7, tr(String(fila[2])), &"texto", Estilo.color(&"ui_texto"))
		var valor := String(valores.get(fila[0], ""))
		if valor != "":
			KitUI.escribir(self, ANCHO - 16.0 - Estilo.ancho(valor, &"bolsillo_valor"), y + 7, valor, &"bolsillo_valor", Estilo.color(&"ui_texto"))
