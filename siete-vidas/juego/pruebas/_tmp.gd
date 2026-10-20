extends SceneTree
func _initialize():
	var s: GDScript = load("res://scripts/jefes/pelea_jefe.gd")
	print("ok ", s.can_instantiate())
	quit()
