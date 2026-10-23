class_name DatosEnemigo
extends Resource
## Los números de un enemigo de piso (ratón de cuerda, A.S.P.I.): con esto y las piezas de Enemigo basta para tener uno
## nuevo, sin programar. Cada enemigo es un archivo .tres en `datos/enemigos/` que se edita en el inspector de Godot.

## Nombre del nodo en el nivel (las pruebas lo buscan por él).
@export var nombre := "Enemigo"
@export_group("Dibujo")
## Imagen de assets/nivel1/ (ArteNivel) mirando a la izquierda, y la de vencido ("" = la misma, gris).
@export var arte := ""
@export var arte_vencido := ""
## Px del arte que quedan bajo los pies (la cola del ratón cuelga 7 px bajo el cuerpo: se apoya por el cuerpo, G1).
@export var apoyo := 0.0
## Alto de lo dibujado (los anuncios no lo tapan).
@export var alto_dibujo := 47.0
## Cuántos px más abajo se dibuja que sus pies físicos: anda más adelante en la franja del piso, más cerca de la cámara
## (A.S.P.I., decisión del creador 2026-10-21). Lo que se toca (sombra, daño, el botón de arriba, la marca) lo acompaña.
@export var profundidad := 0.0
## Más cerca de la cámara: se dibuja delante de Felipe en el piso (no cuando Felipe está encima).
@export var delante_de_felipe := false
## Su rol de profundidad (Capas.Rol): los enemigos del piso van siempre delante de los muebles.
@export var rol: Capas.Rol = Capas.Rol.ENEMIGO_PISO
## Juguete de cuerda: vencido queda patas arriba con la llave girando.
@export var llave_de_cuerda := false
## Escena o script de apariencia propia (A.S.P.I. dibuja su tapa y su luz); vacío = Apariencia (la imagen y listo).
@export var apariencia: Script
## Sombra de contacto: ancho en px y opacidad.
@export var sombra := Vector2(44, 0.36)
@export_group("Cuerpo")
## Caja de colisión (choca con el piso y los muebles; con Felipe no: el daño se mide por distancia).
@export var ancho := 48.0
@export var alto := 30.0
@export_group("Vida")
## Zarpazos que aguanta.
@export var golpes := 1
## Solo le duelen los zarpazos mientras está aturdido (algo le cayó encima).
@export var solo_aturdido := false
## Sonido del nivel al vencerlo ("" para ninguno).
@export var sonido_al_vencer := ""
## Frase de Felipe al vencerlo (clave de Frases.FELIPE; "" para ninguna).
@export var frase_al_vencer := ""
## Cómo se viene abajo (destello, vuelo, «¡POP!», cámara lenta y marca; datos/derrotas/). Sin datos, queda donde cayó.
@export var derrota: DatosDerrota
@export_group("Movimiento")
@export var velocidad_patrulla := 40.0
@export var velocidad_persecucion := 80.0
## Distancia a la que ve (y persigue) a Felipe; 0 = nunca persigue.
@export var vision := 170.0
@export_group("Daño")
## Medias huellas que quita al tocar a Felipe (2 = 1 huella; 0 = inofensivo).
@export var dano := 2
## Px de más, a cada lado de su medio ancho, en que alcanza a Felipe.
@export var alcance_dano := 18.0
@export_group("Mañas que le afectan")
## Oye los maullidos (OyeMaullido).
@export var oye_maullido := false
## Se asusta (Asustable, para la maña futura «Intimidar»).
@export var asustable := true
