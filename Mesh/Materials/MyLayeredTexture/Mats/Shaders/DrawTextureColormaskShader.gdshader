shader_type texture_blit;
// Optional render modes:
render_mode blend_mix /* default , also available: blend_add, blend_sub, blend_mul */;

uniform sampler2D source_texture : hint_blit_source0, filter_linear_mipmap, repeat_enable;
//uniform sampler2D source_texture1 : hint_blit_source1;
// up to 4 sources

//uniform sampler2D texture_color_mask : hint_default_black, filter_linear_mipmap, repeat_enable;
uniform vec4 colorR : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 colorG : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 colorB : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void blit() {
	vec4 mask = texture(source_texture, UV);
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
	
     // Read sources and blit
     COLOR0 = result;//texture(source_texture,UV) * MODULATE;
     //COLOR1 = texture(source_texture1,UV);
     // up to COLOR3
}