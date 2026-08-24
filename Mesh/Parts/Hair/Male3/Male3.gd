extends DollPart

var hairMat:ShaderMaterial

@onready var male_3: MeshInstance3D = $Male3Hair/Male3

func grabMaterials():
	hairMat = male_3.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	applyHairMatOption(hairMat, _optionID, _value)

func applyPartFlags(_theFlags:Dictionary):
	super.applyPartFlags(_theFlags)
	
	if(!_theFlags.has("ThinHead")):
		setBlendshape("Wider", 1.0)
	else:
		setBlendshape("Wider", 1.0 - float(_theFlags["ThinHead"]))
