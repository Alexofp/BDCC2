// NOTE: Shader automatically converted from Godot Engine 4.4.beta4's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

uniform float roughness : hint_range(0.0, 1.0) = 1.0;

uniform float specular : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float metallic : hint_range(0.0, 1.0, 0.01) = 0.0;

uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale : hint_range(-16.0, 16.0) = 1.0;

uniform float clearcoat : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float clearcoat_roughness : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform sampler2D texture_clearcoat : hint_default_white, filter_linear_mipmap, repeat_enable;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

uniform sampler2D texture_color_mask : hint_default_black, filter_linear_mipmap, repeat_enable;
uniform vec4 colorR : source_color = vec4(0.0, 0.4, 0.918, 1.0);
uniform vec4 colorG : source_color = vec4(0.0, 0.631, 1.0, 1.0);
uniform vec4 colorB : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float glowR : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float glowG : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float glowB : hint_range(0.0, 1.0, 0.01) = 0.0;

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;

	METALLIC = metallic;
	SPECULAR = specular;

	ROUGHNESS = roughness;

	// Normal Map: Enabled
	NORMAL_MAP = texture(texture_normal, base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;

	// Clearcoat: Enabled
	vec2 clearcoat_tex = texture(texture_clearcoat, base_uv).xy;
	CLEARCOAT = clearcoat * clearcoat_tex.x;
	CLEARCOAT_ROUGHNESS = clearcoat_roughness * clearcoat_tex.y;

	{
		vec4 mask = texture(texture_color_mask, base_uv);
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

		ALBEDO = mix(ALBEDO, result.rgb, result.a);

		ROUGHNESS *= (1.0-mask.g*0.5);
		CLEARCOAT_ROUGHNESS *= (1.0-mask.g*0.5);
		//CLEARCOAT *= (1.0-mask.g);
		EMISSION = mask.r*color_r.rgb*color_r.a*glowR + mask.g*color_g.rgb*color_g.a*glowG + mask.b*color_b.rgb*color_b.a*glowB;
	}
}
