extends DollPart

@export var eyeMat:ShaderMaterial
@export var headMat:MyMasterBodyMat

func applyOption(_optionID:String, _value:Variant):
	if(eyeMat != null):
		if(_optionID == "eyeColor1"):
			eyeMat.set_shader_parameter("colorR", _value)
		if(_optionID == "eyeColor2"):
			eyeMat.set_shader_parameter("colorG", _value)
		if(_optionID == "eyeColor3"):
			eyeMat.set_shader_parameter("colorB", _value)

func applySkinTypeData(_skinTypeData:SkinTypeData):
	if(headMat == null):
		return
	
	headMat.set_shader_parameter("albedo", _skinTypeData.color)


func gatherPartFlags(_theFlags:Dictionary):
	_theFlags["HumanNeck"] = true

func applyPartFlags(_theFlags:Dictionary):
	pass
