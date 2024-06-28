extends ExtraPart

@export var metalMat:StandardMaterial3D

func applyOption(_optionID: String, _value):
	if(_optionID == "leftChain"):
		$FelineRig/Skeleton3D/PiercingChainLeft.visible = _value
	if(_optionID == "rightChain"):
		$FelineRig/Skeleton3D/PiercingChainRight.visible = _value
	if(_optionID == "color"):
		if(metalMat != null):
			metalMat.albedo_color = _value

func applyToDoll(_theDoll:Doll, _dollPart:DollPart):
	var meshes = [
		$FelineRig/Skeleton3D/PiercingChainLeft,
		$FelineRig/Skeleton3D/PiercingChainRight,
	]
	
	if(_dollPart == null || _theDoll == null):
		for theMesh in meshes:
			theMesh.skeleton = null
		return
	for theMesh in meshes:
		theMesh.skeleton = theMesh.get_path_to(_dollPart.getSkeleton())
