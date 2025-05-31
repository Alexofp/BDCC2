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
@onready var penis_handler: PenisHandler = %PenisHandler

var enableTween:Tween
func enableSplineModifier(doEn:bool, _time:float = 0.5):
	if(enableTween):
		enableTween.kill()
		enableTween = null
	enableTween = create_tween()
	enableTween.set_parallel(true)
	
	follow_spline_skeleton_modifier.active = true
	enableTween.tween_property(follow_spline_skeleton_modifier, "influence", 1.0 if doEn else 0.0, _time)
	for mod in jiggleModifiers:
		mod.active = true
		enableTween.tween_property(mod, "influence", 0.0 if doEn else 1.0, _time)
	enableTween.chain().tween_callback(doEnableSpline.bind(doEn))
	
func doEnableSpline(_isEn:bool):
	follow_spline_skeleton_modifier.active = _isEn
	for mod in jiggleModifiers:
		mod.active = !_isEn
	if(!_isEn):
		follow_spline_skeleton_modifier.holeNode = null
		follow_spline_skeleton_modifier.insideNode = null
		guide_path.holeNode = null
		guide_path.insideNode = null

func setPenisTargets(holeNode:Node3D, insideNode:Node3D):
	if(!holeNode || !insideNode):
		#follow_spline_skeleton_modifier.holeNode = null
		#follow_spline_skeleton_modifier.insideNode = null
		#guide_path.holeNode = null
		#guide_path.insideNode = null
		enableSplineModifier(false)
		#follow_spline_skeleton_modifier.active = false
		#for mod in jiggleModifiers:
		#	mod.active = true
		return
	follow_spline_skeleton_modifier.holeNode = holeNode
	follow_spline_skeleton_modifier.insideNode = insideNode
	guide_path.holeNode = holeNode
	guide_path.insideNode = insideNode
	enableSplineModifier(true)
	#for mod in jiggleModifiers:
	#	mod.active = false
	#follow_spline_skeleton_modifier.active = true

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
	
func getPenisHandler() -> PenisHandler:
	return penis_handler

func gatherPartFlags(_theFlags:Dictionary):
	_theFlags["CrotchBulge"] = true

func applyPartFlags(_theFlags:Dictionary):
	if(_theFlags.has("HidePenis") && _theFlags["HidePenis"]):
		visible = false
	else:
		visible = true
