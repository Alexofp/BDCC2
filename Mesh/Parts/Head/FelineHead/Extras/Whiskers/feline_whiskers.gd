extends ExtraPart

@export var whiskersMat:StandardMaterial3D

func applyOption(_optionID: String, _value):
	if(_optionID == "length"):
		setBlendshape($FelineRig/Skeleton3D/Whiskers, "Length", _value)
	if(_optionID == "drop"):
		setBlendshape($FelineRig/Skeleton3D/Whiskers, "Drop", _value)
	if(_optionID == "color"):
		if(whiskersMat != null):
			whiskersMat.albedo_color = _value

func applyToDoll(_theDoll:Doll, _dollPart:DollPart):
	if(_dollPart == null || _theDoll == null):
		$FelineRig/Skeleton3D/Whiskers.skeleton = null
		return
	$FelineRig/Skeleton3D/Whiskers.skeleton = $FelineRig/Skeleton3D/Whiskers.get_path_to(_dollPart.getSkeleton())
