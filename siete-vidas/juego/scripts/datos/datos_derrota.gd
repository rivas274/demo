class_name DatosDerrota
extends Resource
## Cómo se viene abajo un enemigo al vencerlo (derrotas jugosas, decisión del creador 2026-10-20), en 5 pasos:
## destello y congelado, salir volando, «¡POP!», cámara lenta (solo si se pide) y una marca que queda. Anti-pilar: nada
## sufre ni sangra; son juguetes y máquinas que se desarman con gracia. Lo usa la pieza ReaccionDerrota; cada enemigo
## trae su .tres en `datos/derrotas/` (DatosEnemigo.derrota). Las imágenes son nombres de assets/nivel1/ (ArteNivel);
## si falta una, PiezaSuelta dibuja un provisional de pixel con ese nombre.

@export_group("1. Destello y congelado")
## Segundos (reales) que la silueta se pone blanca.
@export var destello := 0.08
## Destello de toda la pantalla (0 = ninguno, 1 = blanco entero).
@export var destello_pantalla := 0.0
## Congelado del juego (Jugo.congelar), en segundos reales.
@export var congelado := 0.05
## Sacudida de cámara: segundos y fuerza (0 = ninguna).
@export var sacudida := Vector2(0.0, 0.0)
@export_group("2. Salir volando")
## Impulso hacia donde iba el zarpazo (x) y hacia arriba (y negativo), en px/s.
@export var impulso := Vector2(170, -230)
@export var gravedad := 900.0
## Vueltas por segundo mientras vuela (0 = no gira).
@export var vueltas := 2.0
## Lo que conserva al chocar con una pared (0 = se pega, 1 = rebota igual) y al tocar el piso.
@export var rebote_pared := 0.5
@export var rebote_piso := 0.3
@export_group("3. ¡POP!")
## Se desarma al tocar el piso: desaparece su dibujo y suelta las piezas.
@export var desarmarse := true
## Palabra que salta (clave de traducción; "" = ninguna).
@export var palabra := "PALABRA_POP"
## Piezas que suelta (imágenes de assets/nivel1/ o provisionales), con su velocidad de salida (mín., máx.) en px/s.
@export var piezas: PackedStringArray = []
@export var velocidad_piezas := Vector2(90, 180)
## Pieza que sigue girando sola en el piso y cuántos segundos.
@export var pieza_que_gira := ""
@export var giro_segundos := 3.0
## Nube de pelusa: granos y color (0 = ninguna).
@export var nube := 0
@export var color_nube := Color(0.78, 0.76, 0.74, 0.9)
@export_group("4. Cámara lenta")
## Escala del tiempo durante la cámara lenta (1 = sin cámara lenta) y cuánto dura, en segundos reales.
@export var camara_lenta := 1.0
@export var duracion_lenta := 0.5
@export_group("5. La marca que queda")
## Imagen que queda en el piso donde cayó (por ejemplo, la montaña de pelusa), al lado del enemigo.
@export var marca := ""
@export var lado_marca := 46.0
## Fantasmita que sube y se desvanece («resorte con alma»), con su palabra (clave).
@export var fantasma := ""
@export var palabra_fantasma := "PALABRA_BOING"
@export var subida_fantasma := 34.0
@export var tiempo_fantasma := 1.4
@export_group("Felipe")
## Evento de Frases.FELIPE que dice Felipe (sin culpa; no repite la anterior).
@export var frase := ""
