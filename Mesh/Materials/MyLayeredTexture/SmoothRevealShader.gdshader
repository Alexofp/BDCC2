shader_type canvas_item;
render_mode blend_mix;

uniform float cutoff : hint_range(0.0, 1.0) = 0.5;
uniform float smooth_size : hint_range(0.0, 1.0) = 0.2;
uniform sampler2D mask : filter_linear_mipmap, repeat_enable, hint_default_white;
uniform sampler2D alpha_mask : filter_linear_mipmap, repeat_enable, hint_default_white;
uniform float alpha_mask_scroll : hint_range(0.0, 10.0) = 0.0;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment()
{
	float alphaMask = texture(alpha_mask, UV).r;
	float value = texture(mask, UV+vec2(alpha_mask_scroll, -alpha_mask_scroll*7.7321)).r;
	float alpha = color.a*alphaMask*smoothstep(cutoff, cutoff + smooth_size, value * (1.0 - smooth_size) + smooth_size);
	COLOR = vec4(color.rgb, alpha);
}