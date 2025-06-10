extends DollPart

@onready var eyes: MeshInstance3D = $MyHeadRig/Skeleton3D/Eyes
@onready var my_human_head: MeshInstance3D = $MyHeadRig/Skeleton3D/MyHumanHead

var eyeMat:ShaderMaterial
var headMat:MyMasterBodyMat
@onready var face_animator: FaceAnimator = %FaceAnimator

func grabMaterials():
	headMat = my_human_head.get_surface_override_material(0)
	eyeMat = eyes.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	if(eyeMat != null):
		if(_optionID == "eyeColor1"):
			eyeMat.set_shader_parameter("colorR", _value)
		if(_optionID == "eyeColor2"):
			eyeMat.set_shader_parameter("colorG", _value)
		if(_optionID == "eyeColor3"):
			eyeMat.set_shader_parameter("colorB", _value)
	if(_optionID == "faceOverride"):
		face_animator.setFaceOverrideData(_value)

func applySkinTypeData(_skinTypeData:SkinTypeData):
	if(headMat == null):
		return
	
	headMat.set_shader_parameter("albedo", _skinTypeData.color)


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
		headMat.set_shader_parameter("cumCutoff", 1.0-_mess.getMess(FluidsOnBodyZone.Face))
		headMat.set_shader_parameter("cum_layer_scale", 1.0)
