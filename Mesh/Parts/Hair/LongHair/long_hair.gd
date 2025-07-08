extends DollPart

var hairMat:ShaderMaterial

@onready var long_hair: MeshInstance3D = %LongHair

func grabMaterials():
	hairMat = long_hair.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	applyHairMatOption(hairMat, _optionID, _value)
			
