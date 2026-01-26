shader_type spatial;
render_mode unshaded, fog_disabled, depth_draw_never; //, depth_prepass_alpha

//uniform vec3 fog_center = vec3(0.0, 0.0, 0.0);
uniform float fog_radius = 10.0;
uniform float fog_falloff = 5.0;
uniform vec4 fog_color : source_color = vec4(0.6, 0.7, 0.8, 1.0);
uniform float fog_strength = 1.0;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
//uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

varying mat4 inv_view_mat;
varying vec3 v_world_pos;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
	inv_view_mat = INV_VIEW_MATRIX;
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
    vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
    vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
    view.xyz /= view.w;
    vec3 world_position = (INV_VIEW_MATRIX * vec4(view.xyz, 1.0)).xyz;

    float d = distance(world_position, v_world_pos);

    float fog = smoothstep(
        fog_radius,
        fog_radius + fog_falloff,
        d
    );

    //vec3 scene_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
    ALBEDO = fog_color.rgb;//mix(scene_color, fog_color.rgb, fog * fog_strength);
	ALPHA = mix(0.0, 1.0, fog * fog_strength * fog_color.a);
}