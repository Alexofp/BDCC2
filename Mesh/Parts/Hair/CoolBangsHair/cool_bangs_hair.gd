extends DollPart

var hairMat:ShaderMaterial

@onready var cool_bangs_hair: MeshInstance3D = %CoolBangsHair

func grabMaterials():
	hairMat = cool_bangs_hair.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	applyHairMatOption(hairMat, _optionID, _value)
