extends DollPart

@export var fuzzyTail:MeshInstance3D
@export var lionTip:MeshInstance3D
@export var tailMat:MyMasterBodyMat
@export var tailSkeletonModifier:TailSkeletonModifier

func applyOption(_optionID:String, _value:Variant):
	if(_optionID == "tailType"):
		if(fuzzyTail):
			fuzzyTail.visible = (_value == "fluffy")
		if(lionTip):
			lionTip.visible = (_value == "lion")
	if(_optionID == "thickness"):
		if(_value >= 0.0):
			setBlendshape("Thick", _value)
			setBlendshape("Lion", 0.0)
		else:
			setBlendshape("Thick", 0.0)
			setBlendshape("Lion", -_value)
	if(_optionID == "pattern"):
		applyColormaskPatternToMyMat(tailMat, _value)
	if(_optionID == "tailLenMod"):
		if(tailSkeletonModifier):
			tailSkeletonModifier.lenModifier = _value

func applySkinTypeData(_skinTypeData:SkinTypeData):
	if(tailMat == null):
		return
	
	tailMat.set_shader_parameter("albedo", _skinTypeData.color)
	
