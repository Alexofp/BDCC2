extends DollPart

@onready var body = $rig/Skeleton3D/Body

func applyOption(_optionID: String, _value):
	if(_optionID == "thickbutt"):
		setBlendshape(body, "ThickButt", _value)
