shader_type canvas_item;

uniform sampler2D displacement : source_color, repeat_enable;
uniform sampler2D base_flame : source_color;
uniform vec2 displacement_scale;

void fragment() {
	vec2 uv_offset = vec2(0.0, TIME);
	vec4 displacement_amount = texture(displacement, UV * displacement_scale + uv_offset);
	uv_offset = displacement_amount.xy - vec2(0.6);
	uv_offset *= 1.0 - UV.y;
	vec4 col = texture(base_flame, UV + uv_offset);
	COLOR.rgb = col.rgb;
	COLOR.a *= col.a;
}