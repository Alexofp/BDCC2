extends DollPart

var hairMat:ShaderMaterial
var rubberBandMat:ShaderMaterial

@onready var ponytail_2: MeshInstance3D = %Ponytail2
@onready var skeleton_3d: Skeleton3D = %Skeleton3D

func _ready():
	super._ready()
	ProcessBalancer.addAnimTree(null, skeleton_3d, ProcessBalancer.HAIR_PRIORITY)

func grabMaterials():
	hairMat = ponytail_2.get_surface_override_material(0)
	rubberBandMat = ponytail_2.get_surface_override_material(1)

func applyOption(_optionID:String, _value:Variant):
	applyHairMatOption(hairMat, _optionID, _value)
	if(_optionID == "bandColor"):
		rubberBandMat.set_shader_parameter("albedo", _value)
