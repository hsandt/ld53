shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// Gradient max (and start) value
uniform float gradient_max_value = 1.0;
// UV's V value where gradient stops
uniform float gradient_max_v = 1.0;
// Gradient color
uniform vec3 gradient_color : source_color = vec3(1.0, 1.0, 1.0);

void fragment() {
	float gradient_level = gradient_max_value * max(0.0, 1.0 - SCREEN_UV.y / gradient_max_v);
	COLOR = vec4(gradient_color, gradient_level);
}
