# PROTOTIPO: no es código del juego.
# Felipe v8: piezas y huesos marcados a mano por el creador sobre las plantillas
# ortográficas (assets/meshy_prueba/plantilla_esqueleto/). Datos y reglas que usa
# felipe_meshy.gd cuando version = 8.
# - Puntos de los huesos: cruzando perfil y frente (las patas del otro lado, espejadas;
#   la delantera lejana va corrida hacia atrás, como en el modelo).
# - Piezas: máscaras sacadas de sus contornos (mascaras_v8.py) + cortes planos en las
#   articulaciones de las patas, en los 3 tramos de la cola y entre las 2 masas del cuerpo.
class_name FelipeV8
extends RefCounted

const CARPETA := "res://assets/meshy_prueba/plantilla_esqueleto/"
## Mapeo de vistas.gd: modelo centrado en su AABB, 1024 px = 1,15 × 1,899 unidades.
const CENTRO := Vector3(-0.00190401, -0.00079849, -0.00183651)
const PX := 468.79273

const PUNTOS_V8 := {
	"Bone": Vector3(0, -0.274, -0.064),
	"Bone_001": Vector3(0, -0.253, 0.186),
	"Bone_002": Vector3(0, -0.28, 0.446),
	"Bone_003": Vector3(0, -0.093, 0.41),
	"Bone_003_end": Vector3(0, 0.451, 0.698),
	"Bone_004": Vector3(0, -0.103, -0.411),
	"Bone_005": Vector3(0, 0.072, -0.614),
	"Bone_006": Vector3(0, 0.413, -0.608),
	"Bone_007": Vector3(0, 0.59, -0.689),
	"Bone_007_end": Vector3(0, 0.633, -0.891),
	"Bone_014": Vector3(-0.288, -0.366, 0.378),
	"Bone_015": Vector3(-0.283, -0.551, 0.495),
	"Bone_016": Vector3(-0.145, -0.743, 0.495),
	"Bone_016_end": Vector3(-0.145, -0.76, 0.613),
	"Bone_017": Vector3(0.233, -0.366, 0.378),
	"Bone_018": Vector3(0.233, -0.551, 0.405),
	"Bone_019": Vector3(0.233, -0.743, 0.315),
	"Bone_019_end": Vector3(0.164, -0.76, 0.433),
	"Bone_008": Vector3(0.22, -0.242, -0.198),
	"Bone_009": Vector3(0.22, -0.427, -0.091),
	"Bone_010": Vector3(0.21, -0.615, -0.273),
	"Bone_010_end": Vector3(0.21, -0.754, -0.177),
	"Bone_011": Vector3(-0.22, -0.242, -0.198),
	"Bone_012": Vector3(-0.22, -0.427, -0.091),
	"Bone_013": Vector3(-0.21, -0.615, -0.273),
	"Bone_013_end": Vector3(-0.21, -0.754, -0.177),
	"oreja_i": Vector3(-0.283, 0.409, 0.474),
	"oreja_d": Vector3(0.292, 0.409, 0.474),
	"mechon_i": Vector3(-0.454, 0.217, 0.442),
	"mechon_d": Vector3(0.452, 0.217, 0.442),
	"melena": Vector3(0, -0.135, 0.677),
}

const BITS_PERFIL := {"cabeza": 0, "oreja": 1, "mechon": 2, "pata_del": 3, "pata_tras": 4, "cola": 5}
const BITS_FRENTE := {"oreja_i": 0, "oreja_d": 1, "mechon_i": 2, "mechon_d": 3, "pecho": 4, "pata_i": 5, "pata_d": 6}
## Huesos nuevos (no están en el pack): [nombre, padre].
const EXTRA := [["oreja_i", "Bone_003"], ["oreja_d", "Bone_003"], ["mechon_i", "Bone_003"],
	["mechon_d", "Bone_003"], ["melena", "Bone_002"]]
## Corte entre las 2 masas del cuerpo (eje radical de los círculos que dibujó): z.
const Z_CUERPO := 0.203

var perfil: Image
var frente: Image
var patas: Dictionary


func _init(patas_de: Dictionary) -> void:
	patas = patas_de
	perfil = _cargar("mascaras_perfil.png")
	frente = _cargar("mascaras_frente.png")


func _cargar(nombre: String) -> Image:
	var img := Image.new()
	img.load_png_from_buffer(FileAccess.get_file_as_bytes(CARPETA + nombre))
	return img


func _bits(img: Image, u: float, v: float) -> int:
	var x := clampi(int(u), 0, img.get_width() - 1)
	var y := clampi(int(v), 0, img.get_height() - 1)
	return int(round(img.get_pixel(x, y).r * 255.0))


func bits_perfil(c: Vector3, dz: float = 0.0) -> int:
	return _bits(perfil, 512.0 + (c.z + dz - CENTRO.z) * PX, 512.0 - (c.y - CENTRO.y) * PX)


func bits_frente(c: Vector3) -> int:
	return _bits(frente, 512.0 + (c.x - CENTRO.x) * PX, 512.0 - (c.y - CENTRO.y) * PX)


static func tiene(bits: int, tabla: Dictionary, nombre: String) -> bool:
	return (bits >> int(tabla[nombre])) & 1 == 1


## Normal del corte en la junta i de una cadena (bisectriz de los 2 tramos).
static func normal_junta(a: Vector3, b: Vector3, c: Vector3) -> Vector3:
	return ((b - a).normalized() + (c - b).normalized()).normalized()


func planos() -> Array:
	var p: Array = [[Vector3.BACK, Vector3(0, 0, Z_CUERPO)]]
	var cola := ["Bone_004", "Bone_005", "Bone_006", "Bone_007"]
	for i in [1, 2]:
		p.append([normal_junta(PUNTOS_V8[cola[i - 1]], PUNTOS_V8[cola[i]], PUNTOS_V8[cola[i + 1]]), PUNTOS_V8[cola[i]]])
	for pata in patas:
		var n: Array = patas[pata]
		for i in [1, 2]:
			p.append([normal_junta(PUNTOS_V8[n[i - 1]], PUNTOS_V8[n[i]], PUNTOS_V8[n[i + 1]]), PUNTOS_V8[n[i]]])
	return p


func _tramo(c: Vector3, n: Array) -> int:
	var t := 0
	for i in [1, 2]:
		if (c - PUNTOS_V8[n[i]]).dot(normal_junta(PUNTOS_V8[n[i - 1]], PUNTOS_V8[n[i]], PUNTOS_V8[n[i + 1]])) > 0.0:
			t = i
	return t


## Pieza (hueso) de un punto de la malla de Meshy.
func pieza_de(c: Vector3) -> String:
	var bp := bits_perfil(c)
	var bf := bits_frente(c)
	# Cola en 3 tramos.
	if tiene(bp, BITS_PERFIL, "cola") and c.z < -0.22:
		return ["Bone_004", "Bone_005", "Bone_006"][_tramo(c, ["Bone_004", "Bone_005", "Bone_006", "Bone_007"])]
	# Cabeza, orejas y mechones de mejilla.
	if tiene(bp, BITS_PERFIL, "cabeza"):
		var lado := "i" if c.x < 0.0 else "d"
		if tiene(bp, BITS_PERFIL, "oreja") and tiene(bf, BITS_FRENTE, "oreja_" + lado):
			return "oreja_" + lado
		if tiene(bp, BITS_PERFIL, "mechon") and tiene(bf, BITS_FRENTE, "mechon_" + lado):
			return "mechon_" + lado
		return "Bone_003"
	var pecho := tiene(bf, BITS_FRENTE, "pecho") and c.z > 0.45
	# Patas delanteras (la lejana, x > 0, se busca en el perfil corrida hacia adelante).
	if c.z > 0.15 and not (pecho and (c.z > 0.62 or absf(c.x) < 0.1)):
		var cerca := c.x < 0.0
		var y_h: float = PUNTOS_V8["Bone_014"].y
		var y_m: float = PUNTOS_V8["Bone_016"].y
		var dz := 0.0 if cerca else 0.18 * clampf((y_h - c.y) / (y_h - y_m), 0.0, 1.0)
		if tiene(bits_perfil(c, dz), BITS_PERFIL, "pata_del") and tiene(bf, BITS_FRENTE, "pata_i" if cerca else "pata_d"):
			var n: Array = patas["dd" if cerca else "di"]
			return n[_tramo(c, n)]
	# Patas traseras (no la panza del centro).
	if c.z < 0.15 and absf(c.x) > 0.1 and tiene(bp, BITS_PERFIL, "pata_tras"):
		var n: Array = patas["ti" if c.x > 0.0 else "td"]
		return n[_tramo(c, n)]
	if pecho:
		return "melena"
	# Cuerpo: grupa o pecho, según el lado del eje radical.
	return "Bone" if c.z < Z_CUERPO else "Bone_002"
