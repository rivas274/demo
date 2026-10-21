extends SceneTree
## Capturas del estudio v3 (2026-10-21: la segunda isla de juego a la derecha): el cuarto completo en dos vistas, Felipe
## en cada superficie nueva (caja de los libros, librero bajo, repisa del gato) y lo que queda al tirar la planta y el
## portarretratos. Cada captura guarda también, ampliado ×3, el rectángulo del mueble que muestra. Necesita pantalla:
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/capturas_estudio.gd -- <carpeta>

var _carpeta := "user://estudio"
var _sala: Nivel


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_carpeta = args[0]
	DirAccess.make_dir_recursive_absolute(_carpeta)
	_correr.call_deferred()


func _correr() -> void:
	_sala = load("res://escenas/nivel_1.tscn").instantiate()
	_sala.mostrar_titulo = false
	(_sala.guion as GuionNivel1).batalla_con_jefe = false
	root.add_child(_sala)
	var felipe: Felipe = _sala.get_node("Felipe")
	await _esperar(30)
	var aspi: Enemigo = (_sala.guion as GuionNivel1).aspi
	# A.S.P.I. quieta en su base: que no tape los muebles nuevos.
	aspi.patrulla.vision = 0.0
	aspi.patrulla.quieta = true
	aspi.global_position = Nivel1.ASPI[0]
	# El cuarto completo en dos vistas (la cámara lo recorre).
	await _parar(felipe, Vector2(6960, Nivel1.SUELO), 90)
	_capturar("1-cuarto-izquierda")
	await _parar(felipe, Vector2(7620, Nivel1.SUELO), 90)
	_capturar("2-cuarto-derecha")
	# Felipe en cada superficie nueva, con el mueble ampliado.
	var caja := Nivel1.rect_pieza("Caja de los libros")
	var librero := Nivel1.rect_pieza("Librero bajo")
	var repisa := Nivel1.rect_pieza("Repisa del gato")
	var isla := Rect2(7230, Nivel1.SUELO - 190, 345, 200)
	await _parar(felipe, Vector2(caja.get_center().x, caja.position.y), 40)
	_capturar("3-en-la-caja", isla)
	await _parar(felipe, Vector2(librero.get_center().x, librero.position.y), 40)
	_capturar("4-en-el-librero", isla)
	await _parar(felipe, Vector2(repisa.get_center().x, repisa.position.y), 40)
	_capturar("5-en-la-repisa-del-gato", isla)
	# Sin Felipe delante: los muebles solos, ampliados.
	await _parar(felipe, Vector2(7716, Nivel1.SUELO), 60)
	_capturar("6-isla-derecha", isla)
	# Tirados: la planta (se rompe: tierra, pedazos y las hojas) y el portarretratos (queda entero).
	felipe.mirando = -1.0
	for objeto: Objeto in (_sala.guion as GuionNivel1).tirables:
		if objeto.tipo in ["planta", "portarretratos"]:
			objeto.tirable.empujar(felipe)
	await _esperar(120)
	_capturar("7-tirados", isla)
	quit()


func _parar(felipe: Felipe, donde: Vector2, cuadros: int) -> void:
	felipe.global_position = donde
	felipe.velocity = Vector2.ZERO
	await _esperar(cuadros)


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame
	await process_frame


## Guarda la pantalla (640 × 360) y, si se da `zona` (en el mundo), esa parte ampliada ×3.
func _capturar(nombre: String, zona := Rect2()) -> void:
	var imagen := root.get_texture().get_image()
	imagen.save_png("%s/%s.png" % [_carpeta, nombre])
	if zona.has_area():
		var lienzo := _sala.get_viewport().get_canvas_transform()
		var escala := float(imagen.get_width()) / 640.0
		var r := Rect2(lienzo * zona.position, zona.size)
		var rect := Rect2i(Vector2i(r.position * escala), Vector2i(r.size * escala)).intersection(Rect2i(Vector2i.ZERO, imagen.get_size()))
		var parte := imagen.get_region(rect)
		parte.resize(parte.get_width() * 3, parte.get_height() * 3, Image.INTERPOLATE_NEAREST)
		parte.save_png("%s/%s-x3.png" % [_carpeta, nombre])
