extends DollPart

@onready var canine_head: MeshInstance3D = $MyCanineHeadRig/Skeleton3D/CanineHead
@onready var eyes: MeshInstance3D = $MyCanineHeadRig/Skeleton3D/Eyes
@onready var cheek_fluff: MeshInstance3D = %CheekFluff

var eyeMat:ShaderMaterial
var headMat:MyMasterMaterial

@onready var head_layered_texture: MyLayeredTexture = %HeadLayeredTexture

@onready var face_animator: FaceAnimator = %FaceAnimator

func grabMaterials():
	headMat = canine_head.get_surface_override_material(0)
	eyeMat = eyes.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	if(eyeMat != null):
		if(_optionID == "eyeColor1"):
			eyeMat.set_shader_parameter("colorR", _value)
		if(_optionID == "eyeColor2"):
			eyeMat.set_shader_parameter("colorG", _value)
		if(_optionID == "eyeColor3"):
			eyeMat.set_shader_parameter("colorB", _value)
	if(_optionID == "fluff"):
		cheek_fluff.visible = _value
	if(_optionID == "fluffSpiky"):
		setBlendshape("Droop", 1.0-_value)
	if(_optionID == "fluffWide"):
		setBlendshape("Width", _value)
	if(_optionID == "fluffLen"):
		setBlendshape("Length", _value)
	if(_optionID == "fluffThick"):
		setBlendshape("Thickness", _value)
	if(_optionID == "headLayers"):
		updateHeadTexture()
	if(_optionID == "faceOverride"):
		face_animator.setFaceOverrideData(_value)

func applySkinTypeData(_skinType:int, _skinTypeData:SkinTypeData):
	if(headMat == null):
		return
	
	const ignoreUniforms = ["albedo"]
	headMat.copyFrom(preload("res://Mesh/Parts/Head/FelineHead/HeadMat.tres"), ignoreUniforms)
	
	headMat.set_shader_parameter("texture_normal", preload("res://Mesh/Parts/Head/CanineHead/Textures/Fur/MyCanineHeadV2_substance_UVGRID_Normal.png"))
	headMat.set_shader_parameter("texture_orm", preload("res://Mesh/Parts/Head/CanineHead/Textures/Fur/MyCanineHeadV2_substance_UVGRID_ORM.png"))
	
	updateHeadTexture()

func updateHeadTexture():
	var theSkinData:SkinTypeData = getSkinData()
	if(theSkinData == null):
		return
	
	head_layered_texture.clearLayers()
	
	if(getSkinType() == SkinType.Fur):
		head_layered_texture.addSimpleLayer("res://Mesh/Parts/Head/CanineHead/Textures/Fur/MyCanineHeadV2_substance_UVGRID_BaseColor.png", theSkinData.color)
	
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
		headMat.set_shader_parameter("messCutoff", 1.0-_mess.getMess(FluidsOnBodyZone.Face))
		headMat.set_shader_parameter("messLayerScale", 1.0)
#	CUM_NOISE.color_ramp.set_offset(0, 1.0-_mess.getMess(FluidsOnBodyZone.Face))

func applyPartFlags(_theFlags:Dictionary):
	if(_theFlags.has("HeadRingGag") && _theFlags["HeadRingGag"]):
		face_animator.setGagMouthOverride(0.76)
	elif(_theFlags.has("HeadBallGag") && _theFlags["HeadBallGag"]):
		face_animator.setGagMouthOverride(0.57)
	else:
		face_animator.setGagMouthOverride()

func prepareForPreview(_previewMaker):
	headMat.copyFrom(previewDollMat)

func previewTextureVariant(_previewMaker, _textureVariant:TextureVariant):
	if(_textureVariant.pathColormask != ""):
		headMat.set_shader_parameter("texture_color_mask", load(_textureVariant.pathColormask))
	elif(_textureVariant.pathTexture != ""):
		headMat.set_shader_parameter("texture_color_mask", load(_textureVariant.pathTexture))
	else:
		headMat.set_shader_parameter("texture_color_mask", null)
