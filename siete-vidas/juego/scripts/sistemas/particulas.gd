class_name Particulas
extends RefCounted
## Fábrica de partículas de pixel que se repiten en el juego (polvo de un golpe, pelusa de un arañazo): un solo lugar
## para armarlas en vez de copiar diez líneas de ajustes en cada script. Salen apagadas y de un solo disparo: quien las
## usa las pone donde van y llama restart() y emitting = true.


## Nube de polvo hacia arriba: `cantidad` granos que viven `vida` s, con esa gravedad, velocidad (mín., máx.), tamaño
## (mín., máx.) y color; `dispersion` en grados alrededor de la vertical; `explosividad` de 0 a 1 (1: todos a la vez).
static func polvo(cantidad: int, vida: float, gravedad: Vector2, velocidad: Vector2, tamano: Vector2, color: Color, dispersion := 90.0, explosividad := 1.0) -> CPUParticles2D:
	var particulas := CPUParticles2D.new()
	particulas.emitting = false
	particulas.one_shot = true
	particulas.amount = cantidad
	particulas.lifetime = vida
	particulas.explosiveness = explosividad
	particulas.direction = Vector2(0, -1)
	particulas.spread = dispersion
	particulas.gravity = gravedad
	particulas.initial_velocity_min = velocidad.x
	particulas.initial_velocity_max = velocidad.y
	particulas.scale_amount_min = tamano.x
	particulas.scale_amount_max = tamano.y
	particulas.color = color
	return particulas
