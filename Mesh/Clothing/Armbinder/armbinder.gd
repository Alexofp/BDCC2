extends DollPart

func gatherPartFlags(_theFlags:Dictionary):
	_theFlags["ArmbinderPose"] = true

func applyCharOption(_optionID:String, _value:Variant):
	updateThicknessBody(_optionID)
