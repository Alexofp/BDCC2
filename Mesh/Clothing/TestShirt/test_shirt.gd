extends ClothingPart

func _init():
	super._init()
	watchesBodyparts = {
		"root" = [],
	}
func applyToDoll(_theDoll:Doll, _dollPart:DollPart):
	if(_dollPart == null || _theDoll == null):
		$rig/Skeleton3D/TestShirt.skeleton = null
		$rig/Skeleton3D/TestShirtOpened.skeleton = null
		return
	$rig/Skeleton3D/TestShirt.skeleton = $rig/Skeleton3D/TestShirt.get_path_to(_dollPart.getSkeleton())
	$rig/Skeleton3D/TestShirtOpened.skeleton = $rig/Skeleton3D/TestShirtOpened.get_path_to(_dollPart.getSkeleton())

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
	if(_optionID == "opened"):
		$rig/Skeleton3D/TestShirt.visible = !_value
		$rig/Skeleton3D/TestShirtOpened.visible = !!_value
			
	#print("PANTIES TRYING TO SET "+str(_optionID)+" TO VALUE: "+str(_value))
	pass

func onWatchedBodypartOptionChanges(_partID: String, _optionID: String, _value):
	if(_partID == "root"):
		if(_optionID == "thickbutt"):
			setBlendshape($rig/Skeleton3D/TestShirt, "Thickness", _value)
			setBlendshape($rig/Skeleton3D/TestShirtOpened, "Thickness", _value)
		if(_optionID == "muscles"):
			setBlendshape($rig/Skeleton3D/TestShirt, "Muscles", _value)
			setBlendshape($rig/Skeleton3D/TestShirtOpened, "Muscles", _value)
		if(_optionID == "crotchwidth"):
			setBlendshape($rig/Skeleton3D/TestShirt, "PussyWide", _value)
			setBlendshape($rig/Skeleton3D/TestShirtOpened, "PussyWide", _value)
