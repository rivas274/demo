extends RefCounted
## Mide en una hoja de caminar cuánto retrocede el pie apoyado de un cuadro al siguiente (revisión 3, B2 y G9):
## "un ciclo de caminar es una medida, no una tira de dibujos". Para cada par de cuadros busca, en las filas del piso,
## los pies separados que tocan el piso y el corrimiento horizontal que mejor los calza en el cuadro siguiente.
## Devuelve [[cuadro, px]] (px negativo = hacia atrás) solo para los pares que se pueden medir (pies separados,
## buen calce). Se usa con preload("res://pruebas/medir_pasos.gd").pie_apoyado(...).


static func pie_apoyado(ruta: String, cuadros: int, banda: int, ancho_maximo: int, error_maximo: float) -> Array:
	var imagen: Image = (load(ruta) as Texture2D).get_image()
	if imagen.is_compressed():
		imagen.decompress()
	var ancho := imagen.get_width() / cuadros
	var alto := imagen.get_height()
	# Cada cuadro como matriz de opacidad, bajado para que su fila más baja quede en el piso (alinear por los pies).
	var mascaras: Array = []
	for i in cuadros:
		var abajo := 0
		for y in range(alto - 1, -1, -1):
			var hay := false
			for x in ancho:
				if imagen.get_pixel(i * ancho + x, y).a > 0.16:
					hay = true
					break
			if hay:
				abajo = y
				break
		var bajar := alto - 1 - abajo
		var m := PackedByteArray()
		m.resize(ancho * alto)
		for y in range(alto):
			var origen := y - bajar
			for x in ancho:
				m[y * ancho + x] = 1 if origen >= 0 and imagen.get_pixel(i * ancho + x, origen).a > 0.16 else 0
		mascaras.append(m)
	var medidas: Array = []
	for i in cuadros:
		var a: PackedByteArray = mascaras[i]
		var b: PackedByteArray = mascaras[(i + 1) % cuadros]
		var mejor := [INF, 0]
		for tramo in _tramos(a, ancho, alto, banda):
			var x0: int = tramo[0]
			var x1: int = tramo[1]
			if x1 - x0 < 4 or x1 - x0 > ancho_maximo:
				continue
			# Tiene que tocar el piso (las 2 filas de abajo).
			var toca := false
			for x in range(x0, x1):
				if a[(alto - 1) * ancho + x] == 1 or a[(alto - 2) * ancho + x] == 1:
					toca = true
			if not toca:
				continue
			for d in range(-20, 9):
				if x0 + d < 0 or x1 + d > ancho:
					continue
				var diferencia := 0
				for y in range(alto - banda, alto):
					for x in range(x0, x1):
						diferencia += absi(a[y * ancho + x] - b[y * ancho + x + d])
				var error := 255.0 * diferencia / float(banda * (x1 - x0))
				if error < mejor[0]:
					mejor = [error, d]
		if mejor[0] < error_maximo and mejor[1] < 0:
			medidas.append([i, mejor[1]])
	return medidas


## Tramos de columnas con algo opaco en las `banda` filas de abajo: [[x0, x1]].
static func _tramos(m: PackedByteArray, ancho: int, alto: int, banda: int) -> Array:
	var tramos: Array = []
	var desde := -1
	for x in ancho + 1:
		var hay := false
		if x < ancho:
			for y in range(alto - banda, alto):
				if m[y * ancho + x] == 1:
					hay = true
					break
		if hay and desde < 0:
			desde = x
		elif not hay and desde >= 0:
			tramos.append([desde, x])
			desde = -1
	return tramos
