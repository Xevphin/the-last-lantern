shader_type canvas_item;
render_mode unshaded;
uniform float hit_flash : hint_range(0.0, 1.0) = 0.0;
uniform float dissolve : hint_range(0.0, 1.0) = 0.0;
uniform float exposed : hint_range(0.0, 1.0) = 0.0;
varying vec4 vertex_tint;
void vertex() {
	vertex_tint = COLOR;
}
void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec2 cell = floor(UV * vec2(32.0, 40.0));
	float noise = fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453);
	tex.a *= step(dissolve, noise + 0.001);
	tex.rgb = mix(tex.rgb, vec3(1.0, 0.92, 0.68), hit_flash);
	tex.rgb += vec3(0.35, 0.2, 0.035) * exposed;
	COLOR = tex * vertex_tint;
}
