extends SceneTree
## Temporal: Felipe camina por la sala ~7 s (entrada fija) para el video antes/después.
const DURACION := 7.5

func _initialize() -> void:
	_correr.call_deferred()

func _correr() -> void:
	var fps := float(Engine.physics_ticks_per_second)
	var sala: Sala = load("res://escenas/apartamento.tscn").instantiate()
	sala.mostrar_titulo = false
	root.add_child(sala)
	var felipe: Felipe = sala.get_node("Felipe")
	felipe.position = Vector2(120, Sala.SUELO)
	for cuadro in int(DURACION * fps):
		var segundo := cuadro / fps
		if segundo >= 0.6 and segundo < 6.9:
			Input.action_press("mover_derecha")
		else:
			Input.action_release("mover_derecha")
		await physics_frame
	quit(0)
