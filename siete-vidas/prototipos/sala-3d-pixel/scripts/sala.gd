# PROTOTIPO: no es código del juego.
# Pregunta: ¿se ve mejor la sala en 3D renderizado como pixel art?
# Fecha: 2026-10-21
# La sala: pared con ventana, piso de madera, sofá, mesita con lámpara encendida.
extends Node3D

const K := "res://assets/kenney/"

# Colores cálidos tomados de la sala del juego.
const PARED := Color("be926c")
const ZOCALO := Color("7c4127")
const PISO := Color("a15e35")
const PISO_LINEA := Color("572c1d")
const MADERA := Color("a15e35")
const MADERA_OSCURA := Color("572c1d")
const SOFA := Color("d98b5e")
const ALFOMBRA := Color("a55534")
const ALFOMBRA_OSCURA := Color("7c4127")
const LATON := Color("c9a066")
const PANTALLA_LAMPARA := Color("f0c38f")
const PLANTA := Color("6e8a3a")
const CIELO := Color("f0a868")
const CIUDAD := Color("905535")
const PERSIANA := Color("ae7857")

@export var energia_lampara := 2.0
@export var alcance_lampara := 2.1
@export var energia_sol := 1.1
@export var energia_relleno := 0.35

## Dónde se sienta Valeria (centro del cojín, en el piso).
var punto_sofa := Vector3(0.4, 0.0, -0.55)
var lampara: OmniLight3D


func _ready() -> void:
	_pared_y_piso()
	_ventana(-2.6, -1.2, 0.95, 2.05)
	_muebles()
	_luces()


func _pared_y_piso() -> void:
	Toon.caja(self, Vector3(12, 0.2, 2.6), Vector3(0, -0.1, 0.1), PISO)
	for z in [-0.85, -0.35, 0.15, 0.65, 1.1]:
		Toon.caja(self, Vector3(12, 0.004, 0.015), Vector3(0, 0.002, z), PISO_LINEA, false)
	var z_pared := -1.275
	Toon.caja(self, Vector3(2.4, 3.5, 0.15), Vector3(-3.8, 1.75, z_pared), PARED)
	Toon.caja(self, Vector3(7.2, 3.5, 0.15), Vector3(2.4, 1.75, z_pared), PARED)
	Toon.caja(self, Vector3(1.4, 0.95, 0.15), Vector3(-1.9, 0.475, z_pared), PARED)
	Toon.caja(self, Vector3(1.4, 1.45, 0.15), Vector3(-1.9, 2.775, z_pared), PARED)
	Toon.caja(self, Vector3(12, 0.1, 0.04), Vector3(0, 0.05, -1.18), ZOCALO)
	# Cuadro en la pared.
	Toon.caja(self, Vector3(0.5, 0.6, 0.04), Vector3(3.3, 1.95, -1.18), LATON)
	Toon.caja(self, Vector3(0.38, 0.48, 0.02), Vector3(3.3, 1.95, -1.155), Color("8d7f73"), false)


func _ventana(x0: float, x1: float, y0: float, y1: float) -> void:
	var cx := (x0 + x1) * 0.5
	var ancho := x1 - x0
	var alto := y1 - y0
	# Cielo de atardecer y siluetas de edificios detrás (no dan sombra).
	var cielo := Toon.caja(self, Vector3(3.0, 2.0, 0.05), Vector3(cx, 1.6, -2.2), CIELO, false, 1.6)
	cielo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for i in 4:
		var e := Toon.caja(self, Vector3(0.35, 0.5 + 0.17 * (i % 3), 0.05),
			Vector3(x0 + 0.1 + i * 0.4, 1.0, -2.1), CIUDAD, false, 0.8)
		e.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Marco grueso y alféizar.
	var g := 0.07
	Toon.caja(self, Vector3(ancho + 2 * g, g, 0.2), Vector3(cx, y1 + g * 0.5, -1.22), MADERA_OSCURA)
	Toon.caja(self, Vector3(ancho + 0.3, 0.06, 0.3), Vector3(cx, y0 - 0.03, -1.15), MADERA_OSCURA)
	Toon.caja(self, Vector3(g, alto, 0.2), Vector3(x0 - g * 0.5, (y0 + y1) * 0.5, -1.22), MADERA_OSCURA)
	Toon.caja(self, Vector3(g, alto, 0.2), Vector3(x1 + g * 0.5, (y0 + y1) * 0.5, -1.22), MADERA_OSCURA)
	Toon.caja(self, Vector3(0.04, alto, 0.06), Vector3(cx, (y0 + y1) * 0.5, -1.25), MADERA_OSCURA, false)
	# Persiana a medio bajar: tablillas que cortan la luz del sol.
	var n := 9
	for i in n:
		var y := y1 - 0.06 - i * 0.065
		Toon.caja(self, Vector3(ancho, 0.035, 0.03), Vector3(cx, y, -1.3), PERSIANA, false)
	# Plantitas en el alféizar.
	Toon.modelo(self, K + "plantSmall1.glb", 0.28, Vector3(x0 + 0.3, y0, -1.12),
		{"plant": PLANTA, "*": MADERA_OSCURA})
	Toon.modelo(self, K + "pottedPlant.glb", 0.32, Vector3(x1 - 0.3, y0, -1.12),
		{"plant": PLANTA, "wood": MADERA, "woodDark": MADERA_OSCURA})


func _muebles() -> void:
	Toon.modelo(self, K + "rugRectangle.glb", 0.0, Vector3(0.4, 0.0, -0.1),
		{"carpet": ALFOMBRA, "carpetDarker": ALFOMBRA_OSCURA}, 0.0, 2.6)
	Toon.modelo(self, K + "loungeSofa.glb", 0.85, Vector3(punto_sofa.x, 0.0, -0.75),
		{"carpet": SOFA, "wood": MADERA_OSCURA}, 0.0)
	var x_mesa := punto_sofa.x - 1.35
	Toon.modelo(self, K + "sideTable.glb", 0.55, Vector3(x_mesa, 0.0, -0.85),
		{"wood": MADERA, "*": MADERA_OSCURA})
	var lamp := Toon.modelo(self, K + "lampRoundTable.glb", 0.48, Vector3(x_mesa, 0.55, -0.85),
		{"metal": LATON, "lamp": PANTALLA_LAMPARA})
	lamp.name = "Lampara"
	Toon.modelo(self, K + "bookcaseOpenLow.glb", 0.9, Vector3(2.5, 0.0, -1.0),
		{"wood": MADERA, "*": MADERA_OSCURA})
	Toon.modelo(self, K + "books.glb", 0.2, Vector3(2.4, 0.9, -1.0),
		{"carpetDarker": ALFOMBRA_OSCURA, "carpetWhite": PANTALLA_LAMPARA, "plant": Color("3f7a74"), "metal": LATON})
	Toon.modelo(self, K + "pottedPlant.glb", 1.0, Vector3(4.0, 0.0, -0.9),
		{"plant": PLANTA, "wood": MADERA, "woodDark": MADERA_OSCURA})
	# Luz de la lámpara: cálida, con sombra; el shader la corta en escalones.
	lampara = OmniLight3D.new()
	lampara.light_color = Color("ffc27a")
	lampara.light_energy = energia_lampara
	lampara.omni_range = alcance_lampara
	lampara.omni_attenuation = 1.2
	lampara.shadow_enabled = true
	lampara.shadow_bias = 0.03
	lampara.position = Vector3(x_mesa + 0.05, 0.55 + 0.30, -0.6)
	add_child(lampara)


func _luces() -> void:
	# Sol de la tarde entrando por la ventana (desde atrás de la pared).
	var sol := DirectionalLight3D.new()
	sol.light_color = Color("ffb36b")
	sol.light_energy = energia_sol
	sol.shadow_enabled = true
	sol.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sol.directional_shadow_max_distance = 12.0
	add_child(sol)
	sol.look_at_from_position(Vector3.ZERO, Vector3(0.35, -0.75, 0.75), Vector3.UP)
	# Relleno suave de frente, sin sombra, para que se lean las formas.
	var relleno := DirectionalLight3D.new()
	relleno.light_color = Color("ffd9a8")
	relleno.light_energy = energia_relleno
	add_child(relleno)
	relleno.look_at_from_position(Vector3.ZERO, Vector3(0.45, -0.5, -1.0), Vector3.UP)
