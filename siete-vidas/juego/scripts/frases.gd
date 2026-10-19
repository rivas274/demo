class_name Frases
extends RefCounted
## La voz de Felipe (aristócrata ofendido que aprendió a escribir en los comentarios de internet) y las réplicas
## de Valeria (lo trata de bebito gordito y vive para sus redes). Del prototipo de travesuras aprobado.
## Cada frase: [texto, ánimo del retrato] (ver Dialogo.PERSONAJES). Todas caben en 1 o 2 líneas (la prueba lo mide).

const FELIPE := {
	"tirar": [
		["Arte.", 7],
		["La mesa se veía mejor así. De nada.", 4],
		["Yo no lo empujé. Lo liberé.", 0],
		["Física aplicada. Me deben un doctorado.", 7],
	],
	"aranar": [
		["No es daño. Es firma de autor.", 7],
		["Mantenimiento de garras. Un servicio público.", 4],
		["Estaba demasiado... intacto.", 0],
	],
	"aranar_critico": [
		["Afiladas y certeras. Como mis opiniones.", 7],
	],
	"comer": [
		["Aceptable. Apenas.", 3],
		["Diré que estaba rico solo por educación.", 0],
	],
	"snack": [
		["El tributo ha sido aceptado.", 6],
		["Un snack. Lo mínimo para un rey.", 3],
	],
	"sin_snacks": [
		["El bolsillo está vacío. Esto es un escándalo.", 2],
		["Cero snacks. Exijo hablar con la gerencia.", 1],
	],
	"bolsillo_lleno": [
		["Cinco snacks. Ni un rey carga más.", 0],
	],
	"maullar": [
		["MIAU. Traducción: atiéndanme.", 0],
		["Mi voz es un regalo. Úsenla con cuidado.", 3],
		["Anuncio real: vengan. Ahora.", 6],
	],
	"recoger_calcetin": [
		["Un calcetín. Mío ahora. Así funcionan las cosas.", 7],
		["Otro calcetín para el nido real.", 4],
		["Huele a pie humano. Perfecto.", 6],
	],
	"recoger_snack": [
		["Lo guardo. Un rey planifica.", 3],
		["Snack confiscado.", 7],
	],
	"recoger_foto": [
		["Una foto vergonzosa. Esto vale oro.", 6],
	],
	"rascador_publico": [
		["Función de gala. Se aceptan aplausos y snacks.", 7],
		["Lo uso cuando miran. Eso se llama talento.", 4],
	],
	"rascador_solo": [
		["¿Para quién actúo?", 1],
		["Sin público no hay función.", 0],
		["Arte desperdiciado. Nadie miró.", 5],
	],
	"rascador_bis": [
		["El bis no se cobra. Qué público más tacaño.", 5],
	],
	"garras_afiladas": [
		["Afiladas. El sofá no sabe lo que viene.", 7],
	],
	"ranura": [
		["Diez calcetines. El nido me concede una maña más.", 7],
	],
	"agenda_completa": [
		["Agenda completa. Hoy fui un genio. Como ayer.", 7],
	],
}

const VALERIA := {
	## Rascador con público: perdón al instante (y graba).
	"rascador": [
		["¡Mira, sí lo usa! ¡Valió cada centavo!", 3],
		["¡Lo está usando! ¿Alguien está grabando? Ah, sí, yo.", 3],
	],
	## Rascador otra vez en la misma visita (el bis no se cobra).
	"rascador_bis": [["Sí, mi amor, ya te vi. Muy lindo. Igual no hay más snacks.", 0]],
	"perdona": [
		["Ay, no, esa carita... ¿Quién es el bebito más gordito? ¡TÚ!", 2],
		["Ya, ya. Te perdono porque tengo que subirte a mis historias.", 2],
	],
	"regana": [
		["¡PIPE! Estoy en una reunión...", 1],
		["Felipe Ron con Pasas Primero. Nombre completo. Estás en problemas.", 1],
	],
}

var _ultima := {}


## Elige una frase del evento sin repetir la anterior. Devuelve [texto, ánimo] o [] si no hay.
func elegir(quien: String, evento: String) -> Array:
	var tabla: Dictionary = FELIPE if quien == "felipe" else VALERIA
	if not tabla.has(evento):
		return []
	var lista: Array = tabla[evento]
	var clave := quien + ":" + evento
	var indice := randi() % lista.size()
	if lista.size() > 1 and _ultima.get(clave, -1) == indice:
		indice = (indice + 1 + randi() % (lista.size() - 1)) % lista.size()
	_ultima[clave] = indice
	return lista[indice]
