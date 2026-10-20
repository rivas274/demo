class_name DatosJugo
extends Resource
## La receta de jugo de una acción (pilar 5: respuesta jugosa): qué efectos lleva y con qué números. La usa
## RecetaJugo; cada acción tiene su archivo en datos/jugo/ (zoomies.tres, zarpazo.tres...). Todo en 0 = sin ese efecto.
## Idea tomada de los 5 pasos para que un dash se sienta bien: anticipación, estela, líneas, pausa de impacto, polvo.

@export_group("Anticipación")
## Segundos que se prepara antes de salir (no se mueve) y su forma (se limita a ±8 %, Felipe.DEFORMACION_MAXIMA).
@export var anticipacion := 0.0
@export var forma_anticipacion := Vector2(1.06, 0.94)
@export_group("Líneas de velocidad")
## Líneas de pixel detrás del cuerpo mientras corre: cada cuánto sale una tanda, cuántas, largo y vida.
@export var lineas_cada := 0.0
@export var lineas_cantidad := 3
@export var lineas_largo := Vector2(10, 22)
@export var lineas_vida := 0.12
@export var lineas_color := Color(1.0, 1.0, 1.0, 0.8)
@export_group("Cámara")
## Cuánto se adelanta la cámara hacia donde corre (px, sin zoom) y en cuánto tiempo va y vuelve.
@export var adelanto_camara := 0.0
@export var tiempo_camara := 0.18
@export_group("Impacto")
## Pausa de impacto (congelado), sacudida de cámara (s y fuerza) y frase de Felipe (evento de Frases.FELIPE).
@export var pausa_impacto := 0.0
@export var sacudida := 0.0
@export var fuerza_sacudida := 1.0
@export var frase_impacto := ""
## Vibración leve del mando en el impacto: motor débil y fuerte (0 a 1) y segundos (0 = no vibra). La apaga Opciones.
@export var vibracion := Vector3.ZERO
## Solo para aterrizar: desde qué fuerza de caída (0 a 1) vibra.
@export var fuerza_minima := 0.0
@export_group("Polvo y derrape")
## Granos de polvo y de pelos al frenar o chocar (con su empuje), cuánto patina (px) y en cuánto tiempo, y cuánto
## dura la marca del derrape en el piso.
@export var polvo := 0
@export var empuje_polvo := 1.0
@export var color_polvo := Color(0.88, 0.84, 0.79, 0.9)
@export var pelos := 0
@export var color_pelos := Color(0.953, 0.937, 0.91)
@export var derrape := 0.0
@export var tiempo_derrape := 0.0
@export var marca_derrape := 0.0
@export var color_marca := Color(0.16, 0.09, 0.06, 0.7)
