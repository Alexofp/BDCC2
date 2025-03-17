extends DollPart

@export var hairMat:MyMasterBodyMat

@onready var ponytail: MeshInstance3D = %Ponytail

func applyOption(_optionID:String, _value:Variant):
	if(hairMat != null):
		if(_optionID == "color1"):
			hairMat.set_shader_parameter("color_mask_r", _value)
		if(_optionID == "color2"):
			hairMat.set_shader_parameter("color_mask_g", _value)
		if(_optionID == "color3"):
			hairMat.set_shader_parameter("color_mask_b", _value)
