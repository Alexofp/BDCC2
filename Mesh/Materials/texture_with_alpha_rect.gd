extends ColorRect

func setTextures(theTexture:Texture2D, alphaTexture:Texture2D):
	if(material is ShaderMaterial):
		material.set_shader_parameter("mainTexture", theTexture)
		material.set_shader_parameter("alphaTexture", alphaTexture)
