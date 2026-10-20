class_name Indicador
extends Node2D
## Anuncia la interacción cercana (propuesta v4, sección 5), sin carteles de tutorial:
## - el objeto que usaría el botón de acción gana un contorno cálido de 1 px que sigue la silueta de su arte y late
##   suave (pasada única, 2026-10-19: nunca un rectángulo; el del sofá parecía un recorte pegado);
## - sobre la cabeza de Felipe sale una burbuja con el ícono del botón en uso (teclado o mando) y el verbo de
##   Felipe ("Pasar", "Ascender", "Degustar", "Liberar", "Firmar", "Actuar", "Abrir"...);
## - manteniendo la acción sin nada cerca, la burbuja muestra cómo se carga "Degustar snack".
## Se agrega al mundo (no a la interfaz) y dibuja en coordenadas del mundo.
##
## Lo que un objeto interactuable puede dar (todo opcional):
##   verbo(felipe) -> String              verbo de la burbuja (si no, "Usar")
##   arte_indicador() -> {textura, rect, region?, espejo?}  imagen y rectángulo en el mundo: contorno con la forma del
##                                        dibujo (region: parte de la textura, para hojas de animación; espejo: volteado;
##                                        z: capa del contorno, por defecto detrás de muebles y personajes, así el
##                                        contorno solo se ve donde hay pared o piso detrás y nunca cruza a Valeria)
##   rect_indicador() -> Rect2            zona en el mundo (la usan los anuncios y las pruebas; el Indicador no la dibuja)
##   primera_frase() -> String            línea de Felipe la primera vez (con {acción} para el ícono)

## Primera vez que Felipe se acerca a un objeto con primera_frase(): para el diálogo.
signal primera_vez(objeto: Node2D, frase: String)

## Colores en el tema (Estilo): el contorno es crema cálido y suave (no blanco) y late entre 55 % y 100 % de opacidad.
## Placa del rótulo (crítica de Gemini: la caja se veía genérica): marco de madera de 2 px con canto claro arriba y
## oscuro abajo, contorno casi negro, esquinas recortadas de pixel, filete crema por dentro (el borde del diálogo) y
## sombra dura de 2 px. El interior es el del diálogo, para que todo el texto del juego se lea igual.
## Altura de la burbuja sobre los pies de Felipe (mide 67 px con la cola).
const ALTURA_BURBUJA := 84.0

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
// Sin sombrear: la luz del cuarto (LuzCuarto) no tiñe el contorno.
render_mode unshaded;
uniform vec4 color : source_color = vec4(1.0, 0.97, 0.78, 1.0);
uniform vec2 paso = vec2(0.01, 0.01);
// Parte de la textura que se usa (en UV): en una hoja de animación, el cuadro; así no se cuela el vecino.
uniform vec4 limites = vec4(0.0, 0.0, 1.0, 1.0);
float dentro(vec2 uv) {
	return step(limites.x, uv.x) * step(limites.y, uv.y) * step(uv.x, limites.z) * step(uv.y, limites.w);
}
void fragment() {
	vec2 dx = vec2(paso.x, 0.0);
	vec2 dy = vec2(0.0, paso.y);
	float a = texture(TEXTURE, UV).a * dentro(UV);
	float v = max(max(texture(TEXTURE, UV + dx).a * dentro(UV + dx), texture(TEXTURE, UV - dx).a * dentro(UV - dx)),
		max(texture(TEXTURE, UV + dy).a * dentro(UV + dy), texture(TEXTURE, UV - dy).a * dentro(UV - dy)));
	COLOR = (a < 0.5 && v > 0.5) ? color : vec4(0.0);
}
"""


func _ready() -> void:
	name = "Indicador"
	z_index = Capas.INDICADOR
	add_to_group(PresentacionJefe.GRUPO_OCULTAR)
	top_level = true
	global_position = Vector2.ZERO
	_material = ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = SHADER
	_material.shader = shader
	_material.set_shader_parameter("color", Estilo.color(&"indicador_contorno"))
	_contorno = Node2D.new()
	_contorno.name = "Contorno"
	_contorno.z_as_relative = false
	_contorno.z_index = Capas.ARTE_PARED
	_contorno.material = _material
	_contorno.draw.connect(_dibujar_contorno)
	add_child(_contorno)


## La presentación de un jefe lo esconde (M4): ni contorno ni burbuja durante la entrada.
func al_presentar_jefe(presentando: bool) -> void:
	visible = not presentando


func _input(evento: InputEvent) -> void:
	IconosBotones.registrar_evento(evento)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(objeto):
		objeto = null
	var nuevo: Node2D = null
	if felipe and _puede_mostrar():
		nuevo = felipe.objeto_cercano()
	if nuevo != objeto:
		objeto = nuevo
		_aparecer = 0.0
		if objeto and objeto.has_method("primera_frase") and not _vistos.has(objeto.get_instance_id()):
			_vistos[objeto.get_instance_id()] = true
			var frase := tr(String(objeto.call("primera_frase")))
			if frase != "":
				primera_vez.emit(objeto, frase)
		if objeto and tiene_arte(objeto):
			_contorno.z_index = int((objeto.call("arte_indicador") as Dictionary).get("z", Capas.ARTE_PARED))
	verbo = ""
	if objeto:
		verbo = tr(String(objeto.call("verbo", felipe))) if objeto.has_method("verbo") else tr("VERBO_USAR")
	elif felipe and felipe.progreso_comer_snack() > 0.0:
		verbo = tr("VERBO_DEGUSTAR_SNACK")
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
			var region: Rect2 = arte.get("region", Rect2(Vector2.ZERO, tam))
			_material.set_shader_parameter("paso", Vector2(1.0 / tam.x, 1.0 / tam.y))
			_material.set_shader_parameter("limites", Vector4(region.position.x / tam.x, region.position.y / tam.y, region.end.x / tam.x, region.end.y / tam.y))
			# Late suave (no parpadea): de 55 % a 100 %.
			var pulso := 0.775 + 0.225 * sin(Time.get_ticks_msec() / 1000.0 * 4.0)
			_material.set_shader_parameter("color", Estilo.color(&"indicador_contorno", pulso * _aparecer))
			if arte.get("espejo", false):
				_contorno.draw_set_transform(Vector2(rect.get_center().x * 2.0, 0.0), 0.0, Vector2(-1, 1))
			# Un píxel más por lado para que el contorno quepa fuera del dibujo.
			_contorno.draw_texture_rect_region(textura, rect.grow(1.0), Rect2(region.position - Vector2(1, 1), region.size + Vector2(2, 2)))
			_contorno.draw_set_transform(Vector2.ZERO)


func _dibujar_placa(caja: Rect2, punta: Vector2) -> void:
	var marco := caja.grow(2.0)
	var fuera := marco.grow(1.0)
	# Sombra dura (abajo a la derecha), con el piquito.
	_rect_recortado(Rect2(fuera.position + Vector2(2, 2), fuera.size), Estilo.color(&"indicador_sombra"))
	draw_colored_polygon(PackedVector2Array([punta + Vector2(-3, 4), punta + Vector2(7, 4), punta + Vector2(2, 9)]), Estilo.color(&"indicador_sombra"))
	# Contorno y marco de madera con esquinas recortadas.
	_rect_recortado(fuera, Estilo.color(&"indicador_trazo"))
	draw_rect(marco, Estilo.color(&"madera"))
	draw_rect(Rect2(marco.position, Vector2(marco.size.x, 1)), Estilo.color(&"madera_clara"))
	draw_rect(Rect2(marco.position.x, marco.end.y - 1, marco.size.x, 1), Estilo.color(&"madera_oscura"))
	# Piquito de madera hacia Felipe, con su contorno.
	draw_colored_polygon(PackedVector2Array([punta + Vector2(-6, 1), punta + Vector2(6, 1), punta + Vector2(0, 7)]), Estilo.color(&"indicador_trazo"))
	draw_colored_polygon(PackedVector2Array([punta + Vector2(-4, 1), punta + Vector2(4, 1), punta + Vector2(0, 5)]), Estilo.color(&"madera"))
	# Interior del diálogo y filete crema.
	draw_rect(caja, Estilo.color(&"indicador_fondo", 1.0))
	draw_rect(Rect2(caja.position + Vector2(0.5, 0.5), caja.size - Vector2(1, 1)), Estilo.color(&"borde_dorado", 0.55), false, 1.0)
	# Clavitos de bronce en las esquinas del marco.
	for esquina: Vector2 in [marco.position + Vector2(1, 1), Vector2(marco.end.x - 2, marco.position.y + 1)]:
		draw_rect(Rect2(esquina, Vector2(1, 1)), Estilo.color(&"indicador_clavo"))


## Rectángulo con las cuatro esquinas recortadas un pixel (borde de pixel art, no una caja de interfaz lisa).
func _rect_recortado(r: Rect2, color: Color) -> void:
	draw_rect(Rect2(r.position.x + 1, r.position.y, r.size.x - 2, r.size.y), color)
	draw_rect(Rect2(r.position.x, r.position.y + 1, 1, r.size.y - 2), color)
	draw_rect(Rect2(r.end.x - 1, r.position.y + 1, 1, r.size.y - 2), color)


## ¿El objeto da su imagen para un contorno con forma? Si no, no hay contorno (solo la burbuja): nunca un rectángulo.
func tiene_arte(cosa: Node2D) -> bool:
	return cosa.has_method("arte_indicador") and not (cosa.call("arte_indicador") as Dictionary).is_empty()


func _draw() -> void:
	if verbo == "" or felipe == null:
		return
	var accion := "interactuar"
	var ancho_icono := IconosBotones.ancho(accion, 14.0)
	var ancho_texto := Estilo.ancho(verbo, &"indicador")
	var tam := Vector2(ancho_icono + ancho_texto + 12.0, 20.0)
	var centro := (felipe.global_position + Vector2(0, -ALTURA_BURBUJA)).round()
	# Aparece con un saltito (entero, para no emborronar los píxeles).
	centro.y += roundf((1.0 - _aparecer) * 4.0)
	var caja := Rect2((centro - tam / 2.0).round(), tam)
	_dibujar_placa(caja, Vector2(centro.x, caja.end.y))
	IconosBotones.dibujar(self, accion, caja.position + Vector2(4, 3), 14.0)
	# Texto con sombra dura de 1 px, como el del diálogo y la libreta (misma letra).
	Estilo.escribir(self, caja.position + Vector2(ancho_icono + 9.0, 15.0), verbo, &"indicador", Estilo.color(&"indicador_sombra_texto"))
	Estilo.escribir(self, caja.position + Vector2(ancho_icono + 8.0, 14.0), verbo, &"indicador", Estilo.color(&"texto_claro"))
	var progreso := felipe.progreso_comer_snack()
	if progreso > 0.0 and objeto == null:
		draw_rect(Rect2(caja.position + Vector2(2, tam.y - 3), Vector2((tam.x - 4) * progreso, 2)), Estilo.color(&"indicador_verbo"))
