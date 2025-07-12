extends DollPart

var hairMat:ShaderMaterial
var rubberBandMat:ShaderMaterial

@onready var ponytail_3: MeshInstance3D = %Ponytail3

func grabMaterials():
	hairMat = ponytail_3.get_surface_override_material(0)
	rubberBandMat = ponytail_3.get_surface_override_material(1)

func applyOption(_optionID:String, _value:Variant):
	applyHairMatOption(hairMat, _optionID, _value)
	if(_optionID == "bandColor"):
		rubberBandMat.set_shader_parameter("albedo", _value)
