extends DollPart

@export var eyeMat:ShaderMaterial

func applySkinOption(_optionID: String, _value):
	if(_optionID == "eyehue"):
		if(eyeMat != null):
			eyeMat.set_shader_parameter("Shift_Hue", _value)
	if(_optionID == "eyesaturation"):
		if(eyeMat != null):
			eyeMat.set_shader_parameter("Shift_Saturation", _value)
	if(_optionID == "eyetype"):
		if(eyeMat != null):
			if(_value == "robot"):
				eyeMat.set_shader_parameter("texture_albedo", preload("res://Mesh/Textures/Eyes/roboteye.png"))
			else:
				eyeMat.set_shader_parameter("texture_albedo", preload("res://Mesh/Textures/Eyes/eye.png"))
