extends Control

func setRevealAndSmooth(theReveal:float, theSmooth:float):
	var mat:ShaderMaterial = material
	
	mat.set_shader_parameter("cutoff", theReveal)
	mat.set_shader_parameter("smooth_size", theSmooth)

func setScroll(_theScroll:float):
	var mat:ShaderMaterial = material
	mat.set_shader_parameter("alpha_mask_scroll", _theScroll)

func setRevealTexture(theTexture:Texture2D):
	var mat:ShaderMaterial = material
	mat.set_shader_parameter("mask", theTexture)
func setAlphaMaskTexture(theTexture:Texture2D):
	var mat:ShaderMaterial = material
	mat.set_shader_parameter("alpha_mask", theTexture)
