// PROTOTIPO: no es código del juego.
// Pregunta: ¿se ve mejor la sala en 3D renderizado como pixel art?
// Fecha: 2026-10-21
// Casco invertido: se dibujan las caras traseras empujadas N píxeles de pantalla
// hacia afuera. Con cámara ortográfica da un contorno de grosor constante.
shader_type spatial;
render_mode unshaded, cull_front, shadows_disabled;

uniform vec4 color : source_color = vec4(0.13, 0.05, 0.04, 1.0);
uniform float grosor_px = 1.0;

void vertex() {
	vec4 clip = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 n = normalize(mat3(MODELVIEW_MATRIX) * NORMAL);
	vec2 dir = (PROJECTION_MATRIX * vec4(n, 0.0)).xy;
	float largo = length(dir);
	if (largo > 0.0001) {
		dir /= largo;
	}
	clip.xy += dir * grosor_px * 2.0 / VIEWPORT_SIZE * clip.w;
	POSITION = clip;
}

void fragment() {
	ALBEDO = color.rgb;
}
