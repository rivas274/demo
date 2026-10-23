extends SceneTree
## Prueba del sistema de profundidad por rol (v5, decisión del creador: «clasificar todo y definir bien las capas»).
## - Ningún script ni escena del juego fija z_index por su cuenta (solo Capas y Profundidad).
## - En el nivel armado, todo nodo del mundo con capa propia la tiene por su Profundidad (rol), y lo que se dibuja
##   colgado del nivel tiene rol.
## - Las reglas, con Felipe en el piso, en el aire y sobre cada superficie: lo apoyado sobre su mueble y detrás de
##   Felipe (delante si Felipe está en esa superficie), los enemigos del piso delante de todo mueble y detrás de Felipe
##   subido, los restos detrás de Felipe y de A.S.P.I.
## - El caso real: Felipe sobre el escritorio junto al vaso y saltando delante del escritorio (el vigía de superficie).
## Sin ventana:
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_capas.gd
## Termina con código 0 si todo pasa y 1 si algo falla.

## Archivos que SÍ pueden poner z (la tabla y la pieza).
const PERMITIDOS := ["res://scripts/sistemas/capas.gd", "res://scripts/componentes/profundidad.gd"]

var _fallos: Array[String] = []
var sala: Nivel
var felipe: Felipe


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	_sin_z_a_mano()
	sala = load("res://escenas/nivel_1.tscn").instantiate()
	sala.mostrar_titulo = false
	root.add_child(sala)
	felipe = sala.get_node("Felipe")
	await _esperar(30)
	_todo_con_rol()
	_reglas()
	await _caso_real()
	print("Resultado: %d fallos" % _fallos.size())
	for fallo in _fallos:
		print("FALLÓ: " + fallo)
	quit(1 if _fallos.size() > 0 else 0)


## Ningún .gd ni .tscn del juego (fuera de la tabla y la pieza) escribe z_index, z_as_relative ni usa otra vía.
func _sin_z_a_mano() -> void:
	var culpables: Array[String] = []
	for ruta in _archivos("res://scripts", ".gd") + _archivos("res://escenas", ".tscn"):
		if ruta in PERMITIDOS:
			continue
		var texto := FileAccess.get_file_as_string(ruta)
		for patron: String in ["z_index =", "z_index=", "z_as_relative", "Capas.usar("]:
			if patron in texto:
				culpables.append("%s (%s)" % [ruta, patron])
	_comprobar(culpables.is_empty(), "Ningún nodo del mundo fija z_index por su cuenta: todo pasa por Profundidad (%s)" % ", ".join(culpables))


func _archivos(carpeta: String, extension: String) -> Array[String]:
	var lista: Array[String] = []
	var dir := DirAccess.open(carpeta)
	if dir == null:
		return lista
	for archivo in dir.get_files():
		if archivo.ends_with(extension):
			lista.append(carpeta.path_join(archivo))
	for sub in dir.get_directories():
		lista.append_array(_archivos(carpeta.path_join(sub), extension))
	return lista


## Todo nodo del mundo con capa propia la saca de su rol; lo que se dibuja colgado del nivel tiene rol.
func _todo_con_rol() -> void:
	var sin_rol: Array[String] = []
	var mal_resuelto: Array[String] = []
	var pendientes: Array[Node] = [sala]
	while not pendientes.is_empty():
		var nodo: Node = pendientes.pop_back()
		if nodo is CanvasLayer:
			continue
		for hijo in nodo.get_children():
			pendientes.append(hijo)
		if not nodo is CanvasItem or nodo == sala:
			continue
		var item := nodo as CanvasItem
		var pieza := Profundidad.de(item)
		var capa_propia := item.z_index != 0 or not item.z_as_relative
		if capa_propia and pieza == null:
			sin_rol.append(String(item.name))
		elif pieza and item.z_index != Capas.z_para(pieza.rol, pieza.contexto()):
			mal_resuelto.append(String(item.name))
		elif item.get_parent() == sala and pieza == null and _dibuja(item):
			sin_rol.append(String(item.name))
	_comprobar(sin_rol.is_empty(), "Todo lo que se dibuja en el mundo tiene rol de profundidad (sin rol: %s)" % ", ".join(sin_rol))
	_comprobar(mal_resuelto.is_empty(), "Cada z es el que da Capas.z_para con su rol (mal: %s)" % ", ".join(mal_resuelto))


## ¿Dibuja algo por su cuenta? (no un cuerpo de colisión ni un contenedor vacío).
func _dibuja(item: CanvasItem) -> bool:
	if item is StaticBody2D and not item.has_method("_draw"):
		return false
	if item is Camera2D or item is Area2D:
		return false
	return not item.get_signal_connection_list("draw").is_empty() or item.has_method("_draw") or item is Sprite2D or item is AnimatedSprite2D or item is CPUParticles2D


func _con_rol(rol: int) -> Array[Profundidad]:
	var lista: Array[Profundidad] = []
	for nodo in root.get_tree().get_nodes_in_group(Profundidad.GRUPO):
		var pieza := nodo as Profundidad
		if pieza.rol == rol and pieza.is_inside_tree():
			lista.append(pieza)
	return lista


func _z(pieza: Profundidad) -> int:
	return (pieza.get_parent() as CanvasItem).z_index


## Las reglas en cada estado de Felipe: en el piso, en el aire y sobre cada superficie del nivel.
func _reglas() -> void:
	var saltables := _con_rol(Capas.Rol.SALTABLE)
	var apoyados := _con_rol(Capas.Rol.APOYADO)
	var enemigos := _con_rol(Capas.Rol.ENEMIGO_PISO)
	var restos := _con_rol(Capas.Rol.RESTO_PISO)
	_comprobar(saltables.size() >= 20 and apoyados.size() >= 10 and enemigos.size() >= 2, "Hay muebles (%d), objetos apoyados (%d) y enemigos del piso (%d) clasificados" % [saltables.size(), apoyados.size(), enemigos.size()])
	var superficies := PackedStringArray(["piso", "aire"])
	for pieza: Array in Nivel1.PIEZAS:
		superficies.append(pieza[2])
	var errores: Array[String] = []
	for donde in superficies:
		Profundidad.felipe_cambio(root.get_tree(), donde)
		var z_felipe := felipe.z_index
		var z_muebles := -1000
		for s in saltables:
			z_muebles = maxi(z_muebles, _z(s))
		for a in apoyados:
			var suyo := a.superficies[0] if not a.superficies.is_empty() else "piso"
			var mueble := _saltable_de(saltables, suyo)
			if mueble and _z(a) <= _z(mueble):
				errores.append("%s no queda sobre su mueble (%s)" % [a.get_parent().name, suyo])
			if suyo == donde and _z(a) <= z_felipe:
				errores.append("Felipe en %s: %s debería quedar apenas delante de él" % [donde, a.get_parent().name])
			if suyo != donde and _z(a) >= z_felipe:
				errores.append("Felipe en %s: %s debería quedar detrás de él" % [donde, a.get_parent().name])
		for e in enemigos:
			if _z(e) <= z_muebles:
				errores.append("Felipe en %s: %s detrás de un mueble" % [donde, e.get_parent().name])
			if donde != "piso" and _z(e) >= z_felipe:
				errores.append("Felipe en %s (subido o en el aire): %s debería quedar detrás de él" % [donde, e.get_parent().name])
		for r in restos:
			for e in enemigos:
				if _z(r) >= _z(e):
					errores.append("%s (resto) delante de %s" % [r.get_parent().name, e.get_parent().name])
			if _z(r) >= z_felipe:
				errores.append("%s (resto) delante de Felipe" % r.get_parent().name)
	_comprobar(errores.is_empty(), "Reglas de profundidad en %d estados de Felipe (piso, aire y cada superficie): %s" % [superficies.size(), "; ".join(errores.slice(0, 6))])
	# A.S.P.I. contra Felipe en el piso (y en su capa de siempre, no delante de los humanos): lo dicen sus datos.
	Profundidad.de(felipe).delante_de_humanos = false
	Profundidad.de(felipe).aplicar()
	Profundidad.felipe_cambio(root.get_tree(), "piso")
	var aspi: Enemigo = sala.guion.aspi
	_comprobar(aspi.z_index > felipe.z_index == aspi.datos.delante_de_felipe, "Con Felipe en el piso, A.S.P.I. va delante o detrás según sus datos (delante_de_felipe = %s)" % aspi.datos.delante_de_felipe)


func _saltable_de(saltables: Array[Profundidad], superficie: String) -> Profundidad:
	for s in saltables:
		if superficie in s.superficies:
			return s
	return null


## El caso que vio el creador: el vaso del escritorio con Felipe arriba (Felipe pasa por detrás) y saltando delante
## del escritorio (el vaso queda detrás de él). El vigía avisa en el mismo cuadro.
func _caso_real() -> void:
	var vaso: Objeto = null
	for nodo in sala.get_children():
		if nodo is Objeto and (nodo as Objeto).tipo == "vaso":
			vaso = nodo
	var escritorio := Nivel1.rect_pieza("Escritorio")
	var pieza_vaso := Profundidad.de(vaso)
	_comprobar(vaso != null and "Escritorio" in pieza_vaso.superficies, "El vaso sabe que está apoyado en el escritorio (%s)" % [pieza_vaso.superficies if pieza_vaso else "sin rol"])
	felipe.global_position = Vector2(vaso.global_position.x + 30.0, escritorio.position.y - 2.0)
	felipe.velocity = Vector2.ZERO
	await _esperar(20)
	var mueble := _saltable_de(_con_rol(Capas.Rol.SALTABLE), "Escritorio")
	print("DBG ", Profundidad.superficie_felipe, " vaso ", vaso.z_index, " felipe ", felipe.z_index, " mueble ", _z(mueble) if mueble else 999, " ", mueble.puede_subir if mueble else null, " pos ", felipe.global_position)
	_comprobar(Profundidad.superficie_felipe == "Escritorio" and vaso.z_index > felipe.z_index and mueble and _z(mueble) == Capas.SALTABLE_ACTIVO, "Felipe sobre el escritorio junto al vaso: el vaso queda apenas delante (Felipe pasa por detrás) y el escritorio sube un escalón")
	felipe.global_position = Vector2(vaso.global_position.x, escritorio.position.y + 30.0)
	felipe.velocity = Vector2(0, -200)
	await _esperar(2)
	print("DBG3 ", sala.find_children("*", "VigiaSuperficie", true, false), " ", felipe.is_on_floor(), " ", felipe.get_slide_collision_count())
	print("DBG2 ", Profundidad.superficie_felipe, " vaso ", vaso.z_index, " felipe ", felipe.z_index, " pos ", felipe.global_position)
	_comprobar(Profundidad.superficie_felipe == "aire" and vaso.z_index < felipe.z_index, "Saltando delante del escritorio, el vaso queda detrás de Felipe (el cambio es inmediato)")
	await _esperar(60)
	_comprobar(Profundidad.superficie_felipe == "piso" and vaso.z_index < felipe.z_index and _z(mueble) == Capas.MUEBLES, "En el piso, el vaso detrás de Felipe y el escritorio en su capa de siempre")


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("OK    " if condicion else "FALLA ") + descripcion)
	if not condicion:
		_fallos.append(descripcion)
