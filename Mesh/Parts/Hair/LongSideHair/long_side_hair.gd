extends DollPart

var hairMat:ShaderMaterial

@onready var long_side_hair: MeshInstance3D = %LongSideHair

func grabMaterials():
	hairMat = long_side_hair.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	applyHairMatOption(hairMat, _optionID, _value)
