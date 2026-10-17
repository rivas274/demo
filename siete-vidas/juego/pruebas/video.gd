extends SceneTree
## Graba una partida automática cuadro por cuadro (a 30 fps) para ver el prototipo en movimiento:
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/video.gd -- <carpeta>
## Después: ffmpeg -framerate 30 -i <carpeta>/%04d.png felipe.mp4

## [acciones presionadas, cuadros de física (60 por segundo)]
const GUION := [
	[[], 40],
	[["mover_derecha"], 30],
	[["mover_derecha", "saltar"], 22],
	[["mover_derecha"], 30],
	[["mover_derecha", "saltar"], 20],
	[["mover_derecha"], 8],
	[["mover_derecha", "saltar"], 18],
	[["mover_derecha"], 20],
	[[], 40],
	[["zarpazo"], 4],
	[[], 40],
	[["mover_izquierda"], 20],
	[["mover_izquierda", "zoomies"], 30],
	[[], 50],
	[["comer_snack"], 4],
	[[], 70],
]

var _carpeta := "user://video"
var _cuadro := 0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_carpeta = args[0]
	DirAccess.make_dir_recursive_absolute(_carpeta)
	_correr.call_deferred()


func _correr() -> void:
	root.add_child(load("res://escenas/apartamento.tscn").instantiate())
	var presionadas: Array = []
	for paso: Array in GUION:
		for accion: String in presionadas:
			if not accion in paso[0]:
				Input.action_release(accion)
		for accion: String in paso[0]:
			if not accion in presionadas:
				Input.action_press(accion)
		presionadas = paso[0]
		for i in paso[1]:
			await physics_frame
			if i % 2 == 0:
				await _guardar_cuadro()
	quit()


func _guardar_cuadro() -> void:
	await process_frame
	root.get_texture().get_image().save_png("%s/%04d.png" % [_carpeta, _cuadro])
	_cuadro += 1
