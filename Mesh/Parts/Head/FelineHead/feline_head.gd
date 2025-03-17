extends DollPart

@export var eyeMat:ShaderMaterial
@export var headMat:MyMasterBodyMat

@onready var head_layered_texture: MyLayeredTexture = %HeadLayeredTexture

func applyOption(_optionID:String, _value:Variant):
	if(eyeMat != null):
		if(_optionID == "eyeColor1"):
			eyeMat.set_shader_parameter("colorR", _value)
		if(_optionID == "eyeColor2"):
			eyeMat.set_shader_parameter("colorG", _value)
		if(_optionID == "eyeColor3"):
			eyeMat.set_shader_parameter("colorB", _value)
	if(_optionID == "headLayers"):
		updateHeadTexture()

func applySkinTypeData(_skinTypeData:SkinTypeData):
	if(headMat == null):
		return
	
	#headMat.set_shader_parameter("albedo", _skinTypeData.color)
	
	const ignoreUniforms = ["albedo"]
	headMat.copyFrom(load("res://Mesh/Parts/Body/FeminineBody/FurBodySmartMat.tres"), ignoreUniforms)
	#headMat.set_shader_parameter("texture_albedo", load("res://Mesh/Parts/Head/FelineHead/Textures/Fur/MyFelineHeadV2_low_FelineHead_BaseColor.png"))
	headMat.set_shader_parameter("texture_normal", load("res://Mesh/Parts/Head/FelineHead/Textures/Fur/MyFelineHeadV2_low_FelineHead_Normal.png"))
	headMat.set_shader_parameter("texture_orm", load("res://Mesh/Parts/Head/FelineHead/Textures/Fur/MyFelineHeadV2_low_FelineHead_ORM.png"))
	
	updateHeadTexture()

func updateHeadTexture():
	var theSkinData:SkinTypeData = getSkinData()
	if(theSkinData == null):
		return
	
	head_layered_texture.clearLayers()
	
	if(theSkinData.skinType == SkinType.Fur):
		head_layered_texture.addSimpleLayer("res://Mesh/Parts/Head/FelineHead/Textures/Fur/MyFelineHeadV2_low_FelineHead_BaseColor.png", theSkinData.color)
	#if(theSkinData.skinType == SkinType.HumanSkin):
	#	body_layered_texture.addSimpleLayer("res://Mesh/Parts/Body/FeminineBody/Textures/Skin/MyBodySubstancePainter_Body_BaseColor.png", theSkinData.color)
	
	addLayersToTexture(head_layered_texture, getOptionValue("headLayers", []))

	headMat.set_shader_parameter("texture_albedo", head_layered_texture.getTexture())
