@tool
extends PenisHandlerBase
class_name PenisHandler

@export var part:DollPart
@export var skeleton:Skeleton3D
@export var animPlayer:AnimationPlayer

# Basic stuff
@export var straponMode:bool = false # Ignores cage stuff, cum stuff, always hard

# PP len stuff
var penisLen:float = 1.0
@export_enum(" ") var lenModificationTip: String
@export var lenChainLength:int = 1
#var lenModificationBoneID:int = -1
@export_enum(" ") var ballsBone: String
#var ballsBoneID:int = -1
@export_enum(" ") var scaleBone: String
@export_enum(" ") var scaleBoneDown: String

var lenModifier:PenisSkeletonModifier

# PP guide-to-hole/thickness stuff
@export var thicknessCurve:Curve = preload("res://Mesh/Parts/Util/Penis/ThicknessCurveKnot.tres")
@export var thicknessMult:float = 1.0
@export_enum(" ") var penisGuideStart: String
@export_enum(" ") var penisGuideTip: String
@export var penisGuideChainLen:int = 1
var shaftNode:BoneAttachment3D

var followSplineModifier:FollowSplineSkeletonModifier
var guidePath:PenisGuidePath
var guiding:float = 0.0

# Wiggle stuff
@export_enum(" ") var penisWiggleTip: String
@export var penisWiggleChainLen:int = 1
@export_enum(" ") var ballsWiggleBone: String
@export_enum(" ") var ballsWiggleBoneExtra1: String
@export_enum(" ") var ballsWiggleBoneExtra2: String

var wiggleMods:Array[SkeletonModifier3D] = []
var wiggleModsExtra:Array[SkeletonModifier3D] = []

# Cum particles stuff
@export_enum(" ") var cumForwardBone: String
@export_enum(" ") var cumInsideBone: String
var cumForwardScene:Node3D
var cumInsideScene:Node3D
const BACK_CUM_ATTACH = preload("res://Mesh/Parts/Util/Penis/BackCumAttach.tscn")
const TIP_CUM_ATTACH = preload("res://Mesh/Parts/Util/Penis/TipCumAttach.tscn")

# Erection stuff
var erection:float = 1.0
var erectionTarget:float = 1.0
var erectionOverrideMax:float = 0.0
@export var gravityHard:float = 10.0
@export var gravitySoft:float = 200.0
@export var hardAnim:String = "APose"
@export var hardToSoftAnim:String = "HardToSoft"

# Caged stuff
@export var cageBone:String = ""
@export var cagedAnim:String = ""
@export var cageScale:float = 1.0
var cagedState:bool = false
var cagedBoneAttacher:BoneAttachment3D

func _validate_property(property: Dictionary) -> void:
	if property.name in ["lenModificationTip", "ballsBone", "scaleBone", "scaleBoneDown", "penisGuideTip", "penisWiggleTip", "ballsWiggleBone", "ballsWiggleBoneExtra1", "ballsWiggleBoneExtra2", "cumForwardBone", "cumInsideBone", "penisGuideStart", "cageBone"]:
		if skeleton:
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = skeleton.get_concatenated_bone_names()
	if(property.name in ["hardToSoftAnim", "hardAnim", "cagedAnim"]):
		if(animPlayer):
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = Util.join(animPlayer.get_animation_list(), ",")

func clearModifiers():
	erection = 1.0
	guiding = 0.0
	
	if(lenModifier):
		lenModifier.queue_free()
		lenModifier = null
	if(followSplineModifier):
		followSplineModifier.queue_free()
		followSplineModifier = null
	if(guidePath):
		guidePath.queue_free()
		guidePath = null
	for theMod:SkeletonModifier3D in wiggleMods:
		theMod.queue_free()
	wiggleMods.clear()
	for theMod:SkeletonModifier3D in wiggleModsExtra:
		theMod.queue_free()
	wiggleModsExtra.clear()
	if(cumForwardScene):
		cumForwardScene.queue_free()
		cumForwardScene = null
	if(cumInsideScene):
		cumInsideScene.queue_free()
		cumInsideScene = null
	if(shaftNode):
		shaftNode.queue_free()
		shaftNode = null
	if(animPlayer):
		animPlayer.play(hardAnim, 0.0, 1.0)
		animPlayer.stop()
	if(cagedBoneAttacher):
		cagedBoneAttacher.queue_free()
		cagedBoneAttacher = null
	
func createModifiers():
	clearModifiers()
	
	if(!skeleton):
		return
	
	if(!penisGuideStart.is_empty()):
		shaftNode = BoneAttachment3D.new()
		skeleton.add_child(shaftNode)
		shaftNode.bone_name = penisGuideStart
	
	lenModifier = PenisSkeletonModifier.new()
	lenModifier.lenModificationBone = lenModificationTip
	lenModifier.chainLength = lenChainLength
	lenModifier.ballsBone = ballsBone
	lenModifier.scaleBone = scaleBone
	lenModifier.scaleBone2 = scaleBoneDown
	skeleton.add_child(lenModifier)
	
	guidePath = PenisGuidePath.new()
	guidePath.shaftNode = shaftNode
	skeleton.add_child(guidePath)
	
	followSplineModifier = FollowSplineSkeletonModifier.new()
	followSplineModifier.bone = penisGuideTip
	followSplineModifier.chainLength = penisGuideChainLen
	followSplineModifier.thicknessCurve = thicknessCurve
	followSplineModifier.targetPath = guidePath
	followSplineModifier.active = false
	skeleton.add_child(followSplineModifier)
	
	if(!penisWiggleTip.is_empty()):
		var theBoneIDs := getBoneIDs(penisWiggleTip, penisWiggleChainLen, true)
		for theBoneID in theBoneIDs:
			var theBoneName:String = skeleton.get_bone_name(theBoneID)
			var newMod := DMWBWiggleRotationModifier3D.new()
			newMod.name = "PPWiggle"+str(theBoneName)
			newMod.properties = preload("res://Mesh/Parts/Util/Penis/PPWiggleProps.tres")
			newMod.bone_name = theBoneName
			skeleton.add_child(newMod)
			wiggleMods.append(newMod)
	for theBoneName:String in [ballsWiggleBone, ballsWiggleBoneExtra1, ballsWiggleBoneExtra2]:
		if(!theBoneName.is_empty()):
			var newMod := DMWBWiggleRotationModifier3D.new()
			newMod.name = "PPWiggle"+str(theBoneName)
			newMod.properties = preload("res://Mesh/Parts/Util/Penis/BallsWiggleProps.tres")
			newMod.bone_name = theBoneName
			skeleton.add_child(newMod)
			wiggleModsExtra.append(newMod)
	
	if(!cumForwardBone.is_empty()):
		cumForwardScene = TIP_CUM_ATTACH.instantiate()
		cumForwardScene.bone_name = cumForwardBone
		skeleton.add_child(cumForwardScene)
	if(!cumInsideBone.is_empty()):
		cumInsideScene = BACK_CUM_ATTACH.instantiate()
		cumInsideScene.bone_name = cumInsideBone
		skeleton.add_child(cumInsideScene)
	if(!cageBone.is_empty()):
		cagedBoneAttacher = BoneAttachment3D.new()
		cagedBoneAttacher.bone_name = cageBone
		skeleton.add_child(cagedBoneAttacher)
		var cageAttachPoint:DollAttachPoint = DollAttachPoint.new()
		cageAttachPoint.pointName = "chastityCage"
		cageAttachPoint.scale = Vector3(cageScale, cageScale, cageScale)
		cageAttachPoint.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
		cagedBoneAttacher.add_child(cageAttachPoint)
	
func _ready() -> void:
	if(Engine.is_editor_hint()):
		return
	createModifiers()

func cum(_isForward:bool, _isStrapon:bool = false):
	if(straponMode != _isStrapon): # Strapons ignore non-strapon orgasms. PPs ignore strapon orgasms
		return
	
	if(cagedState): # We trust that the cage will orgasm instead
		return
	if(!_isForward):
		if(cumInsideScene && cumInsideScene.getFirst()):
			CumManager.doShoot(cumInsideScene.getFirst(), RNG.randfRange(1.0, 3.0))
	else:
		if(cumForwardScene && cumForwardScene.getFirst()):
			CumManager.doShoot(cumForwardScene.getFirst(), RNG.randfRange(1.0, 3.0))

	if(_isForward):
		if(cumForwardScene):
			cumForwardScene.cum()
	else:
		if(cumInsideScene):
			cumInsideScene.cum()

# Returns _chainLen bones, including the tip (or less if the hierarchy wasn't long enough)
func getBoneIDs(_tipName:String, _chainLen:int, _reverse:bool = false) -> Array[int]:
	if(!skeleton || _chainLen <= 0):
		return []
	var theTipID:int = skeleton.find_bone(_tipName)
	if(theTipID < 0):
		return []
		
	var result:Array[int] = [theTipID]
	while(_chainLen > 1):
		theTipID = skeleton.get_bone_parent(theTipID)
		if(theTipID < 0):
			break
		result.append(theTipID)
		_chainLen -= 1
	
	if(_reverse):
		result.reverse()
	
	return result


func internalSetGuiding(_guiding:float):
	guiding = _guiding
	updateSkeletonModifiers()

var enableTween:Tween
func enableSplineModifier(doEn:bool, _time:float = 0.5):
	if(enableTween):
		enableTween.kill()
		enableTween = null
	enableTween = create_tween()
	enableTween.set_parallel(true)
	
	enableTween.tween_method(internalSetGuiding, guiding, 1.0 if doEn else 0.0, _time)
	#followSplineModifier.active = true
	#enableTween.tween_property(followSplineModifier, "influence", 1.0 if doEn else 0.0, _time)
	#for mod in wiggleMods:
		#mod.active = true
		#enableTween.tween_property(mod, "influence", 0.0 if doEn else 1.0, _time)
	enableTween.chain().tween_callback(doEnableSpline.bind(doEn))
	
func doEnableSpline(_isEn:bool):
	if(enableTween):
		enableTween.kill()
		enableTween = null
	guiding = 1.0 if _isEn else 0.0
	updateSkeletonModifiers()
	#followSplineModifier.active = _isEn
	#for mod in wiggleMods:
		#mod.active = !_isEn
		#mod.influenceActualMax = 1.0 if !_isEn else 0.0
	if(!_isEn):
		followSplineModifier.holeNode = null
		followSplineModifier.insideNode = null
		guidePath.holeNode = null
		guidePath.insideNode = null

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
	followSplineModifier.holeNode = holeNode
	followSplineModifier.insideNode = insideNode
	guidePath.holeNode = holeNode
	guidePath.insideNode = insideNode
	enableSplineModifier(true)
	#for mod in jiggleModifiers:
	#	mod.active = false
	#follow_spline_skeleton_modifier.active = true

func getPenisRootScale() -> float:
	if(!lenModifier):
		return 1.0
	return lenModifier.penisScale

func setPenisRootScale(_scale:float):
	if(!lenModifier):
		return
	if(_scale > 1.0):
		lenModifier.penisScale = _scale
		lenModifier.penisScale2 = 1.0
	else:
		lenModifier.penisScale = 1.0
		lenModifier.penisScale2 = _scale

func applyOption(_optionID:String, _value:Variant) -> bool:
	if(_optionID == "penisScale"):
		setPenisRootScale(_value)
		return true
	if(_optionID == "penisLenMod"):
		penisLen = _value
		updateSkeletonModifiers()
		return true
	if(_optionID == "penBallsDrop"):
		if(lenModifier):
			lenModifier.ballsDrop = _value
		return true
	if(_optionID == "penBallsScale"):
		if(lenModifier):
			lenModifier.ballsScale = _value
		return true
	if(_optionID == "erection"):
		#setErection(_value)
		erectionOverrideMax = _value
		checkShouldProcess()
		return true
	
	return false

func setGravity(_grav:float):
	for theMod:DMWBWiggleRotationModifier3D in wiggleMods:
		theMod.force_global = Vector3(0.0, -_grav, 0.0)

func setWiggleModInfluence(_influence:float):
	for theMod:DMWBWiggleRotationModifier3D in wiggleMods:
		theMod.influence = _influence
		theMod.influenceActualMax = _influence
		theMod.active = (_influence > 0.0)

func setWiggleModInfluenceExtra(_influence:float):
	for theMod:DMWBWiggleRotationModifier3D in wiggleModsExtra:
		theMod.influence = _influence
		theMod.influenceActualMax = _influence
		theMod.active = (_influence > 0.0)

func getActualErection() -> float:
	return maxf(erection, guiding)

func updateSkeletonModifiers():
	var theErection:float = erection#getActualErection()
	
	if(cagedState):
		if(animPlayer):
			animPlayer.play(cagedAnim, 0.0, 1.0)
		erection = 0.0
		setGravity(0.0)
	elif(theErection >= 1.0):
		if(animPlayer):
			animPlayer.play(hardAnim, 0.2, 1.0)
		setGravity(gravityHard)
	elif(theErection >= ERECTION_MIDDLE):
		if(animPlayer):
			animPlayer.play(hardAnim, 0.2, 1.0)
		setGravity(remap(theErection, 1.0, ERECTION_MIDDLE, gravityHard, gravitySoft))
	else:
		if(animPlayer):
			animPlayer.play(hardToSoftAnim, 0.2, 0.0)
			animPlayer.seek(remap(theErection, ERECTION_MIDDLE, 0.0, 0.0, animPlayer.current_animation_length))
		setGravity(gravitySoft)
	
	var theErectionInfluence:float = 1.0
	if(theErection < ERECTION_WIGGLE_MIDDLE):
		theErectionInfluence = clampf(remap(theErection, ERECTION_WIGGLE_MIDDLE, ERECTION_WIGGLE_BOTTOM, 1.0, 0.0), 0.0, 1.0)
	var theGuidingInfluence:float = clampf(1.0-guiding, 0.0, 1.0)
	
	if(followSplineModifier):
		followSplineModifier.active = (guiding > 0.0 && theErection >= ERECTION_WIGGLE_MIDDLE && !cagedState)
		followSplineModifier.influence = guiding*theErection
	
	#if(lenModifier):
	#	lenModifier.active = (theErection > 0.0)
	#	lenModifier.influence = theErection
	
	if(lenModifier):
		if(cagedState):
			lenModifier.lenModifier = 1.0
		else:
			var theTargetLen := (penisLen-1.0)/float(lenChainLength)*3.0+1.0
			lenModifier.lenModifier = theTargetLen*theErectionInfluence+(1.0-theErectionInfluence)
			#lenModifier.active = !cagedState
	
	setWiggleModInfluence(theErectionInfluence*theGuidingInfluence*(0.0 if cagedState else 1.0))
	setWiggleModInfluenceExtra(1.0)
	#setWiggleModInfluenceExtra(theErectionInfluence)

var erectionTween:Tween
func setErection(_val:float):
	if(straponMode):
		return
	_val = clampf(_val, 0.0, 1.0)
	#if(erectionTween):
		#erectionTween.kill()
		#erectionTween = null
	if(erectionTarget == _val):
		return
	erectionTarget = _val
	checkShouldProcess()
	#erectionTween = create_tween()
	#erectionTween.tween_method(setErectionInstant, erection, _val, absf(erection - _val)*ERECTION_TIME)

const ERECTION_MIDDLE := 0.6
const ERECTION_WIGGLE_MIDDLE := 0.6
const ERECTION_WIGGLE_BOTTOM := 0.3
const ERECTION_TIME := 2.0

func setErectionInstant(_val:float):
	_val = clampf(_val, 0.0, 1.0)
	#if(erection == _val):
	#	return
	erection = _val
	updateSkeletonModifiers()

func setTargetErection(_val:float):
	setErection(_val)
	#erectionTarget = _val
	#checkShouldProcess()

func getTargetErectionFinal() -> float:
	if(straponMode):
		return 1.0
	return maxf(maxf(erectionTarget, erectionOverrideMax), guiding)

func checkShouldProcess():
	var shouldUpdate:bool = false
	var theTarget:float = getTargetErectionFinal()
	if(theTarget != erection):
		shouldUpdate = true
	set_process(shouldUpdate)

func setCaged(_caged:bool):
	if(cagedState == _caged || straponMode):
		return
	cagedState = _caged
	updateSkeletonModifiers()
	checkShouldProcess()

func _process(_delta: float) -> void:
	var _newErection:float = Util.moveValueTo(erection, getTargetErectionFinal(), _delta*0.5)
	setErectionInstant(_newErection)
	checkShouldProcess()

@export_tool_button("Test Penis Length and Balls", "Callable") var doTestCreate_action = doTestCreate
@export_tool_button("Test Cum", "Callable") var doTestCum_action = doTestCum
@export_tool_button("Test Erection Soft", "Callable") var doTestErectionSoft_action = doTestErectionSoft
@export_tool_button("Test Erection Hard", "Callable") var doTestErectionHard_action = doTestErectionHard
@export_tool_button("TEST STOP ALL", "Callable") var doTestStop_action = doTestStop

func doTestErectionSoft():
	createModifiers()
	setErection(0.0)
func doTestErectionHard():
	createModifiers()
	setErectionInstant(0.0)
	setErection(1.0)

func doTestCreate():
	createModifiers()
	
	if(lenModifier):
		lenModifier.ballsScale = 2.0
		lenModifier.lenModifier = 2.0

func doTestStop():
	clearModifiers()

func doTestCum():
	createModifiers()
	if(cumForwardScene):
		cumForwardScene.cum()
	if(cumInsideScene):
		cumInsideScene.cum()
