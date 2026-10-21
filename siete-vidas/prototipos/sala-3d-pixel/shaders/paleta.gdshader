// PROTOTIPO: no es código del juego.
// Pregunta: ¿se ve mejor la sala en 3D renderizado como pixel art?
// Fecha: 2026-10-21
// Post-proceso 2D: lleva cada píxel al color más cercano de una paleta cálida.
shader_type canvas_item;

uniform bool activa = true;
uniform vec3 paleta[48];
uniform int cantidad = 0;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if (activa && cantidad > 0) {
		vec3 mejor = c.rgb;
		float dist = 1e9;
		for (int i = 0; i < cantidad; i++) {
			vec3 d = (c.rgb - paleta[i]) * vec3(0.30, 0.59, 0.11) * 3.0;
			float k = dot(d, d) + dot(c.rgb - paleta[i], c.rgb - paleta[i]) * 0.5;
			if (k < dist) {
				dist = k;
				mejor = paleta[i];
			}
		}
		c.rgb = mejor;
	}
	COLOR = vec4(c.rgb, 1.0);
}
