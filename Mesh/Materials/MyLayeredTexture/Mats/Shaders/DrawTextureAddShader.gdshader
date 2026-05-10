shader_type texture_blit;
// Optional render modes:
render_mode blend_add /* default , also available: blend_mix, blend_add, blend_sub, blend_mul */;

uniform sampler2D source_texture : hint_blit_source0, filter_linear_mipmap, repeat_enable;
//uniform sampler2D source_texture1 : hint_blit_source1;
// up to 4 sources

void blit() {
     // Read sources and blit
     COLOR0 = texture(source_texture,UV) * MODULATE;
     //COLOR1 = texture(source_texture1,UV);
     // up to COLOR3
}