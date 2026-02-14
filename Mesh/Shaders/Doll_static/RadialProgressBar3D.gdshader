shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, unshaded;

uniform vec4 albedo : source_color = vec4(1.0);
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_back : source_color, filter_linear_mipmap, repeat_enable, hint_default_transparent;
uniform vec4 color_back : source_color = vec4(1.0);
uniform float alpha_final: hint_range(0.0, 1.0, 0.01) = 1.0;

uniform sampler2D progressImage : filter_linear_mipmap, repeat_enable, hint_default_white;
uniform float amount: hint_range(0.0, 1.0, 0.01);
uniform float smoothness : hint_range(0.0, 1.0, 0.01) = 0.02;

uniform vec3 uv1_scale = vec3(1.0);
uniform vec3 uv1_offset;

uniform float mesh_size = 1.0;

void vertex() {
	VERTEX *= mesh_size;
	
	UV = UV * uv1_scale.xy + uv1_offset.xy;

	// Billboard Mode: Enabled
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			MAIN_CAM_INV_VIEW_MATRIX[0],
			MAIN_CAM_INV_VIEW_MATRIX[1],
			MAIN_CAM_INV_VIEW_MATRIX[2],
			MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	vec2 base_uv = UV;

	vec4 back_tex = texture(texture_back, base_uv);
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;

	ALPHA *= albedo.a * albedo_tex.a;
	
	float half = smoothness * 0.5;
	float mask = texture(progressImage, base_uv).r;
	//float alpha_mask = smoothstep(amount - half, amount + half, mask);
	float amountAdj = amount * (1.0 + smoothness);
	float alpha_mask = smoothstep(amountAdj - smoothness, amountAdj , mask);
	
	ALBEDO = mix(back_tex.rgb*color_back.rgb, ALBEDO.rgb, ALPHA*alpha_mask);
	
	ALPHA = max(ALPHA * alpha_mask, back_tex.a*color_back.a) * alpha_final;
	
	
	//ALPHA -= (1.0-progressColor.r) * amount;
}
