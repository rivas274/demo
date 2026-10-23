class_name SaludFelipe
extends RefCounted
## La salud de Felipe: las 9 huellas (decisión del creador del 2026-10-23, `siete-vidas/diseno/salud-9-huellas.md`).
## Las 9 vidas del título SON la salud: no hay corazones ni reintentos aparte.
##
## - **Por dentro, medias huellas:** su pieza Vida cuenta 18 medias (`MEDIAS_MAX`). Un golpe normal quita 2 (1 huella;
##   `HaceDano.dano` = 2) y deja 1,2 s invulnerable (`Felipe.TIEMPO_INVULNERABLE`).
## - **Opción «Golpes»** (`Opciones.golpes`, accesibilidad, no bloquea logros): Normal quita lo que dice el golpe;
##   Suaves, la mitad (½ huella: se ve el estado «media»); Ninguno, nada (el golpe empuja, suena y deja invulnerable).
## - **Curación:** el snack y el plato curan 1 huella (`CURA_COMIDA`); llegar a un descanso las llena todas. La pelusa
##   no cura.
## - **A 0:** se desmaya (`EstadoDesmayado`: 9 gatitos fantasma suben y vuelven a bajar) y reaparece en el último
##   descanso con todo lleno, sin perder nada, diciendo «Siesta táctica.». Al TERCER desmayo del nivel le llega el
##   Collar de la Vergüenza (`DESMAYOS_COLLAR`).
## - **Pocas huellas:** con 3 o menos (`HUELLAS_BAJAS`), las que quedan laten (lo dibuja BarraVida) y Felipe dice una
##   vez «Esto es un empate técnico.» (otra vez solo si se curó por encima de 3).
## No dibuja nada: avisa con señales y la interfaz y las frases escuchan.

## Se desmayó (cuántas veces en este nivel).
signal desmayado(veces: int)
## Volvió del desmayo en el último descanso, con todo lleno.
signal reaparecio
## Le quedan 3 huellas o menos (una vez hasta que vuelva a tener más).
signal pocas_huellas
## Se le llenaron las huellas en un descanso.
signal descanso

const HUELLAS := 9
const MEDIAS_POR_HUELLA := 2
const MEDIAS_MAX := HUELLAS * MEDIAS_POR_HUELLA
## Medias que cura comer (el snack del bolsillo o el plato): 1 huella.
const CURA_COMIDA := 2
const HUELLAS_BAJAS := 3
## Al desmayo número 3 del mismo nivel llega el Collar de la Vergüenza.
const DESMAYOS_COLLAR := 3

var felipe: Felipe
## Desmayos en este nivel (el resumen del día los cuenta como «siestas tácticas»).
var desmayos := 0
var _avisado := false


func _init(de: Felipe) -> void:
	felipe = de
	felipe.vida.cambio.connect(_al_cambiar)


## Huellas que le quedan (6,5 = seis y media).
func huellas() -> float:
	return float(felipe.vida.actual) / MEDIAS_POR_HUELLA


## Cuántas medias quita un golpe de `medias`, según la opción «Golpes».
static func medias_del_golpe(medias: int) -> int:
	match Opciones.golpes:
		Opciones.Golpes.SUAVES:
			return ceili(medias / 2.0)
		Opciones.Golpes.NINGUNO:
			return 0
	return medias


## Comer cura una huella.
func comer() -> void:
	felipe.vida.curar(CURA_COMIDA)


## Llegó a un descanso: si le falta algo, se llena todo.
func descansar() -> void:
	if felipe.vida.actual < felipe.vida.maximo and not felipe.vida.muerto:
		felipe.vida.llenar()
		descanso.emit()


## Se desmayó: cuenta el desmayo y, al tercero del nivel, se pone el Collar de la Vergüenza.
func desmayarse() -> void:
	desmayos += 1
	if desmayos >= DESMAYOS_COLLAR and not felipe.tiene_collar:
		felipe.tiene_collar = true
	desmayado.emit(desmayos)


## Vuelve del desmayo con todo lleno y sin perder nada (lo llama EstadoDesmayado).
func volver() -> void:
	felipe.vida.llenar()
	_avisado = false
	reaparecio.emit()


func _al_cambiar(actual: int, _maximo: int) -> void:
	if actual > HUELLAS_BAJAS * MEDIAS_POR_HUELLA:
		_avisado = false
	elif actual > 0 and not _avisado:
		_avisado = true
		pocas_huellas.emit()
