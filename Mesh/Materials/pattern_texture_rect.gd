extends ColorRect

func setColors(rColor:Color, gColor:Color, bColor:Color):
	if(material is ShaderMaterial):
		material.set_shader_parameter("colorR", rColor)
		material.set_shader_parameter("colorG", gColor)
		material.set_shader_parameter("colorB", bColor)

func setTexture(theTexture:Texture2D):
	if(material is ShaderMaterial):
		material.set_shader_parameter("pattern_texture", theTexture)
