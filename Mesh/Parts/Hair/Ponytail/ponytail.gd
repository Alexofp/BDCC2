extends DollPart

@export var hairMat:ShaderMaterial

func applyOption(_optionID: String, _value):
	applySkinOption(_optionID, _value)

func applySkinOption(_optionID: String, _value):
	if(_optionID == "hue"):
		if(hairMat != null):
			hairMat.set_shader_parameter("hueShift", _value)
	if(_optionID == "sat"):
		if(hairMat != null):
			hairMat.set_shader_parameter("saturationMult", _value)
	if(_optionID == "value"):
		if(hairMat != null):
			hairMat.set_shader_parameter("valueMult", _value)
