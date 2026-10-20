extends SceneTree
## Prueba de las piezas (componentes) por separado, en un mundo mínimo (un piso y Felipe), sin el nivel: Vida,
## RecibeGolpes, HaceDano, MovimientoPatrulla, Tirable, OyeMaullido, Asustable, SombraContacto, el ayudante
## Componentes.de, la máquina de estados de Felipe (patrón Estado), las conductas de un jefe (patrón Estrategia) y un
## enemigo nuevo armado SOLO con un recurso de datos (demostración de «armar piezas y llenar
## datos, no programar»). Sin ventana:
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_componentes.gd
## Termina con código 0 si todo pasa y 1 si algo falla.

const PISO := 448.0

var _fallos: Array[String] = []
var mundo: Node2D
var felipe: Felipe


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	mundo = Node2D.new()
	mundo.name = "Mundo de prueba"
	root.add_child(mundo)
	var piso := StaticBody2D.new()
	var forma := CollisionShape2D.new()
	var caja := RectangleShape2D.new()
	caja.size = Vector2(4000, 40)
	forma.shape = caja
	forma.position = Vector2(1000, PISO + 20.0)
	piso.add_child(forma)
	mundo.add_child(piso)
	felipe = load("res://escenas/entidades/felipe.tscn").instantiate()
	felipe.position = Vector2(1400, PISO)
	mundo.add_child(felipe)
	await _esperar(10)

	_probar_vida()
	_probar_recibe_golpes()
	await _probar_hace_dano()
	await _probar_tirable()
	await _probar_oye_maullido()
	await _probar_asustable()
	await _probar_enemigo_solo_con_datos()
	await _probar_datos_del_juego()
	await _probar_escenas()
	await _probar_estados_felipe()
	_probar_conductas_jefe()

	for fallo in _fallos:
		print("FALLA: ", fallo)
	print("Resultado: %d fallos" % _fallos.size())
	quit(1 if _fallos.size() > 0 else 0)


func _probar_vida() -> void:
	var vida := Vida.new(3, 0.5)
	mundo.add_child(vida)
	var murio := [0]
	var cambios: Array[int] = []
	vida.murio.connect(func() -> void: murio[0] += 1)
	vida.cambio.connect(func(actual: int, _maximo: int) -> void: cambios.append(actual))
	_comprobar(vida.actual == 3 and not vida.muerto, "Vida empieza llena (3 de 3)")
	_comprobar(vida.danar(1) and vida.actual == 2 and cambios == [2], "Vida: un golpe quita 1 y avisa con «cambio»")
	_comprobar(not vida.danar(1) and vida.actual == 2, "Vida: justo después de un golpe es invulnerable (tiempo_invulnerable)")
	vida.avanzar(0.6)
	vida.invulnerable = true
	_comprobar(not vida.danar(1) and vida.actual == 2, "Vida: con escudo (invulnerable) no le duele")
	vida.invulnerable = false
	vida.curar(5)
	_comprobar(vida.actual == 3, "Vida: curar no pasa del máximo")
	vida.danar(1)
	vida.avanzar(0.6)
	vida.danar(1)
	vida.avanzar(0.6)
	vida.danar(1)
	_comprobar(vida.muerto and vida.actual == 0 and murio[0] == 1, "Vida emite «murio» una vez al llegar a cero")
	_comprobar(not vida.danar(1) and murio[0] == 1, "Vida: muerta ya no recibe golpes ni vuelve a morir")
	vida.llenar()
	_comprobar(not vida.muerto and vida.actual == 3, "Vida: llenar() la deja entera otra vez")
	vida.queue_free()


func _probar_recibe_golpes() -> void:
	var cosa := Node2D.new()
	var vida := Vida.new(2)
	var golpes := RecibeGolpes.new()
	cosa.add_child(vida)
	cosa.add_child(golpes)
	mundo.add_child(cosa)
	_comprobar(Componentes.de(cosa, RecibeGolpes) == golpes and Componentes.de(cosa, Vida) == vida, "Componentes.de encuentra las piezas de una entidad")
	_comprobar(Componentes.de(cosa, Tirable) == null, "Componentes.de devuelve null si no lleva la pieza")
	var golpeado := [0]
	var rebotes := [0]
	golpes.golpeado.connect(func(_f: Felipe) -> void: golpeado[0] += 1)
	golpes.rebotado.connect(func(_f: Felipe) -> void: rebotes[0] += 1)
	golpes.recibir_zarpazo(felipe)
	_comprobar(vida.actual == 1 and golpeado[0] == 1, "RecibeGolpes pasa el zarpazo a la Vida")
	golpes.solo_aturdido = true
	golpes.recibir_zarpazo(felipe)
	_comprobar(vida.actual == 1 and rebotes[0] == 1, "RecibeGolpes: si hace falta aturdirla, el zarpazo rebota")
	golpes.aturdir(3.0)
	_comprobar(golpes.esta_aturdido(), "RecibeGolpes queda aturdida al caerle algo encima")
	golpes.recibir_zarpazo(felipe)
	_comprobar(vida.muerto, "Aturdida, el zarpazo sí le duele")
	cosa.queue_free()


func _probar_hace_dano() -> void:
	felipe.vida.llenar()
	felipe.vida.restante_invulnerable = 0.0
	var cosa := Node2D.new()
	var dano := HaceDano.new()
	dano.activo = false
	cosa.add_child(dano)
	cosa.position = felipe.global_position + Vector2(20, 0)
	mundo.add_child(cosa)
	await _esperar(3)
	_comprobar(felipe.corazones == Felipe.CORAZONES_MAX, "HaceDano inactivo no lastima")
	dano.activo = true
	await _esperar(3)
	_comprobar(felipe.corazones == Felipe.CORAZONES_MAX - 1, "HaceDano quita un corazón al tocar a Felipe")
	felipe.vida.restante_invulnerable = 0.0
	dano.pausar(1.0)
	await _esperar(3)
	_comprobar(felipe.corazones == Felipe.CORAZONES_MAX - 1, "HaceDano en pausa (aturdido) no lastima")
	cosa.queue_free()
	await _esperar(2)
	felipe.vida.llenar()
	felipe.vida.restante_invulnerable = 0.0
	felipe.global_position = Vector2(1400, PISO)
	felipe.velocity = Vector2.ZERO
	await _esperar(40)


func _probar_tirable() -> void:
	var vaso := Objeto.crear(load("res://datos/objetos/taza.tres"), PISO, 0.0)
	vaso.position = Vector2(300, PISO - 90.0)
	mundo.add_child(vaso)
	var raton := Enemigo.crear(load("res://datos/enemigos/raton.tres"), 200.0, 400.0)
	# Donde cae la taza: sale hacia donde mira Felipe y avanza unos 40 px.
	raton.position = Vector2(335, PISO)
	raton.patrulla.quieta = true
	mundo.add_child(raton)
	var aturdido := [0.0]
	raton.recibe_golpes.aturdido.connect(func(s: float) -> void: aturdido[0] = s)
	var cayo := [false]
	vaso.tirable.caido.connect(func(_p: Vector2) -> void: cayo[0] = true)
	_comprobar(vaso.tirable.is_in_group(Componentes.INTERACTUABLES) and vaso.tirable.verbo(felipe) == "Liberar", "Tirable se ofrece al botón de acción («Liberar»)")
	felipe.mirando = 1.0
	vaso.tirable.empujar(felipe)
	_comprobar(vaso.tirable.cayendo and not vaso.tirable.is_in_group(Componentes.INTERACTUABLES), "Tirable: empujado empieza a caer y deja de ofrecerse")
	await _esperar(60)
	_comprobar(cayo[0] and vaso.tirable.roto and is_equal_approx(vaso.position.y, PISO), "Tirable cae hasta el piso y se rompe")
	_comprobar(aturdido[0] == Tirable.ATURDIR and raton.recibe_golpes.esta_aturdido(), "Tirable aturde a lo que tenga debajo (RecibeGolpes)")
	vaso.tirable.reponer()
	_comprobar(not vaso.tirable.roto and vaso.position == Vector2(300, PISO - 90.0), "Tirable: reponer() lo deja entero en su lugar")
	vaso.queue_free()
	raton.queue_free()
	await _esperar(2)


func _probar_oye_maullido() -> void:
	felipe.global_position = Vector2(1400, PISO)
	var cerca := OyeMaullido.new()
	var lejos := OyeMaullido.new()
	var angosto := OyeMaullido.new()
	angosto.alcance_x = 50.0
	var oidos := {}
	for oido: OyeMaullido in [cerca, lejos, angosto]:
		oidos[oido] = 0
		oido.oyo.connect(func(_f: Felipe) -> void: oidos[oido] += 1)
		mundo.add_child(oido)
	cerca.global_position = felipe.global_position + Vector2(150, 0)
	lejos.global_position = felipe.global_position + Vector2(Felipe.RADIO_MAULLIDO + 60.0, 0)
	angosto.global_position = felipe.global_position + Vector2(150, 0)
	await _esperar(5)
	Input.action_press("maullar")
	await _esperar(2)
	Input.action_release("maullar")
	for i in 90:
		await physics_frame
		if felipe.estado != Felipe.Estado.MAULLANDO:
			break
	_comprobar(oidos[cerca] == 1 and oidos[lejos] == 0, "OyeMaullido oye dentro del radio del maullido, no fuera")
	_comprobar(oidos[angosto] == 0, "OyeMaullido con alcance_x no oye a Felipe más lejos que eso")
	for oido: OyeMaullido in [cerca, lejos, angosto]:
		oido.queue_free()
	await _esperar(2)


func _probar_asustable() -> void:
	var raton := Enemigo.crear(load("res://datos/enemigos/raton.tres"), 0.0, 2000.0)
	raton.position = Vector2(700, PISO)
	mundo.add_child(raton)
	await _esperar(5)
	_comprobar(Componentes.de(raton, Asustable) != null and raton.is_in_group(Componentes.ENEMIGOS), "El ratón lleva la pieza Asustable (lista para «Intimidar»)")
	var quien := Node2D.new()
	mundo.add_child(quien)
	quien.global_position = raton.global_position + Vector2(-40, 0)
	raton.asustable.asustar(quien)
	var x0 := raton.global_position.x
	await _esperar(30)
	_comprobar(raton.global_position.x > x0 + 10.0, "Asustable: el ratón huye lejos de quien lo asusta")
	raton.queue_free()
	quien.queue_free()
	await _esperar(2)


## Un enemigo nuevo sin una línea de código: solo un recurso de datos. Patrulla, lastima al tocar, aguanta 2 zarpazos,
## tiene sombra y se dibuja (sin imagen: un bloque de su tamaño).
func _probar_enemigo_solo_con_datos() -> void:
	var datos := DatosEnemigo.new()
	datos.nombre = "Pelusa malvada"
	datos.ancho = 40.0
	datos.alto = 24.0
	datos.golpes = 2
	datos.velocidad_patrulla = 60.0
	datos.vision = 0.0
	datos.dano = 1
	var pelusa := Enemigo.crear(datos, 500.0, 700.0)
	pelusa.position = Vector2(600, PISO)
	var vencido := [false]
	pelusa.vencido.connect(func(_e: Enemigo) -> void: vencido[0] = true)
	mundo.add_child(pelusa)
	_comprobar(pelusa.name == "Pelusa malvada" and pelusa.vida.maximo == 2 and pelusa.dano.dano == 1 and pelusa.sombra != null and pelusa.apariencia is Apariencia, "Enemigo nuevo: con solo datos lleva Vida, HaceDano, sombra y apariencia")
	var minimo := INF
	var maximo := -INF
	for i in 240:
		await physics_frame
		minimo = minf(minimo, pelusa.global_position.x)
		maximo = maxf(maximo, pelusa.global_position.x)
	_comprobar(maximo - minimo > 60.0 and minimo > 480.0 and maximo < 720.0, "Enemigo nuevo: patrulla entre sus límites (%.0f a %.0f)" % [minimo, maximo])
	felipe.vida.llenar()
	felipe.vida.restante_invulnerable = 0.0
	pelusa.patrulla.quieta = true
	felipe.global_position = pelusa.global_position + Vector2(10, 0)
	felipe.velocity = Vector2.ZERO
	await _esperar(3)
	_comprobar(felipe.corazones < Felipe.CORAZONES_MAX, "Enemigo nuevo: lastima a Felipe al tocarlo")
	felipe.global_position = Vector2(1400, PISO)
	pelusa.recibe_golpes.recibir_zarpazo(felipe)
	_comprobar(not vencido[0] and pelusa.vida.actual == 1, "Enemigo nuevo: el primer zarpazo le quita uno de 2")
	pelusa.recibe_golpes.recibir_zarpazo(felipe)
	await _esperar(30)
	_comprobar(vencido[0] and pelusa.vida.muerto and absf(pelusa.velocity.x) < 1.0, "Enemigo nuevo: al segundo zarpazo queda vencido y se detiene")
	pelusa.queue_free()
	felipe.vida.llenar()
	await _esperar(2)


## Los dos enemigos del juego son el mismo Enemigo con otros datos (sin herencia).
func _probar_datos_del_juego() -> void:
	var raton := Enemigo.crear(load("res://datos/enemigos/raton.tres"))
	var aspi := Enemigo.crear(load("res://datos/enemigos/aspi.tres"))
	_comprobar(raton.get_script() == aspi.get_script(), "El ratón y A.S.P.I. usan el mismo script (Enemigo); solo cambian sus datos")
	_comprobar(raton.vida.maximo == 1 and aspi.vida.maximo == 3 and raton.patrulla.vision == 0.0 and aspi.patrulla.vision > 0.0, "Ratón: 1 zarpazo y no persigue; A.S.P.I.: 3 apagados y persigue")
	_comprobar(aspi.oido != null and raton.oido == null and aspi.apariencia is AparienciaAspi and raton.apariencia is Apariencia, "A.S.P.I. oye maullidos y tiene su propia apariencia; el ratón, la de siempre")
	raton.free()
	aspi.free()


## Las escenas de las entidades (escenas/entidades/) se arman solas con sus datos.
func _probar_escenas() -> void:
	var raton := Enemigo.desde_escena("res://escenas/entidades/raton.tscn", 10.0, 90.0)
	var aspi := Enemigo.desde_escena("res://escenas/entidades/aspi.tscn")
	_comprobar(raton.name == "Raton" and raton.patrulla.limite_derecho == 90.0 and raton.dano != null, "raton.tscn: el ratón sale de su escena con sus piezas y sus límites")
	_comprobar(aspi.name == "ASPI" and aspi.apariencia is AparienciaAspi and aspi.oido != null, "aspi.tscn: A.S.P.I. sale de su escena con su apariencia y su oído")
	raton.free()
	aspi.free()
	var caja := CajaCarton.crear()
	caja.position = Vector2(900, PISO)
	mundo.add_child(caja)
	_comprobar(caja.vida != null and Componentes.de(caja, RecibeGolpes) != null and Componentes.de(caja, SueltaRecompensa) != null, "caja_carton.tscn: la caja trae Vida, RecibeGolpes y SueltaRecompensa")
	(Componentes.de(caja, RecibeGolpes) as RecibeGolpes).recibir_zarpazo(felipe)
	_comprobar(caja.roto, "La caja se rompe de un zarpazo")
	caja.queue_free()
	var pollo := Comida.crear(load("res://datos/objetos/pollo.tres"))
	_comprobar(pollo.tipo == "pollo" and pollo.verbo(felipe) == "Degustar" and Componentes.de(pollo, SombraContacto) != null, "comida.tscn: la comida toma sus datos y trae su sombra")
	pollo.free()
	var llaves := Objeto.crear(load("res://datos/objetos/llaves.tres"), PISO)
	var vaso := Objeto.crear(load("res://datos/objetos/vaso.tres"), PISO)
	_comprobar(llaves.name == "Llaves" and llaves.tirable.sonido == "caja" and not llaves.datos.se_rompe, "Las llaves suenan a metal y no se rompen (sus datos)")
	_comprobar(vaso.name == "Vaso" and not vaso.tirable.aturde and vaso.tirable.logro == "La Gravedad Funciona", "El vaso no aturde y da su logro (sus datos)")
	llaves.free()
	vaso.free()
	await _esperar(2)


## Felipe: cada Estado tiene su objeto (EstadoFelipe) y cambiar de estado llama salir() del viejo y entrar() del nuevo.
func _probar_estados_felipe() -> void:
	felipe.position = Vector2(1400, PISO)
	felipe.velocity = Vector2.ZERO
	await _esperar(5)
	var todos := true
	for valor: int in Felipe.Estado.values():
		todos = todos and felipe._estados.has(valor) and (felipe._estados[valor] as EstadoFelipe).id == valor
	_comprobar(todos, "Estado: cada estado de Felipe tiene su objeto con su id")
	_comprobar(felipe.estado == Felipe.Estado.SUELO and felipe._estado is EstadoLibre, "Estado: quieto en el piso está en SUELO (EstadoLibre)")
	felipe.estado = Felipe.Estado.ZARPAZO
	_comprobar(felipe._estado is EstadoAccion and felipe.sprite.animation == (felipe._estado as EstadoAccion).animacion, "Estado: asignar ZARPAZO entra a EstadoAccion y pone su animación")
	felipe._estado.animacion_terminada()
	_comprobar(felipe.estado == Felipe.Estado.SUELO, "Estado: al terminar la animación del zarpazo vuelve a SUELO")
	await _esperar(5)


## Jefe: las conductas se prueban en orden de prioridad, desde su fase, y el ataque en curso se queda con los cuadros
## hasta que termina (sin nivel ni jefe: solo la pelea y sus datos).
func _probar_conductas_jefe() -> void:
	var datos := DatosJefe.new()
	var primera := ConductaPrueba.new()
	primera.clave = "primera"
	primera.desde_fase = 1
	var segunda := ConductaPrueba.new()
	segunda.clave = "segunda"
	datos.conductas = [primera, segunda]
	var pelea := PeleaJefe.new(datos, null, null, null, Rect2())
	var copia_primera := pelea.conducta("primera") as ConductaPrueba
	var copia_segunda := pelea.conducta("segunda") as ConductaPrueba
	_comprobar(copia_primera != primera and copia_primera.pelea == pelea, "Jefe: cada pelea usa copias de sus conductas (los datos no cambian)")
	pelea.correr_conductas(0.1)
	_comprobar(copia_primera.intentos == 0 and copia_segunda.intentos == 1 and pelea.activa == copia_segunda, "Jefe: en la fase 0 la conducta «desde la fase 1» no se usa y ataca la siguiente")
	pelea.correr_conductas(0.1)
	pelea.correr_conductas(0.1)
	_comprobar(copia_segunda.intentos == 1 and copia_segunda.cuadros == 2 and pelea.activa == null, "Jefe: el ataque en curso se queda con los cuadros hasta terminar")
	pelea.vencidas = 1
	pelea.correr_conductas(0.1)
	_comprobar(copia_primera.intentos == 1 and pelea.activa == copia_primera, "Jefe: desde su fase, la primera en la lista tiene prioridad")
	_comprobar(DatosJefe.por_fase([1, 2, 3], 1) == 2 and DatosJefe.por_fase([1, 2, 3], 7) == 3, "Jefe: los números por fase usan el último si faltan fases")
	pelea.free()


## Conducta de prueba: ataca siempre que se la deja y dura dos cuadros.
class ConductaPrueba extends ConductaJefe:
	@export var clave := ""
	var intentos := 0
	var cuadros := 0

	func nombre() -> String:
		return clave

	func intentar(_delta: float) -> bool:
		intentos += 1
		pelea.empezar_ataque(self)
		return true

	func actualizar(_delta: float) -> bool:
		cuadros += 1
		return cuadros < 2


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("OK    " if condicion else "FALLA ") + descripcion)
	if not condicion:
		_fallos.append(descripcion)
