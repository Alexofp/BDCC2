// NOTE: Shader automatically converted from Godot Engine 4.4.beta2's CanvasItemMaterial.

shader_type canvas_item;
render_mode blend_mix;
//render_mode blend_premul_alpha;

uniform sampler2D texture_color_mask : hint_default_black, filter_linear_mipmap, repeat_enable;
uniform vec4 colorR : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 colorG : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 colorB : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment(){
	vec4 mask = texture(texture_color_mask, UV);
	float maskF = mask.r + mask.g + mask.b;
	maskF = max(maskF, 1.0);
	mask.rgb /= maskF;

	vec4 color_r = colorR;
	vec4 color_g = colorG;
	vec4 color_b = colorB;

    vec4 result = vec4(0.0);
	result += mask.r*color_r*color_r.a;
	result += mask.g*color_g*color_g.a;
	result += mask.b*color_b*color_b.a;

	result.a *= mask.a;

    // Output the final color
    COLOR = result;
}