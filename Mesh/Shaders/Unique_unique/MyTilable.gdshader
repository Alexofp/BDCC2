// NOTE: Shader automatically converted from Godot Engine 4.3.stable's ORMMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

//uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
//uniform float point_size : hint_range(0.1, 128.0, 0.1);
uniform sampler2D texture_orm : hint_roughness_g, filter_linear_mipmap, repeat_enable;

uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
//uniform float normal_scale : hint_range(-16.0, 16.0);

uniform float ao_light_affect : hint_range(0.0, 1.0, 0.01);
uniform float specular: hint_range(0.0, 1.0, 0.01) = 0.5;

uniform vec2 uv1_scale = vec2(1.0);
uniform vec2 uv1_offset = vec2(0.0);

instance uniform float roughness_mult : hint_range(0.0, 1.0, 0.01) = 0.5;
instance uniform vec3 color_tile_base : source_color, instance_index(12) = vec3(1.0);

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
	//UV = UV * uv1_scale + vec2(uv1_offset, uv1_offset);//* uv1_scale.xy + uv1_offset.xy;
	//UV.xy = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz * uv1_scale * uv1_scale_final + vec2(uv1_offset, uv1_offset);
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo_tex.rgb * color_tile_base.rgb; //albedo.rgb *

	vec4 orm_tex = texture(texture_orm, base_uv);
	float roughnessRemapped = (roughness_mult - 0.5)*2.0; // -1.0, 1.0
	ROUGHNESS = (orm_tex.g * (0.5 - abs(roughness_mult-0.5))*2.0) + max(0.0, roughnessRemapped);
 	METALLIC = orm_tex.b;
	SPECULAR = specular;

	// Normal Map: Enabled
	NORMAL_MAP = texture(texture_normal, base_uv).rgb;
	NORMAL_MAP_DEPTH = 1.0;//normal_scale;

	// Ambient Occlusion: Enabled
	AO = orm_tex.r;
	AO_LIGHT_AFFECT = ao_light_affect;
}
