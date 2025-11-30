extends DollPart

var hairMat:ShaderMaterial

@onready var long_chaos_hair: MeshInstance3D = %LongChaosHair

func grabMaterials():
	hairMat = long_chaos_hair.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	applyHairMatOption(hairMat, _optionID, _value)
			
