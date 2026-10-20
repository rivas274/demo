class_name AgachadoFelipe
extends RefCounted
## Agacharse y gatear (una postura que convive con los estados: se puede estar en SUELO y agachado). Solo en el piso;
## bajo un mueble no se puede parar aunque se suelte el botón. Agachado + saltar sobre una repisa que se atraviesa
## desde abajo baja a través de ella. Es una parte de Felipe (felipe.agachado_felipe); la bandera es felipe.agachado.

var felipe: Felipe
var _tiempo_bajando := 0.0


func _init(de: Felipe) -> void:
	felipe = de


func actualizar() -> void:
	var quiere := Input.is_action_pressed("agacharse") and felipe.is_on_floor() and felipe.estado in [Felipe.Estado.SUELO, Felipe.Estado.ATERRIZANDO]
	if quiere and not felipe.agachado:
		poner(true)
	elif felipe.agachado and not quiere and cabe_de_pie():
		poner(false)


## Se agacha o se para: la caja de colisión cambia de alto y la transición se dibuja (cuadros 0 a 2 de la hoja de
## gatear): al bajar hacia adelante, al pararse al revés.
func poner(valor: bool) -> void:
	felipe.agachado = valor
	var caja := felipe.cuerpo.shape as RectangleShape2D
	var alto := Felipe.ALTO_AGACHADO if valor else Felipe.ALTO_DE_PIE
	caja.size.y = alto
	felipe.cuerpo.position.y = -alto / 2.0
	felipe.efectos.detener()
	felipe.sprite.rotation = 0.0
	felipe.sprite.scale = felipe.efectos.escala_base()
	if valor:
		felipe.sprite.play("agacharse")
	elif felipe.is_on_floor():
		felipe.animador.levantarse()


## ¿Hay espacio arriba para pararse? (Los muebles que se atraviesan desde abajo no estorban.)
func cabe_de_pie() -> bool:
	return not felipe.test_move(felipe.global_transform, Vector2(0, -(Felipe.ALTO_DE_PIE - Felipe.ALTO_AGACHADO)))


func sobre_mueble_atravesable() -> bool:
	for i in felipe.get_slide_collision_count():
		var choque := felipe.get_slide_collision(i)
		var objeto := choque.get_collider() as CollisionObject2D
		if choque.get_normal().y < -0.5 and objeto and objeto.get_collision_layer_value(Felipe.CAPA_ATRAVESABLE):
			return true
	return false


## Agachado + saltar sobre una repisa: deja de chocar con los muebles atravesables un instante y cae.
func bajar_por_mueble() -> void:
	felipe.set_collision_mask_value(Felipe.CAPA_ATRAVESABLE, false)
	_tiempo_bajando = 0.25
	poner(false)
	felipe.position.y += 2.0


## Al empezar cada cuadro: pasado el instante de bajar, vuelve a chocar con los muebles atravesables.
func actualizar_bajada(delta: float) -> void:
	if _tiempo_bajando <= 0.0:
		return
	_tiempo_bajando -= delta
	if _tiempo_bajando <= 0.0:
		felipe.set_collision_mask_value(Felipe.CAPA_ATRAVESABLE, true)
