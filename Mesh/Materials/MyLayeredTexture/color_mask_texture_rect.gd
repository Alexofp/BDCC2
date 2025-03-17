extends Control

func setColors(colorR:Color, colorG:Color, colorB:Color):
	var mat:ShaderMaterial = material
	
	mat.set_shader_parameter("colorR", colorR)
	mat.set_shader_parameter("colorG", colorG)
	mat.set_shader_parameter("colorB", colorB)

func setTexture(theTexture:Texture2D):
	var mat:ShaderMaterial = material
	
	#texture = theTexture
	mat.set_shader_parameter("texture_color_mask", theTexture)
