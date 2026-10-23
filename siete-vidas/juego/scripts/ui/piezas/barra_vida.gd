class_name BarraVida
extends Control
## Pieza de interfaz que muestra una pieza Vida (interfaz v2 «A + C», kit assets/ui/v2/). Solo escucha: se conecta a
## la señal `Vida.cambio` y se redibuja cuando cambia (nada de preguntar en cada cuadro). No sabe de quién es la vida
## ni qué pasa al morir.
##
## - HUELLAS (la salud de Felipe: 9 huellas = 18 medias): la caja de la salud con la cara de Felipe (hace una mueca al
##   recibir un golpe) y una fila de 9 huellas en sus 5 estados: llena, media, vacía, golpe y curando. Al perder, la
##   huella destella blanca 60 ms, rebota 3 px y queda vacía (o media) a los 240 ms; al curar, se llena de abajo arriba
##   en 220 ms con un brillo. Si cambian varias, van en cascada cada 60 ms. Con 3 huellas o menos, las que quedan laten.
##   Con texto grande (`grande`), todo al doble (304×40).
## - BARRA (la de un jefe, A2 del layout: 250×40 arriba a la derecha): retrato chico sobre su fondo inclinado, nombre
##   en franja, marco con 3 segmentos (I, II y III, la fase activa en su color) y 2 capas: la vida y el «daño
##   reciente» crema, que baja 300 ms después. Al cambiar de fase, el marco tiembla una vez. Abajo, la franja del
##   escudo (A.S.P.I.: el depósito).
## Con «Reducir movimiento» no hay rebotes, latidos que se mueven ni temblores: solo el cambio de color.
## Se arma con escenas/ui/barra_vida.tscn (huellas) y barra_jefe.tscn (jefe).

## Se redibujó con un valor nuevo (para las pruebas y para quien quiera reaccionar).
signal mostrada(actual: int, maximo: int)

enum Forma { HUELLAS, BARRA }
enum Huella { LLENA, MEDIA, VACIA, GOLPE, CURANDO }

const NOMBRES_HUELLA := ["llena", "media", "vacia", "golpe", "curando"]
## Medias por huella (la Vida de Felipe cuenta medias).
const MEDIAS := 2
## Tiempos de las huellas (s): destello del golpe, rebote, llenado al curar y cascada entre huellas.
const DESTELLO := 0.06
const GOLPE_TOTAL := 0.24
const CURA := 0.22
const CASCADA := 0.06
## Latido de las huellas que quedan con pocas: cada LATIDO s, un pulso de 0,12 s.
const LATIDO := 0.8
const HUELLAS_BAJAS := 3
## Medidas del layout (normal; con texto grande, el doble).
const CAJA_SALUD := Vector2(152, 20)
const PASO_HUELLA := 14.0
## Barra del jefe: retrato, franja del nombre y la barra (220×14 lógico; el relleno de 208×6 adentro).
const ANCHO_JEFE := 250.0
const X_BARRA := 30.0
const Y_BARRA := 17.0
const ANCHO_BARRA := 220.0
const ALTO_MARCO := 14.0
const RELLENO := Vector2(5, 4)
const ANCHO_RELLENO := 208.0
const ALTO_RELLENO := 6.0
const FASES := ["I", "II", "III"]
## El daño reciente espera esto y baja en BAJADA s.
const ESPERA_RECIENTE := 0.3
const BAJADA := 0.25

@export var forma := Forma.HUELLAS:
	set(valor):
		forma = valor
		queue_redraw()
## Texto grande (200 %): la salud al doble.
@export var grande := false:
	set(valor):
		grande = valor
		queue_redraw()
## Nombre del jefe en la franja (solo forma BARRA).
@export var titulo := "":
	set(valor):
		titulo = valor
		queue_redraw()
## Si el título no cabe en la franja, se escribe este (el nombre a secas): nunca se corta con «…».
@export var titulo_corto := "":
	set(valor):
		titulo_corto = valor
		queue_redraw()
## Cara del jefe (ícono del kit) y el color de su fase activa.
@export var cara_jefe := "cara-jefe-aspi"
@export var color_jefe := &"personaje_aspi"

var actual := 0
var maximo := 0
## 0 a 1: franja del escudo bajo la barra.
var escudo := 0.0:
	set(valor):
		escudo = valor
		queue_redraw()
## Si es >= 0, muestra esta fracción en vez de la vida (la barra que se llena en la entrada de un jefe).
var forzada := -1.0:
	set(valor):
		forzada = valor
		queue_redraw()
## Lo que muestra la capa de «daño reciente» (0 a 1).
var reciente := 1.0
## Animación de cada huella: {indice: [GOLPE o CURANDO, segundos (negativo = espera su turno en la cascada), estado
## final, estado de antes]}.
var animando := {}

var _vida: Vida
var _reloj := 0.0
var _espera_reciente := 0.0
var _temblor := 0.0
var _mueca := 0.0


## Lo que se ve (0 a 1).
var fraccion: float:
	get:
		if forzada >= 0.0:
			return forzada
		return float(actual) / maximo if maximo > 0 else 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Empieza a escuchar esa Vida (deja de escuchar la anterior) y muestra lo que tiene ahora.
func conectar(vida: Vida) -> void:
	if _vida and is_instance_valid(_vida) and _vida.cambio.is_connected(_al_cambiar):
		_vida.cambio.disconnect(_al_cambiar)
	_vida = vida
	animando.clear()
	if vida == null:
		return
	vida.cambio.connect(_al_cambiar)
	actual = vida.actual if vida.actual >= 0 else vida.maximo
	maximo = vida.maximo
	reciente = fraccion
	queue_redraw()
	mostrada.emit(actual, maximo)


func _al_cambiar(nuevo: int, de: int) -> void:
	var antes := actual
	actual = nuevo
	maximo = de
	if forma == Forma.HUELLAS:
		_animar_huellas(antes, nuevo)
	elif nuevo < antes:
		_espera_reciente = ESPERA_RECIENTE
		_temblor = 0.2
	else:
		reciente = fraccion
	queue_redraw()
	mostrada.emit(actual, maximo)


## Estado que tiene la huella `i` con `medias` medias.
static func estado_de(i: int, medias: int) -> Huella:
	if medias >= (i + 1) * MEDIAS:
		return Huella.LLENA
	if medias > i * MEDIAS:
		return Huella.MEDIA
	return Huella.VACIA


## Cuántas huellas hay (9 para Felipe).
func huellas() -> int:
	return ceili(maximo / float(MEDIAS))


## Pone en cascada la animación de las huellas que cambiaron: golpe al perder, curando al ganar.
func _animar_huellas(antes: int, ahora: int) -> void:
	if antes == ahora:
		return
	var orden: Array[int] = []
	for i in huellas():
		if estado_de(i, antes) != estado_de(i, ahora):
			orden.append(i)
	if ahora < antes:
		orden.reverse()
		_mueca = 0.35
	for n in orden.size():
		var i := orden[n]
		animando[i] = [Huella.GOLPE if ahora < antes else Huella.CURANDO, -n * CASCADA, estado_de(i, ahora), estado_de(i, antes)]
	set_process(true)


func _process(delta: float) -> void:
	delta = delta / maxf(Engine.time_scale, 0.001)
	_reloj += delta
	_mueca = maxf(0.0, _mueca - delta)
	_temblor = maxf(0.0, _temblor - delta)
	for i: int in animando.keys():
		var a: Array = animando[i]
		a[1] += delta
		if a[1] >= (GOLPE_TOTAL if a[0] == Huella.GOLPE else CURA):
			animando.erase(i)
	if _espera_reciente > 0.0:
		_espera_reciente -= delta
	elif reciente > fraccion:
		reciente = maxf(fraccion, reciente - delta / BAJADA)
	elif forzada >= 0.0 or reciente < fraccion:
		reciente = fraccion
	queue_redraw()


## ¿Laten ahora las huellas que quedan? (3 o menos, y no vacías del todo).
func latiendo() -> bool:
	return forma == Forma.HUELLAS and actual > 0 and actual <= HUELLAS_BAJAS * MEDIAS


func _draw() -> void:
	if forma == Forma.HUELLAS:
		_dibujar_huellas()
	else:
		_dibujar_barra()


## Medida lógica de lo que ocupa (para las zonas del layout).
func medida() -> Vector2:
	return CAJA_SALUD * (2.0 if grande else 1.0) if forma == Forma.HUELLAS else Vector2(ANCHO_JEFE, 40.0)


func _dibujar_huellas() -> void:
	var g := 2.0 if grande else 1.0
	var sufijo := "-grande" if grande else ""
	var caja := Rect2(Vector2.ZERO, CAJA_SALUD * g)
	KitUI.pieza(self, "hud-caja" + sufijo, caja)
	# La cara de Felipe: hace una mueca (orejas planas) y tiembla 1 px al recibir un golpe.
	var cara := KitUI.textura(("cara-hud-felipe-golpe" if _mueca > 0.0 else "cara-hud-felipe") + sufijo)
	if cara:
		var tiembla := 0.0 if Opciones.reducir_movimiento or _mueca <= 0.0 else (1.0 if int(_mueca * 30.0) % 2 == 0 else -1.0)
		draw_texture(cara, Vector2(4.0 * g + tiembla, floorf((caja.size.y - cara.get_height()) / 2.0)))
	var late := latiendo() and fmod(_reloj, LATIDO) < 0.12
	for i in huellas():
		var estado := estado_de(i, actual)
		var t := textura_huella(Huella.VACIA)
		var pos := Vector2(8.0 * g + 16.0 * g + i * PASO_HUELLA * g - g, floorf((caja.size.y - t.get_height()) / 2.0))
		if animando.has(i):
			_huella_animada(i, pos, g)
			continue
		if late and estado != Huella.VACIA:
			# Latido: la huella que queda se aclara y, si se puede mover, sube 1 px.
			var arriba := Vector2(0, 0.0 if Opciones.reducir_movimiento else -g)
			draw_texture(textura_huella(Huella.CURANDO if estado == Huella.LLENA else estado), pos + arriba)
			continue
		draw_texture(textura_huella(estado), pos)


func _huella_animada(i: int, pos: Vector2, g: float) -> void:
	var a: Array = animando[i]
	var final: Huella = a[2]
	var t := float(a[1])
	if t < 0.0:
		# Todavía espera su turno en la cascada: se ve como estaba.
		draw_texture(textura_huella(a[3]), pos)
		return
	if a[0] == Huella.GOLPE:
		if t < DESTELLO:
			draw_texture(textura_huella(Huella.GOLPE), pos)
			return
		var k := (t - DESTELLO) / (GOLPE_TOTAL - DESTELLO)
		var rebote := 0.0 if Opciones.reducir_movimiento else -roundf(3.0 * g * sin(PI * k))
		draw_texture(textura_huella(final), pos + Vector2(0, rebote))
		return
	# Curando: se llena de abajo arriba, más clara, y al final queda en su estado.
	draw_texture(textura_huella(Huella.VACIA), pos)
	KitUI.icono_desde_abajo(self, "huella-curando" + ("-grande" if g > 1.0 else ""), pos, t / CURA)


func textura_huella(estado: Huella) -> Texture2D:
	return KitUI.textura("huella-" + NOMBRES_HUELLA[estado] + ("-grande" if grande else ""))


## La barra del jefe, con las medidas de la lámina (x 0 = su borde izquierdo; ancho 250).
func _dibujar_barra() -> void:
	var tiembla := Vector2(1.0 if _temblor > 0.0 and int(_temblor * 40.0) % 2 == 0 and not Opciones.reducir_movimiento else 0.0, 0)
	KitUI.icono(self, "jefe-retrato-marco", Vector2.ZERO)
	KitUI.fragmentos(self, &"jefe", Vector2(4, 2))
	var cara := KitUI.textura(cara_jefe)
	if cara:
		draw_texture(cara, Vector2(4, 25 - cara.get_height()))
	KitUI.franja_texto(self, "jefe-nombre-franja", Vector2(X_BARRA, 0), 14.0, titulo_visible(), &"jefe_barra", Estilo.color(&"ui_contorno"))
	var marco := Rect2(Vector2(X_BARRA, Y_BARRA) + tiembla, Vector2(ANCHO_BARRA, ALTO_MARCO))
	KitUI.pieza(self, "jefe-barra-marco", marco)
	var dentro := marco.position + RELLENO
	_tira("jefe-barra-dano", dentro, roundf(ANCHO_RELLENO * clampf(reciente, 0.0, 1.0)))
	_tira("jefe-barra-relleno", dentro, roundf(ANCHO_RELLENO * clampf(fraccion, 0.0, 1.0)))
	if escudo > 0.0:
		draw_rect(Rect2(dentro + Vector2(0, ALTO_RELLENO - 2.0), Vector2(roundf(ANCHO_RELLENO * escudo), 2)), Estilo.color(&"ui_maquina"))
	KitUI.icono(self, "jefe-barra-cortes", marco.position)
	# Fases I, II y III bajo su segmento; la activa, en el color del jefe (no solo el color: también el número).
	var activa := fase_activa()
	for i in FASES.size():
		var x := dentro.x + roundf(ANCHO_RELLENO * (i + 0.5) / FASES.size()) - roundf(Estilo.ancho(FASES[i], &"cartel_kit") / 2.0)
		var color := Estilo.color(color_jefe) if i == activa else Estilo.color(&"ui_texto")
		KitUI.escribir(self, x, Y_BARRA + 10.0 + 6.0, FASES[i], &"cartel_kit", color, true)


## La fase que se está peleando (0, 1 o 2): las que ya cayeron, contadas desde la izquierda.
func fase_activa() -> int:
	if maximo <= 0:
		return 0
	return clampi(maximo - actual, 0, FASES.size() - 1)


## Repite una tira del kit (relleno de la barra) a lo ancho.
func _tira(nombre: String, pos: Vector2, ancho: float) -> void:
	var t := KitUI.textura(nombre)
	if t == null or ancho < 1.0:
		return
	var x := 0.0
	while x < ancho:
		var w := minf(t.get_width(), ancho - x)
		draw_texture_rect_region(t, Rect2(pos + Vector2(x, 0), Vector2(w, t.get_height())), Rect2(0, 0, w, t.get_height()))
		x += w


## El título que se ve en la franja: entero si cabe; si no, el corto; nunca cortado con «…».
func titulo_visible() -> String:
	var cabe := ANCHO_JEFE - X_BARRA - 16.0
	if Estilo.ancho(titulo, &"jefe_barra") <= cabe or titulo_corto == "":
		return titulo if Estilo.ancho(titulo, &"jefe_barra") <= cabe else Estilo.recortar(titulo, &"jefe_barra", cabe)
	return titulo_corto
