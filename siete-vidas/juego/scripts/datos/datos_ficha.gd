class_name DatosFicha
extends Resource
## La «Ficha de Su Majestad» del menú de pausa (pilar 4: más kilos, más defensa, más carisma y más ataque). Las
## estadísticas salen del peso con esta tabla; cada una tiene tres frases satíricas (claves de traducciones/textos.csv)
## según cuánto tenga. La velocidad aparece solo como chiste y no cambia.
##
## SOLO DE CHISTE (decisión del creador, 2026-10-20): estas estadísticas no cambian nada del juego. Ningún sistema
## (daño, perdón, golpes) las lee; se muestran en la ficha y nada más. El peso es el único número real, y solo se ve
## aquí (nunca en el HUD).

const ESTADISTICAS: Array[StringName] = [&"defensa", &"carisma", &"ataque", &"peso"]

@export_group("Tabla del peso")
## Kilos de cada fila de la tabla (de menor a mayor); entre filas, el valor se interpola.
@export var kilos: PackedFloat32Array = [8.0, 9.5, 11.0, 13.0]
## Valor de cada estadística (0 a 1) en cada fila de `kilos`.
@export var defensa: PackedFloat32Array = [0.35, 0.55, 0.8, 1.0]
@export var carisma: PackedFloat32Array = [0.5, 0.68, 0.85, 1.0]
@export var ataque: PackedFloat32Array = [0.3, 0.48, 0.7, 0.9]
## La barra del peso va de `peso_vacio` kg (vacía) a `peso_lleno` kg (llena).
@export var peso_vacio := 6.0
@export var peso_lleno := 13.0
@export_group("Frases")
## Con menos de umbrales.x, frase baja; con menos de umbrales.y, la del medio; si no, la alta.
@export var umbrales := Vector2(0.5, 0.8)
## Tres claves por estadística: [baja, media, alta].
@export var frases := {
	&"defensa": ["FICHA_DEFENSA_1", "FICHA_DEFENSA_2", "FICHA_DEFENSA_3"],
	&"carisma": ["FICHA_CARISMA_1", "FICHA_CARISMA_2", "FICHA_CARISMA_3"],
	&"ataque": ["FICHA_ATAQUE_1", "FICHA_ATAQUE_2", "FICHA_ATAQUE_3"],
	&"peso": ["FICHA_PESO_1", "FICHA_PESO_2", "FICHA_PESO_3"],
}
## El chiste fijo de la velocidad (no tiene barra: no cambia).
@export var frase_velocidad := "FICHA_VELOCIDAD_FRASE"
@export_group("Humor")
## El humor de Felipe según los kilos: hasta humor_hasta[i] kg, humores[i]; pasado el último, el último humor.
@export var humor_hasta: PackedFloat32Array = [8.5, 9.5, 11.0]
@export var humores: PackedStringArray = ["HUMOR_ATLETICO", "HUMOR_ESPONJOSO", "HUMOR_MODO_INVIERNO", "HUMOR_MODO_BUDA"]


## Valor (0 a 1) de la estadística con esos kilos.
func valor(estadistica: StringName, kg: float) -> float:
	if estadistica == &"peso":
		return clampf(inverse_lerp(peso_vacio, peso_lleno, kg), 0.0, 1.0)
	var fila: PackedFloat32Array = get(estadistica)
	if kg <= kilos[0]:
		return fila[0]
	for i in range(1, kilos.size()):
		if kg <= kilos[i]:
			return lerpf(fila[i - 1], fila[i], inverse_lerp(kilos[i - 1], kilos[i], kg))
	return fila[fila.size() - 1]


## Clave de la frase de la estadística con esos kilos.
func frase(estadistica: StringName, kg: float) -> String:
	var v := valor(estadistica, kg)
	var tres: Array = frases[estadistica]
	return tres[0] if v < umbrales.x else (tres[1] if v < umbrales.y else tres[2])


## Todas las estadísticas con esos kilos: {estadistica: [valor, clave de la frase]}.
func estadisticas(kg: float) -> Dictionary:
	var todas := {}
	for e in ESTADISTICAS:
		todas[e] = [valor(e, kg), frase(e, kg)]
	return todas


## Clave del humor de Felipe con esos kilos (Atlético, Esponjoso, Modo Invierno, Modo Buda).
func humor(kg: float) -> String:
	for i in humor_hasta.size():
		if kg < humor_hasta[i]:
			return humores[i]
	return humores[humores.size() - 1]


## Los kilos como se leen en la ficha: «9,8 kg».
static func texto_kilos(kg: float) -> String:
	return ("%.1f kg" % kg).replace(".", ",")
