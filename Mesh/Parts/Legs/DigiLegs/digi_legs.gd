extends DollPart

@onready var legs = $rig/Skeleton3D/Digilegs

func applyParentOption(_optionID: String, _value):
	if(_optionID == "thickbutt"):
		setBlendshape(legs, "ThickButt", _value)
