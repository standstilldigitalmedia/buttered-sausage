shader_type canvas_item;

// === UV/Position Effects (applied first) ===

// Wave: undulating vertical motion
uniform float wave_enabled = 0.0;
uniform float wave_amplitude = 0.03;
uniform float wave_frequency = 10.0;
uniform float wave_speed = 3.0;

// Shake: jittery random motion
uniform float shake_enabled = 0.0;
uniform float shake_amount = 0.02;
uniform float shake_speed = 20.0;

// === Color Effects (applied to sampled color) ===

// Rainbow: cycle through hues based on position and time
uniform float rainbow_enabled = 0.0;
uniform float rainbow_frequency = 1.0;
uniform float rainbow_speed = 1.0;
uniform float rainbow_saturation = 1.0;

// === Alpha Effects (applied last) ===

// Apparate: mystical scattered fade based on UV position
uniform float apparate_enabled = 0.0;
uniform float apparate_progress = 2.0;
uniform float apparate_spread = 0.15;

// Pulse: rhythmic alpha pulsing
uniform float pulse_enabled = 0.0;
uniform float pulse_speed = 2.0;
uniform float pulse_min_alpha = 0.3;

// === Helper Functions ===

// HSV to RGB conversion for rainbow effect
vec3 hsv_to_rgb(vec3 hsv) {
	float h = hsv.x * 6.0;
	float s = hsv.y;
	float v = hsv.z;

	float c = v * s;
	float x = c * (1.0 - abs(mod(h, 2.0) - 1.0));
	float m = v - c;

	vec3 rgb;
	if (h < 1.0) rgb = vec3(c, x, 0.0);
	else if (h < 2.0) rgb = vec3(x, c, 0.0);
	else if (h < 3.0) rgb = vec3(0.0, c, x);
	else if (h < 4.0) rgb = vec3(0.0, x, c);
	else if (h < 5.0) rgb = vec3(x, 0.0, c);
	else rgb = vec3(c, 0.0, x);

	return rgb + vec3(m);
}

// Pseudo-random function for shake
float random(vec2 st) {
	return fract(sin(dot(st, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;

	// === 1. Apply UV/Position Effects ===

	// Wave: offset Y based on X position and time
	if (wave_enabled > 0.5) {
		uv.y += sin(uv.x * wave_frequency + TIME * wave_speed) * wave_amplitude;
	}

	// Shake: random offset based on time
	if (shake_enabled > 0.5) {
		float time_seed = floor(TIME * shake_speed);
		uv.x += (random(vec2(time_seed, 0.0)) - 0.5) * shake_amount;
		uv.y += (random(vec2(0.0, time_seed)) - 0.5) * shake_amount;
	}

	// === 2. Sample Texture with modified UV ===
	vec4 color = texture(TEXTURE, uv);

	// === 3. Apply Color Effects ===

	// Rainbow: apply hue based on position and time
	if (rainbow_enabled > 0.5) {
		float hue = fract(UV.x * rainbow_frequency + TIME * rainbow_speed);
		vec3 rainbow_color = hsv_to_rgb(vec3(hue, rainbow_saturation, 1.0));
		// Multiply to preserve text shape (only colored pixels get rainbow)
		color.rgb *= rainbow_color;
	}

	// === 4. Apply Alpha Effects ===

	// Apparate: scattered fade based on progress
	if (apparate_enabled > 0.5) {
		float fade_start = apparate_progress - apparate_spread;
		float fade_end = apparate_progress;

		if (UV.x > fade_end) {
			color.a = 0.0;
		} else if (UV.x > fade_start) {
			float fade_factor = (fade_end - UV.x) / apparate_spread;
			color.a *= fade_factor;
		}
	}

	// Pulse: rhythmic alpha variation
	if (pulse_enabled > 0.5) {
		float pulse = mix(pulse_min_alpha, 1.0, (sin(TIME * pulse_speed) + 1.0) * 0.5);
		color.a *= pulse;
	}

	COLOR = color;
}
