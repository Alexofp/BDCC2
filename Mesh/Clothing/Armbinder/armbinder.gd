extends DollPart

func gatherPartFlags(_theFlags:Dictionary):
	if(getDoll().getBodySkeleton().getShoulderWidthInfluence() <= 0.5):
		_theFlags["ArmsPose"] = "ArmsArmbinder"
	else:
		_theFlags["ArmsPose"] = "ArmsArmbinderMale"
	_theFlags["ArmbinderPose"] = true

func applyCharOption(_optionID:String, _value:Variant):
	updateThicknessBody(_optionID)
