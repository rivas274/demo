class_name NotaArteGatuno
extends RefCounted
## La nota de «Arte gatuno» al terminar la pelea con A.S.P.I. (idea de Gemini, 2026-10-23; opcional: se ve, no obliga):
## cuánto del estudio quedó en el piso (lo tirado sobre todo lo que se podía tirar), en 3 rangos. Si pasa del 85 %,
## Valeria lo oye desde abajo («¡¡FELIPE!!») y sale el logro «Reestructuración Inmobiliaria».

## Hasta qué porcentaje vale cada rango (el último, hasta 100) y su clave de texto.
const RANGOS := [[40, "ARTE_GATUNO_AFICIONADO"], [80, "ARTE_GATUNO_DECORADOR"], [100, "ARTE_GATUNO_OBRA_MAESTRA"]]
## Desde cuánto se oye a Valeria y sale el logro.
const GRITO := 85
const LOGRO := "LOGRO_REESTRUCTURACION_INMOBILIARIA"


## Porcentaje de desorden (0 a 100): objetos caídos y cosas soltadas por las fuentes, sobre el total.
static func porcentaje(b: BatallaAspi) -> int:
	var total := 0
	var tirado := 0
	for objeto in b.municion:
		if is_instance_valid(objeto):
			total += 1
			tirado += 1 if objeto.tirable.roto else 0
	for fuente in b.fuentes:
		if is_instance_valid(fuente):
			total += fuente.datos.piezas.size()
			tirado += fuente.usadas
	return int(roundf(100.0 * tirado / maxf(total, 1.0)))


## Lo que dice Felipe según la nota (Frases.FELIPE): se la pasó en grande en todos los casos.
static func frase(por_ciento: int) -> String:
	match rango(por_ciento):
		"ARTE_GATUNO_AFICIONADO":
			return "arte_aficionado"
		"ARTE_GATUNO_OBRA_MAESTRA":
			return "arte_obra"
	return "estudio_destruido"


## Clave del rango (Aficionado, Decorador u O B R A   M A E S T R A).
static func rango(por_ciento: int) -> String:
	for datos: Array in RANGOS:
		if por_ciento <= int(datos[0]):
			return datos[1]
	return RANGOS[-1][1]


## Muestra la nota (cartel de la zona C, sin tapar el diálogo) y, si toca, el grito de Valeria y el logro.
static func mostrar(b: BatallaAspi) -> int:
	var por_ciento := porcentaje(b)
	b.presentacion.cartel(TranslationServer.translate("ARTE_GATUNO_NOTA") % por_ciento, 3.0, rango(por_ciento))
	if por_ciento > GRITO:
		b.nivel.sonar("golpe", 0.7)
		b.nivel.travesuras.decir_valeria("grito_estudio", true)
		b.nivel.desbloquear_logro(LOGRO)
	return por_ciento
