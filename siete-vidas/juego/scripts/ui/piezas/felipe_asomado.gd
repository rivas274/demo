class_name FelipeAsomado
extends Node2D
## Pieza de interfaz: Felipe que asoma por un costado de un menú y le da un manotazo al letrero elegido (menú de
## estambre, decisión del creador 2026-10-20). Usa su animación `zarpazo` de siempre (AnimacionesFelipe, a su escala
## del juego) y golpea en su cuadro de impacto (Felipe.CUADRO_IMPACTO_ZARPAZO), como en el juego. No decide nada:
## la pantalla espera `manotazo()` y después hace lo que se eligió.

## La pata llegó al letrero.
signal golpeo(boton: Button)

## Segundos que tarda en asomar y en esconderse, y cuánto se desliza al asomar.
const ASOMAR := 0.1
const DESLIZ := 18.0

var sprite: AnimatedSprite2D
var ocupado := false


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = AnimacionesFelipe.crear()
	sprite.scale = Vector2.ONE * Felipe.ESCALA_SPRITE
	# Los pies en el origen, como en felipe.tscn.
	sprite.position = Vector2(0, -36)
	add_child(sprite)


## Asoma en el hueco (al costado del botón), da el manotazo, golpea el letrero en el cuadro de impacto y se esconde.
## `lado`: -1 si asoma por la izquierda (mira a la derecha), 1 por la derecha.
func manotazo(boton: Button, hueco: Control, lado := -1, fuerza := 1.0) -> void:
	if ocupado:
		return
	ocupado = true
	var r := hueco.get_global_rect()
	var destino := Vector2(r.get_center().x, r.end.y).round()
	sprite.flip_h = lado > 0
	global_position = destino + Vector2(lado * DESLIZ, 0)
	modulate.a = 0.0
	visible = true
	var entrar := create_tween().set_parallel()
	entrar.tween_property(self, "global_position", destino, ASOMAR)
	entrar.tween_property(self, "modulate:a", 1.0, ASOMAR)
	await entrar.finished
	sprite.play(&"zarpazo")
	sprite.frame = 0
	while sprite.is_playing() and sprite.frame < Felipe.CUADRO_IMPACTO_ZARPAZO:
		await sprite.frame_changed
	if boton is BotonMenu:
		(boton as BotonMenu).golpear(fuerza)
	golpeo.emit(boton)
	if sprite.is_playing():
		await sprite.animation_finished
	var salir := create_tween().set_parallel()
	salir.tween_property(self, "global_position", destino + Vector2(lado * DESLIZ, 0), ASOMAR)
	salir.tween_property(self, "modulate:a", 0.0, ASOMAR)
	await salir.finished
	visible = false
	ocupado = false
