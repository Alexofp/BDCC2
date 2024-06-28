extends ClothingPart

func _init():
	super._init()
	watchesBodyparts = {
		"root" = [],
	}

func applyToDoll(_theDoll:Doll, _dollPart:DollPart):
	if(_dollPart == null || _theDoll == null):
		$rig/Skeleton3D/TestPanties.skeleton = null
		$rig/Skeleton3D/TestPantiesShifted.skeleton = null
		return
	$rig/Skeleton3D/TestPanties.skeleton = $rig/Skeleton3D/TestPanties.get_path_to(_dollPart.getSkeleton())
	$rig/Skeleton3D/TestPantiesShifted.skeleton = $rig/Skeleton3D/TestPantiesShifted.get_path_to(_dollPart.getSkeleton())

#func applyToDoll(_theDoll:Doll, _dollPart:DollPart):
	#setMeshToBodypartByPath($rig/Skeleton3D/Retopo_TshirtTest_001, [])
#
#func getBodyAlphaTexturePath() -> String:
	#return "res://Mesh/Clothing/SimpleTshirt/ShirtAlpha.png"
#
#
#func applyPartTags(_partTags:Dictionary):
	#pass

func applyOption(_optionID: String, _value):
	if(_optionID == "shiftedAside"):
		$rig/Skeleton3D/TestPanties.visible = !_value
		$rig/Skeleton3D/TestPantiesShifted.visible = !!_value
			
	print("PANTIES TRYING TO SET "+str(_optionID)+" TO VALUE: "+str(_value))

func onWatchedBodypartOptionChanges(_partID: String, _optionID: String, _value):
	if(_partID == "root"):
		if(_optionID == "thickbutt"):
			setBlendshape($rig/Skeleton3D/TestPanties, "Thickness", _value)
			setBlendshape($rig/Skeleton3D/TestPantiesShifted, "Thickness", _value)
		if(_optionID == "muscles"):
			setBlendshape($rig/Skeleton3D/TestPanties, "Muscles", _value)
			setBlendshape($rig/Skeleton3D/TestPantiesShifted, "Muscles", _value)
		if(_optionID == "crotchwidth"):
			setBlendshape($rig/Skeleton3D/TestPanties, "PussyWide", _value)
			setBlendshape($rig/Skeleton3D/TestPantiesShifted, "PussyWide", _value)
