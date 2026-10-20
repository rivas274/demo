class_name FelipeEnCojin
extends Node2D
## Pieza de interfaz: Su Majestad en su cojín de terciopelo (menú «Decreto real»). Felipe A con sus animaciones de
## siempre (AnimacionesFelipe) a su única escala (Felipe.ESCALA_SPRITE), sobre el cojín, con la corona encima como un
## objeto aparte (no está en Felipe A: se dibuja aparte y se mueve por código). La corona sigue la cabeza cuadro a
## cuadro: se mide el tope del cráneo en cada cuadro de la hoja y la corona se apoya ahí, entre las orejas.
## El origen es el centro de abajo del cojín. Escena: escenas/ui/felipe_en_cojin.tscn.

@export var cojin: Texture2D
@export var corona: Texture2D
## Animación de Felipe sobre el cojín (en bucle).
@export var animacion := &"sentado"
## Dónde apoya las patas, desde el centro de abajo del cojín (la parte de arriba del cojín se hunde un poco).
@export var apoyo := Vector2(0, -34)
## Corona: cuánto baja su borde de abajo desde el tope del cráneo y cuánto se corre desde el centro de la cabeza
## (px del juego).
@export var corona_bajo_orejas := 4.0
@export var corona_corrida := 3.0
## Felipe mira hacia la derecha (como Felipe A); con `mirar_izquierda` se da vuelta.
@export var mirar_izquierda := false

var sprite_cojin: Sprite2D
var felipe: AnimatedSprite2D
var sprite_corona: Sprite2D
## Por cuadro de la animación: [x del centro de la cabeza, y del tope del cráneo] en px de la hoja.
var _cabezas := {}

## Ancho mínimo (px de la hoja) de un tramo para ser la frente: la cabeza de Felipe A mide unos 45 px de ancho.
const ANCHO_FRENTE := 34


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	sprite_cojin = Sprite2D.new()
	sprite_cojin.name = "Cojin"
	sprite_cojin.texture = cojin
	sprite_cojin.centered = false
	if cojin:
		sprite_cojin.position = Vector2(-roundf(cojin.get_width() / 2.0), -cojin.get_height())
	add_child(sprite_cojin)
	felipe = AnimatedSprite2D.new()
	felipe.name = "Felipe"
	felipe.sprite_frames = AnimacionesFelipe.crear()
	felipe.scale = Vector2.ONE * Felipe.ESCALA_SPRITE
	felipe.flip_h = mirar_izquierda
	felipe.centered = false
	add_child(felipe)
	sprite_corona = Sprite2D.new()
	sprite_corona.name = "Corona"
	sprite_corona.texture = corona
	add_child(sprite_corona)
	felipe.frame_changed.connect(_poner_corona)
	felipe.play(animacion)
	_poner_corona()


func _cuadro_actual() -> Texture2D:
	return felipe.sprite_frames.get_frame_texture(felipe.animation, felipe.frame)


## Felipe con las patas en el apoyo (el borde de abajo de la hoja = las patas, como en felipe.tscn) y la corona entre
## las orejas del cuadro que se ve.
func _poner_corona() -> void:
	var cuadro := _cuadro_actual()
	if cuadro == null:
		return
	var lado := cuadro.get_size()
	var escala := Felipe.ESCALA_SPRITE
	var origen := (apoyo - Vector2(lado.x * escala / 2.0, lado.y * escala)).round()
	felipe.position = origen
	var cabeza := _cabeza(cuadro)
	var x := cabeza.x if not mirar_izquierda else lado.x - cabeza.x
	var en_juego := origen + Vector2(x, cabeza.y) * escala
	var alto_corona := corona.get_height() if corona else 0
	sprite_corona.position = (en_juego + Vector2(corona_corrida * (-1.0 if mirar_izquierda else 1.0), corona_bajo_orejas - alto_corona / 2.0)).round()


## Centro de la cabeza y tope del cráneo entre las orejas (en px de la hoja), medidos una vez por cuadro: de arriba
## hacia abajo, la primera fila donde lo opaco corre seguido por lo ancho de una cabeza (las orejas son dos tramos
## cortos y la cola, uno angosto; la frente ya es un tramo ancho).
func _cabeza(cuadro: Texture2D) -> Vector2:
	var clave := "%s:%d" % [felipe.animation, felipe.frame]
	if _cabezas.has(clave):
		return _cabezas[clave]
	var resultado := Vector2(cuadro.get_width() / 2.0, cuadro.get_height() * 0.3)
	var imagen := cuadro.get_image()
	if imagen:
		for y in imagen.get_height():
			var tramo := _tramo_mas_ancho(imagen, y)
			if tramo.y - tramo.x >= ANCHO_FRENTE:
				resultado = Vector2((tramo.x + tramo.y) / 2.0, y)
				break
	_cabezas[clave] = resultado
	return resultado


## [desde, hasta) del tramo opaco más ancho de la fila.
func _tramo_mas_ancho(imagen: Image, y: int) -> Vector2:
	var mejor := Vector2.ZERO
	var desde := -1
	for x in imagen.get_width() + 1:
		var opaco := x < imagen.get_width() and imagen.get_pixel(x, y).a > 0.5
		if opaco and desde < 0:
			desde = x
		elif not opaco and desde >= 0:
			if x - desde > mejor.y - mejor.x:
				mejor = Vector2(desde, x)
			desde = -1
	return mejor
