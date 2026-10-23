class_name DatosJefe
extends Resource
## Los datos de una pelea de jefe: cómo se presenta (PresentacionJefe), sus fases y lo que hace en cada una. Un jefe nuevo
## es un .tres en `datos/jefes/` con estos números y sus conductas (ataques) en orden de prioridad; la pelea genérica
## (PeleaJefe) hace el resto. Las listas por fase tienen un valor por fase (si falta, vale el último).

@export_group("Presentación")
@export var nombre := "JEFE"
@export var titulo := ""
## Lo que «ruge» en el paso 8 de la entrada.
@export var rugido := ""
## Cuánto más alto que el cuerpo se encuadra en la entrada.
@export var alto_extra := 20.0
@export_group("Fases")
## Cuántas veces hay que vencerlo (A.S.P.I.: tres apagados). También las divisiones de su barra.
@export var fases := 3
## Cartel y pista al empezar cada fase ({accion} es el ícono del botón).
@export var carteles: PackedStringArray = []
@export var pistas: PackedStringArray = []
## Velocidad de persecución por fase (la de patrulla es el 70 %).
@export var velocidad: PackedFloat32Array = []
@export_group("Vulnerable")
## Cuánto aguanta antes de quedar vulnerable, por fase (A.S.P.I.: manchas que le llenan el depósito).
@export var capacidad: PackedInt32Array = []
## Segundos que queda vulnerable, por fase (A.S.P.I.: detenida con el depósito lleno).
@export var tiempo_vulnerable: PackedFloat32Array = []
## Pista mientras está vulnerable.
@export var pista_vulnerable := ""
## Lo que devuelve al vencer cada fase (A.S.P.I.: motas de la montaña de pelusa que escupe al apagarse; cada mota es
## una mancha). Lo que tragó vuelve al piso: así nunca falta munición (revisión del 2026-10-23).
@export var devuelve: PackedInt32Array = []
## Segundos quieta e inofensiva al empezar una fase nueva (Felipe alcanza a alejarse).
@export var reinicio := 1.5
@export_group("Sonidos")
## Sonido de cada momento de la pelea: evento -> nombre del sonido del nivel (assets/sonidos/). Ganchos para los sonidos
## finales (encargo en memoria/05): A.S.P.I. usa motor, reversa, atragantar, blorp y cortocircuito.
@export var sonidos := {}
## Cuánto sube el tono del motor con cada mancha que traga (0 = no cambia).
@export var tono_por_mancha := 0.0
@export_group("Conductas")
## Ataques y conductas en orden de prioridad (ConductaJefe).
@export var conductas: Array[ConductaJefe] = []


## Valor de una lista por fase (si la fase pasa del largo, el último).
static func por_fase(lista: Variant, fase: int) -> Variant:
	return lista[mini(fase, lista.size() - 1)]
