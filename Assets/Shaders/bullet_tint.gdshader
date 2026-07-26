shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(0.2, 0.55, 1.0, 1.0);

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	float luminance = dot(source.rgb, vec3(0.299, 0.587, 0.114));
	COLOR = vec4(tint_color.rgb * luminance, source.a * tint_color.a);
}
