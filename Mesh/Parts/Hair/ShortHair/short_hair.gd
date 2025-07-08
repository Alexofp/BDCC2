extends DollPart

var hairMat:ShaderMaterial

@onready var short_hair: MeshInstance3D = %ShortHair

func grabMaterials():
	hairMat = short_hair.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	applyHairMatOption(hairMat, _optionID, _value)
			
