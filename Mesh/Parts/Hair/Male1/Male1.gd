extends DollPart

var hairMat:ShaderMaterial

@onready var male_1: MeshInstance3D = $Male1Hair/Male1

func grabMaterials():
	hairMat = male_1.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	applyHairMatOption(hairMat, _optionID, _value)

func applyPartFlags(_theFlags:Dictionary):
	super.applyPartFlags(_theFlags)
	
	if(!_theFlags.has("ThinHead")):
		setBlendshape("WideHead", 1.0)
	else:
		setBlendshape("WideHead", 1.0 - float(_theFlags["ThinHead"]))
