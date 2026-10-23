class_name PeleaJefe
extends Node2D
## Pelea de jefe genérica: lo que toda pelea tiene igual. Espera a que Felipe entre a la arena (ya terminado el fundido
## de la puerta), lo presenta con PresentacionJefe (los 8 pasos, nombre, barra y carteles; nunca una presentación
## propia), corre sus conductas (ataques en orden de prioridad, DatosJefe.conductas), y si Felipe sale (perdió una vida)
## lo espera y al volver hace la entrada corta. Cada jefe extiende esta pelea solo con lo que lo hace único (A.S.P.I.:
## el depósito que se llena) y pone sus números en un DatosJefe. Receta: siete-vidas/memoria/07-arquitectura.md.

signal empezada
signal fase_cambiada(fase: Fase)
signal terminada

enum Fase { ESPERANDO, ENTRADA, PELEA, FIN }

var fase := Fase.ESPERANDO:
	set(valor):
		fase = valor
		# La barra del jefe se ve solo durante la pelea.
		if presentacion:
			presentacion.mostrar_barra = fase == Fase.PELEA
		_usar_globo()
var datos: DatosJefe
var jefe: Enemigo
var felipe: Felipe
var nivel: Nivel
## Donde se pelea.
var arena: Rect2
## Cuántas fases venció ya Felipe (A.S.P.I.: apagados).
## La Vida del jefe refleja las fases que le quedan: la barra (BarraVida) la escucha por su señal `cambio`.
var vencidas := 0:
	set(valor):
		vencidas = valor
		if jefe and jefe.vida:
			jefe.vida.fijar(jefe.vida.maximo - vencidas)
## Entrada de 8 pasos, carteles y barra de vida (componente reutilizable para cualquier jefe).
var presentacion: PresentacionJefe
## Felipe salió de la arena (perdió una vida): el jefe espera y al volver hay entrada corta.
var ausente := false:
	set(valor):
		ausente = valor
		_usar_globo()
## Lo que piensa Felipe en la pelea va en un globito sobre él (no en el cuadro de arriba) y la cámara mira hacia el
## jefe cuando se acerca desde lejos (crítica de Gemini, 2026-10-23).
var globo: GloboDialogo
var camara: CamaraPelea
## Copias de las conductas de los datos para esta pelea, y el ataque en curso.
var conductas: Array[ConductaJefe] = []
var activa: ConductaJefe
var _volviendo := false


func _init(datos_jefe: DatosJefe, el_jefe: Enemigo, gato: Felipe, de_nivel: Nivel, donde: Rect2) -> void:
	datos = datos_jefe
	jefe = el_jefe
	felipe = gato
	nivel = de_nivel
	arena = donde
	# La pelea en sí no dibuja nada: cada parte va en su capa de la tabla única (Capas, B1 de la revisión 3).
	Profundidad.poner(self, Capas.Rol.JUEGO)
	process_mode = Node.PROCESS_MODE_ALWAYS
	for conducta: ConductaJefe in datos.conductas:
		var copia := conducta.duplicate() as ConductaJefe
		copia.pelea = self
		conductas.append(copia)


func _ready() -> void:
	# Sin jefe no hay pelea (algunas pruebas lo quitan).
	jefe.tree_exiting.connect(queue_free)
	presentacion = PresentacionJefe.new(tr(datos.nombre), tr(datos.titulo))
	presentacion.texto_rugido = tr(datos.rugido)
	presentacion.alto_jefe = jefe.datos.alto + datos.alto_extra
	presentacion.terminada.connect(_al_terminar_presentacion)
	add_child(presentacion)
	globo = GloboDialogo.new(felipe)
	# Nada de globito en pleno peligro (v4): la frase espera a que pase o se descarta.
	globo.peligro = amenaza
	add_child(globo)
	camara = CamaraPelea.new(self)
	add_child(camara)


## Durante la pelea (con Felipe en la arena) lo que dice Felipe va al globito; fuera de ella, al cuadro de siempre.
func _usar_globo() -> void:
	if nivel == null or nivel.travesuras == null or nivel.travesuras.dialogo == null:
		return
	var en_pelea := fase == Fase.PELEA and not ausente and globo != null
	nivel.travesuras.dialogo.globo = globo if en_pelea else null
	if not en_pelea and camara:
		camara.soltar()


## ¿El jefe avisa un ataque (para que la cámara lo mire si viene de lejos)? Cada jefe dice cuándo.
func amenaza() -> bool:
	return false


## La conducta con ese nombre (por ejemplo, "embestida"), o null.
func conducta(nombre: String) -> ConductaJefe:
	for c in conductas:
		if c.nombre() == nombre:
			return c
	return null


func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	match fase:
		Fase.ESPERANDO:
			# Al entrar a la arena (ya terminado el fundido de la puerta), el jefe despierta.
			if felipe_en_arena() and felipe.is_on_floor() and not nivel.cruzando():
				empezar()
		Fase.PELEA:
			if not felipe_en_arena():
				_salir()
			elif ausente:
				if felipe.is_on_floor() and not nivel.cruzando() and not presentacion.presentando:
					_volver()
			else:
				_actualizar_pelea(delta)
	_cada_cuadro(delta)


func felipe_en_arena() -> bool:
	return arena.grow_individual(-30, 0, -30, 0).has_point(felipe.global_position - Vector2(0, 1))


## Arranca la entrada: congela el juego y toma la cámara.
func empezar() -> void:
	if fase != Fase.ESPERANDO:
		return
	fase = Fase.ENTRADA
	presentacion.conectar_vida(jefe.vida)
	presentacion.pantallas = nivel.pantallas
	_al_empezar()
	presentacion.presentar(felipe, jefe, Rect2(arena.position.x, 0, arena.size.x, nivel.datos.alto))
	empezada.emit()


## Para pruebas y depuración: termina la entrada de golpe.
func saltar_entrada() -> void:
	presentacion.saltar()


func _al_terminar_presentacion() -> void:
	jefe.visible = true
	if fase == Fase.PELEA and _volviendo:
		_volviendo = false
		ausente = false
		jefe.patrulla.quieta = false
		return
	if fase != Fase.ENTRADA:
		return
	fase = Fase.PELEA
	jefe.patrulla.quieta = false
	jefe.patrulla.vision = arena.size.x
	_al_empezar_pelea()
	cambiar_fase()


## Empieza una fase (la primera, o la siguiente tras vencer una): cartel, pista y relojes de las conductas.
func cambiar_fase() -> void:
	for c in conductas:
		c.al_cambiar_fase(vencidas)
	_al_cambiar_fase()
	# Sin pistas (A.S.P.I. v4: cartel de una línea; las instrucciones van como íconos donde sirven), solo el cartel.
	var pista: String = DatosJefe.por_fase(datos.pistas, vencidas) if not datos.pistas.is_empty() else ""
	presentacion.cartel(DatosJefe.por_fase(datos.carteles, vencidas), 2.4, pista)
	presentacion.destello(0.4)
	presentacion.sacudir(0.25)
	fase_cambiada.emit(fase)


## Las conductas de la fase actual, en orden: el ataque en curso sigue; si no hay, la primera que se haga cargo.
func correr_conductas(delta: float) -> void:
	if activa:
		if not activa.actualizar(delta):
			activa = null
		return
	for c in conductas:
		if vencidas >= c.desde_fase and c.intentar(delta):
			return


## Relojes de todas las conductas (al principio del cuadro de pelea) y lo que vigilan antes de actuar.
func avanzar_relojes(delta: float) -> void:
	for c in conductas:
		c.cada_cuadro(delta)


func vigilar(delta: float) -> void:
	for c in conductas:
		c.vigilar(delta)


## Una conducta empezó un ataque: la pelea la sigue hasta que termine.
func empezar_ataque(conducta_que_ataca: ConductaJefe) -> void:
	activa = conducta_que_ataca


## Corta el ataque en curso y deja al jefe en reposo (cada jefe agrega lo suyo).
func terminar_ataque() -> void:
	activa = null


## Felipe salió de la arena: todo queda en pausa, con la fase guardada.
func _salir() -> void:
	if ausente:
		return
	ausente = true
	terminar_ataque()
	felipe.empuje = Vector2.ZERO
	_al_salir_felipe()


## Vuelve a la pelea: entrada corta (portazo y nombre, 1 s) y sigue en la fase a la que llegó.
func _volver() -> void:
	_volviendo = true
	presentacion.presentar_corta(felipe, jefe, Rect2(arena.position.x, 0, arena.size.x, nivel.datos.alto))


# --- Lo que cada jefe agrega (vacío aquí) ----------------------------------------------------------------------

## Al arrancar la entrada (escudo, quieto, inofensivo...).
func _al_empezar() -> void:
	pass


## Al terminar la entrada, antes de la primera fase.
func _al_empezar_pelea() -> void:
	pass


## Al empezar cada fase (velocidades, reinicio).
func _al_cambiar_fase() -> void:
	pass


## Cada cuadro de pelea con Felipe en la arena.
func _actualizar_pelea(_delta: float) -> void:
	pass


## Cada cuadro, pase lo que pase (proyectiles, lo que se repone).
func _cada_cuadro(_delta: float) -> void:
	pass


## Felipe salió de la arena (limpiar lo de la fase).
func _al_salir_felipe() -> void:
	pass
