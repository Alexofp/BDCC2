shader_type texture_blit;
// Optional render modes:
render_mode blend_mix /* default , also available: blend_mix, blend_add, blend_sub, blend_mul */;

uniform sampler2D source_texture : hint_blit_source0, filter_linear_mipmap, repeat_enable;
//uniform sampler2D source_texture1 : hint_blit_source1;
// up to 4 sources

uniform float cutoff : hint_range(0.0, 1.0) = 0.5;
uniform float smooth_size : hint_range(0.0, 1.0) = 0.2;
//uniform sampler2D mask : filter_linear_mipmap, repeat_enable, hint_default_white;
uniform sampler2D alpha_mask : filter_linear_mipmap, repeat_enable, hint_default_white;
uniform float alpha_mask_scroll : hint_range(0.0, 10.0) = 0.0;

void blit() {
	float alphaMask = texture(alpha_mask, UV).r;
	float value = texture(source_texture, UV+vec2(alpha_mask_scroll, -alpha_mask_scroll*7.7321)).r;
	float alpha = MODULATE.a*alphaMask*smoothstep(cutoff, cutoff + smooth_size, value * (1.0 - smooth_size) + smooth_size);
	
	 // Read sources and blit
	 COLOR0 = vec4(MODULATE.rgb, alpha);//texture(source_texture,UV) * MODULATE;
	 //COLOR1 = texture(source_texture1,UV);
	 // up to COLOR3
}
