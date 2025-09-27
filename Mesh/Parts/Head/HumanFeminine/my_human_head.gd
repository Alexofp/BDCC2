extends DollPart

@onready var eyes: MeshInstance3D = $MyHeadRig/Skeleton3D/Eyes
@onready var my_human_head: MeshInstance3D = $MyHeadRig/Skeleton3D/MyHumanHead
@onready var mouth_mesh: MeshInstance3D = %MouthMesh
@onready var eye_brows: MeshInstance3D = %EyeBrows
@onready var eyelashes: MeshInstance3D = %Eyelashes

var eyeMat:ShaderMaterial
var headMat:ShaderMaterial
var mouthMat:ShaderMaterial
var browMat:ShaderMaterial
var eyelashesMat:ShaderMaterial
@onready var face_animator: FaceAnimator = %FaceAnimator

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

func applySkinTypeData(_skinType:int, _skinTypeData:SkinTypeData):
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
		headMat.set_shader_parameter("messCutoff", 1.0-_mess.getMess(FluidsOnBodyZone.Face))
		headMat.set_shader_parameter("messLayerScale", 1.0)
