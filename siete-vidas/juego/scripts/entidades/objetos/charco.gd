class_name Charco
extends Node2D
## Un charco suelto en el piso (sin objeto roto encima): el agua que se le sale a A.S.P.I. del tanque al chocar contra
## el enchufe en el apagón, si en el piso no quedó ningún charco de agua o café (siempre hay al menos uno: la clave de
## la fase 3). Se dibuja como el charco de lo que se rompe (Objeto): 3 filas tendidas en el plano del piso, borde oscuro
## y medio claro, sin degradado, y crece en 3 escalones.

const CRECER := 0.45

var ancho := 46.0
var alto := 4
var claro := Color(0.68, 0.84, 0.94)
var oscuro := Color(0.4, 0.6, 0.78)
var _tiempo := 0.0


static func crear(donde: Vector2, ancho_charco := 46.0) -> Charco:
	var charco := Charco.new()
	charco.name = "Charco"
	charco.position = donde
	charco.ancho = ancho_charco
	return charco


func _ready() -> void:
	Capas.usar(self, Capas.JUEGO)


func _process(delta: float) -> void:
	if _tiempo < CRECER + 0.05:
		_tiempo += delta
		queue_redraw()


func _draw() -> void:
	var paso := ceilf(clampf(_tiempo / CRECER, 0.0, 1.0) * 3.0) / 3.0
	var w0 := roundf(ancho * maxf(paso, 0.34))
	for fila in alto:
		var w := roundf(w0 * (0.6 + 0.4 * float(fila + 1) / float(alto)) / 2.0) * 2.0
		var y := float(fila) - 1.0
		draw_rect(Rect2(-w / 2.0, y, w, 1), oscuro)
		if fila < alto - 1 and w > 8.0:
			draw_rect(Rect2(-w / 2.0 + 3.0, y, w - 6.0, 1), claro)
