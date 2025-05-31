shader_type spatial;

uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float edge_threshold : hint_range(0.0, 1.0) = 0.05;
uniform float rim_threshold : hint_range(0.0, 1.0) = 0.7;

void fragment() {
	float rimOutline = 1.0 - max(dot(NORMAL, VIEW), 0.0); // VIEW is camera dir
	//rim = smoothstep(0.3, 0.6, rim); // tune these

    vec3 nOutline = normalize(NORMAL);
    vec3 dxOutline = dFdx(nOutline);
    vec3 dyOutline = dFdy(nOutline);
    //float edge = length(dx) + length(dy);
    //float edge = length(dx) + length(dy);
    float edgeOutline = dot(dxOutline, dxOutline) + dot(dyOutline, dyOutline);
	edgeOutline /= dot(VERTEX, VERTEX);

    if (edgeOutline > (edge_threshold*edge_threshold) && rimOutline > rim_threshold) {
        ALBEDO = outline_color.rgb;
    }
}