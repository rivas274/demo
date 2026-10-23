class_name AyudaAspi
extends Node2D
## Instrucciones sin texto en la pelea con A.S.P.I. (v4; Gemini y ChatGPT: los subtítulos de los carteles parecían un
## examen). En vez de «Si te aspira, mantén [S]» o «[M] la atrae», el ícono del botón aparece sobre Felipe justo
## cuando sirve, y **solo la primera vez**:
## - **Agacharse:** mientras la succión lo arrastra de pie (ícono del botón y una flecha hacia abajo).
## - **Maullar:** en el apagón, con Felipe en el piso cerca de un charco y A.S.P.I. libre (ícono y ondas de sonido).
## Se va cuando Felipe lo hace (o a los `DURA` s). Va entre la cabeza de Felipe y su globito, sin sombrear (se lee en
## el apagón). Pieza de BatallaAspi.

## Altura del ícono sobre los pies de Felipe (Felipe mide 67 px; su globito empieza a 104).
const ALTURA := 86.0
const ALTO_ICONO := 16.0
## Segundos como mucho que se muestra cada ícono.
const DURA := 4.0
## Segundos a la vista para darlo por leído si deja de servir antes.
const VISTO := 1.5
## Distancia (px) a un charco para sugerir el maullido.
const CERCA_CHARCO := 110.0

var b: BatallaAspi
## Qué ícono se ve ahora ("" = ninguno) y cuáles ya se mostraron (no vuelven).
var accion := ""
var vistos: Array[String] = []
var _reloj := 0.0


func _init(de: BatallaAspi) -> void:
	name = "Ayuda sin texto"
	b = de


func _ready() -> void:
	Capas.usar(self, Capas.EFECTOS)
	material = b.sin_sombrear


func _process(delta: float) -> void:
	var antes := accion
	if accion != "":
		_reloj += delta
		if _hecho(accion) or _reloj >= DURA:
			vistos.append(accion)
			accion = ""
		elif not _sirve(accion):
			# Dejó de servir: se va; solo cuenta como visto si alcanzó a leerse (VISTO s).
			if _reloj >= VISTO:
				vistos.append(accion)
			accion = ""
	if accion == "" and b.fase == PeleaJefe.Fase.PELEA and not b.ausente:
		for posible: String in ["agacharse", "maullar"]:
			if not posible in vistos and _sirve(posible):
				accion = posible
				_reloj = 0.0
				break
	if accion != "" or antes != "":
		queue_redraw()


## ¿Ahora sirve ese botón?
func _sirve(que: String) -> bool:
	var felipe := b.felipe
	match que:
		"agacharse":
			return b.succionando and felipe.empuje != Vector2.ZERO
		"maullar":
			var corto := b.conducta("cortocircuito") as ConductaCortocircuito
			if corto == null or not b.apagon.activo or b.apagon.parpadeando() or b.llena or not felipe.is_on_floor():
				return false
			for charco in corto.charcos():
				if absf(felipe.global_position.x - charco.x) < CERCA_CHARCO:
					return true
	return false


## ¿Felipe ya lo hizo?
func _hecho(que: String) -> bool:
	match que:
		"agacharse":
			return b.felipe.agachado
		"maullar":
			return b.felipe.estado == Felipe.Estado.MAULLANDO
	return false


func _draw() -> void:
	if accion == "" or not is_instance_valid(b.felipe):
		return
	var ancho := IconosBotones.ancho(accion, ALTO_ICONO)
	var pies := b.felipe.global_position
	# Sube y baja 1 px (llama la atención sin moverse de lugar).
	var salto := -1.0 if int(_reloj * 4.0) % 2 == 0 else 0.0
	var esquina := (pies + Vector2(-ancho / 2.0 - 5.0, -ALTURA + salto)).round()
	# Fondo oscuro de 1 px alrededor para que se lea sobre cualquier fondo.
	draw_rect(Rect2(esquina - Vector2(2, 2), Vector2(ancho + 14.0, ALTO_ICONO + 4.0)), Color(0.08, 0.06, 0.1, 0.85))
	IconosBotones.dibujar(self, accion, esquina, ALTO_ICONO)
	var color := Estilo.color(&"oportunidad")
	var signo := esquina + Vector2(ancho + 3.0, 0.0)
	if accion == "agacharse":
		# Flecha hacia abajo.
		draw_rect(Rect2(signo + Vector2(2, 2), Vector2(2, 7)), color)
		draw_colored_polygon(PackedVector2Array([signo + Vector2(-1, 9), signo + Vector2(7, 9), signo + Vector2(3, 14)]), color)
	else:
		# Ondas de sonido: tres rayitas que crecen.
		for i in 3:
			var alto := 4.0 + i * 3.0
			draw_rect(Rect2(signo + Vector2(i * 3.0, 8.0 - alto / 2.0), Vector2(1, alto)), color)
