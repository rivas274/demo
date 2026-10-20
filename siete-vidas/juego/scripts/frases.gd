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
	# Nivel 1 v4 (propuesta, sección 2): una por momento, casi todas salen una sola vez.
	"meta": [["La libertad está allá arriba.", 0]],
	"inicio": [["Día 1 de la dieta. Último día de esta casa.", 0]],
	"cajas": [["Cajas de la mudanza. Llevan un año «ordenándose».", 4]],
	"cajas_arriba": [["Desde aquí arriba, esas cajas se ven… empujables.", 7]],
	"cajas_tiradas": [["Mudanza terminada. De nada.", 7]],
	"tazon": [["Tres croquetas. Esto es un crimen.", 2]],
	"cocina_cerrada": [["Cerrada. Y adentro huele a café.", 1]],
	"balcon_cerrado": [["Cerrada. Esa aspiradora tiene la llave.", 1]],
	"robot": [["Arriba manda el robot. Abajo, la servidumbre.", 0]],
	"robot_registra": [["Ese robot cree que me registra. Yo lo registro a él.", 0]],
	"puerta_abierta": [["Puerta entornada. Invitación aceptada.", 7]],
	"ropa": [["Doblada era aburrida. Ahora tiene pelo de rey.", 7]],
	"pizza": [["Esa pizza es mía. Algún día.", 4]],
	# La puerta del baño (lugar insinuado para la maña futura «Abrir puertas»).
	"bano": [["El trono de porcelana. Algún día será mío.", 4]],
	"bano_manija": [["Esa manija me mira raro.", 1]],
	"laser_visto": [["No. No voy a caer.", 1]],
	"cojin": [["Tiene mi forma. Obviamente.", 7]],
	"cortina": [["Mis garras no están a la altura. Todavía.", 2]],
	"quien_cerro": [["…¿Quién cerró?", 2]],
	"balcon": [["Soy un gato de interior. Mi cardio es mirar por la ventana.", 0]],
	"aterrice": [["No me caí. Aterricé con estilo.", 7]],
	"limpieza": [["Limpieza cancelada.", 7]],
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
	# Nivel 1 v4.
	"vaso": [["¡PIPE! ¡Ese vaso era de mi abuela!", 1]],
	"sofa_atrapado": [["¡Ahí no, bebito, AQUÍ!", 1]],
	"sofa_roto": [["¡El sofá! ¡Lo estoy pagando en 12 cuotas!", 1]],
	"grabando": [["¡Miren! ¡Usa su rascador! #GatoFit #BebitoGordito", 3]],
	"cocina_dieta": [["Voy por un café. Y tú no entras: dieta.", 0]],
	"cocina_abre": [["Ya, entra, pero no hay nada para ti.", 0]],
	"popo": [["¡ACABO DE LIMPIARLA! Voy por bolsas...", 1]],
	"llaves": [["¿Mis llaves? ¿OTRA VEZ?", 1]],
	"cajas": [["¡Mis cajas! ¡Estaban ORDENADAS!", 1]],
	"cajas_audifonos": [["¡¿Qué fue ESO?! …Perdón, era el gato. ¡FELIPE, MIS CAJAS!", 1]],
	"almuerzo": [["¡ESE ERA MI ALMUERZO! Esto va a mis historias.", 1]],
	"audifonos": [["Reunión. Audífonos puestos. Pórtate bien, bebito.", 0]],
	"maullido": [["¿Qué pasa, mi bebito gordito? Dieta, mi amor.", 2]],
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
