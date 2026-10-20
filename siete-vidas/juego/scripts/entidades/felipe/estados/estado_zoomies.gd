class_name EstadoZoomies
extends EstadoFelipe
## ZOOMIES: un arranque corto y recto a toda velocidad (se gana en Downtown; apagado en el nivel 1), con su receta de
## jugo (datos/jugo/zoomies.tres, RecetaJugo):
## 1. ANTICIPA: se aplasta un instante (dentro de ±8 %) sin moverse.
## 2. CORRE: sale disparado con estela, líneas de velocidad y la cámara adelantada hacia donde corre. Si choca con un
##    mueble: pausa de impacto, sacudida, polvo y una frase (señal impacto("zoomies_choque")).
## 3. DERRAPA: al terminar el impulso en el piso patina unos px frenando, con polvo, pelos y una marca breve en el
##    piso (un gato de 8 kg que no sabe frenar). Si aprieta una dirección, sigue caminando o corriendo sin derrapar.

enum Fase { ANTICIPA, CORRE, DERRAPA }

var fase := Fase.ANTICIPA
var receta: RecetaJugo
var _tiempo := 0.0
var _velocidad_derrape := 0.0
var _frenado := 0.0


func _init(de: Felipe, estado: Felipe.Estado) -> void:
	super(de, estado)
	receta = RecetaJugo.de(de, "zoomies")


## datos: {"direccion": float} (hacia dónde aprieta; 0 = hacia donde mira).
func entrar(datos := {}) -> void:
	var direccion: float = datos.get("direccion", 0.0)
	if direccion != 0.0:
		felipe.mirando = signf(direccion)
	felipe.velocity = Vector2.ZERO
	felipe.sprite.play("correr")
	fase = Fase.ANTICIPA
	_tiempo = receta.datos.anticipacion
	if _tiempo > 0.0:
		felipe.efectos.estirar(receta.forma_anticipacion(), _tiempo)
	else:
		_salir_disparado()


func _salir_disparado() -> void:
	fase = Fase.CORRE
	_tiempo = felipe.duracion_zoomies
	felipe.velocity = Vector2(felipe.mirando * felipe.velocidad_zoomies, 0.0)
	felipe.efectos.estirar(Vector2(1.06, 0.95), felipe.duracion_zoomies)
	receta.adelantar_camara(felipe.get_node_or_null("Camara") as Camera2D, felipe.mirando)


func fisica(delta: float, direccion: float) -> void:
	match fase:
		Fase.ANTICIPA:
			_tiempo -= delta
			felipe.velocity = Vector2.ZERO
			if _tiempo <= 0.0:
				_salir_disparado()
		Fase.CORRE:
			_tiempo -= delta
			felipe.velocity.y = 0.0
			receta.correr(delta, felipe.mirando, Felipe.ALTO_DE_PIE)
			# Chocó si la pared le da de frente (no la que tenía detrás al salir).
			if felipe.is_on_wall() and felipe.get_wall_normal().x * felipe.mirando < 0.0:
				_chocar()
			elif _tiempo <= 0.0:
				_terminar_impulso(direccion)
		Fase.DERRAPA:
			_tiempo -= delta
			felipe.aplicar_gravedad(delta)
			if direccion != 0.0 or _tiempo <= 0.0 or not felipe.is_on_floor():
				felipe.cambiar_estado(Felipe.Estado.SUELO if felipe.is_on_floor() else Felipe.Estado.AIRE)
				return
			felipe.velocity.x = felipe.mirando * maxf(0.0, _velocidad_derrape - _frenado * (receta.datos.tiempo_derrape - _tiempo))


## Choca con un mueble o una pared: se detiene en seco, pausa y sacudida (el sistema Jugo, por la señal impacto),
## polvo y una frase.
func _chocar() -> void:
	felipe.velocity.x = 0.0
	receta.polvo_y_pelos(-felipe.mirando)
	felipe.efectos.aterrizar(0.6)
	felipe.impacto.emit("zoomies")
	felipe.cambiar_estado(Felipe.Estado.SUELO if felipe.is_on_floor() else Felipe.Estado.AIRE)


func _terminar_impulso(direccion: float) -> void:
	_velocidad_derrape = receta.velocidad_derrape()
	# Si aprieta hacia donde corre, sigue corriendo; si está en el aire, cae. Si no, derrapa.
	if direccion != 0.0 or not felipe.is_on_floor() or _velocidad_derrape <= 0.0:
		felipe.cambiar_estado(Felipe.Estado.SUELO if felipe.is_on_floor() else Felipe.Estado.AIRE)
		felipe.velocity.x = felipe.mirando * felipe.velocidad_correr
		return
	fase = Fase.DERRAPA
	# La animación de derrape desde Felipe A (cuadros 3 a 6 de su hoja): clava las patas y se inclina.
	felipe.sprite.play("derrape")
	_tiempo = receta.datos.tiempo_derrape
	_frenado = _velocidad_derrape / receta.datos.tiempo_derrape
	felipe.velocity.x = felipe.mirando * _velocidad_derrape
	receta.polvo_y_pelos(felipe.mirando)
	receta.marca(felipe.mirando)
	felipe.efectos.inclinar(-0.12, receta.datos.tiempo_derrape)
