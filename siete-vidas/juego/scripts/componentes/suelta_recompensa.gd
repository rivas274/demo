class_name SueltaRecompensa
extends Node
## Pieza para lo que suelta algo al romperse o vencerlo (la caja de cartón suelta un snack). Escucha la `murio` de la
## Vida hermana: suena y deja la recompensa (Recogible) donde estaba, con un saltito. La recompensa la entrega Travesuras.

signal solto(tipo: String)

## "snack", "calcetin" o "foto" (los tipos de Recogible).
@export var tipo := "snack"
## Dónde aparece, desde los pies de la entidad, y con qué impulso sale.
@export var desfase := Vector2(0, -30)
@export var impulso := Vector2(30, -140)
## Sonido del nivel al soltarla ("" para ninguno).
@export var sonido := "caja"


func _init() -> void:
	name = "SueltaRecompensa"


func _ready() -> void:
	var vida := Componentes.de(get_parent(), Vida) as Vida
	if vida:
		vida.murio.connect(soltar)


func soltar() -> void:
	var nivel := Componentes.nivel(self)
	if nivel == null:
		return
	if sonido != "":
		nivel.sonar(sonido)
	nivel.travesuras.soltar(tipo, (get_parent() as Node2D).global_position + desfase, impulso)
	solto.emit(tipo)
