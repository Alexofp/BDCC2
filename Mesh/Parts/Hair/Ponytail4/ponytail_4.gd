extends DollPart

var hairMat:ShaderMaterial
var rubberBandMat:ShaderMaterial

@onready var ponytail_4: MeshInstance3D = %Ponytail4
@onready var ponytail_4_bow: MeshInstance3D = %Ponytail4Bow

func grabMaterials():
	hairMat = ponytail_4.get_surface_override_material(0)
	rubberBandMat = ponytail_4_bow.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	applyHairMatOption(hairMat, _optionID, _value)
	if(_optionID == "bandColor"):
		rubberBandMat.set_shader_parameter("albedo", _value)
