shader_type spatial;
//render_mode cull_disabled;

#include "KajiyaKayBSDF.gdshaderinc"

group_uniforms Color;
uniform vec3 root_color : source_color = vec3(0,0,0);
uniform vec3 tip_color : source_color = vec3(0,0,0);
uniform sampler2D diffuse_texture : source_color;
uniform vec3 primary_color : source_color = vec3(1.0);
uniform vec3 secondary_color : source_color = vec3(1.0);

group_uniforms SpecularHighlights;
uniform float primary_shift : hint_range(-4, 4) = 0.0;
uniform float secondary_shift : hint_range(-4, 4) = 0.5;
uniform sampler2D specular_shift : hint_default_white;
uniform float specular_power : hint_range(0, 500) = 20;
uniform float specular_width : hint_range(0, 1) = 0.5;
uniform float specular_scale : hint_range(0, 1) = 0.3;
uniform float ambient_occlusion : hint_range(0.0, 1.0) = 1.0;

group_uniforms Structural;
uniform float scatter : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform bool use_diffuse_texture;
uniform sampler2D property_tex : hint_default_white; // Red = AO, Green = Nothing, Blue = Root-tips-gradient, Alpha = Alpha
uniform sampler2D hair_normal_map : hint_roughness_normal;

group_uniforms ColorMask;
uniform sampler2D texture_color_mask : hint_default_transparent, filter_linear_mipmap, repeat_enable;
uniform vec4 color_mask_r : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 color_mask_g : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform vec4 color_mask_b : source_color = vec4(0.0, 0.0, 1.0, 1.0);

varying vec3 binormal;

void fragment(){
	mediump vec4 property = texture(property_tex, UV);
	//vec4 property = texture(property_tex, UV);
	vec3 basecolor = mix(root_color.rgb, tip_color.rgb, property.b);
	if(use_diffuse_texture){
		vec3 base_hair = texture(diffuse_texture, UV).rgb;
		ALBEDO = base_hair;
	} else {
		ALBEDO = basecolor;
	}
	ALBEDO.rgb = mix(ALBEDO.rgb, ALBEDO.rgb*COLOR.rgb, ambient_occlusion);
	
{
	vec4 colormask_tex = texture(texture_color_mask, UV2);

	float maskSum = colormask_tex.r + colormask_tex.g + colormask_tex.b;
	maskSum = max(maskSum, 1.0);
	colormask_tex.rgb /= maskSum;

	vec4 color_r = color_mask_r;
	vec4 color_g = color_mask_g;
	vec4 color_b = color_mask_b;

	vec4 colormask_result = vec4(0.0);
	colormask_result += colormask_tex.r*color_r*color_r.a;
	colormask_result += colormask_tex.g*color_g*color_g.a;
	colormask_result += colormask_tex.b*color_b*color_b.a;

	colormask_result.a *= colormask_tex.a;

	ALBEDO.rgb = mix(ALBEDO.rgb, colormask_result.rgb, colormask_result.a);
}
	
	NORMAL_MAP = texture(hair_normal_map, UV).rgb;
	AO = property.r;
	ALPHA = property.a;
	//ALPHA_HASH_SCALE = 0.1;
	ALPHA_SCISSOR_THRESHOLD = 0.1;
	binormal = BINORMAL;
}

void light()
{
	float shift_tex = texture(specular_shift, UV).r - 0.5;
	vec3 N = normalize(NORMAL);
	vec3 B = normalize(binormal);
	vec3 V = normalize(VIEW);
	vec3 L = normalize(LIGHT);

	// Energy conserving lambert wrap shader.
	// https://web.archive.org/web/20210228210901/http://blog.stevemcauley.com/2011/12/03/energy-conserving-wrapped-diffuse/
	// Simulates multiple scattering very well.
	float ambientdiffuse = max(0.0, (dot(N, L) + ROUGHNESS) / ((1.0 + ROUGHNESS) * (1.0 + ROUGHNESS))) * (1.0 / PI) * scatter;

	vec3 specular = specular_kajiya_kay(shift_tex, primary_color, primary_shift, secondary_color, secondary_shift, N, B, V, L, specular_power, specular_width, specular_scale);

	DIFFUSE_LIGHT += ambientdiffuse * LIGHT_COLOR * ATTENUATION;
	SPECULAR_LIGHT += specular * LIGHT_COLOR * ATTENUATION * SPECULAR_AMOUNT;
}
