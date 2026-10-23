extends SceneTree
## Ruido visual de la pelea con A.S.P.I. (v5, «un solo foco a la vez»): los mismos 4 momentos para comparar versiones
## y variantes a ×1, con dos medidas objetivas por momento:
## - **animados:** cuántos elementos animados hay a la vez en pantalla (sistemas de partículas activos, piezas en el
##   aire, palabra, globito, cartel, aviso, barra de reinicio, bolas, motas del rayo, LED que parpadea, Indicador);
## - **movimiento:** 20 cuadros seguidos (`<momento>-mov-NN.png`) para medir qué parte de la pantalla cambia.
## Momentos: 1 fase 1 limpiando el desorden, 2 justo después del primer «¡CLIC!», 3 fase 2 llena con desorden,
## 4 fase 3 (apagón) con una bola de pelo en camino. Funciona también con la v4 (lo nuevo se lee con `get`).
## Necesita pantalla:
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/capturas_ruido.gd -- <carpeta> [variante]
## Variantes (DatosJugoJefe, grupo «Ruido»): A (solo quitar), B (velo 0,15 sobre la pared), C (velo 0,25 sobre la
## pared), D (velo 0,2 sobre pared y muebles), E (velo 0,2 sobre la pared, sin destello y restos más oscuros).

const VARIANTES := {
	"A": {"velo": 0.0},
	"B": {"velo": 0.15, "velo_capa": -2},
	"C": {"velo": 0.25, "velo_capa": -2},
	"D": {"velo": 0.2, "velo_capa": -1},
	"v5": {},
	"E": {"velo": 0.2, "velo_capa": -2, "brillo_tirables": 0, "tinte_resto": Color(0.5, 0.46, 0.46)},
}

var _carpeta := "user://ruido"
var sala: Nivel
var felipe: Felipe
var batalla: BatallaAspi
var aspi: Enemigo
var _medidas: Array[String] = []


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_carpeta = args[0]
	DirAccess.make_dir_recursive_absolute(_carpeta)
	_correr.call_deferred(args[1] if args.size() > 1 else "")


func _correr(variante: String) -> void:
	sala = load("res://escenas/nivel_1.tscn").instantiate()
	sala.mostrar_titulo = false
	root.add_child(sala)
	felipe = sala.get_node("Felipe")
	batalla = sala.guion.batalla
	aspi = sala.guion.aspi
	var datos: Resource = batalla.datos.jugo
	for clave: String in VARIANTES.get(variante, {}):
		datos.set(clave, VARIANTES[variante][clave])
	felipe.vida.restante_invulnerable = 99999.0
	await _esperar(30)
	await _parar(Vector2(6990, Nivel1.SUELO), 10)
	await _esperar_que(func() -> bool: return batalla.fase != PeleaJefe.Fase.ESPERANDO, 60)
	batalla.saltar_entrada()
	await _esperar_que(func() -> bool: return batalla.fase == PeleaJefe.Fase.PELEA, 300)
	for nombre: String in ["embestida", "bola"]:
		batalla.conducta(nombre).set("reloj_espera", 9999.0)
	(batalla.conducta("embestida") as AtaqueEmbestida).espera = PackedFloat32Array([9999.0])
	(batalla.conducta("bola") as AtaqueBolaPelo).espera = 9999.0
	# Sin ataques no hay daño: sin invulnerabilidad, Felipe no parpadea en las capturas.
	felipe.vida.restante_invulnerable = 0.0
	# 1. Fase 1: tira la taza y los libros de la caja; ella limpia.
	felipe.mirando = 1.0
	for objeto in batalla.municion:
		if objeto.tipo in ["taza", "libros_pila_b", "vaso"]:
			objeto.tirable.empujar(felipe)
	await _parar(Vector2(7180, Nivel1.SUELO), 60)
	await _esperar_que(func() -> bool: return batalla.limpiando, 600)
	await _parar(Vector2(7150, Nivel1.SUELO - 98), 30)
	await _momento("1-fase1")
	# 2. Justo después del primer «¡CLIC!».
	await _esperar_que(func() -> bool: return batalla.llena, 900)
	await _caerle_encima()
	await _esperar(20)
	await _momento("2-golpe")
	# 3. Fase 2 con desorden, llena.
	await _esperar_que(func() -> bool: return not batalla.montanas.is_empty() and batalla.montanas[-1].en_piso, 400)
	for fuente in batalla.fuentes:
		if fuente.datos.arte in ["pizarra", "librero_bajo"]:
			fuente.soltar(-1.0)
	for objeto in batalla.municion:
		if objeto.tipo in ["maceta", "planta"]:
			objeto.tirable.empujar(felipe)
	await _parar(Vector2(7300, Nivel1.SUELO), 60)
	await _esperar_que(func() -> bool: return batalla.llena, 60 * 30)
	await _parar(Vector2(aspi.global_position.x - 110.0, Nivel1.SUELO), 30)
	await _momento("3-fase2-llena")
	for intento in 4:
		if batalla.apagados >= 2:
			break
		await _esperar_que(func() -> bool: return batalla.llena, 60 * 20)
		await _caerle_encima()
	# 4. Fase 3 (apagón) con una bola de pelo en camino.
	var corto := batalla.conducta("cortocircuito") as ConductaCortocircuito
	await _esperar_que(func() -> bool: return corto.hecho, 900)
	await _esperar(90)
	await _esperar_que(func() -> bool: return not batalla.llena and batalla.reinicio <= 0.0 and batalla.reacciones.despertando <= 0.0, 600)
	batalla.manchas.clear()
	batalla.tipos_mancha.clear()
	batalla.nodos_mancha.clear()
	await _parar(Vector2(aspi.global_position.x + 160.0, Nivel1.SUELO), 2)
	var bola := batalla.conducta("bola") as AtaqueBolaPelo
	bola.reloj_espera = 0.0
	await _esperar_que(func() -> bool: return not batalla.bolas.is_empty(), 300)
	await _esperar(6)
	await _momento("4-fase3-bola")
	var archivo := FileAccess.open("%s/medidas.txt" % _carpeta, FileAccess.WRITE)
	archivo.store_string("\n".join(_medidas) + "\n")
	archivo.close()
	quit()


## Captura el momento a ×1, cuenta lo animado y guarda 20 cuadros seguidos para medir el movimiento.
func _momento(nombre: String) -> void:
	_capturar(nombre)
	var cuenta := 0
	for i in 20:
		await process_frame
		cuenta = maxi(cuenta, _animados())
		_capturar("%s-mov-%02d" % [nombre, i])
	_medidas.append("%s animados %d" % [nombre, cuenta])


func _animados() -> int:
	var n := 0
	for nodo in sala.find_children("*", "CPUParticles2D", true, false):
		var p := nodo as CPUParticles2D
		if p.emitting and p.is_visible_in_tree():
			n += 1
	for nodo in sala.find_children("*", "PiezaSuelta", true, false):
		var pieza := nodo as PiezaSuelta
		if not pieza.en_piso or pieza.girando:
			n += 1
	var jugo: Jugo = sala.travesuras.jugo
	if is_instance_valid(jugo.get("_palabra_actual")):
		n += 1
	if batalla.globo and batalla.globo.visible_ahora():
		n += 1
	if float(batalla.presentacion.get("_cartel")) > 0.0:
		n += 1
	if batalla.llena:
		n += 1
	if batalla.reinicio > 0.0:
		n += 2 if batalla.get("calma") == null else 1
	n += batalla.bolas.size()
	for fondo in sala.find_children("*", "FondoApartamento", true, false):
		if fondo.get("sin_motas") != "estudio":
			n += 5
	if batalla.apariencia.get("led_parpadea") != false:
		n += 1
	if sala.travesuras.indicador.verbo != "":
		n += 1
	return n


func _caerle_encima() -> void:
	await _esperar(20)
	var antes := batalla.apagados
	felipe.global_position = aspi.global_position + Vector2(0, -62)
	felipe.velocity = Vector2.ZERO
	for i in 60:
		await physics_frame
		if batalla.apagados > antes:
			break


func _parar(donde: Vector2, cuadros: int) -> void:
	felipe.global_position = donde
	felipe.velocity = Vector2.ZERO
	await _esperar(cuadros)


func _esperar_que(condicion: Callable, maximo: int) -> void:
	for i in maximo:
		if condicion.call():
			return
		await physics_frame


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame
	await process_frame


func _capturar(nombre: String) -> void:
	root.get_texture().get_image().save_png("%s/%s.png" % [_carpeta, nombre])
