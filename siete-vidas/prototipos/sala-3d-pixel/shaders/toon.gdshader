// PROTOTIPO: no es código del juego.
// Pregunta: ¿se ve mejor la sala en 3D renderizado como pixel art?
// Fecha: 2026-10-21
// Luz en escalones (sin degradados): cada luz se corta en 0 / medio / lleno.
shader_type spatial;
render_mode specular_disabled, ambient_light_disabled;

uniform vec4 color : source_color = vec4(1.0);
uniform bool usar_color_vertice = false;
uniform float emision = 0.0;
uniform bool escalones = true;
uniform float corte_bajo = 0.12;
uniform float corte_alto = 0.55;
uniform float nivel_medio = 0.55;
// Luz ambiente propia: la sombra es un tono plano y algo violeta (luz cálida, sombra fría).
uniform vec3 ambiente = vec3(0.36, 0.31, 0.44);
// Papel mural: rayas verticales suaves cada `rayas` metros (0 = sin rayas).
uniform float rayas = 0.0;
uniform vec4 color_raya : source_color = vec4(0.0);
varying vec3 pos_mundo;

void vertex() {
	pos_mundo = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 base = color.rgb;
	if (usar_color_vertice) {
		base *= COLOR.rgb;
	}
	if (rayas > 0.0 && fract(pos_mundo.x / rayas) < 0.18) {
		base = color_raya.rgb;
	}
	ALBEDO = base;
	EMISSION = base * emision + base * ambiente;
}

void light() {
	float n_l = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	float e = n_l * ATTENUATION;
	float q = e;
	if (escalones) {
		q = e > corte_alto ? 1.0 : (e > corte_bajo ? nivel_medio : 0.0);
	}
	DIFFUSE_LIGHT += q * LIGHT_COLOR / PI;
}
