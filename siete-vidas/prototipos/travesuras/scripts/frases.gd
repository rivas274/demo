# PROTOTIPO: no es código del juego.
# Pregunta: ¿hacer travesuras de gato con la voz de Felipe y una respuesta épica es divertido por sí solo?
# Fecha: 2026-10-18
class_name Frases
extends RefCounted
## La voz de Felipe (sarcasmo aristócrata ofendido) y las réplicas de Valeria.
## Cada frase: [texto, retrato]. Retratos de felipe-retratos.png (3 x 3, de izquierda a derecha):
## 0 de reojo, 1 orejas planas, 2 sorprendido, 3 ojos cerrados, 4 sonrisa leve, 5 asqueado,
## 6 feliz, 7 presumido, 8 bufando. Para Valeria: 0 enojada, 1 derretida, 2 cansada.
## Hay UNA sola frase de internet en toda la sala (la del florero), por la regla del pilar 5.

const FELIPE := {
	"tirar_vaso": [
		["Arte.", 7],
		["La mesa se veía mejor así. De nada.", 4],
		["Yo no lo empujé. Lo liberé.", 0],
		["Física aplicada. Me deben un doctorado.", 7],
	],
	"tirar_florero": [
		["Las flores me estaban mirando raro.", 0],
		["Decoración mejorada. Mi talento no tiene techo.", 7],
		["Ese florero tenía energía de personaje secundario.", 4],
	],
	"tirar_control": [
		["Nadie cambia de canal sin mi permiso.", 0],
		["La tele es para quienes no tienen gato.", 4],
	],
	"patear": [
		["Y no vuelvas.", 0],
		["Sigue en el piso. Como corresponde.", 4],
	],
	"arañar": [
		["No es daño. Es firma de autor.", 7],
		["El sofá estaba demasiado... intacto.", 0],
		["Mantenimiento de garras. Un servicio público.", 4],
	],
	"comer": [
		["Aceptable. Apenas.", 3],
		["Diré que estaba rico solo por educación.", 0],
		["Croquetas. Otra vez. Qué castigo.", 5],
	],
	"plato_vacio": [
		["El plato está vacío. Esto es un escándalo.", 2],
	],
	"snack": [
		["El tributo ha sido aceptado.", 6],
		["Un snack. Lo mínimo para un rey.", 3],
	],
	"maullar": [
		["Anuncio real: tengo hambre. O no. Vengan igual.", 6],
		["Mi voz es un regalo. Úsenla con cuidado.", 3],
		["MIAU. Traducción: atiéndanme.", 0],
	],
	"intimidar": [
		["Mírenme bien. Soy enorme y aterrador.", 8],
		["No me busquen. Ya me encontraron.", 8],
		["Bufido de nivel profesional.", 1],
	],
	"llega_valeria": [
		["Llegó la gerencia.", 2],
		["Yo no fui. Fue la gravedad.", 0],
		["Ah, público.", 4],
	],
	"en_su_cara": [
		["Sí. Delante tuyo. ¿Algún problema?", 7],
		["Mírame bien. Esto es para ti.", 4],
	],
	"perdonado": [
		["Como estaba previsto.", 6],
		["Siete vidas, cero disculpas.", 7],
		["El carisma es un arma. La mía está cargada.", 3],
	],
	"persecucion": [
		["Un rey no corre. Trota con dignidad.", 1],
		["Persecución mediocre. Dos estrellas.", 0],
	],
	"se_fue": [
		["Volverá. Siempre vuelven.", 4],
		["Lo repuso todo. Qué falta de imaginación.", 0],
		["Reabrieron el museo. Hora de otra exposición.", 7],
	],
}

const VALERIA := {
	"llega": [
		["¡FELIPE!", 0],
		["¡FELIPE! ¿¡Otra vez!?", 0],
		["¡FELIPE! ¡Te estoy viendo!", 0],
	],
	"llega_florero": [["¡FELIPE! ¡Mi florero!", 0]],
	"en_su_cara": [
		["¡¿Y ENCIMA EN MI CARA?!", 0],
		["¡FELIPE, NO!", 0],
	],
	"perdona": [
		["Ay... ya, ya. ¿Quién es mi gordito?", 1],
		["No te puedo odiar. Toma, malcriado.", 1],
	],
	"persigue": [
		["¡Ven acá, bandido!", 0],
		["¡No te escondas, te vi!", 0],
	],
	"se_va": [
		["Ash. Gato.", 2],
		["Yo ordeno, tú desordenas. Qué lindo.", 2],
	],
}

var _ultima := {}


## Elige una frase del evento sin repetir la anterior. Devuelve [texto, retrato] o [] si no hay.
func elegir(quien: String, evento: String) -> Array:
	var tabla: Dictionary = FELIPE if quien == "felipe" else VALERIA
	if not tabla.has(evento):
		return []
	var lista: Array = tabla[evento]
	var clave := quien + evento
	var indice := randi() % lista.size()
	if lista.size() > 1 and _ultima.get(clave, -1) == indice:
		indice = (indice + 1 + randi() % (lista.size() - 1)) % lista.size()
	_ultima[clave] = indice
	return lista[indice]
