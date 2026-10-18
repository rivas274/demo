# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-18
class_name Sonidos
extends Node
## Sonidos sintetizados al arrancar (sin archivos): rotura, golpes, maullido, bufido, ronroneo, etc.
## Feos a propósito; solo tienen que tener peso y leerse.

const MEZCLA := 22050

@export var volumen_db := -10.0

var _sonidos := {}
var _reproductores: Array[AudioStreamPlayer] = []
var _ronroneo: AudioStreamPlayer
var _azar := RandomNumberGenerator.new()


func _ready() -> void:
	_azar.seed = 7
	_sonidos["rotura"] = _rotura()
	_sonidos["golpe"] = _golpe(70.0, 0.22, 0.9)
	_sonidos["golpe_pata"] = _golpe(160.0, 0.08, 0.5)
	_sonidos["peso"] = _peso()
	_sonidos["zarpazo"] = _zumbido()
	_sonidos["arañar"] = _aranar()
	_sonidos["maullido"] = _maullido()
	_sonidos["bufido"] = _bufido()
	_sonidos["comer"] = _comer()
	_sonidos["pop"] = _pop()
	_sonidos["salto"] = _blip(330.0, 520.0, 0.07, 0.25)
	_sonidos["felipe_grito"] = _grito()
	_sonidos["perdon"] = _arpegio()
	_sonidos["texto"] = _blip(700.0, 700.0, 0.025, 0.12)
	var ronroneo := _ronronear()
	ronroneo.loop_mode = AudioStreamWAV.LOOP_FORWARD
	ronroneo.loop_end = int(MEZCLA * 0.8)
	_sonidos["ronroneo"] = ronroneo
	for i in 8:
		var reproductor := AudioStreamPlayer.new()
		reproductor.volume_db = volumen_db
		add_child(reproductor)
		_reproductores.append(reproductor)
	_ronroneo = AudioStreamPlayer.new()
	_ronroneo.stream = ronroneo
	_ronroneo.volume_db = volumen_db
	add_child(_ronroneo)


func sonar(nombre: String, tono := 1.0) -> void:
	if nombre == "ronroneo_on":
		if not _ronroneo.playing:
			_ronroneo.play()
		return
	if nombre == "ronroneo_off":
		_ronroneo.stop()
		return
	if not _sonidos.has(nombre):
		return
	for reproductor in _reproductores:
		if not reproductor.playing:
			reproductor.stream = _sonidos[nombre]
			reproductor.pitch_scale = tono
			reproductor.play()
			return


func _a_wav(muestras: PackedFloat32Array) -> AudioStreamWAV:
	var datos := PackedByteArray()
	datos.resize(muestras.size() * 2)
	for i in muestras.size():
		datos.encode_s16(i * 2, int(clampf(muestras[i], -1.0, 1.0) * 32000.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MEZCLA
	wav.stereo = false
	wav.data = datos
	return wav


func _vacio(segundos: float) -> PackedFloat32Array:
	var m := PackedFloat32Array()
	m.resize(int(segundos * MEZCLA))
	return m


## Vidrio: golpe de ruido seco y tintineos agudos que siguen sonando.
func _rotura() -> AudioStreamWAV:
	var m := _vacio(0.9)
	var bajo := 0.0
	for i in m.size():
		var t := float(i) / MEZCLA
		var ruido := _azar.randf_range(-1, 1)
		bajo = lerpf(bajo, ruido, 0.3)
		m[i] = (ruido - bajo) * exp(-t * 14.0) * 0.9 + sin(TAU * 60.0 * t) * exp(-t * 18.0) * 0.6
	for k in 9:
		var inicio := _azar.randf_range(0.0, 0.45)
		var f := _azar.randf_range(2400.0, 5200.0)
		for i in range(int(inicio * MEZCLA), m.size()):
			var t := float(i) / MEZCLA - inicio
			m[i] += sin(TAU * f * t) * exp(-t * 22.0) * 0.22
	return _a_wav(m)


func _golpe(frecuencia: float, segundos: float, fuerza: float) -> AudioStreamWAV:
	var m := _vacio(segundos)
	var fase := 0.0
	for i in m.size():
		var t := float(i) / MEZCLA
		fase += TAU * frecuencia * (1.0 - t / segundos * 0.5) / MEZCLA
		m[i] = (sin(fase) * 0.9 + _azar.randf_range(-1, 1) * exp(-t * 80.0) * 0.5) * exp(-t * 6.0 / segundos) * fuerza
	return _a_wav(m)


## El "peso" de cada travesura: bombo grave que baja de tono, saturado.
func _peso() -> AudioStreamWAV:
	var m := _vacio(0.45)
	var fase := 0.0
	for i in m.size():
		var t := float(i) / MEZCLA
		fase += TAU * (110.0 * exp(-t * 9.0) + 42.0) / MEZCLA
		m[i] = tanh(sin(fase) * 2.5) * exp(-t * 7.0) * 0.85
	return _a_wav(m)


func _zumbido() -> AudioStreamWAV:
	var m := _vacio(0.14)
	var filtro := 0.0
	for i in m.size():
		var t := float(i) / MEZCLA
		filtro = lerpf(filtro, _azar.randf_range(-1, 1), 0.1 + t * 4.0)
		m[i] = filtro * sin(PI * t / 0.14) * 0.6
	return _a_wav(m)


## Arañar tela: tres rasguños de ruido agudo.
func _aranar() -> AudioStreamWAV:
	var m := _vacio(0.3)
	var antes := 0.0
	for i in m.size():
		var t := float(i) / MEZCLA
		var ruido := _azar.randf_range(-1, 1)
		var agudo := ruido - antes
		antes = ruido
		var golpe := fmod(t, 0.1) / 0.1
		m[i] = agudo * 0.45 * (1.0 - golpe) * (0.6 + 0.4 * sin(t * 900.0))
	return _a_wav(m)


## "Miau": tono que sube y baja con armónicos y vibrato.
func _maullido() -> AudioStreamWAV:
	var m := _vacio(0.62)
	var fase := 0.0
	for i in m.size():
		var t := float(i) / 0.62 / MEZCLA
		var f := 520.0 + 380.0 * sin(PI * minf(t * 1.4, 1.0)) - 160.0 * t + 12.0 * sin(t * 60.0)
		fase += TAU * f / MEZCLA
		var forma := sin(fase) * 0.6 + sin(fase * 2.0) * 0.3 * (1.0 - t) + sin(fase * 3.0) * 0.15
		var volumen := minf(t * 12.0, 1.0) * (1.0 - t) * 1.2
		m[i] = forma * volumen * 0.8
	return _a_wav(m)


## Bufido: soplido de ruido con un gruñido grave.
func _bufido() -> AudioStreamWAV:
	var m := _vacio(0.7)
	var antes := 0.0
	for i in m.size():
		var t := float(i) / MEZCLA
		var ruido := _azar.randf_range(-1, 1)
		var agudo := ruido - antes * 0.6
		antes = ruido
		var volumen := minf(t * 30.0, 1.0) * exp(-t * 2.5)
		m[i] = (agudo * 0.55 + sin(TAU * 85.0 * t) * 0.3 * (0.5 + 0.5 * sin(TAU * 30.0 * t))) * volumen
	return _a_wav(m)


func _ronronear() -> AudioStreamWAV:
	var m := _vacio(0.8)
	var filtro := 0.0
	for i in m.size():
		var t := float(i) / MEZCLA
		filtro = lerpf(filtro, _azar.randf_range(-1, 1), 0.05)
		var pulso := pow(0.5 + 0.5 * sin(TAU * 25.0 * t), 3.0)
		m[i] = (filtro * 2.0 + sin(TAU * 50.0 * t) * 0.4) * pulso * 0.45
	return _a_wav(m)


func _comer() -> AudioStreamWAV:
	var m := _vacio(0.3)
	for i in m.size():
		var t := float(i) / MEZCLA
		var golpe := fmod(t, 0.09)
		m[i] = _azar.randf_range(-1, 1) * exp(-golpe * 70.0) * 0.6
	return _a_wav(m)


func _pop() -> AudioStreamWAV:
	return _blip(600.0, 1300.0, 0.09, 0.4)


func _blip(desde: float, hasta: float, segundos: float, fuerza: float) -> AudioStreamWAV:
	var m := _vacio(segundos)
	var fase := 0.0
	for i in m.size():
		var t := float(i) / MEZCLA / segundos
		fase += TAU * lerpf(desde, hasta, t) / MEZCLA
		m[i] = signf(sin(fase)) * fuerza * (1.0 - t)
	return _a_wav(m)


## "¡FE-LI-PE!": tres sílabas de onda cuadrada, la última más larga y aguda.
func _grito() -> AudioStreamWAV:
	var m := _vacio(0.7)
	var silabas := [[0.0, 0.14, 420.0], [0.16, 0.3, 470.0], [0.32, 0.68, 560.0]]
	var fase := 0.0
	for i in m.size():
		var t := float(i) / MEZCLA
		for s: Array in silabas:
			if t >= s[0] and t < s[1]:
				var u: float = (t - s[0]) / (s[1] - s[0])
				fase += TAU * (s[2] * (1.0 - 0.15 * u) + 8.0 * sin(t * 50.0)) / MEZCLA
				m[i] = (signf(sin(fase)) * 0.3 + sin(fase * 2.0) * 0.2) * minf(u * 20.0, 1.0) * minf((1.0 - u) * 10.0, 1.0)
	return _a_wav(m)


func _arpegio() -> AudioStreamWAV:
	var m := _vacio(0.6)
	var notas := [523.0, 659.0, 784.0, 1046.0]
	for i in m.size():
		var t := float(i) / MEZCLA
		var n := mini(int(t / 0.1), 3)
		var u := t - n * 0.1
		m[i] = sin(TAU * notas[n] * t) * exp(-u * 6.0) * 0.4
	return _a_wav(m)
