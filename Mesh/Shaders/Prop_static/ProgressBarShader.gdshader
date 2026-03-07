shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, unshaded, shadows_disabled;

uniform vec4 colorOutline : source_color;
uniform vec4 colorFill : source_color;
uniform sampler2D texture_outline : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_fill : source_color, filter_linear_mipmap, repeat_enable;
instance uniform float progress : hint_range(0.0, 1.0, 0.001);
uniform float edge : hint_range(0.0, 1.0, 0.01);

uniform vec2 uv1_scale = vec2(1.0, 1.0);
uniform vec2 uv1_offset;

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;

	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			MAIN_CAM_INV_VIEW_MATRIX[0],
			MAIN_CAM_INV_VIEW_MATRIX[1],
			MAIN_CAM_INV_VIEW_MATRIX[2],
			MODEL_MATRIX[3]);

	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
			vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
			vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
			vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	vec2 base_uv = UV;

	vec4 outline_tex = texture(texture_outline, base_uv);
	vec4 fill_tex = texture(texture_fill, base_uv);

	float t = smoothstep(progress - edge, progress, base_uv.x / (1.0+edge));
	float fillMask = 1.0 - t;

	vec3 outline_col = colorOutline.rgb * outline_tex.rgb;
	vec3 fill_col    = colorFill.rgb * fill_tex.rgb;

	float outline_a = colorOutline.a * outline_tex.a;
	float fill_a    = colorFill.a * fill_tex.a * fillMask;

	vec3 final_rgb = outline_col * outline_a + fill_col * fill_a * (1.0 - outline_a);
	float final_a  = outline_a + fill_a * (1.0 - outline_a);

	ALBEDO = final_rgb / max(final_a, 0.0001);
	ALPHA = final_a;
}
