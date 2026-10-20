class_name DatosNivel
extends Resource
## Lo que el constructor de niveles (Nivel) necesita saber de un nivel para armarlo: cuartos, piezas sólidas, puertas,
## escalera de fondo, primeras frases, descansos y la meta. No tiene lógica de juego: son datos. Cada nivel los llena
## desde sus constantes (por ejemplo, Nivel1.datos() en scripts/niveles/nivel_1/nivel_1.gd).

## Geometría: techo, línea de apoyo del piso (los pies), borde de abajo de la pantalla y ancho total.
var techo := 24.0
var suelo := 448.0
var alto := 478.0
var ancho := 640.0
## Cuartos en orden de ruta: [rectángulo, nombre, estilo de pared].
var habitaciones: Array = []
## Orden de la ruta (las reglas de diseño la usan).
var ruta: Array = []
## Piezas sólidas: [rectángulo, se atraviesa desde abajo, nombre, estilo ("invisible", "arte", "repisa", "lugar_visto"),
## imagen con la que calza].
var piezas: Array = []
## Lo que va encima de una repisa dibujada: nombre de la pieza -> imagen (la caja de recuerdos del lugar visto).
var adornos_de_piezas := {}
## Puertas, de a pares: [nombre, pie (al centro), puerta a la que lleva].
var puertas: Array = []
## Caras que empiezan cerradas o entornadas (las dos caras de un par se ven igual), y las que dejan ver sombra detrás.
var puertas_cerradas: Array = []
var puertas_entornadas: Array = []
var puertas_con_sombra_detras: Array = []
## Puertas-ventana (estilo "balcon").
var puertas_balcon: Array = []
## Escalera de fondo: la cara al pie (se sube escalón por escalón), los pies en cada peldaño, el pie y la cima.
var puerta_escalera := ""
var peldanos: Array[Vector2] = []
var escalera_pie := Vector2.ZERO
var escalera_cima := Vector2.ZERO
## Primeras frases de Felipe: [zona, línea con {acción}, ánimo del retrato]. Salen una vez.
var lecciones: Array = []
## Puntos de descanso (caja de arena, cojín): ahí reaparece Felipe si pierde una vida.
var descansos: Array = []
## Snacks hasta los que rellena el bolsillo un punto de descanso al llegar (decisión del creador, 2026-10-20).
var snacks_en_descanso := 3
## La meta que la cámara muestra al empezar (R4): cuarto y rótulo.
var cuarto_meta := ""
var rotulo_meta := ""
## La Agenda de Su Majestad del nivel (Agenda.NIVEL_1...).
var agenda: Array = []


## Nombre del cuarto que contiene el punto, mirando un píxel arriba para que el piso cuente ("" si está fuera).
static func buscar_habitacion(cuartos: Array, punto: Vector2) -> String:
	for habitacion: Array in cuartos:
		if (habitacion[0] as Rect2).has_point(punto - Vector2(0, 1)):
			return habitacion[1]
	return ""


## Rectángulo del cuarto con ese nombre.
static func buscar_rect(cuartos: Array, nombre: String) -> Rect2:
	for habitacion: Array in cuartos:
		if habitacion[1] == nombre:
			return habitacion[0]
	return Rect2()


func habitacion_de(punto: Vector2) -> String:
	return DatosNivel.buscar_habitacion(habitaciones, punto)


func rect_de(nombre: String) -> Rect2:
	return DatosNivel.buscar_rect(habitaciones, nombre)


## Estilo de marco de una puerta: "balcon" (puerta-ventana), "vano" (hueco sin hoja, la escalera de fondo) o "" (puerta
## de madera). Las dos caras de un par usan el mismo.
func estilo_puerta(nombre: String) -> String:
	for datos: Array in puertas:
		if datos[0] == nombre:
			var caras := [datos[0], datos[2]]
			for balcon: String in puertas_balcon:
				if balcon in caras:
					return "balcon"
			if puerta_escalera in caras:
				return "vano"
	return ""
