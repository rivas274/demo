class_name DatosBoton
extends Resource
## Números del comportamiento de los botones de menú (BotonMenu): golpe al apretar, brillo y vaivén con foco,
## entrada desde arriba y pulso del botón principal. Se cambian en el inspector (datos/ui/boton_menu.tres).

@export_group("Arte (menú de estambre)")
## Hilo que se repite hacia arriba desde la argolla, ovillo de donde cuelga la columna y motas de pelusa del
## manotazo. Sin hilo, el botón no cuelga (se dibuja como un botón del tema, sin estambre).
@export var hilo: Texture2D
@export var ovillo: Texture2D
@export var pelusas: Array[Texture2D] = []
## Largo del hilo sobre la argolla (es también la separación entre letreros; la argolla es el punto_cuelgue del
## botón).
@export var largo_hilo := 12.0
@export_group("Pelusa")
## Motas que suelta un manotazo: cuántas, cuánto vuelan (px), cuánto caen (px) y cuánto duran (s).
@export var pelusa_cantidad := 3
@export var pelusa_distancia := 34.0
@export var pelusa_caida := 46.0
@export var pelusa_tiempo := 0.9
## Escala de cada mota (las de la hoja miden unos 28 px: a la mitad se leen como pelusa, no como ovillos).
@export var pelusa_escala := 0.5
@export_group("Manotazo de Felipe")
## Fuerza del golpe cuando Felipe elige un letrero (1 = un golpe normal).
@export var fuerza_manotazo := 1.6
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
@export_group("Manotazo")
## golpear(fuerza): impulso de vaivén extra (grados por unidad de fuerza) que se apaga solo; período del columpio
## y cuánto se amortigua por segundo (0 a 1: lo que queda después de un segundo).
@export var golpe_grados := 14.0
@export var golpe_periodo := 0.9
@export var golpe_amortiguacion := 0.15
@export_group("Entrada")
## Cae desde fuera del borde de arriba hasta su sitio (rebote), escalonado entre botones.
@export var tiempo_entrada := 0.9
@export var escalon_entrada := 0.08
@export_group("Principal")
## Pulso sutil del botón principal: brillo entre 1 y 1 + pulso, con ese período.
@export var pulso_principal := 0.1
@export var periodo_pulso := 1.6
