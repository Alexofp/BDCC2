extends DollPart

@onready var feline_head: MeshInstance3D = $MyHeadRig/Skeleton3D/FelineHead
@onready var eyes: MeshInstance3D = $MyHeadRig/Skeleton3D/Eyes

var eyeMat:ShaderMaterial
var headMat:MyMasterBodyMat

@onready var head_layered_texture: MyLayeredTexture = %HeadLayeredTexture

@onready var face_animator: FaceAnimator = %FaceAnimator

func grabMaterials():
	headMat = feline_head.get_surface_override_material(0)
	eyeMat = eyes.get_surface_override_material(0)

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
	if(_optionID == "faceOverride"):
		face_animator.setFaceOverrideData(_value)

func applySkinTypeData(_skinTypeData:SkinTypeData):
	if(headMat == null):
		return
	
	#headMat.set_shader_parameter("albedo", _skinTypeData.color)
	
	const ignoreUniforms = ["albedo"]
	headMat.copyFrom(preload("res://Mesh/Parts/Head/FelineHead/HeadMat.tres"), ignoreUniforms)
	#headMat.set_shader_parameter("texture_albedo", preload("res://Mesh/Parts/Head/FelineHead/Textures/Fur/MyFelineHeadV2_low_FelineHead_BaseColor.png"))
	headMat.set_shader_parameter("texture_normal", preload("res://Mesh/Parts/Head/FelineHead/Textures/Fur/MyFelineHeadV2_low_FelineHead_Normal.png"))
	headMat.set_shader_parameter("texture_orm", preload("res://Mesh/Parts/Head/FelineHead/Textures/Fur/MyFelineHeadV2_low_FelineHead_ORM.png"))
	
	#headMat.set_shader_parameter("texture_cum_mask", CUM_NOISE)
	#headMat.set_shader_parameter("texture_cum_mask", null)
	#headMat.set_shader_parameter("texture_cum_layer", null)
	
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
	updateBodyMess()

func _on_head_layered_texture_on_texture_updated(newTexture: Texture2D) -> void:
	headMat.set_shader_parameter("texture_albedo", newTexture)

func getFaceAnimator() -> FaceAnimator:
	return face_animator
	
#const CUM_GRADIENT:GradientTexture1D= preload("res://Mesh/Parts/Head/FelineHead/Textures/CumGradient.tres")
#const CUM_NOISE = preload("res://Mesh/Parts/Head/FelineHead/Textures/CumNoise.tres")

func updateBodyMess():
	var _mess:FluidsOnBodyProfile = getBodyMess()
	if(!_mess):
		return
	if(headMat):
		headMat.set_shader_parameter("cumCutoff", 1.0-_mess.getMess(FluidsOnBodyZone.Face))
		headMat.set_shader_parameter("cum_layer_scale", 1.0)
#	CUM_NOISE.color_ramp.set_offset(0, 1.0-_mess.getMess(FluidsOnBodyZone.Face))

func applyPartFlags(_theFlags:Dictionary):
	if(_theFlags.has("HeadRingGag") && _theFlags["HeadRingGag"]):
		face_animator.setGagMouthOverride(0.76)
	elif(_theFlags.has("HeadBallGag") && _theFlags["HeadBallGag"]):
		face_animator.setGagMouthOverride(0.57)
	else:
		face_animator.setGagMouthOverride()
