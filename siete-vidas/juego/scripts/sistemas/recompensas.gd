class_name Recompensas
extends RefCounted
## Lo que Felipe junta (decisión del creador, 2026-10-19):
## - calcetines → el nido de Su Majestad (la cesta de la sala); cada 10, una ranura de maña (aquí solo el
##   contador y el texto: el sistema de mañas viene después);
## - fotos vergonzosas → la galería (logro Galería Viral);
## - snacks → el bolsillo de Felipe (5 como máximo; se comen manteniendo la acción);
## - caminos → se avisan con `camino_abierto` (el nivel abre la puerta o la persiana).

signal cambio(tipo: String)
signal camino_abierto(id: String)
## Juntó 10 calcetines más: ganó una ranura de maña.
signal ranura_ganada(total: int)
## Quiso guardar un snack con el bolsillo lleno (el snack se queda donde estaba).
signal bolsillo_lleno

const CALCETINES_POR_RANURA := 10

var felipe: Felipe
var calcetines := 0
var fotos := 0
var caminos: Array[String] = []


func _init(de: Felipe = null) -> void:
	felipe = de


## Entrega una recompensa ({"tipo", "cantidad", "id"}). Devuelve cuántas unidades entraron
## (un snack no entra si el bolsillo está lleno).
func dar(recompensa: Dictionary) -> int:
	var tipo := String(recompensa.get("tipo", ""))
	var cantidad := int(recompensa.get("cantidad", 1))
	var entraron := 0
	match tipo:
		"calcetin":
			for i in cantidad:
				calcetines += 1
				entraron += 1
				if calcetines % CALCETINES_POR_RANURA == 0:
					ranura_ganada.emit(ranuras())
		"foto":
			fotos += cantidad
			entraron = cantidad
		"snack":
			for i in cantidad:
				if felipe and felipe.guardar_snack():
					entraron += 1
				else:
					bolsillo_lleno.emit()
					break
		"camino":
			var id := String(recompensa.get("id", ""))
			if id != "" and not caminos.has(id):
				caminos.append(id)
				camino_abierto.emit(id)
			entraron = 1
	if entraron > 0:
		cambio.emit(tipo)
	return entraron


func snacks() -> int:
	return felipe.snacks if felipe else 0


## Ranuras de maña ganadas con los calcetines del nido.
func ranuras() -> int:
	return calcetines / CALCETINES_POR_RANURA


## "3/10 para tu próxima ranura" (para el resumen del día).
func texto_ranura() -> String:
	return "%d/%d para tu próxima ranura" % [calcetines % CALCETINES_POR_RANURA, CALCETINES_POR_RANURA]
