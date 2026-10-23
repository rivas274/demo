class_name DatosBoton
extends Resource
## Números y aspecto de un tipo de botón de menú (BotonMenu): golpe al apretar, brillo y vaivén con foco, entrada
## barriendo (interfaz v2) y pulso del principal. Cada tipo es un .tres: datos/ui/boton_menu.tres (el botón del kit v2).

@export_group("Aspecto")
## Variación del tema que lo dibuja (BotonMenu, BotonOpcion...).
@export var variacion := &"BotonMenu"
## Tamaño fijo del dibujo (0 = el que pida el texto).
@export var tamano := Vector2.ZERO
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
## Barre desde la izquierda hasta su sitio (rebote), escalonado entre botones.
@export var tiempo_entrada := 0.9
@export var escalon_entrada := 0.08
@export_group("Principal")
## Pulso sutil del botón principal: brillo entre 1 y 1 + pulso, con ese período.
@export var pulso_principal := 0.1
@export var periodo_pulso := 1.6
