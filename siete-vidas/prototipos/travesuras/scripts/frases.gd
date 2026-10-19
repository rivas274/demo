# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
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
	"recoger_calcetin": [
		["Un calcetín. Mío ahora. Así funcionan las cosas.", 7],
		["Otro calcetín para la colección real.", 4],
		["Huele a pie humano. Perfecto.", 6],
	],
	"recoger_snack": [
		["Lo guardo. Un rey planifica.", 3],
		["Snack confiscado.", 7],
	],
	"recoger_foto": [
		["Valeria en pijama de unicornio. Esto vale oro.", 6],
	],
	"tele": [
		["Su serie. Qué conveniente.", 0],
		["Ah, la serie. Y el control tan cerca del borde...", 4],
	],
	"persiana": [
		["¡La persiana! El control también sirve para algo.", 2],
	],
	"rascador_publico": [
		["Función de gala. Se aceptan aplausos y snacks.", 7],
		["Ovación de pie. Bueno, de sofá. Igual cuenta.", 6],
		["Lo uso cuando miran. Eso se llama talento.", 4],
	],
	"rascador_solo": [
		["¿Para quién actúo?", 1],
		["Sin público no hay función.", 0],
		["Arte desperdiciado. Nadie miró.", 5],
		["Esto no cuenta si nadie lo ve.", 0],
	],
	"rascador_bis": [
		["El bis no se cobra. Qué público más tacaño.", 5],
	],
	"garras_afiladas": [
		["Afiladas. El sofá no sabe lo que viene.", 7],
	],
	"recoger_foto_rascador": [
		["Valeria arañando el rascador \"para enseñarme\". Chantaje asegurado.", 6],
	],
	"agenda_completa": [
		["Agenda completa. Hoy fui un genio. Como ayer.", 7],
	],
	"se_fue": [
		["Volverá. Siempre vuelven.", 4],
		["Lo repuso todo. Qué falta de imaginación.", 0],
		["Reabrieron el museo. Hora de otra exposición.", 7],
	],
}

## Voz de Valeria (biblia): teletrabaja, sube todo a redes, lo ama de verdad y le habla como a un bebé
## ("Pipe"). El chiste es el contraste: él se cree un dios y ella lo trata de bebito gordito; el enojo
## se le pasa en cuanto piensa en sus seguidores.
const VALERIA := {
	"llega": [
		["¡PIPE! Estoy en una reunión...", 0],
		["Felipe Ron con Pasas Primero. Nombre completo. Estás en problemas.", 0],
		["Dime que no es lo que creo... Es lo que creo.", 2],
	],
	"llega_florero": [["¡El florero de mi abuela! Sobrevivió a dos mudanzas, Pipe. DOS.", 0]],
	"en_su_cara": [
		["¿Mirándome a los ojos? ¿EN SERIO?", 0],
		["Esto es personal. Yo lo sé. Tú lo sabes.", 0],
	],
	"perdona": [
		["Ay, no, esa carita... ¿Quién es el bebito más gordito? ¡TÚ!", 1],
		["Ya, ya. Te perdono porque tengo que subirte a mis historias.", 1],
		["No puedo enojarme con esos cachetes. Toma, chantajista.", 1],
	],
	"persigue": [
		["¡Bájate de ahí, bandido!", 0],
		["¡Pipe! ¡No me hagas subirme a una silla!", 0],
	],
	"tele": [
		["Me lo merezco. Un capítulo. Uno.", 2],
		["Si te portas bien, sales en mi próximo post.", 1],
	],
	"interrumpida": [
		["¡NO! ¡Justo cuando se iban a besar!", 0],
		["¡Pipe! ¡Ahora no sé en qué capítulo iba!", 0],
	],
	"golpeada": [
		["Acabo de lavarme el pelo. ACABO.", 0],
		["Respira, Valeria. Es un gato. Es TU gato.", 2],
	],
	"persiana": [["¿Quién subió la...? Pipe, ¿desde cuándo tienes pulgares?", 2]],
	"se_va": [
		["Me voy antes de decir algo de lo que me arrepienta.", 2],
		["Te voy a hacer un post. Y no te va a gustar.", 2],
		["Mis seguidores se van a reír. Yo no.", 2],
	],
	## Rascador con público: perdón al instante.
	"rascador": [
		["¡Mira, sí lo usa! ¡Valió cada centavo!", 1],
		["¡Lo está usando! ¿Alguien está grabando? Ah, sí, yo.", 1],
	],
	## Rascador otra vez en la misma visita (el bis no se cobra).
	"rascador_bis": [["Sí, mi amor, ya te vi. Muy lindo. Igual no hay más snacks.", 2]],
	## Secreta: le araña el sofá al lado del rascador, delante de ella.
	"junto_rascador": [["¡Pipe! ¡El rascador está AHÍ! ¡A diez centímetros!", 0]],
	## Celular y flash (perdón o algo muy gracioso).
	"historias": [["Esto va directo a mis historias.", 1]],
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
