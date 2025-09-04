extends DollPart

var hairMat:ShaderMaterial
var bowMat:ShaderMaterial

@onready var long_hair_bow: MeshInstance3D = %LongHairBow
@onready var bow: MeshInstance3D = %Bow

func grabMaterials():
	hairMat = long_hair_bow.get_surface_override_material(0)
	bowMat = bow.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	applyHairMatOption(hairMat, _optionID, _value)
			
	if(_optionID == "bowColor"):
		if(bowMat):
			bowMat.set_shader_parameter("albedo", _value)
	if(_optionID == "bowHide"):
		bow.visible = !_value
