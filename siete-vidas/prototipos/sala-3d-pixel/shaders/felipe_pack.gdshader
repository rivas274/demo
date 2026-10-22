// PROTOTIPO: no es código del juego.
// Felipe sobre el gato de Quaternius: colores y cara pintados por píxel según la posición
// de reposo de cada punto (guardada en UV y UV2 por scripts/felipe_pack.gd), así las
// manchas y los ojos quedan nítidos aunque la malla sea low poly y se mueven con ella.
// Luz: la misma de toon.gdshader (escalones opcionales).
shader_type spatial;
render_mode specular_disabled, ambient_light_disabled;

uniform bool escalones = true;
uniform float corte_bajo = 0.12;
uniform float corte_alto = 0.55;
uniform float nivel_medio = 0.55;
uniform vec3 ambiente = vec3(0.26, 0.22, 0.34);
// Sin escalones (vista de cerca): luz suave con un relleno ambiente más claro.
uniform float ambiente_suave = 0.0;

uniform vec3 blanco : source_color = vec3(0.953, 0.937, 0.910);
uniform vec3 atigrado : source_color = vec3(0.545, 0.471, 0.392);
uniform vec3 raya : source_color = vec3(0.42, 0.36, 0.30);
uniform vec3 cola_c : source_color = vec3(0.29, 0.247, 0.212);
uniform vec3 cola_r : source_color = vec3(0.21, 0.176, 0.149);
uniform vec3 rosa : source_color = vec3(0.898, 0.604, 0.635);
uniform vec3 ojo_c : source_color = vec3(0.639, 0.690, 0.416);
uniform vec3 pupila_c : source_color = vec3(0.10, 0.09, 0.08);
uniform vec3 linea_c : source_color = vec3(0.20, 0.16, 0.13);

// Medidas del modelo (espacio del modelo en reposo), las pone el script.
uniform vec3 centro_cabeza = vec3(2.5, 2.7, 0.0);
uniform float radio_cabeza = 1.0;
uniform float x_cola = -1.75;
uniform float y_lomo = 2.0;
uniform vec4 manchas[3];  // centro xyz y radio

varying vec3 reposo;

void vertex() {
	reposo = vec3(UV.x, UV.y, UV2.x);
}

float elipse(vec2 p, vec2 c, vec2 r) {
	vec2 d = (p - c) / r;
	return dot(d, d);
}

void fragment() {
	vec3 p = reposo;
	vec3 c = blanco;
	vec3 h = (p - centro_cabeza) / radio_cabeza;  // cabeza: x adelante, y arriba, z lado
	bool es_cabeza = length(h) < 1.35 && p.x > centro_cabeza.x - 1.1 * radio_cabeza;
	if (es_cabeza) {
		// Gorra: arriba; baja más por los lados y la nuca que por la cara.
		float linea = 0.12 + 0.25 * smoothstep(0.2, 0.9, h.x) - 0.25 * smoothstep(0.3, 0.9, abs(h.z));
		bool gorra = h.y > linea;
		// Franja blanca en V entre los ojos.
		bool v_blanca = h.x > 0.35 && abs(h.z) < (0.62 - h.y) * 0.32;
		if (gorra && !v_blanca) {
			c = atigrado;
			if (h.y > 0.45 && sin(abs(h.z) * 14.0 + 2.0 * h.x) > 0.7) c = raya;
		}
		// Orejas: rosado por dentro (lo que mira adelante sobre la gorra).
		if (h.y > 0.72 && abs(h.z) > 0.25 && h.x > -0.05 && NORMAL.y > -2.0) {
			c = mix(c, rosa, smoothstep(0.0, 0.25, h.x) * 0.9);
		}
		// Cara: en el plano z-y visto de frente, solo lo que mira adelante.
		if (h.x > 0.45) {
			vec2 f = vec2(abs(h.z), h.y);
			// Ojos de reojo, a media asta: elipse con párpado recto que cae hacia afuera.
			vec2 c_ojo = vec2(0.36, 0.12);
			float e = elipse(f, c_ojo, vec2(0.17, 0.12));
			float parpado = c_ojo.y + 0.02 - 0.10 * (f.x - c_ojo.x);
			if (e < 1.0 && f.y < parpado) {
				c = ojo_c;
				// Pupila corrida hacia el lado (mirada de reojo, ambos al mismo lado).
				float lado = sign(h.z);
				vec2 c_pup = vec2(c_ojo.x + 0.04 * lado, c_ojo.y - 0.01);
				if (elipse(f, c_pup, vec2(0.05, 0.09)) < 1.0) c = pupila_c;
				if (elipse(f, c_pup + vec2(0.03, 0.04), vec2(0.022, 0.022)) < 1.0) c = vec3(1.0);
			}
			if ((e >= 1.0 && e < 1.45 && f.y < parpado + 0.03) || (e < 1.2 && abs(f.y - parpado) < 0.022)) c = linea_c;
			// Ceja gruñona: raya corta inclinada sobre el ojo.
			if (abs(f.y - (c_ojo.y + 0.2 - 0.18 * (f.x - c_ojo.x))) < 0.03 && abs(f.x - c_ojo.x) < 0.14) c = mix(c, raya, 0.8);
			// Nariz rosada: triángulo con la punta abajo.
			float t = (0.0 - h.y) / 0.11;
			if (t > 0.0 && t < 1.0 && abs(h.z) < 0.09 * (1.0 - t) + 0.01) c = rosa;
			// Boca de desdén: V invertida chica bajo la nariz.
			if (abs(h.y - (-0.2 - 0.25 * abs(h.z))) < 0.018 && abs(h.z) < 0.12) c = linea_c;
			if (abs(h.z) < 0.015 && h.y < -0.11 && h.y > -0.2) c = linea_c;
		}
	} else if (p.x < x_cola && p.y > y_lomo - 0.2) {
		// Cola entera oscura con bandas suaves.
		c = cola_c;
		if (sin(length(p.xy - vec2(x_cola, y_lomo)) * 6.5) > 0.4) c = cola_r;
	} else {
		// Manchas del lomo, simétricas, con borde suave y rayas sutiles.
		float m = 0.0;
		for (int i = 0; i < 3; i++) {
			vec3 d = (p - manchas[i].xyz) / vec3(manchas[i].w * 1.25, manchas[i].w * 0.8, manchas[i].w);
			m = max(m, 1.0 - smoothstep(0.85, 1.05, length(d)));
		}
		vec3 parche = atigrado;
		if (sin(p.x * 5.0 + 1.5 * sin(p.y * 2.0)) > 0.6) parche = raya;
		c = mix(blanco, parche, m);
	}
	ALBEDO = c;
	EMISSION = c * mix(ambiente, vec3(0.42), ambiente_suave);
}

void light() {
	float n_l = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	float e = n_l * ATTENUATION;
	float q = e;
	if (escalones) {
		if (LIGHT_IS_DIRECTIONAL) {
			q = e > corte_bajo ? 1.0 : 0.0;
		} else {
			q = e > corte_alto ? 1.0 : (e > corte_bajo ? nivel_medio : 0.0);
		}
	}
	DIFFUSE_LIGHT += q * LIGHT_COLOR / PI;
}
