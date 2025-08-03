extends DollPart

var hairMat:ShaderMaterial

@onready var short_hair_2: MeshInstance3D = %ShortHair2

func grabMaterials():
	hairMat = short_hair_2.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	applyHairMatOption(hairMat, _optionID, _value)
			
