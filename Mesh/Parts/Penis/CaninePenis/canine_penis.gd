extends DollPart

@export var ballsMat:MyMasterBodyMat
@export var shaftMat:MyMasterBodyMat
@export var nodeToScale:Node3D
@export var furTuft:MeshInstance3D
@export var tuftMat:MyMasterBodyMat
@export var penisModifier:PenisSkeletonModifier
@export var jiggleModifiers:Array[SkeletonModifier3D] = []

@onready var guide_path: Path3D = %GuidePath
@onready var follow_spline_skeleton_modifier: FollowSplineSkeletonModifier = %FollowSplineSkeletonModifier

func setPenisTargets(holeNode:Node3D, insideNode:Node3D):
	if(!holeNode || !insideNode):
		follow_spline_skeleton_modifier.holeNode = null
		guide_path.holeNode = null
		guide_path.insideNode = null
		follow_spline_skeleton_modifier.active = false
		for mod in jiggleModifiers:
			mod.active = true
		return
	follow_spline_skeleton_modifier.holeNode = holeNode
	guide_path.holeNode = holeNode
	guide_path.insideNode = insideNode
	for mod in jiggleModifiers:
		mod.active = false
	follow_spline_skeleton_modifier.active = true

func applyOption(_optionID:String, _value:Variant):
	if(_optionID == "penisScale"):
		if(nodeToScale):
			nodeToScale.scale = Vector3(_value, _value, _value)
	if(_optionID == "furTuft"):
		if(furTuft):
			furTuft.visible = _value
	if(_optionID == "furTuftColor"):
		if(tuftMat):
			tuftMat.set_shader_parameter("albedo", _value)
	if(_optionID == "penisLenMod"):
		if(penisModifier):
			penisModifier.lenModifier = _value
	if(_optionID == "penBallsDrop"):
		if(penisModifier):
			penisModifier.ballsDrop = _value
	if(_optionID == "penBallsScale"):
		if(penisModifier):
			penisModifier.ballsScale = _value
	if(_optionID == "shaftColor"):
		if(shaftMat):
			shaftMat.set_shader_parameter("albedo", _value)
	if(_optionID == "pattern"):
		if(shaftMat):
			applyColormaskPatternToMyMat(shaftMat, _value)

func applySkinTypeData(_skinTypeData:SkinTypeData):
	if(ballsMat == null):
		return
	
	ballsMat.set_shader_parameter("albedo", _skinTypeData.color)
	
