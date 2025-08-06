shader_type spatial;

//{{DEFINES_PLACEHOLDER}}

render_mode
blend_mix,
#ifdef MY_ALPHASUPPORT
depth_prepass_alpha,
#endif
depth_draw_opaque,
#ifdef MY_TOONSHADING
diffuse_toon,
#else
diffuse_burley,
#endif
specular_schlick_ggx,
#ifdef MY_SUBSURFACESCATTER_SKIN
sss_mode_skin,
#endif
#ifdef MY_UNSHADED
unshaded,
#endif
#ifdef MY_DOUBLESIDED
cull_disabled
#else
cull_back
#endif
;

uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
#ifdef MY_NORMAL_MAP
uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
#endif
#ifdef MY_BENT_NORMAL_MAP
uniform sampler2D texture_bent_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
#endif
#ifdef MY_PBR_TREE_TEXTURES
uniform sampler2D texture_ambient_occlusion : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
#endif
#ifdef MY_PBR_ORM
uniform sampler2D texture_orm : hint_roughness_g, filter_linear_mipmap, repeat_enable;
#endif
#ifdef MY_PBR_EmissionTexture
uniform sampler2D texture_emission : source_color, hint_default_black, filter_linear_mipmap, repeat_enable;
#endif

uniform vec4 albedo : source_color = vec4(1.0);
uniform float normal_scale : hint_range(-16.0, 16.0) = 1.0;
uniform float ao_light_affect : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float ao_mult : hint_range(0.0, 2.0, 0.01) = 1.0;
uniform float roughness : hint_range(0.0, 2.0) = 1.0;
uniform float specular : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float metallic : hint_range(0.0, 2.0, 0.01) = 1.0;
//#define MY_PBR_EMISSION
#ifdef MY_PBR_EMISSION
uniform vec3 emission : source_color = vec3(1.0);
uniform float emission_energy : hint_range(0.0, 20.0, 0.01) = 1.0;
#endif

#ifdef MY_PBR_CLEARCOAT
uniform float clearcoat : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float clearcoat_roughness : hint_range(0.0, 1.0, 0.01) = 0.5;
#endif

#ifdef MY_PBR_ANISOTROPY
uniform float anisotropy_ratio : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform sampler2D texture_anisotropy_flowmap : hint_anisotropy, filter_linear_mipmap, repeat_enable;
#endif

#ifdef MY_ALPHAMASK
uniform sampler2D texture_alpha : hint_default_black, filter_nearest, repeat_enable;
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0, 0.001) = 0.5;
#endif

#ifdef MY_RIMLIGHT
uniform float rim : hint_range(0.0, 3.0, 0.01) = 1.0;
uniform float rim_tint : hint_range(0.0, 1.0, 0.01) = 0.5;
//uniform sampler2D texture_rim : hint_default_white, filter_linear_mipmap, repeat_enable;
#endif

#ifdef MY_SUBSURFACESCATTER
uniform float subsurface_scattering_strength : hint_range(0.0, 1.0, 0.01) = 0.5;
//uniform sampler2D texture_subsurface_scattering : hint_default_white, filter_linear_mipmap, repeat_enable;
#endif

#ifdef MY_BACKLIGHT
uniform vec4 backlight : source_color = vec4(0.3, 0.24, 0.24, 1.0);
//uniform sampler2D texture_backlight : hint_default_black, filter_linear_mipmap, repeat_enable;
#endif

uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0);
//uniform vec3 uv2_scale = vec3(1.0, 1.0, 1.0);
//uniform vec3 uv2_offset = vec3(0.0);

#ifdef MY_FRESHNEL
uniform float freshnel_width : hint_range(0.0, 30.0, 0.1) = 5.0;
uniform float freshnel_mod : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform vec4 freshnel_color : source_color = vec4(0.0,0.0,0.0,1.0);

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view))-freshnel_mod, 0.0, 1.0 )), amount);
}
#endif

//#define MY_COLORMASK
#ifdef MY_COLORMASK
uniform sampler2D texture_color_mask : hint_default_transparent, filter_linear_mipmap, repeat_enable;
uniform vec4 color_mask_r : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 color_mask_g : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform vec4 color_mask_b : source_color = vec4(0.0, 0.0, 1.0, 1.0);
#endif

//#define MY_GLOBALDETAILROUGHMAP
#ifdef MY_GLOBALDETAILROUGHMAP
uniform sampler2D texture_detail_rough_global : hint_roughness_b, filter_linear_mipmap, repeat_enable;
uniform float detail_rough_scale : hint_range(0.01, 100.0, 0.01) = 1.0;
uniform float detail_rough_blend : hint_range(0.01, 3.0, 0.01) = 1.0;

#endif
//#define MY_GLOBALDETAILMAP
#ifdef MY_GLOBALDETAILMAP
uniform sampler2D texture_detail_normal_global : hint_normal, filter_linear_mipmap, repeat_enable;
uniform float detail_normal_scale : hint_range(0.01, 100.0, 0.01) = 1.0;
uniform float detail_normal_blend : hint_range(0.01, 3.0, 0.01) = 1.0;

vec3 _simple_normal_blend(vec3 b, vec3 d) {
	return vec3(b.xy + d.xy - 0.5, 1.0);
}

vec3 udm_normal_blend(vec3 b, vec3 d) {
	b = b*2.0 - 1.0;
	d = d*2.0 - 1.0;
	vec3 r = vec3(b.xy + d.xy, b.z);
	r = normalize(r);
	return r*0.5 + 0.5;
}
#endif

//#define MY_OUTLINE
#ifdef MY_OUTLINE
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_thickness : hint_range(0.0, 1.0) = 0.8;
#endif

#ifdef MY_EDGE_OUTLINE_1
uniform float outline1_thickness : hint_range(0.0, 1000.0, 0.01) = 1.0;
uniform float outline1_contrast : hint_range(0.0, 5.0, 0.01) = 1.0;
uniform vec4 outline1_color : source_color;
#endif
#ifdef MY_EDGE_OUTLINE_2
uniform float outline2_thickness : hint_range(0.0, 1000.0, 0.01) = 1.0;
uniform float outline2_contrast : hint_range(0.0, 5.0, 0.01) = 1.0;
uniform vec4 outline2_color : source_color;
#endif

//#define MY_MESSLAYER
#ifdef MY_MESSLAYER
uniform sampler2D texture_mess_layer: source_color, hint_default_white, filter_linear_mipmap, repeat_enable;
uniform float messLayerScale : hint_range(0.0, 10.0) = 1.0;

uniform sampler2D texture_mess_mask: hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 messColor : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float messRoughness : hint_range(0.0, 1.0) = 0.0;
uniform float messScroll : hint_range(0.0, 1.0) = 0.0;

uniform float messCutoff : hint_range(0.0, 1.0) = 0.0;
uniform float messSmoothSize : hint_range(0.0, 1.0) = 0.1;
#endif

//#define MY_EXTRA_LAYER
#ifdef MY_EXTRA_LAYER
uniform vec4 extra_albedo : source_color = vec4(1.0);
uniform sampler2D texture_extra_albedo : source_color, filter_linear_mipmap, repeat_enable, hint_default_transparent;
uniform sampler2D texture_extra_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_extra_orm : hint_roughness_g, filter_linear_mipmap, repeat_enable;
	#ifdef MY_RIMLIGHT
uniform float extra_rim : hint_range(0.0, 100.0, 0.01) = 1.0;
uniform float extra_rim_tint : hint_range(0.0, 1.0, 0.01) = 0.5;
	#endif
#endif

// ratio 0.0 returns 0.0
// ratio 0.5 returns value*0.5
// ratio 1.0 returns value
// ratio 1.5 returns value*0.5 + 0.5
// ratio 2.0 returns 1.0
float bilinearLerp(float value, float ratio) {
	return value * (clamp(ratio, 0.0, 1.0) - clamp(-1.0+ratio, 0.0, 1.0)) + 1.0 * max(ratio-1.0, 0.0);
}

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;

#ifdef MY_UV_BASED_DISCARD
	if(base_uv.y < 0.0)
		discard;
#endif

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	vec4 orm_tex = vec4(1.0, 1.0, 0.0, 1.0);
#ifdef MY_PBR_ORM
	orm_tex = texture(texture_orm, base_uv);
#endif
#ifdef MY_PBR_TREE_TEXTURES
	orm_tex = vec4(texture(texture_ambient_occlusion, base_uv).r, texture(texture_roughness, base_uv).r, texture(texture_metallic, base_uv).r, 1.0);
#endif
#ifdef MY_PBR_ORME
	vec3 emission_tex = vec3(orm_tex.a);
#endif
#ifdef MY_PBR_EmissionTexture
	vec3 emission_tex = texture(texture_emission, base_uv).rgb;
#endif
#ifdef MY_PBR_EMISSION
	EMISSION = emission_tex * emission * emission_energy;
#endif

	ALBEDO = albedo.rgb * albedo_tex.rgb;
#ifdef MY_NORMAL_MAP
	NORMAL_MAP = texture(texture_normal, base_uv).rgb;
#endif
#ifdef MY_BENT_NORMAL_MAP
	BENT_NORMAL_MAP = texture(texture_bent_normal, base_uv).rgb;
#endif

	AO = bilinearLerp(orm_tex.r, ao_mult);
	ROUGHNESS = bilinearLerp(orm_tex.g, roughness);
	METALLIC = bilinearLerp(orm_tex.b, metallic);

	NORMAL_MAP_DEPTH = normal_scale;
	AO_LIGHT_AFFECT = ao_light_affect;
	SPECULAR = specular;

#ifdef MY_PBR_CLEARCOAT
	CLEARCOAT = clearcoat;
	CLEARCOAT_ROUGHNESS = clearcoat_roughness;
#endif

#ifdef MY_PBR_ANISOTROPY
	vec3 anisotropy_tex = texture(texture_anisotropy_flowmap, base_uv).rga;
	ANISOTROPY = anisotropy_ratio * anisotropy_tex.b;
	ANISOTROPY_FLOW = anisotropy_tex.rg * 2.0 - 1.0;
#endif

#ifdef MY_ALBEDO_MATCAP
{
	//vec2 matcapUV = (NORMAL.xy * vec2(0.5, -0.5) + vec2(0.5, 0.5));
	//ALBEDO = texture(texture_albedo, matcapUV).rgb * albedo.rgb;

	// With normal map support
	vec3 normalV = mat3(TANGENT, BINORMAL, NORMAL) * (NORMAL_MAP.xyz*2.0-1.0);
	vec2 matcapUV = (normalV.xy * vec2(0.5, -0.5) + vec2(0.5, 0.5));
	ALBEDO = texture(texture_albedo, matcapUV).rgb * albedo.rgb;
}
#endif

#ifdef MY_COLORMASK
{
	vec4 colormask_tex = texture(texture_color_mask, base_uv);

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
#endif

#ifdef MY_FRESHNEL
	// Freshnel: Enabled
	float basic_fresnel = fresnel(freshnel_width, NORMAL, VIEW);
	basic_fresnel = smoothstep(0.0, 1.0, basic_fresnel); //0.5 magic number seems to give the most intuitive control
	ALBEDO = mix(ALBEDO, freshnel_color.rgb, basic_fresnel*freshnel_color.a);// - basic_fresnel;
#endif

#ifdef MY_RIMLIGHT
	// Rim: Enabled
	//vec2 rim_tex = texture(texture_rim, base_uv).xy;
	RIM = rim;// * rim_tex.x;// - basic_fresnel*2.5;
	RIM_TINT = rim_tint;// * rim_tex.y;
#endif

#ifdef MY_SUBSURFACESCATTER
	// Subsurface Scattering: Enabled
	//float sss_tex = texture(texture_subsurface_scattering, base_uv).r;
	SSS_STRENGTH = subsurface_scattering_strength;// * sss_tex;
#endif

#ifdef MY_BACKLIGHT
	// Backlight: Enabled
	//vec3 backlight_tex = texture(texture_backlight, base_uv).rgb;
	BACKLIGHT = (backlight.rgb);// + backlight_tex);
#endif

#ifdef MY_ALPHAMASK
	vec4 alpha_tex = texture(texture_alpha, base_uv);
	ALPHA *= (1.0 - alpha_tex.r);
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
#endif

#ifdef MY_ALPHASUPPORT
	ALPHA *= albedo_tex.a*albedo.a;
#endif

#ifdef MY_GLOBALDETAILMAP
	vec3 detail_norm_tex_global = texture(texture_detail_normal_global, base_uv*detail_normal_scale).rgb; // base_uv
	detail_norm_tex_global = mix(vec3(0.5,0.5,1.0), detail_norm_tex_global, detail_normal_blend);
	NORMAL_MAP = udm_normal_blend(NORMAL_MAP, detail_norm_tex_global); //_simple_normal_blend
#endif

#ifdef MY_GLOBALDETAILROUGHMAP
	vec3 detail_rough_tex_global = texture(texture_detail_rough_global, base_uv*detail_rough_scale).rgb; // base_uv
	detail_rough_tex_global.g = detail_rough_tex_global.g * (detail_rough_blend) + 1.0 - detail_rough_blend;

	//detail_rough_tex_global.rgb = mix(vec3(0.5,0.5,1.0), detail_norm_tex_global, detail_normal_blend);
	//NORMAL_MAP = udm_normal_blend(NORMAL_MAP, detail_norm_tex_global); //_simple_normal_blend
	ROUGHNESS *= detail_rough_tex_global.g;
#endif

#ifdef MY_EXTRA_LAYER
{
	vec4 extra_albedo_tex = texture(texture_extra_albedo, base_uv);
	vec4 extra_final_albedo = extra_albedo * extra_albedo_tex;
	vec3 extra_normal_tex = texture(texture_extra_normal, base_uv).rgb;
	vec4 extra_orm_tex = texture(texture_extra_orm, base_uv);

	ALBEDO = mix(ALBEDO, extra_final_albedo.rgb, extra_final_albedo.a);
	NORMAL_MAP = mix(NORMAL_MAP, extra_normal_tex.rgb, extra_final_albedo.a);
	AO = mix(AO, extra_orm_tex.r, extra_final_albedo.a);
	ROUGHNESS = mix(ROUGHNESS, extra_orm_tex.g, extra_albedo_tex.a);
	METALLIC = mix(METALLIC, extra_orm_tex.b, extra_final_albedo.a);
#ifdef MY_RIMLIGHT
	RIM = mix(RIM, extra_rim, extra_final_albedo.a);
	RIM_TINT = mix(RIM_TINT, extra_rim_tint, extra_final_albedo.a);
#endif
#ifdef MY_SUBSURFACESCATTER
	SSS_STRENGTH = mix(SSS_STRENGTH, 0.0, extra_final_albedo.a);
#endif
}
#endif

#ifdef MY_MESSLAYER

	vec4 mess_tex = texture(texture_mess_layer, (base_uv + vec2(messScroll*3.3, messScroll) - vec2(0.0, TIME*0.001))*messLayerScale);
	vec4 mess_mask_tex = texture(texture_mess_mask, base_uv);

	float messValue = mess_tex.a;
	float messAlphaAlpha = smoothstep(messCutoff, messCutoff + messSmoothSize, messValue * (1.0 - messSmoothSize) + messSmoothSize);

	float messAlpha = mess_tex.a * mess_mask_tex.r * messColor.a * messAlphaAlpha;

	ALBEDO = mix(ALBEDO, mess_tex.rgb*messColor.rgb, messAlpha);
	ROUGHNESS = mix(ROUGHNESS, messRoughness, messAlpha);

	BACKLIGHT = mix(BACKLIGHT, vec3(0.5, 0.5, 0.5), messAlpha);
	//SPECULAR = 3.0;//mix(SPECULAR, 30.0, min(messAlpha*3.0, 1.0));
	//RIM = mix(RIM, 1.0, messAlpha);
	//RIM_TINT = mix(RIM_TINT, 1.0, messAlpha);
#endif

#ifdef MY_EDGE_OUTLINE
{
	vec3 nOutline = normalize(NORMAL);
	vec3 dxOutline = dFdx(nOutline);
	vec3 dyOutline = dFdy(nOutline);
	float edgeOutline = dot(dxOutline, dxOutline) + dot(dyOutline, dyOutline);
	edgeOutline /= dot(VERTEX, VERTEX);
	edgeOutline /= (VIEWPORT_SIZE.x / VIEWPORT_SIZE.y);

#ifdef MY_EDGE_OUTLINE_1
	{
		float finalOutline = edgeOutline * outline1_thickness;
		finalOutline = (finalOutline - 0.5) * outline1_contrast + 0.5;
		ALBEDO = mix(ALBEDO, outline1_color.rgb, clamp(finalOutline * outline1_color.a, 0.0, 1.0));
	}
#endif
#ifdef MY_EDGE_OUTLINE_2
	{
		float finalOutline = edgeOutline * outline2_thickness;
		finalOutline = (finalOutline - 0.5) * outline2_contrast + 0.5;
		ALBEDO = mix(ALBEDO, outline2_color.rgb, clamp(finalOutline * outline2_color.a, 0.0, 1.0));
	}
#endif
}
#endif

#ifdef MY_OUTLINE
{
	float rimOutline = 1.0 - max(dot(NORMAL, VIEW), 0.0); // VIEW is camera dir

    vec3 nOutline = normalize(NORMAL);
    vec3 dxOutline = dFdx(nOutline);
    vec3 dyOutline = dFdy(nOutline);
    float edgeOutline = dot(dxOutline, dxOutline) + dot(dyOutline, dyOutline);
	edgeOutline /= dot(VERTEX, VERTEX);

    if (edgeOutline > 0.000001 && rimOutline > outline_thickness) {
        ALBEDO = mix(ALBEDO, outline_color.rgb, outline_color.a);
    }
}
#endif

}

//#define MY_CUSTOM_SHADING
#ifdef MY_CUSTOM_SHADING
uniform float shadow_size = 0.045;
uniform float shadow_blend = 0.001;
uniform float shadow_extra_intensity = 0.0;
uniform vec4 shadow_color : source_color;
uniform vec4 light_tint : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform float rimlight_size = 0.921;
uniform float rimlight_blend = 0.01;
uniform vec4 rimlight_color : source_color;
uniform vec3 normal_bias = vec3(0.0);
uniform vec3 light_bias = vec3(0.0);

float light_fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void light(){
	float NdotL = dot(NORMAL + normal_bias, LIGHT + light_bias);

	float rounded = smoothstep(shadow_size, shadow_blend + shadow_size, NdotL);
	rounded = mix(1.0, rounded, shadow_color.a);
	float one_minus = 1.0 - rounded;
	vec3 mult1 = LIGHT_COLOR * rounded * light_tint.rgb * ATTENUATION;
	vec3 mult2 = (one_minus * 1.4 * shadow_color.rgb) - shadow_extra_intensity;
	vec3 add1 = mult1 + mult2;

	float add3  = rimlight_blend + rimlight_size;
	float basic_fresnel = light_fresnel(1.0, NORMAL, VIEW);
	float smoothed = smoothstep(rimlight_size, add3, basic_fresnel);

	vec3 add2 = add1 + smoothed * rimlight_color.rgb;
	DIFFUSE_LIGHT += ALBEDO * add2;
}
#endif