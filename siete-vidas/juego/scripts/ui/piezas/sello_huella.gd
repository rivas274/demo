class_name SelloHuella
extends Node2D
## Pieza de interfaz: el sello de lacre con la huella de Su Majestad (menú «Decreto real»). estampar() lo deja caer
## en pasos enteros (3×, 2×, 1×: nítido en pixel art), lo cambia por el lacre aplastado y suelta destellos dorados;
## quien lo llama espera a que termine. Con `estampado_de_entrada`, aparece ya estampado y quieto (decoración del
## pergamino). Con Opciones.reducir_movimiento no cae ni salen volando los destellos (aparecen y se apagan en su sitio).
## Escena: escenas/ui/sello_huella.tscn (texturas y tiempos en el inspector).

## Terminó de estamparse (después del golpe y la espera).
signal estampado

@export var sello: Texture2D
@export var lacre: Texture2D
@export var destellos: Array[Texture2D] = []
## Pasos de la caída: escalas enteras de mayor a menor (el último es 1) y cuánto dura cada una.
@export var pasos_caida: Array[int] = [3, 2]
@export var tiempo_paso := 0.05
## Lo que espera después del golpe antes de avisar `estampado` (para que se lea).
@export var espera := 0.32
## Destellos: cuántos, a qué distancia salen, cuánto se alejan y cuánto duran.
@export var cantidad_destellos := 3
@export var radio_destellos := 22.0
@export var vuelo_destellos := 8.0
@export var tiempo_destellos := 0.42
## Aparece ya estampado (sin animación).
@export var estampado_de_entrada := false

var sprite: Sprite2D
## Destellos vivos (para las pruebas).
var vivos: Array[Sprite2D] = []
var _listo := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	sprite = Sprite2D.new()
	sprite.name = "Sello"
	add_child(sprite)
	if estampado_de_entrada:
		sprite.texture = lacre
		_listo = true
	else:
		visible = false


## ¿Ya está el lacre aplastado?
func listo() -> bool:
	return _listo


## Cae, se aplasta en lacre, suelta los destellos y espera; termina con `estampado`.
func estampar() -> void:
	visible = true
	_listo = false
	if not Opciones.reducir_movimiento:
		sprite.texture = sello
		for paso in pasos_caida:
			sprite.scale = Vector2.ONE * paso
			modulate.a = 0.5 if paso == pasos_caida[0] else 1.0
			await get_tree().create_timer(tiempo_paso, true).timeout
	sprite.scale = Vector2.ONE
	modulate.a = 1.0
	sprite.texture = lacre
	_listo = true
	_soltar_destellos()
	await get_tree().create_timer(espera, true).timeout
	estampado.emit()


func _soltar_destellos() -> void:
	if destellos.is_empty():
		return
	for i in cantidad_destellos:
		var d := Sprite2D.new()
		d.texture = destellos[i % destellos.size()]
		# Repartidos alrededor del sello, hacia arriba (como chispas que saltan del golpe).
		var angulo := -PI / 2.0 + (float(i) - (cantidad_destellos - 1) / 2.0) * 1.1
		var direccion := Vector2.from_angle(angulo)
		d.position = (direccion * radio_destellos).round()
		add_child(d)
		vivos.append(d)
		var t := d.create_tween().set_parallel()
		if not Opciones.reducir_movimiento:
			t.tween_property(d, "position", (direccion * (radio_destellos + vuelo_destellos)).round(), tiempo_destellos)
		# Se apagan a saltos (pixel art: sin desvanecido suave).
		t.tween_property(d, "modulate:a", 0.0, tiempo_destellos).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		t.chain().tween_callback(func() -> void:
			vivos.erase(d)
			d.queue_free())
