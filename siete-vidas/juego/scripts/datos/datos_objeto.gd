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
## Su rol de profundidad (Capas.Rol): apoyado sobre el mueble donde está (detrás de Felipe, salvo que Felipe esté en
## esa misma superficie). Al caer pasa a lo que se toca y, en el piso, a resto.
@export var rol: Capas.Rol = Capas.Rol.APOYADO
@export_group("Si se come (Comida)")
## Snacks que recarga en el bolsillo al comerla (el plato de Felipe: 1; decisión del creador, 2026-10-20).
@export var recarga_snacks := 0
## El recipiente que queda en el mundo, vacío, después de comer (imagen de assets/nivel1/; "" = desaparece entero).
## Solo desaparece la comida: el tazón queda vacío con croquetas sueltas; la bandeja del pollo, con los huesitos.
@export var vacio := ""
@export_group("Si se tira (Tirable)")
## Al caer aturde a lo que tenga debajo (la taza y la maceta sí; el vaso no).
@export var aturde := true
## Al caer queda roto en el piso (las llaves no: siguen enteras).
@export var se_rompe := true
## Logro al caer ("" para ninguno).
@export var logro := ""
## Sonido del nivel al caer.
@export var sonido := "vidrio"
@export_group("Lo que queda roto (marca en el piso)")
## Pedazos que saltan al romperse, rebotan y quedan quietos (imágenes de assets/nivel1/, recortadas del arte del
## objeto con `herramientas/preparar_arte_nivel.py rotos`). Los dibuja PiezaSuelta, como en las derrotas.
@export var piezas_rotura: PackedStringArray = []
@export var velocidad_piezas := Vector2(110, 190)
## Charco (o tierra) que se extiende en el piso en escalones de pixel, 2 tonos y sin degradado. Ancho 0 = ninguno.
@export var charco_ancho := 0.0
@export var charco_alto := 3.0
@export var charco_claro := Color(0.62, 0.8, 0.92)
@export var charco_oscuro := Color(0.38, 0.6, 0.78)
## El charco es agua o café: en el apagón de A.S.P.I. (fase 3) la electrocuta si pasa por encima.
@export var conduce := false
## Imagen que queda apoyada en el charco (la planta tirada de la maceta; "" = ninguna).
@export var queda := ""


## Nombre del nodo: el pedido o el tipo con mayúscula.
func nombre_de_nodo() -> String:
	return nombre if nombre != "" else tipo.capitalize()
