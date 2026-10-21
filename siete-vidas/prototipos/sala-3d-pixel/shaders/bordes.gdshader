// PROTOTIPO: no es código del juego.
// Pregunta: ¿se ve mejor la sala en 3D renderizado como pixel art?
// Fecha: 2026-10-21
// Post-proceso de bordes (Forward+), en un quad pegado a la cámara:
// - contorno EXTERIOR de 1 px donde salta la profundidad: café profundo mezclado
//   con el tono más oscuro del objeto (nunca negro puro);
// - contorno INTERIOR donde cambian las normales (brazos sobre el cuerpo, cojines,
//   la cola sobre el lomo): el mismo color, más oscuro, y más claro que el exterior.
// Umbrales duros: no hay medios píxeles ni antialias.
shader_type spatial;
render_mode unshaded, depth_test_disabled, depth_draw_never, cull_disabled, fog_disabled, shadows_disabled;

uniform sampler2D pantalla : hint_screen_texture, filter_nearest;
uniform sampler2D profundidad : hint_depth_texture, filter_nearest;
uniform sampler2D normales : hint_normal_roughness_texture, filter_nearest;

uniform bool activo = true;
uniform bool interior = true;
uniform float umbral_profundidad = 0.12; // metros
uniform float umbral_normal = 0.45;
uniform vec3 cafe : source_color = vec3(0.16, 0.08, 0.06);
uniform float oscuro_exterior = 0.08; // en lineal (≈ 0,3 en sRGB)
uniform float oscuro_interior = 0.42; // en lineal (≈ 0,68 en sRGB)

void vertex() {
	POSITION = vec4(VERTEX.xy * 2.0, 1.0, 1.0);
}

float lineal(vec2 uv, mat4 inv_proy) {
	float d = texture(profundidad, uv).r;
	vec4 v = inv_proy * vec4(uv * 2.0 - 1.0, d, 1.0);
	return -v.z / v.w;
}

vec3 normal_en(vec2 uv) {
	return normalize(texture(normales, uv).xyz * 2.0 - 1.0);
}

void fragment() {
	vec3 c = texture(pantalla, SCREEN_UV).rgb;
	if (activo) {
		vec2 px = 1.0 / VIEWPORT_SIZE;
		float d = lineal(SCREEN_UV, INV_PROJECTION_MATRIX);
		vec3 n = normal_en(SCREEN_UV);
		float borde_ext = 0.0;
		float borde_int = 0.0;
		vec2 vecinos[4] = vec2[](vec2(px.x, 0.0), vec2(-px.x, 0.0), vec2(0.0, px.y), vec2(0.0, -px.y));
		for (int i = 0; i < 4; i++) {
			vec2 uv = SCREEN_UV + vecinos[i];
			float dv = lineal(uv, INV_PROJECTION_MATRIX);
			// Solo el píxel más cercano dibuja el contorno: queda de 1 px y por fuera del fondo.
			if (dv - d > umbral_profundidad) {
				borde_ext = 1.0;
			}
			vec3 nv = normal_en(uv);
			// Sesgo de dirección (como en t3ssel8r): la línea va de un solo lado del pliegue.
			float sesgo = dot(n - nv, vec3(0.6, 0.8, 0.2));
			if (abs(dv - d) <= umbral_profundidad && 1.0 - dot(n, nv) > umbral_normal && sesgo > 0.0) {
				borde_int = 1.0;
			}
		}
		if (borde_ext > 0.5) {
			c = mix(c * oscuro_exterior, cafe, 0.6);
		} else if (interior && borde_int > 0.5) {
			c = c * oscuro_interior;
		}
	}
	ALBEDO = c;
}
