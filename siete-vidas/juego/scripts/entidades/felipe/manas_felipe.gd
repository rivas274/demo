class_name ManasFelipe
extends RefCounted
## Las mañas de Felipe en el cuadro justo (regla de las acciones: el efecto sale en el cuadro de impacto, nunca al
## apretar el botón): el zarpazo golpea lo que lleve RecibeGolpes, el manotazo tira lo que estaba pidiendo (un Tirable,
## la caja de la mudanza), las garras dejan su marca, la boca traga y el maullido llega a cada OyeMaullido cercano.
## También busca qué tiene al alcance el botón de acción. Es una parte de Felipe (felipe.manas): Felipe decide cuándo
## empieza cada maña y en qué estado queda; aquí solo pasa lo que pasa cuando la pata, la boca o las garras llegan.

var felipe: Felipe
## Lo que pasa cuando la pata llega (manotazo), con qué se araña y qué se come.
var al_impacto := Callable()
var es_manotazo := false
var objetivo: Node2D
var alimento: Node2D
var comiendo_snack := false


func _init(de: Felipe) -> void:
	felipe = de


## Zarpazo: la pata golpea lo que tenga enfrente (no tira nada).
func preparar_zarpazo() -> void:
	es_manotazo = false
	al_impacto = Callable()


## Terminó la animación de la maña: no queda nada pendiente.
func limpiar() -> void:
	al_impacto = Callable()
	objetivo = null
	alimento = null
	comiendo_snack = false


## El objeto interactuable más cercano al alcance, o null si no hay ninguno (el botón no hace nada).
## Los objetos anchos (sofá, rascador) dicen con punto_para(desde) dónde se los alcanza; los que a veces
## no se pueden usar, con disponible(felipe).
func objeto_cercano() -> Node2D:
	var mejor: Node2D = null
	var mejor_distancia := INF
	for objeto: Node2D in felipe.get_tree().get_nodes_in_group(Componentes.INTERACTUABLES):
		if objeto.has_method("disponible") and not objeto.call("disponible", felipe):
			continue
		var punto: Vector2 = objeto.call("punto_para", felipe.global_position) if objeto.has_method("punto_para") else objeto.global_position
		var distancia := punto - felipe.global_position
		if absf(distancia.x) <= Felipe.ALCANCE.x and absf(distancia.y) <= Felipe.ALCANCE.y and absf(distancia.x) < mejor_distancia:
			mejor = objeto
			mejor_distancia = absf(distancia.x)
	return mejor


## El efecto de cada acción sale cuando el dibujo llega (cuadro de impacto). Conectado a sprite.frame_changed.
func al_cambiar_cuadro() -> void:
	var sprite := felipe.sprite
	var estado := felipe.estado
	var cuadro := sprite.frame
	match String(sprite.animation):
		"zarpazo":
			if estado != Felipe.Estado.ZARPAZO:
				return
			if cuadro == Felipe.CUADRO_SILBIDO_ZARPAZO:
				felipe.sonido.emit("zarpazo")
			elif cuadro == Felipe.CUADRO_IMPACTO_ZARPAZO:
				_marcar_impacto()
				if es_manotazo:
					var accion := al_impacto
					al_impacto = Callable()
					if accion.is_valid():
						accion.call()
					felipe.impacto.emit("manotazo")
				else:
					_golpear()
					felipe.impacto.emit("zarpazo")
		"comer":
			if estado == Felipe.Estado.COMIENDO and cuadro == Felipe.CUADRO_IMPACTO_COMER:
				_marcar_impacto()
				_tragar()
		"aranar":
			if estado == Felipe.Estado.ARANANDO and cuadro in Felipe.CUADROS_IMPACTO_ARANAR:
				_marcar_impacto()
				var critico := false
				if is_instance_valid(objetivo) and objetivo.has_method("al_aranar"):
					critico = bool(objetivo.call("al_aranar", felipe))
				felipe.sonido.emit("aranar")
				felipe.aranazo.emit(objetivo, critico)
				felipe.impacto.emit("aranar")
		"maullar":
			if estado == Felipe.Estado.MAULLANDO and cuadro == Felipe.CUADRO_MAULLIDO:
				_marcar_impacto()
				_maullar_ahora()


func _marcar_impacto() -> void:
	felipe.ultimo_impacto = {"animacion": String(felipe.sprite.animation), "cuadro": felipe.sprite.frame}


func _tragar() -> void:
	felipe.vida.curar(1)
	felipe.peso += Felipe.PESO_POR_COMIDA
	felipe.sonido.emit("comer")
	if comiendo_snack:
		felipe.snacks -= 1
		felipe.snacks_cambiados.emit(felipe.snacks)
		felipe.snack_comido.emit()
	elif is_instance_valid(alimento) and alimento.has_method("al_comido"):
		if alimento.has_method("snacks_que_recarga"):
			felipe.recargar_snacks(felipe.snacks + int(alimento.call("snacks_que_recarga")))
		alimento.call("al_comido")
	alimento = null
	comiendo_snack = false
	felipe.impacto.emit("comer")


func _maullar_ahora() -> void:
	var boca := felipe.global_position + Vector2(Felipe.BOCA.x * felipe.mirando, Felipe.BOCA.y)
	felipe.sonido.emit("maullido")
	felipe.maullo.emit(boca)
	for oyente: Node in felipe.get_tree().get_nodes_in_group(Felipe.GRUPO_OYENTES):
		if oyente is OyeMaullido and (oyente as OyeMaullido).global_position.distance_to(felipe.global_position) <= Felipe.RADIO_MAULLIDO:
			(oyente as OyeMaullido).oir_maullido(felipe)


## El zarpazo golpea lo que esté justo enfrente y lleve la pieza RecibeGolpes (ratones, A.S.P.I., la caja).
func _golpear() -> void:
	for enemigo: Node2D in felipe.get_tree().get_nodes_in_group(Componentes.ENEMIGOS):
		var distancia := enemigo.global_position - felipe.global_position
		var enfrente := signf(distancia.x) == felipe.mirando or absf(distancia.x) < 8.0
		var golpes := Componentes.de(enemigo, RecibeGolpes) as RecibeGolpes
		if golpes and enfrente and absf(distancia.x) <= Felipe.ALCANCE_ZARPAZO.x and absf(distancia.y) <= Felipe.ALCANCE_ZARPAZO.y:
			golpes.recibir_zarpazo(felipe)
