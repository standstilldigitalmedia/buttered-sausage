shader_type canvas_item;

// Varying to pass vertex position to fragment shader for crawl fade
varying float vertex_y;

void vertex() {
	// Pass the local Y position to fragment shader for crawl fade calculation
	vertex_y = VERTEX.y;
}

// === UV/Position Effects (applied first) ===

// Wave: undulating motion
uniform float wave_enabled = 0.0;
uniform float wave_amplitude = 0.03;
uniform float wave_frequency = 10.0;
uniform float wave_speed = 3.0;
uniform float wave_horizontal = 0.0;  // 0 = vertical wave (up/down), 1 = horizontal wave (left/right)

// Shake: jittery random motion
uniform float shake_enabled = 0.0;
uniform float shake_amount = 0.02;
uniform float shake_speed = 20.0;

// Glitch: digital corruption with slice displacement and RGB separation
uniform float glitch_enabled = 0.0;
uniform float glitch_intensity = 0.5;
uniform float glitch_speed = 5.0;
uniform float glitch_block_size = 0.1;
uniform float glitch_color_drift = 0.02;

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

// === Crawl Effect (Star Wars style) ===

// Crawl: fade at top of viewport as text scrolls through
// Scrolling is handled by position tween + clip_contents, shader handles fade
uniform float crawl_enabled = 0.0;
uniform float crawl_fade_pixels = 20.0;  // Height of fade zone in pixels
uniform float crawl_label_position_y = 0.0;  // Label's current position.y (updated during scroll)

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

// Pseudo-random function
float random(vec2 st) {
	return fract(sin(dot(st, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	// Capture incoming modulation (includes font_color, modulate property, etc.)
	vec4 modulate_color = COLOR;
	vec2 uv = UV;

	// === Crawl Effect ===
	// Scrolling is handled by position tween + clip_contents on parent container
	// Shader handles fade at top of viewport
	float crawl_fade_factor = 1.0;

	if (crawl_enabled > 0.5 && crawl_fade_pixels > 0.0) {
		// vertex_y is the pixel position in label-local space (from vertex shader)
		// Add label's position.y to get position in viewport space
		float viewport_y = vertex_y + crawl_label_position_y;

		// Fade pixels near the top of viewport (viewport_y close to 0)
		if (viewport_y < crawl_fade_pixels) {
			crawl_fade_factor = max(0.0, viewport_y / crawl_fade_pixels);
		}
	}

	// === 1. Apply UV/Position Effects ===

	// Wave: offset based on position and time
	if (wave_enabled > 0.5) {
		if (wave_horizontal > 0.5) {
			// Horizontal wave: text moves left/right based on Y position
			uv.x += sin(uv.y * wave_frequency + TIME * wave_speed) * wave_amplitude;
		} else {
			// Vertical wave: text moves up/down based on X position
			uv.y += sin(uv.x * wave_frequency + TIME * wave_speed) * wave_amplitude;
		}
	}

	// Shake: random offset based on time
	if (shake_enabled > 0.5) {
		float time_seed = floor(TIME * shake_speed);
		uv.x += (random(vec2(time_seed, 0.0)) - 0.5) * shake_amount;
		uv.y += (random(vec2(0.0, time_seed)) - 0.5) * shake_amount;
	}

	// Glitch: horizontal slice displacement (UV component)
	float glitch_active = 0.0;
	if (glitch_enabled > 0.5) {
		// Intermittent glitch trigger based on time
		float glitch_time = floor(TIME * glitch_speed);
		float glitch_trigger = random(vec2(glitch_time, 1.0));

		// Only glitch some of the time based on intensity
		if (glitch_trigger < glitch_intensity) {
			glitch_active = 1.0;

			// Divide into horizontal blocks and offset each block
			float block = floor(uv.y / glitch_block_size);
			float block_random = random(vec2(block, glitch_time));

			// Offset block horizontally
			uv.x += (block_random - 0.5) * glitch_intensity * 0.15;

			// Occasional vertical jump for extra chaos
			if (random(vec2(glitch_time, block)) > 0.8) {
				uv.y += (random(vec2(block, glitch_time * 2.0)) - 0.5) * glitch_block_size;
			}
		}
	}

	// === 2. Sample Texture ===
	vec4 color;

	// Glitch: RGB channel separation (chromatic aberration)
	if (glitch_active > 0.5) {
		// Sample each color channel at slightly different positions
		float drift = glitch_color_drift * glitch_intensity;
		color.r = texture(TEXTURE, uv + vec2(drift, 0.0)).r;
		color.g = texture(TEXTURE, uv).g;
		color.b = texture(TEXTURE, uv - vec2(drift, 0.0)).b;
		color.a = texture(TEXTURE, uv).a;

		// Occasional color inversion for extra glitchiness
		float glitch_time = floor(TIME * glitch_speed);
		if (random(vec2(glitch_time, 3.0)) > 0.85) {
			color.rgb = vec3(1.0) - color.rgb;
		}
	} else {
		color = texture(TEXTURE, uv);
	}

	// === 3. Apply Color Effects ===

	// Rainbow: apply hue based on position and time
	if (rainbow_enabled > 0.5) {
		float hue = fract(UV.x * rainbow_frequency + TIME * rainbow_speed);
		vec3 rainbow_color = hsv_to_rgb(vec3(hue, rainbow_saturation, 1.0));
		// Multiply to preserve text shape (only colored pixels get rainbow)
		color.rgb *= rainbow_color;
	}

	// === 4. Apply Alpha Effects ===

	// Crawl: apply fade at top of viewport
	if (crawl_enabled > 0.5) {
		color.a *= crawl_fade_factor;
	}

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

	// Apply modulation: rainbow overrides RGB so only use alpha, others use full modulation
	if (rainbow_enabled > 0.5) {
		COLOR = vec4(color.rgb, color.a * modulate_color.a);
	} else {
		COLOR = color * modulate_color;
	}
}
