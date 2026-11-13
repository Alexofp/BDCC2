extends DollPart

var hairMat:ShaderMaterial

@onready var short_hair_2: MeshInstance3D = %ShortHair2
@onready var skeleton_3d: Skeleton3D = %Skeleton3D

func _ready():
	super._ready()
	ProcessBalancer.addAnimTree(null, skeleton_3d, ProcessBalancer.HAIR_PRIORITY)

func grabMaterials():
	hairMat = short_hair_2.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	applyHairMatOption(hairMat, _optionID, _value)
			
