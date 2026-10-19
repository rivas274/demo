class_name Indicador
extends Node2D
## Anuncia la interacción cercana (propuesta v4, sección 5), sin carteles de tutorial:
## - el objeto que usaría el botón de acción gana un contorno claro de 1 px;
## - sobre la cabeza de Felipe sale una burbuja con el ícono del botón en uso (teclado o mando) y el verbo de
##   Felipe ("Pasar", "Ascender", "Degustar", "Liberar", "Firmar", "Actuar", "Abrir"...);
## - manteniendo la acción sin nada cerca, la burbuja muestra cómo se carga "Degustar snack".
## Se agrega al mundo (no a la interfaz) y dibuja en coordenadas del mundo.
##
## Lo que un objeto interactuable puede dar (todo opcional):
##   verbo(felipe) -> String              verbo de la burbuja (si no, "Usar")
##   arte_indicador() -> {textura, rect}  imagen y rectángulo en el mundo: contorno con la forma del dibujo
##   rect_indicador() -> Rect2            rectángulo en el mundo: contorno rectangular
##   primera_frase() -> String            línea de Felipe la primera vez (con {acción} para el ícono)

## Primera vez que Felipe se acerca a un objeto con primera_frase(): para el diálogo.
signal primera_vez(objeto: Node2D, frase: String)

const COLOR_CONTORNO := Color(1.0, 0.97, 0.78)
const FONDO := Color(0.13, 0.09, 0.12, 0.9)
const BORDE := Color(0.95, 0.85, 0.6)
const TEXTO := Color(1, 0.97, 0.92)
## Altura de la burbuja sobre los pies de Felipe (mide 67 px con la cola).
const ALTURA_BURBUJA := 84.0
const TAM_LETRA := 10

var felipe: Felipe
## Objeto que se está anunciando (null si no hay).
var objeto: Node2D
## Verbo que se muestra ("" si no hay burbuja).
var verbo := ""
var _vistos := {}
var _contorno: Node2D
var _material: ShaderMaterial
var _aparecer := 0.0

const SHADER := """
shader_type canvas_item;
uniform vec4 color : source_color = vec4(1.0, 0.97, 0.78, 1.0);
uniform vec2 paso = vec2(0.01, 0.01);
float alfa(vec2 uv) {
	if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) { return 0.0; }
	return texture(TEXTURE, uv).a;
}
void fragment() {
	float a = alfa(UV);
	float v = max(max(alfa(UV + vec2(paso.x, 0.0)), alfa(UV - vec2(paso.x, 0.0))),
		max(alfa(UV + vec2(0.0, paso.y)), alfa(UV - vec2(0.0, paso.y))));
	COLOR = (a < 0.5 && v > 0.5) ? color : vec4(0.0);
}
"""


func _ready() -> void:
	name = "Indicador"
	z_index = 50
	top_level = true
	global_position = Vector2.ZERO
	_material = ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = SHADER
	_material.shader = shader
	_material.set_shader_parameter("color", COLOR_CONTORNO)
	_contorno = Node2D.new()
	_contorno.name = "Contorno"
	_contorno.material = _material
	_contorno.draw.connect(_dibujar_contorno)
	add_child(_contorno)


func _input(evento: InputEvent) -> void:
	IconosBotones.registrar_evento(evento)


func _physics_process(delta: float) -> void:
	var nuevo: Node2D = null
	if felipe and _puede_mostrar():
		nuevo = felipe.objeto_cercano()
	if nuevo != objeto:
		objeto = nuevo
		_aparecer = 0.0
		if objeto and objeto.has_method("primera_frase") and not _vistos.has(objeto.get_instance_id()):
			_vistos[objeto.get_instance_id()] = true
			var frase := String(objeto.call("primera_frase"))
			if frase != "":
				primera_vez.emit(objeto, frase)
	verbo = ""
	if objeto:
		verbo = String(objeto.call("verbo", felipe)) if objeto.has_method("verbo") else "Usar"
	elif felipe and felipe.progreso_comer_snack() > 0.0:
		verbo = "Degustar snack"
	_aparecer = minf(1.0, _aparecer + delta * 8.0)
	queue_redraw()
	_contorno.queue_redraw()


## Solo cuando Felipe podría usar el botón: en el piso, de pie y sin estar haciendo otra cosa.
func _puede_mostrar() -> bool:
	return felipe.is_on_floor() and not felipe.agachado and felipe.estado in [Felipe.Estado.SUELO, Felipe.Estado.ATERRIZANDO]


func _dibujar_contorno() -> void:
	if not is_instance_valid(objeto):
		return
	if objeto.has_method("arte_indicador"):
		var arte: Dictionary = objeto.call("arte_indicador")
		if not arte.is_empty():
			var textura: Texture2D = arte["textura"]
			var rect: Rect2 = arte["rect"]
			var tam := textura.get_size()
			_material.set_shader_parameter("paso", Vector2(1.0 / tam.x, 1.0 / tam.y))
			# Un píxel más por lado para que el contorno quepa fuera del dibujo.
			_contorno.draw_texture_rect_region(textura, rect.grow(1.0), Rect2(Vector2(-1, -1), tam + Vector2(2, 2)))


## ¿El objeto da su imagen para un contorno con forma? Si no, el contorno es un rectángulo.
func _tiene_arte(cosa: Node2D) -> bool:
	return cosa.has_method("arte_indicador") and not (cosa.call("arte_indicador") as Dictionary).is_empty()


func _rect_simple(cosa: Node2D) -> Rect2:
	if cosa.has_method("rect_indicador"):
		return cosa.call("rect_indicador")
	return Rect2(cosa.global_position + Vector2(-14, -28), Vector2(28, 28))


func _draw() -> void:
	if is_instance_valid(objeto) and not _tiene_arte(objeto):
		var marco := _rect_simple(objeto).grow(1.0)
		draw_rect(Rect2(marco.position.round() + Vector2(0.5, 0.5), marco.size.round()), COLOR_CONTORNO, false, 1.0)
	if verbo == "" or felipe == null:
		return
	var fuente := ThemeDB.fallback_font
	var accion := "interactuar"
	var ancho_icono := IconosBotones.ancho(accion, 14.0)
	var ancho_texto := fuente.get_string_size(verbo, HORIZONTAL_ALIGNMENT_LEFT, -1, TAM_LETRA).x
	var tam := Vector2(ancho_icono + ancho_texto + 12.0, 20.0)
	var centro := (felipe.global_position + Vector2(0, -ALTURA_BURBUJA)).round()
	# Aparece con un saltito (entero, para no emborronar los píxeles).
	centro.y += roundf((1.0 - _aparecer) * 4.0)
	var caja := Rect2((centro - tam / 2.0).round(), tam)
	draw_rect(caja.grow(1.0), BORDE)
	draw_rect(caja, FONDO)
	# Piquito hacia Felipe.
	var punta := Vector2(centro.x, caja.end.y)
	draw_colored_polygon(PackedVector2Array([punta + Vector2(-4, 0), punta + Vector2(4, 0), punta + Vector2(0, 4)]), BORDE)
	IconosBotones.dibujar(self, accion, caja.position + Vector2(4, 3), 14.0)
	draw_string(fuente, caja.position + Vector2(ancho_icono + 8.0, 14.0), verbo, HORIZONTAL_ALIGNMENT_LEFT, -1, TAM_LETRA, TEXTO)
	var progreso := felipe.progreso_comer_snack()
	if progreso > 0.0 and objeto == null:
		draw_rect(Rect2(caja.position + Vector2(2, tam.y - 3), Vector2((tam.x - 4) * progreso, 2)), Color(1.0, 0.75, 0.35))
