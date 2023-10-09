extends Node3D

var savedOptions = {}

func _ready():
	resetOptionsToDefault()
	#applyOption("thickbutt", 1.0)

func _process(_delta):
	pass

func resetOptionsToDefault():
	var theOptions = getOptions()
	
	for optionKey in theOptions:
		savedOptions[optionKey] = theOptions[optionKey]["default"]

func getOptions() -> Dictionary:
	return {
		"breastsize": {
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.5,
		},
		"thickbutt": {
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
	}

func setBlendshape(mesh: MeshInstance3D, blendShapeID: String, val: float):
	var blendShapeIndex = mesh.find_blend_shape_by_name(blendShapeID)
	mesh.set_blend_shape_value(blendShapeIndex, val)

func applyOption(optionID, value):
	if(optionID == "thickbutt"):
		setBlendshape($rig/Skeleton3D/Body, "ThickButt", value)
		
