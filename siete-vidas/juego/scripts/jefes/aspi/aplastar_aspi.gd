class_name AplastarAspi
extends Node2D
## «Aplastar» (v5, pedido del creador): con A.S.P.I. vulnerable (llena o en corto) y al alcance, el botón de acción
## hace un **salto dirigido** que siempre cae sobre ella. Nació porque, con tantos muebles cerca, a veces Felipe caía
## en la silla en vez de sobre ella. Caerle encima con un salto normal sigue valiendo igual.
## - **Alcance:** en el piso, a `alcance_piso` px o menos; subido a un mueble (silla, escritorio, repisa, caja o
##   librero), a `alcance_mueble` px o menos de lado (debajo o al costado del mueble).
## - **Prioridad:** le gana a cualquier otra acción cercana (tirar, despegar, esparcir): ManasFelipe.objeto_cercano
##   pregunta primero `prioritario(felipe)`. El Indicador marca el contorno de A.S.P.I.; el botón lo dice su aviso
##   amarillo, «[E] ¡APLASTA!» (sin burbuja repetida sobre Felipe: un aviso a la vez).
## - **El salto:** el de siempre (`Felipe.saltar`, sin animación nueva), pero su recorrido es un arco corto que lleva
##   los pies a la tapa de A.S.P.I. aunque ella se corra, y atraviesa lo que haya en medio (como el soplido o bajar
##   agachado). Al llegar, el golpe de siempre (RemateAspi.apagar: silencio, pausa, estrellas, temblor y «¡CLIC!»).
## Pieza de BatallaAspi; los números, en `datos/jefes/aspi_jugo.tres` (grupo «Aplastar»).

var b: BatallaAspi
var datos: DatosJugoJefe
## En pleno salto dirigido (RemateAspi no busca el golpe por su cuenta mientras tanto).
var saltando := false
## Para las pruebas: cuántos aplastes llegaron y dónde quedó Felipe respecto de ella al llegar.
var aplastes := 0
var ultima_llegada := Vector2.INF
var _t := 0.0
var _duracion := 0.0
var _desde := Vector2.ZERO
var _mascara := 0
var _atravesando := -1.0


func _init(de: BatallaAspi) -> void:
	name = "Aplastar"
	b = de
	datos = de.datos.jugo if de.datos.jugo else DatosJugoJefe.new()
	# Después de que Felipe se movió en el cuadro: el arco manda.
	process_physics_priority = 100


func _ready() -> void:
	add_to_group(Componentes.INTERACTUABLES)


## Para el Indicador y el botón: solo con A.S.P.I. vulnerable y al alcance.
func disponible(felipe: Felipe) -> bool:
	return prioritario(felipe)


func prioritario(felipe: Felipe) -> bool:
	if saltando or not b.llena or b.fase != PeleaJefe.Fase.PELEA or b.ausente or not felipe.is_on_floor():
		return false
	return al_alcance(felipe.global_position)


## ¿Desde `pies` se la alcanza? En el piso, cerca; subido a un mueble, debajo o al costado.
func al_alcance(pies: Vector2) -> bool:
	var aspi := b.jefe.global_position
	var dx := absf(aspi.x - pies.x)
	var subido := b.nivel.datos.suelo - pies.y > 10.0
	if subido:
		return dx <= datos.alcance_mueble and b.nivel.datos.suelo - pies.y <= datos.altura_mueble
	return dx <= datos.alcance_piso


func punto_para(_desde: Vector2) -> Vector2:
	return b.felipe.global_position


## El aviso amarillo sobre ella ya dice «[E] ¡APLASTA!»: el Indicador no repite su burbuja (un aviso a la vez).
func burbuja_propia() -> bool:
	return true


func verbo(_felipe: Felipe) -> String:
	return "VERBO_APLASTAR"


## Lo que ocupa (R8: lado menor ≥ 24 px): el dibujo de A.S.P.I.
func rect_indicador() -> Rect2:
	return b.apariencia.rect_dibujado()


## Su silueta para el contorno del Indicador (la imagen del cuerpo que se ve ahora, en su lugar).
func arte_indicador() -> Dictionary:
	var apariencia := b.apariencia
	var t := ArteNivel.textura(apariencia.cuerpo_actual())
	if t == null:
		return {}
	var pie := (b.jefe.global_position + Vector2(0, -apariencia.alto_rueda + apariencia.profundidad_actual())).round()
	return {"textura": t, "rect": Rect2(pie + Vector2(-roundf(t.get_width() / 2.0), -t.get_height()), t.get_size()), "espejo": apariencia.en_espejo(), "z": Capas.JUEGO_CERCA}


func interactuar(felipe: Felipe) -> void:
	if not prioritario(felipe):
		return
	saltando = true
	_t = 0.0
	_desde = felipe.global_position
	var distancia := _destino().distance_to(_desde)
	_duracion = clampf(datos.aplastar_base + distancia / datos.aplastar_px_por_s, datos.aplastar_base, datos.aplastar_maximo)
	felipe.mirando = signf(_destino().x - _desde.x) if absf(_destino().x - _desde.x) > 1.0 else felipe.mirando
	# El salto de siempre (sonido, estado y animación); el recorrido lo lleva el arco.
	felipe.saltar(-300.0)
	_mascara = felipe.collision_mask
	felipe.collision_mask = 0


## Donde caen los pies: la tapa de A.S.P.I. (el dibujo va `profundidad` px más abajo que sus pies).
func _destino() -> Vector2:
	return b.jefe.global_position + Vector2(0, b.jefe.datos.profundidad - BatallaAspi.ALTO_ARRIBA)


## Punto del arco en `k` (0 a 1): curva de Bézier con la cima `altura_arco` px sobre el más alto de los dos extremos.
func _arco(k: float) -> Vector2:
	var hasta := _destino()
	var cima := Vector2((_desde.x + hasta.x) / 2.0, minf(_desde.y, hasta.y) - datos.altura_arco)
	return _desde.lerp(cima, k).lerp(cima.lerp(hasta, k), k)


func _physics_process(delta: float) -> void:
	var felipe := b.felipe
	if _atravesando >= 0.0:
		_atravesando += delta
		if (_atravesando > 0.15 and felipe.is_on_floor()) or _atravesando > 2.0:
			felipe.set_collision_mask_value(Felipe.CAPA_ATRAVESABLE, true)
			_atravesando = -1.0
	if not saltando:
		return
	_t += delta
	var k := minf(_t / _duracion, 1.0)
	var antes := felipe.global_position
	felipe.global_position = _arco(k)
	felipe.velocity = (felipe.global_position - antes) / maxf(delta, 0.001)
	if k >= 0.6:
		b.remate.silenciar()
	if k < 1.0:
		return
	_llegar()


## Llegó a la tapa: el golpe de siempre (si todavía está vulnerable) y rebota como al apagarla con un salto normal.
func _llegar() -> void:
	var felipe := b.felipe
	saltando = false
	aplastes += 1
	ultima_llegada = felipe.global_position - b.jefe.global_position
	# Vuelve a chocar con el piso y los muebles sólidos; los atravesables, recién al tocar el piso.
	felipe.collision_mask = _mascara
	felipe.set_collision_mask_value(Felipe.CAPA_ATRAVESABLE, false)
	_atravesando = 0.0
	felipe.velocity = Vector2(0.0, RemateAspi.REBOTE)
	if b.llena:
		b.remate.apagar()
	else:
		felipe.velocity.y = datos.rebote_mareada
