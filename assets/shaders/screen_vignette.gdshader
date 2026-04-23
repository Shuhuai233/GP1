shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0, 0.0, 0.0, 0.5);
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float inner_radius : hint_range(0.0, 1.0) = 0.4;
uniform float outer_radius : hint_range(0.0, 1.0) = 0.8;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv) * 2.0;
	float vignette = smoothstep(inner_radius, outer_radius, dist);
	COLOR = vec4(color.rgb, vignette * intensity);
}
