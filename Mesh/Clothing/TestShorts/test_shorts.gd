extends ClothingPart

func _init():
	super._init()
	watchesBodyparts = {
		"root" = [],
	}
func applyToDoll(_theDoll:Doll, _dollPart:DollPart):
	if(_dollPart == null || _theDoll == null):
		$rig/Skeleton3D/TestShorts.skeleton = null
		$rig/Skeleton3D/TestShortsPulledDown.skeleton = null
		return
	$rig/Skeleton3D/TestShorts.skeleton = $rig/Skeleton3D/TestShorts.get_path_to(_dollPart.getSkeleton())
	$rig/Skeleton3D/TestShortsPulledDown.skeleton = $rig/Skeleton3D/TestShortsPulledDown.get_path_to(_dollPart.getSkeleton())

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
	if(_optionID == "pulledDown"):
		$rig/Skeleton3D/TestShorts.visible = !_value
		$rig/Skeleton3D/TestShortsPulledDown.visible = !!_value
			
	#print("PANTIES TRYING TO SET "+str(_optionID)+" TO VALUE: "+str(_value))
	pass

func onWatchedBodypartOptionChanges(_partID: String, _optionID: String, _value):
	if(_partID == "root"):
		if(_optionID == "thickbutt"):
			setBlendshape($rig/Skeleton3D/TestShorts, "Thickness", _value)
			setBlendshape($rig/Skeleton3D/TestShortsPulledDown, "Thickness", _value)
		if(_optionID == "muscles"):
			setBlendshape($rig/Skeleton3D/TestShorts, "Muscles", _value)
			setBlendshape($rig/Skeleton3D/TestShortsPulledDown, "Muscles", _value)
		if(_optionID == "crotchwidth"):
			setBlendshape($rig/Skeleton3D/TestShorts, "PussyWide", _value)
			setBlendshape($rig/Skeleton3D/TestShortsPulledDown, "PussyWide", _value)
