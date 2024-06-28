extends ExtraPart

@export var metalMat:StandardMaterial3D

func applyOption(_optionID: String, _value):
	if(_optionID == "rod1"):
		$FelineRig/Skeleton3D/PiercingBalls_001.visible = _value
	if(_optionID == "rod2"):
		$FelineRig/Skeleton3D/PiercingBalls_002.visible = _value
	if(_optionID == "rod3"):
		$FelineRig/Skeleton3D/PiercingBalls_003.visible = _value
	if(_optionID == "rod4"):
		$FelineRig/Skeleton3D/PiercingBalls_004.visible = _value
	if(_optionID == "rod5"):
		$FelineRig/Skeleton3D/PiercingBalls_005.visible = _value
	if(_optionID == "color"):
		if(metalMat != null):
			metalMat.albedo_color = _value

func applyToDoll(_theDoll:Doll, _dollPart:DollPart):
	var meshes = [
		$FelineRig/Skeleton3D/PiercingBalls_001,
		$FelineRig/Skeleton3D/PiercingBalls_002,
		$FelineRig/Skeleton3D/PiercingBalls_003,
		$FelineRig/Skeleton3D/PiercingBalls_004,
		$FelineRig/Skeleton3D/PiercingBalls_005,
	]
	
	if(_dollPart == null || _theDoll == null):
		for theMesh in meshes:
			theMesh.skeleton = null
		return
	for theMesh in meshes:
		theMesh.skeleton = theMesh.get_path_to(_dollPart.getSkeleton())
