shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D mainTexture : source_color,hint_default_transparent,filter_linear_mipmap,repeat_enable;
uniform sampler2D alphaTexture : source_color,hint_default_white,filter_linear_mipmap,repeat_enable;

void fragment(){
	vec4 textureColor = texture(mainTexture, UV);
	vec4 alphaColor = texture(alphaTexture, UV);
	
	vec4 patternColorFinal = textureColor;
	patternColorFinal.a *= (alphaColor.r);
	COLOR = patternColorFinal;
}