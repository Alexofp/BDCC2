extends DollPart

@onready var eyes: MeshInstance3D = $MyHeadRig/Skeleton3D/Eyes
@onready var my_human_head: MeshInstance3D = $MyHeadRig/Skeleton3D/MyHumanHead
@onready var mouth_mesh: MeshInstance3D = %MouthMesh
@onready var eye_brows: MeshInstance3D = %EyeBrows
@onready var eyelashes: MeshInstance3D = %Eyelashes
@onready var copy_neck_modifier: CopyBoneModifier = %CopyNeckModifier

var eyeMat:ShaderMaterial
var headMat:ShaderMaterial
var mouthMat:ShaderMaterial
var browMat:ShaderMaterial
var eyelashesMat:ShaderMaterial
@onready var face_animator: FaceAnimator = %FaceAnimator

@onready var head_layered_texture: MyLayeredTexture = %HeadLayeredTexture

@onready var eye_move_l: MoveBoneModifier = %EyeMoveL
@onready var eye_move_r: MoveBoneModifier = %EyeMoveR

func setDoll(theDoll:Doll):
	super.setDoll(theDoll)
	if(theDoll):
		copy_neck_modifier.setTargetSkeleton(theDoll.getBodySkeleton().getSkeleton())

func grabMaterials():
	headMat = my_human_head.get_surface_override_material(0)
	eyeMat = eyes.get_surface_override_material(0)
	mouthMat = mouth_mesh.get_surface_override_material(0)
	browMat = eye_brows.get_surface_override_material(0)
	eyelashesMat = eyelashes.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	applyEyeOptions(eyes, _optionID, _value)
	applyMouthOptions(mouthMat, _optionID, _value)
	applyBrowOptions(browMat, _optionID, _value)
	applyEyelashesOptions(eyelashesMat, _optionID, _value)
	if(_optionID == "faceOverride"):
		face_animator.setFaceOverrideData(_value)
	elif(_optionID == "headLayers"):
		updateHeadTexture()
	elif(_optionID == "earsElf"):
		setBlendshape("EarsElf", _value)
	elif(_optionID == "lipsBig"):
		setBlendshape("LipsBig", _value)
	elif(_optionID == "jawWide"):
		setBlendshape("JawWide", _value)
	elif(_optionID == "earsHide"):
		setBlendshape("EarsHide", _value)
	elif(_optionID == "mouthCurve"):
		setBlendshape("MouthCurve", _value)
	elif(_optionID == "fangs"):
		setBlendshape("Fangs", _value)
	elif(_optionID == "noseWidth"):
		setBlendshape("NoseWidth", _value)
	elif(_optionID == "eyeSpacing"):
		const EYE_SPACING := 0.005
		var finalVal:float = 0.0
		if(_value > 0.0):
			finalVal = remap(_value, 0.0, 1.0, 0.0, 0.7)
		if(_value < 0.0):
			finalVal = remap(_value, 0.0, 1.0, 0.0, 1.5)
		eye_move_l.translation.x = finalVal*EYE_SPACING
		eye_move_r.translation.x = -finalVal*EYE_SPACING

func applySkinTypeData(_skinType:int, _skinTypeData:SkinTypeData):
	if(headMat == null):
		return
	
	#headMat.set_shader_parameter("albedo", _skinTypeData.color)
	updateHeadTexture()

func updateHeadTexture():
	var theSkinData:SkinTypeData = getSkinData()
	if(theSkinData == null):
		return
	
	head_layered_texture.clearLayers()
	
	if(true):
		head_layered_texture.addSimpleLayer("res://Mesh/Parts/Body/FeminineBody/Textures/Skin/skinwhite.png", theSkinData.color)
		var colorDark:Color = theSkinData.color
		colorDark.v *= 0.5678
		colorDark.s = minf(1.0, colorDark.s*4.0)
		colorDark.h += 0.01
		var colorLight:Color = theSkinData.color
		colorLight.v = minf(1.0, colorLight.v*1.3)
		colorLight.s *= 0.5985
		colorLight.h += 0.03
		var colorHighlight:Color = theSkinData.color
		colorHighlight.v = minf(1.0, colorHighlight.v*3.0)
		colorHighlight.s *= 0.1
		colorHighlight.h += 0.0
		head_layered_texture.addColorMaskLayer("res://Mesh/Parts/Head/HumanFeminine/Textures/HumanSkin/Head_low_DefaultMaterial_BaseColor.png", colorHighlight, colorLight, colorDark)
	
	addLayersToTexture(head_layered_texture, getOptionValue("headLayers", []))

	#head_layered_texture.addSimpleLayer("res://Mesh/Parts/Head/FelineHead/Textures/Layers/FelineSnout.png", getOptionValue("snout", Color.WHITE))
	#head_layered_texture.addSimpleLayer("res://Mesh/Parts/Head/FelineHead/Textures/Layers/Lines.png", getOptionValue("lines", Color.WHITE))

	headMat.set_shader_parameter("texture_albedo", head_layered_texture.getTexture())
	updateBodyMess()



func gatherPartFlags(_theFlags:Dictionary):
	_theFlags["HumanNeck"] = true

func applyPartFlags(_theFlags:Dictionary):
	if(_theFlags.has("HeadRingGag") && _theFlags["HeadRingGag"]):
		face_animator.setGagMouthOverride(1.0)
	elif(_theFlags.has("HeadBallGag") && _theFlags["HeadBallGag"]):
		face_animator.setGagMouthOverride(1.0)
	else:
		face_animator.setGagMouthOverride()

#func setExpressionState(_newExpr:int):
	#face_animator.setExpressionState(_newExpr)
	#pass

func getFaceAnimator() -> FaceAnimator:
	return face_animator

func updateBodyMess():
	var _mess:FluidsOnBodyProfile = getBodyMess()
	if(!_mess):
		return
	if(headMat):
		headMat.set_shader_parameter("messCutoff", 1.0-_mess.getMess(FluidsOnBodyZone.Face))
		headMat.set_shader_parameter("messLayerScale", 1.0)

func _on_head_layered_texture_on_texture_updated(newTexture: Variant) -> void:
	headMat.set_shader_parameter("texture_albedo", newTexture)

func setHeadMat(_mat:ShaderMaterial):
	_mat = _mat.duplicate()
	$MyHeadRig/Skeleton3D/MyHumanHead.set_surface_override_material(0, _mat)
	#cheek_fluff.set_surface_override_material(0, _mat)
	headMat = _mat

func prepareForPreview(_previewMaker):
	#headMat.copyFrom(previewDollMat)
	setHeadMat(previewDollMat)
	pass

func previewTextureVariant(_previewMaker, _textureVariant:TextureVariant):
	if(_textureVariant.pathColormask != ""):
		headMat.set_shader_parameter("texture_color_mask", load(_textureVariant.pathColormask))
	elif(_textureVariant.pathTexture != ""):
		headMat.set_shader_parameter("texture_color_mask", load(_textureVariant.pathTexture))
	else:
		headMat.set_shader_parameter("texture_color_mask", null)
