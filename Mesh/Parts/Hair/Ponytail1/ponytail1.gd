extends DollPart

var hairMat:MyMasterBodyMat

@onready var ponytail: MeshInstance3D = %Ponytail

func grabMaterials():
	hairMat = ponytail.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	if(hairMat != null):
		if(_optionID == "color1"):
			hairMat.set_shader_parameter("color_mask_r", _value)
		if(_optionID == "color2"):
			hairMat.set_shader_parameter("color_mask_g", _value)
		if(_optionID == "color3"):
			hairMat.set_shader_parameter("color_mask_b", _value)
			
