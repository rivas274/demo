class_name DatosBoton
extends Resource
## Números del comportamiento de los botones de menú (BotonMenu): golpe al apretar, brillo y vaivén con foco,
## entrada desde arriba y pulso del botón principal. Se cambian en el inspector (datos/ui/boton_menu.tres).

@export_group("Al apretar")
## Escala a la que se encoge y cuánto tarda en encogerse y en volver (con rebote).
@export var escala_apretado := 0.9
@export var tiempo_apretar := 0.07
@export var tiempo_soltar := 0.2
@export_group("Con foco o encima")
## Brillo (modulate) mientras tiene foco.
@export var brillo_foco := 1.2
## Vaivén de péndulo con el pivote arriba al centro: amplitud máxima en grados, período en segundos y cuánto tarda
## la amplitud en subir o bajar (nunca de golpe).
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
