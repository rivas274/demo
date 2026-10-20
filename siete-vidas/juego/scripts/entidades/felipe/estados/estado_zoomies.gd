class_name EstadoZoomies
extends EstadoFelipe
## ZOOMIES: un arranque corto y recto a toda velocidad (se gana en Downtown; apagado en el nivel 1).

var _tiempo := 0.0


## datos: {"direccion": float} (hacia dónde aprieta; 0 = hacia donde mira).
func entrar(datos := {}) -> void:
	_tiempo = felipe.duracion_zoomies
	var direccion: float = datos.get("direccion", 0.0)
	if direccion != 0.0:
		felipe.mirando = signf(direccion)
	felipe.velocity = Vector2(felipe.mirando * felipe.velocidad_zoomies, 0.0)
	felipe.efectos.estirar(Vector2(1.06, 0.95), felipe.duracion_zoomies)


func fisica(delta: float, _direccion: float) -> void:
	_tiempo -= delta
	felipe.velocity.y = 0.0
	if _tiempo <= 0.0:
		felipe.cambiar_estado(Felipe.Estado.SUELO if felipe.is_on_floor() else Felipe.Estado.AIRE)
		felipe.velocity.x = felipe.mirando * felipe.velocidad_correr
