class_name DatosBoton
extends Resource
## Números y aspecto de un tipo de botón de menú (BotonMenu): golpe al apretar, brillo y vaivén con foco, entrada
## desde arriba, pulso del principal y, si trae `sello`, el sello que se estampa al elegirlo. Cada tipo es un .tres:
## datos/ui/boton_menu.tres (el botón de siempre) y datos/ui/boton_pergamino.tres (el pergamino del Decreto real).

@export_group("Aspecto")
## Variación del tema que lo dibuja (BotonMenu, BotonPergamino...).
@export var variacion := &"BotonMenu"
## Tamaño fijo del dibujo (0 = el que pida el texto): el pergamino va a su tamaño de pixel, no se estira.
@export var tamano := Vector2.ZERO
@export_group("Al elegir")
## Escena SelloHuella que se estampa sobre el botón al elegirlo (sin escena, no hay sello) y dónde, como fracción del
## tamaño del botón.
@export var sello: PackedScene
@export var lugar_sello := Vector2(0.84, 0.5)
@export_group("Al apretar")
## Escala a la que se encoge y cuánto tarda en encogerse y en volver (con rebote).
@export var escala_apretado := 0.9
@export var tiempo_apretar := 0.07
@export var tiempo_soltar := 0.2
@export_group("Con foco o encima")
## Brillo (modulate) mientras tiene foco.
@export var brillo_foco := 1.2
## Vaivén de péndulo con el pivote arriba al centro: amplitud máxima en grados (0 = quieto), período en segundos y
## cuánto tarda la amplitud en subir o bajar (nunca de golpe).
@export var vaiven_grados := 6.0
@export var vaiven_periodo := 2.2
@export var vaiven_rampa := 0.4
## Lo que tarda el brillo en subir o bajar.
@export var tiempo_brillo := 0.15
@export_group("Entrada")
## Cae desde fuera del borde de arriba hasta su sitio (rebote), escalonado entre botones.
@export var tiempo_entrada := 0.9
@export var escalon_entrada := 0.08
@export_group("Principal")
## Pulso sutil del botón principal: brillo entre 1 y 1 + pulso, con ese período.
@export var pulso_principal := 0.1
@export var periodo_pulso := 1.6
