class_name ConductaJefe
extends Resource
## Una conducta de un jefe (patrón Estrategia): un ataque (embestida, soplido, bola de pelo) o algo que hace cuando no
## ataca (limpiar manchas). Cada una es un recurso con sus números en el inspector, dentro de los datos del jefe
## (DatosJefe.conductas, en orden de prioridad). La pelea (PeleaJefe) las prueba en ese orden cada cuadro: la primera
## que `intentar` devuelva true se queda con el cuadro; si empezó un ataque, la pelea la sigue con `actualizar` hasta
## que termine. Un jefe nuevo = datos + las conductas que ya existan + un par de conductas nuevas.

## Desde qué fase la usa (0 = desde el principio; A.S.P.I.: el soplido desde la 1, las bolas desde la 2).
@export var desde_fase := 0

## La pelea que la usa (la pone PeleaJefe al copiar la conducta para esta pelea).
var pelea: PeleaJefe


## Nombre corto (para buscarla con PeleaJefe.conducta y para las pruebas).
func nombre() -> String:
	return ""


## Siempre, al principio de cada cuadro de pelea (relojes que corren aunque esté ocupada).
func cada_cuadro(_delta: float) -> void:
	pass


## Antes de probar las conductas, si el jefe puede actuar (por ejemplo, contar cuánto lleva Felipe arriba de algo).
func vigilar(_delta: float) -> void:
	pass


## ¿Se hace cargo de este cuadro? Si empieza un ataque, llama pelea.empezar_ataque(self).
func intentar(_delta: float) -> bool:
	return false


## Mientras es el ataque en curso. Devuelve false cuando terminó.
func actualizar(_delta: float) -> bool:
	return false


## Empieza una fase nueva de la pelea (reiniciar sus relojes).
func al_cambiar_fase(_fase: int) -> void:
	pass

