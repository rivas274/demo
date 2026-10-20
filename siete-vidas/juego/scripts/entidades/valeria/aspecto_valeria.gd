class_name AspectoValeria
extends RefCounted
## Cómo se ve Valeria: sus poses (texturas), el fundido cruzado entre poses (G1), el giro, el vano oscuro de las
## puertas, la mascarilla (G6), los audífonos, el corazón roto y el "REC" del celular. Solo dibuja lo que Valeria ya
## decidió (actividad, mirando, giro, vano): no cambia nada de su comportamiento.

## Fila del arte "serie" que queda sobre el asiento. Crítica de Gemini (2026-10-19): con 148 se veía flotando sobre
## el cojín (los muslos 18 px sobre el asiento y los pies 10 px sobre el piso). Con 139 los pies tocan el piso (la
## última fila del arte cae en SUELO) y el muslo queda sobre el cojín, que se hunde (sombra en _cojin_hundido).
const FILA_CADERA := 139
## Mascarilla (G6): rectángulo de nariz y boca en la imagen de cada pose mirando a la derecha y la oreja donde se
## engancha el elástico. El caminar sube y baja la cabeza: CABEZA_CAMINAR da el desfase de cada cuadro.
const MASCARILLA := {
	"neutra": [Rect2(27, 47, 26, 10), Vector2(19, 45)],
	"caminar": [Rect2(54, 50, 26, 10), Vector2(46, 47)],
}
const CABEZA_CAMINAR := [0, -4, -2, 0, -1, -3, -1, -1]
const POSES := ["neutra", "enojada", "perdonando", "grabando", "serie", "caminar"]
const COLOR_AUDIFONOS := Color(0.15, 0.15, 0.18)
const ROJO := Color("e0483b")
const ROJO_OSCURO := Color("6e1a22")

## Pose y lugar con que se dibujó por última vez (las pruebas comparan con el estado: nada se dibuja viejo).
var pose_dibujada := ""
var pos_dibujada := Vector2.ZERO
## Cuánto va del fundido cruzado (0 a 1).
var mezcla := 1.0

var _v: Valeria
var _texturas := {}
## Pose dibujada antes del último cambio: {"pose", "pos", "mirando", "cuadro"}.
var _previa := {}
var _pose_actual := ""
var _cuadro_actual := 0
var _ultima_pos := Vector2.ZERO
var _ultimo_mirando := 1.0


func _init(de: Valeria) -> void:
	_v = de


func cargar() -> void:
	for nombre in POSES:
		var ruta: String = Valeria.RUTA % nombre
		_texturas[nombre] = load(ruta) if ResourceLoader.exists(ruta) else null


func avanzar(delta: float) -> void:
	mezcla = minf(1.0, mezcla + delta / Valeria.TRANSICION)


## Sin fundido desde la pose anterior (se puso en otro lugar o entró por una puerta).
func reiniciar() -> void:
	_previa = {}
	mezcla = 1.0
	_pose_actual = _v.pose()


## Si cambió la pose desde el último dibujo, empieza el fundido cruzado desde la anterior, en el lugar donde SE DIBUJÓ
## (no donde está ahora: así la pose sentada nunca se dibuja bajada al piso, G1). Se decide al dibujar, porque el
## cambio puede llegar por una señal en cualquier momento del cuadro.
func _seguir_pose(nueva: String) -> void:
	if nueva == _pose_actual:
		return
	# Entre estar de pie y caminar no hay fundido: es la misma figura, el ciclo empieza en el cuadro de contacto.
	var de_pie := ["neutra", "caminar"]
	if _pose_actual != "" and _v.visible and not (_pose_actual in de_pie and nueva in de_pie):
		_previa = {"pose": _pose_actual, "pos": _ultima_pos, "mirando": _ultimo_mirando, "cuadro": _cuadro_actual}
		mezcla = 0.0
	_pose_actual = nueva


func datos_pose(nombre: String, cuadro := -1) -> Dictionary:
	var textura: Texture2D = _texturas.get(nombre)
	if textura == null:
		return {}
	var region := Rect2(Vector2.ZERO, textura.get_size())
	if nombre == "caminar":
		var ancho := textura.get_width() / float(Valeria.CUADROS_CAMINAR)
		var i := cuadro if cuadro >= 0 else _v.cuadro_caminar()
		region = Rect2(i * ancho, 0, ancho, textura.get_height())
	var base := 0.0 if nombre != "serie" else -region.size.y + FILA_CADERA
	return {"textura": textura, "region": region, "base": base}


## Contorno del Indicador con la silueta de la pose que se ve (el cuadro de la hoja, volteado si mira a la izquierda).
func arte_indicador() -> Dictionary:
	if pose_dibujada == "":
		return {}
	var datos := datos_pose(pose_dibujada, _cuadro_actual)
	if datos.is_empty():
		return {}
	var region: Rect2 = datos["region"]
	var pos := pos_dibujada + Vector2(-region.size.x / 2.0, -region.size.y - float(datos["base"]))
	return {"textura": datos["textura"], "rect": Rect2(pos, region.size), "region": region, "espejo": _v.mirando < 0.0}


## Rectángulo (en el mundo) que ocupa la pose actual: sus pies nunca quedan bajo el piso (G1).
func rect_dibujado() -> Rect2:
	var datos := datos_pose(_v.pose())
	if datos.is_empty():
		return Rect2(_v.global_position + Vector2(-14, -Valeria.ALTO), Vector2(28, Valeria.ALTO))
	var tam: Vector2 = (datos["region"] as Rect2).size
	return Rect2(_v.global_position + Vector2(-tam.x / 2.0, -tam.y - float(datos["base"])), tam)


func dibujar() -> void:
	pose_dibujada = ""
	pos_dibujada = _v.global_position
	if _v.actividad == Valeria.Actividad.FUERA:
		_pose_actual = ""
		return
	var nombre := _v.pose()
	_seguir_pose(nombre)
	_ultima_pos = _v.global_position
	_ultimo_mirando = _v.mirando
	pose_dibujada = nombre
	_cuadro_actual = _v.cuadro_caminar()
	var alfa := _v.vano
	if nombre == "serie" and mezcla >= 1.0:
		_cojin_hundido(alfa)
	var hay_previa := mezcla < 1.0 and not _previa.is_empty()
	if hay_previa:
		var desplazado: Vector2 = _previa["pos"] - _v.global_position
		_dibujar_pose(_previa["pose"], desplazado, _previa["mirando"], 1.0, alfa * (1.0 - mezcla), _previa["cuadro"])
	# Al girar, la figura se angosta hasta casi una línea y se abre del otro lado.
	var ancho := absf(cos(_v.giro * PI)) if _v.giro < 1.0 else 1.0
	var lado := _v.mirando if _v.giro >= 0.5 else _v.mirando_antes
	# Respira: 1 px de alto (bien dentro de ±8 %) cuando está quieta.
	var respira := 1.0
	if _v.actividad in [Valeria.Actividad.DE_PIE, Valeria.Actividad.SENTADA]:
		respira = 1.0 + 0.005 * sin(_v.tiempo * 2.4)
	_dibujar_pose(nombre, Vector2.ZERO, lado, maxf(ancho, 0.12), alfa * (mezcla if hay_previa else 1.0), _cuadro_actual, respira)
	var datos := datos_pose(nombre)
	var arriba := -Valeria.ALTO
	if not datos.is_empty():
		arriba = -(datos["region"] as Rect2).size.y - float(datos["base"])
	if _v.audifonos:
		_audifonos(arriba)
	if _v.actividad == Valeria.Actividad.REGANANDO and _v.motivo_regano != "":
		_corazon_roto(Vector2(0, arriba - 14.0 + roundf(sin(_v.tiempo * 6.0) * 2.0)))
	if _v.actividad == Valeria.Actividad.GRABANDO and int(_v.tiempo * 3.0) % 2 == 0:
		var rec := Vector2(_v.mirando * 26.0, arriba + 6.0)
		_v.draw_circle(rec, 3.0, ROJO)
		_v.draw_string(ThemeDB.fallback_font, rec + Vector2(5, 4), "REC", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, ROJO)


func _audifonos(arriba: float) -> void:
	var m := _v.mirando
	_v.draw_arc(Vector2(m * 2.0, arriba + 26.0), 15.0, PI, TAU, 10, COLOR_AUDIFONOS, 3.0)
	_v.draw_rect(Rect2(Vector2(m * 2.0 - 18.0, arriba + 22.0), Vector2(6, 10)), COLOR_AUDIFONOS)
	# El de adelante, afuera: corrido sobre la sien mientras escucha (sacar_audifono).
	var afuera := Vector2(4.0, -10.0) if _v.audifono_afuera > 0.0 else Vector2.ZERO
	_v.draw_rect(Rect2(Vector2(m * 2.0 + 12.0, arriba + 22.0) + afuera, Vector2(6, 10)), COLOR_AUDIFONOS)


func _dibujar_pose(nombre: String, desplazado: Vector2, lado: float, ancho: float, alfa: float, cuadro: int, alto := 1.0) -> void:
	if alfa <= 0.0:
		return
	var datos := datos_pose(nombre, cuadro)
	if datos.is_empty():
		_dibujar_provisional()
		return
	var region: Rect2 = datos["region"]
	var tam := region.size
	var base: float = datos["base"]
	# Los pies quedan en el origen: estirar o girar no los mueve.
	_v.draw_set_transform(desplazado + Vector2(0, -base), 0.0, Vector2((-1.0 if lado < 0.0 else 1.0) * ancho, alto))
	# Al aparecer o desaparecer en un vano se ve desde la oscuridad (más oscura cuanto más adentro).
	var tinte := Color(1, 1, 1, alfa).lerp(Color(0.15, 0.1, 0.1, alfa), (1.0 - _v.vano) * 0.7)
	_v.draw_texture_rect_region(datos["textura"], Rect2(Vector2(-tam.x / 2.0, -tam.y), tam), region, tinte)
	if _v.mascarilla and MASCARILLA.has(nombre):
		_dibujar_mascarilla(nombre, tam, cuadro, alfa)
	_v.draw_set_transform(Vector2.ZERO)


## Mascarilla quirúrgica sobre nariz y boca, con pliegues y el elástico a la oreja (G6). Va dentro de la transformación
## de la pose: sigue la cara, el espejo y el giro.
func _dibujar_mascarilla(nombre: String, tam: Vector2, cuadro: int, alfa: float) -> void:
	var datos: Array = MASCARILLA[nombre]
	var cara: Rect2 = datos[0]
	var oreja: Vector2 = datos[1]
	var dy := float(CABEZA_CAMINAR[cuadro % CABEZA_CAMINAR.size()]) if nombre == "caminar" else 0.0
	var origen := Vector2(-tam.x / 2.0, -tam.y + dy)
	var r := Rect2(origen + cara.position, cara.size)
	var tela := Color(0.80, 0.91, 0.96, alfa)
	var borde := Color(0.30, 0.42, 0.52, alfa)
	var forma := PackedVector2Array([
		r.position + Vector2(0, 2), r.position + Vector2(r.size.x * 0.5, 0), r.position + Vector2(r.size.x, 1),
		r.end + Vector2(-1, -3), r.position + Vector2(r.size.x * 0.62, r.size.y + 1), r.position + Vector2(3, r.size.y - 2),
	])
	_v.draw_line(origen + oreja, r.position + Vector2(1, 3), borde, 1.0)
	_v.draw_line(origen + oreja + Vector2(0, 3), r.position + Vector2(2, r.size.y - 3), borde, 1.0)
	_v.draw_colored_polygon(forma, tela)
	_v.draw_polyline(forma + PackedVector2Array([forma[0]]), borde, 1.0)
	for pliegue in 2:
		var y := r.position.y + 4.0 + pliegue * 3.0
		_v.draw_line(Vector2(r.position.x + 3, y), Vector2(r.end.x - 3, y), Color(0.55, 0.68, 0.76, alfa), 1.0)


## Sombra del cojín hundido bajo Valeria sentada (crítica de Gemini: que no flote sobre el sofá). En pixeles: dos
## franjas, la de abajo más oscura, sin degradado suave.
func _cojin_hundido(alfa: float) -> void:
	var lado := _v.mirando
	_v.draw_rect(Rect2(-24.0 + lado * 4.0, -9.0, 50.0, 4.0), Color(0.25, 0.08, 0.06, 0.18 * alfa))
	_v.draw_rect(Rect2(-20.0 + lado * 4.0, -5.0, 42.0, 5.0), Color(0.25, 0.08, 0.06, 0.30 * alfa))


## Corazón roto sobre la cabeza: lo que se arregla frotándose (propuesta v4, sección 5).
func _corazon_roto(centro: Vector2) -> void:
	for lado in [-1.0, 1.0]:
		var desplazado := centro + Vector2(lado * 2.0, 0)
		_v.draw_circle(desplazado + Vector2(lado * 4.0, -3), 5.0, ROJO_OSCURO)
		_v.draw_colored_polygon(PackedVector2Array([desplazado + Vector2(0, -6), desplazado + Vector2(lado * 9.5, -3), desplazado + Vector2(0, 9)]), ROJO_OSCURO)
		_v.draw_circle(desplazado + Vector2(lado * 4.0, -3), 4.0, ROJO)
		_v.draw_colored_polygon(PackedVector2Array([desplazado + Vector2(0, -5), desplazado + Vector2(lado * 8.0, -3), desplazado + Vector2(0, 7)]), ROJO)


func _dibujar_provisional() -> void:
	_v.draw_rect(Rect2(-14, -Valeria.ALTO, 28, Valeria.ALTO), Color("3e7c7a"))
	_v.draw_circle(Vector2(0, -Valeria.ALTO + 14), 13.0, Color("d9a27c"))
