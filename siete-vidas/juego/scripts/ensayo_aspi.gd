class_name EnsayoAspi
extends Node2D
## Ensayo sin riesgo de la pelea, en el pasillo (propuesta v4 §2.4, R1 y R12): Felipe tira el vaso de la consola, sale
## A.S.P.I. del estudio, va a la mancha y la aspira. Su succión arrastra a Felipe si está de pie; agachado se aferra
## ("Mantén {agacharse}. Uñas: modo ancla."). Aquí no hace daño. Al terminar dice "Suciedad eliminada. Gato…
## registrado." y vuelve a su cuarto. Usa una A.S.P.I. aparte (inofensiva) para no tocar la de la pelea.

signal terminado

const SUCCION := 150.0
const RADIO := 200.0
const TIEMPO_LIMPIEZA := 2.6

enum Paso { ESPERANDO, VA, LIMPIA, VUELVE, LISTO }

var paso := Paso.ESPERANDO
var aspi: Aspi
var mancha_x := INF
var sala: Sala
var _puerta: Vector2
var _reloj := 0.0
var _dijo_ancla := false


func _init(nivel: Sala, puerta: Vector2) -> void:
	sala = nivel
	_puerta = puerta
	name = "Ensayo de A.S.P.I."


func _ready() -> void:
	var cuarto := Sala.rect_de("pasillo")
	aspi = Aspi.new(cuarto.position.x + 40.0, cuarto.end.x - 40.0)
	aspi.name = "ASPI del ensayo"
	aspi.inofensiva = true
	aspi.vision = 0.0
	aspi.quieta = true
	aspi.visible = false
	aspi.position = _puerta
	aspi.process_mode = Node.PROCESS_MODE_DISABLED
	sala.add_child.call_deferred(aspi)
	var dibujo := Node2D.new()
	dibujo.name = "Mancha del ensayo"
	dibujo.z_index = 9
	dibujo.draw.connect(func() -> void:
		if mancha_x != INF and paso in [Paso.ESPERANDO, Paso.VA, Paso.LIMPIA]:
			ArteNivel.dibujar(dibujo, "mancha", mancha_x, Sala.SUELO + 2.0)
		if paso == Paso.LIMPIA:
			var t := Time.get_ticks_msec() / 1000.0
			for i in 10:
				var lado := -1.0 if i % 2 == 0 else 1.0
				var avance := fmod(t * 1.4 + i * 0.37, 1.0)
				var x := aspi.global_position.x + lado * (1.0 - avance) * RADIO
				var y := Sala.SUELO - 6.0 - fmod(i * 23.0, 60.0)
				dibujo.draw_line(Vector2(x, y), Vector2(x + lado * 16.0, y), Color(Color("dff3ff"), 0.7 * avance), 1.5))
	add_child(dibujo)


## El vaso de la consola cayó en `x`: sale A.S.P.I. (una sola vez).
func empezar(x: float) -> void:
	if paso != Paso.ESPERANDO:
		return
	mancha_x = x
	paso = Paso.VA
	aspi.process_mode = Node.PROCESS_MODE_INHERIT
	aspi.visible = true
	aspi.global_position = _puerta
	aspi.quieta = false
	aspi.destino = x
	(sala.puertas["pasillo>estudio"] as Puerta).abrir_un_momento(0.8)
	sala.sonar("succion")


func _physics_process(delta: float) -> void:
	var felipe := sala.felipe
	match paso:
		Paso.VA:
			if absf(aspi.global_position.x - mancha_x) < 6.0:
				paso = Paso.LIMPIA
				_reloj = 0.0
				sala.sonar("succion")
		Paso.LIMPIA:
			_reloj += delta
			felipe.empuje = Vector2.ZERO
			var distancia := aspi.global_position.x - felipe.global_position.x
			if absf(distancia) < RADIO and absf(distancia) > 6.0 and absf(felipe.global_position.y - aspi.global_position.y) < 40.0:
				felipe.empuje = Vector2(signf(distancia) * SUCCION, 0.0)
				if not _dijo_ancla:
					_dijo_ancla = true
					sala.travesuras.dialogo.decir("felipe", "Mantén {agacharse}. Uñas: modo ancla.", 1, true)
			if _reloj >= TIEMPO_LIMPIEZA:
				felipe.empuje = Vector2.ZERO
				paso = Paso.VUELVE
				aspi.destino = _puerta.x
				sala.travesuras.dialogo.decir("aspi", "Suciedad eliminada. Gato… registrado.", 1, true)
		Paso.VUELVE:
			if absf(aspi.global_position.x - _puerta.x) < 6.0:
				paso = Paso.LISTO
				aspi.visible = false
				aspi.process_mode = Node.PROCESS_MODE_DISABLED
				(sala.puertas["pasillo>estudio"] as Puerta).abrir_un_momento(0.6)
				sala.travesuras.decir_felipe("robot_registra")
				terminado.emit()
	if paso in [Paso.VA, Paso.LIMPIA]:
		for hijo in get_children():
			if hijo is Node2D:
				(hijo as Node2D).queue_redraw()
