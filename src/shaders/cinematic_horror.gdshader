shader_type canvas_item;

// Cinematic CCTV & Survival Horror Post-Processing Shader
// Shadow of Lanna: Midnight Rite

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.45;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.85;
uniform float grain_amount : hint_range(0.0, 0.2) = 0.035;
uniform vec4 tint_color : source_color = vec4(0.9, 0.95, 1.05, 1.0);

float random(vec2 uv) {
	return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	
	// Vignette (darkened corners like CCTV / classic horror lens)
	vec2 centered = uv - vec2(0.5);
	float dist = length(centered);
	float vignette = smoothstep(0.75 - vignette_intensity, 0.75, dist);
	
	// Subtle film grain
	float grain = (random(uv + vec2(TIME * 0.1)) - 0.5) * grain_amount;
	
	vec4 color = textureLod(screen_texture, uv, 0.0);
	color.rgb = mix(color.rgb, vec3(0.0), vignette * vignette_opacity);
	color.rgb += grain;
	color.rgb *= tint_color.rgb;
	
	COLOR = color;
}
