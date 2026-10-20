class_name DatosObjeto
extends Resource
## Los datos de un objeto del nivel: los que se tiran (vaso, taza de café, maceta, llaves) y la comida (tazón, pollo).
## Un objeto nuevo es un archivo .tres en `datos/objetos/` más una línea en los datos del nivel (dónde va).

## Qué es; también el nombre de su imagen en assets/nivel1/ (ArteNivel).
@export var tipo := "vaso"
## Nombre del nodo en el nivel ("" = el tipo con mayúscula; las pruebas buscan algunos por nombre, como «Vaso»).
@export var nombre := ""
## Verbo de Felipe en la burbuja del Indicador.
@export var verbo := "VERBO_LIBERAR"
@export_group("Si se tira (Tirable)")
## Al caer aturde a lo que tenga debajo (la taza y la maceta sí; el vaso no).
@export var aturde := true
## Al caer queda roto en el piso (las llaves no: siguen enteras).
@export var se_rompe := true
## Logro al caer ("" para ninguno).
@export var logro := ""
## Sonido del nivel al caer.
@export var sonido := "vidrio"


## Nombre del nodo: el pedido o el tipo con mayúscula.
func nombre_de_nodo() -> String:
	return nombre if nombre != "" else tipo.capitalize()
