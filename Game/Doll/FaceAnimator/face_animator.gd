@tool
extends Node
class_name FaceAnimator

var gestures:Array[FaceGestureBase] = []
var tweens:Dictionary[String, Tween] = {}

@export var dollPart:DollPart

@export var animPlayer:AnimationPlayer :
	set(value):
		animPlayer = value
		notify_property_list_changed()

@export var baseAnim_anim:String = "HeadTPose"

@export var eyesClose_anim:String = "Eyes_Close"
@export var eyesSexy_anim:String = "Eyes_Sexy"

@export var lookLeft_anim:String = "Look_Left"
@export var lookRight_anim:String = "Look_Right"
@export var lookUp_anim:String = "Look_Up"
@export var lookDown_anim:String = "Look_Down"
@export var lookCross_anim:String = "Look_Cross"

@export var mouthOpen_anim:String = "Mouth_Open"
@export var mouthPanting_anim:String = "Mouth_Panting"
@export var mouthBlep_anim:String = "Mouth_Blep"
@export var mouthSad_anim:String = "Mouth_Sad"
@export var mouthSmile_anim:String = "Mouth_Smile"
@export var mouthSnarl_anim:String = "Mouth_Snarl"

@export var browsShy_anim:String = "Brows_Shy"
@export var browsAngry_anim:String = "Brows_Angry"


func _validate_property(property: Dictionary) -> void:
	if property.name.ends_with("_anim"):
		if(animPlayer):
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = Util.join(animPlayer.get_animation_list(), ",")
			if(property.hint_string != ""):
				property.hint_string = " ,"+property.hint_string
		else:
			animTree.tree_root = null

var eyesClosedParam:String = "Eyes_Close/seek_request"
var eyesSexyParam:String = "Eyes_Sexy/blend_amount"
var lookDirXParam:String = "Look_Dir_X/blend_position"
var lookDirYParam:String = "Look_Dir_Y/blend_position"
var lookCrossParam:String = "Look_Cross/add_amount"
var mouthOpenParam:String = "Mouth_Open/seek_request"
var mouthBlepParam:String = "Mouth_Blep_Pos/seek_request"
var mouthPantingParam:String = "Panting/add_amount"
var mouthSmileParam:String = "Mouth_Smile/add_amount"
var mouthSadParam:String = "Mouth_Sad/add_amount"
var mouthSnarlParam:String = "Mouth_Snarl/add_amount"
var browsShyParam:String = "Brows_Shy/blend_amount"
var browsAngryParam:String = "Brows_Angry/blend_amount"

@onready var animTree: AnimationTree = %AnimationTree

@export var expressionState:int = DollExpressionState.Normal :
	set(value):
		expressionState = value

@export var moanMultiplier:float = 1.0

var faceOverride:FaceAnimatorOverrideProfile = FaceAnimatorOverrideProfile.new()
var gagMouthOverride:float = -1.0

static var cachedGestures:Array = []
func _ready() -> void:
	updateAnimTree()
	
	if(cachedGestures.is_empty()):
		var cachedGesturesPaths = Util.getScriptsInFolder("res://Game/Doll/FaceAnimator/Gestures/")
		for path in cachedGesturesPaths:
			cachedGestures.append(load(path))
	for gestureClass in cachedGestures:
		addGesture(gestureClass.new())
	#addGestureByID("Moan")
	#addGestureByID("SexGiving")
	#addGestureByID("SexReceiving")
	#addGestureByID("Blinking")
	#addGestureByID("LookDir")
	#addGestureByID("Orgasm")
	
	sortGestures()
	
	pass

func addGesture(theGesture:FaceGestureBase):
	theGesture.animatorRef = weakref(self)
	gestures.append(theGesture)
	theGesture.updateExpressionState(expressionState)
	theGesture.influence = 1.0 if theGesture.isEnabled() else 0.0
	
func addGestureByID(theID:String):
	addGesture(load("res://Game/Doll/FaceAnimator/Gestures/"+theID+".gd").new())

func getDoll() -> Doll:
	if(!dollPart):
		return null
	return dollPart.getDoll()

func getCharacter() -> BaseCharacter:
	var theDoll := getDoll()
	if(!theDoll):
		return null
	return theDoll.getCharacter()

var facialAnimTree = preload("res://Game/Doll/FaceAnimator/FacialAnimTree.tres")

func updateAnimTree():
	if(!animPlayer):
		animTree.anim_player = NodePath()
		animTree.tree_root = null
		return
	animTree.anim_player = animTree.get_path_to(animPlayer)
	
	var blendTree:AnimationNodeBlendTree = facialAnimTree.duplicate(true)
	
	setBlendTreeAnimNode(blendTree, "anim_mouth_open", mouthOpen_anim)
	
	setBlendTreeAnimNode(blendTree, "mouth_panting_anim", mouthPanting_anim)
	setBlendTreeAnimNode(blendTree, "mouth_blep", mouthBlep_anim)
	setBlendTreeAnimNode(blendTree, "mouth_smile", mouthSmile_anim)
	setBlendTreeAnimNode(blendTree, "mouth_sad", mouthSad_anim)
	setBlendTreeAnimNode(blendTree, "mouth_snarl", mouthSnarl_anim)
	setBlendTreeAnimNode(blendTree, "mouth_panting_base", baseAnim_anim)
	
	setBlendTreeAnimNode(blendTree, "eyes_close_anim", eyesClose_anim)
	setBlendTreeAnimNode(blendTree, "eyes_sexy", eyesSexy_anim)
	setBlendTreeAnimNode(blendTree, "eyes_closed_base", baseAnim_anim)
	
	setBlendTreeAnimNode(blendTree, "brows_base", baseAnim_anim)
	setBlendTreeAnimNode(blendTree, "brows_shy", browsShy_anim)
	setBlendTreeAnimNode(blendTree, "brows_angry", browsAngry_anim)
	
	setBlendTreeAnimNode(blendTree, "look_cross", lookCross_anim)
	
	setBlendTreeBlend1Nodes(blendTree, "Look_Dir_X", [
		[lookLeft_anim, -1.0],
		[lookRight_anim, 1.0],
	])
	
	setBlendTreeBlend1Nodes(blendTree, "Look_Dir_Y", [
		[lookDown_anim, -1.0],
		[lookUp_anim, 1.0],
	])
	
	#animTree.root_node = animPlayer.root_node
	animTree.tree_root = blendTree
	animTree["parameters/Look_Dir/add_amount"] = 1.0
	animTree["parameters/LookDirStuff/add_amount"] = 1.0
	animTree["parameters/Mouth_Add/add_amount"] = 1.0
	animTree["parameters/Brows_Add/add_amount"] = 1.0
	animTree["parameters/Mouth_Blep/add_amount"] = 1.0
	animTree["parameters/Mouth_Blep_Time/scale"] = 0.0
	animTree["parameters/Eyes_Close_Time/scale"] = 0.0
	animTree["parameters/Eyes_Closed_Add/add_amount"] = 1.0
	animTree["parameters/Mouth_Open_Add/add_amount"] = 1.0
	animTree["parameters/Eyes_Close_Time/scale"] = 0.0

func setBlendTreeAnimNode(theBlendTree:AnimationNodeBlendTree, animNodeName:String, newAnim:String):
	var anAnimNode:AnimationNodeAnimation = theBlendTree.get_node(animNodeName)
	anAnimNode.animation = newAnim

func setBlendTreeBlend1Nodes(theBlendTree:AnimationNodeBlendTree, animNodeName:String, animsAndPoses:Array):
	var blendSpace1Node:AnimationNodeBlendSpace1D = theBlendTree.get_node(animNodeName)
	while(blendSpace1Node.get_blend_point_count() > 0):
		blendSpace1Node.remove_blend_point(0)
	for animAndPos in animsAndPoses:
		var newAnimNode:AnimationNodeAnimation = AnimationNodeAnimation.new()
		newAnimNode.animation = animAndPos[0]
		blendSpace1Node.add_blend_point(newAnimNode, animAndPos[1])

func setParam(theParam:String, theValue:float):
	if(!animTree):
		return
	animTree["parameters/"+theParam] = theValue

# Can bind the param name this way
func setParamRev(theValue:float, theParam:String):
	if(!animTree):
		return
	animTree.set("parameters/"+theParam, theValue)

func getParamValue(theParam:String) -> float:
	if(!animTree):
		return 0.0
	var result = animTree.get("parameters/"+theParam)
	if(result is float):
		return result
	return 0.0

func setExpressionState(_newExpr:int):
	if(_newExpr == DollExpressionState.IgnoreChange):
		return
	if(_newExpr == expressionState):
		return
	expressionState = _newExpr
	for gesture in gestures:
		gesture.updateExpressionState(expressionState)

func getExpressionState() -> int:
	return expressionState

func sendFaceGestureEvent(_eventID:String, _args:Array):
	for gesture in gestures:
		gesture.onEvent(_eventID, _args)

func doMoan(_soundEntry: SexSoundEntry, _voiceHandler:VoiceHandler, moanMult:float = 1.0):
	sendFaceGestureEvent("moan", [_soundEntry, _voiceHandler, moanMult])

func doMoanLoudness(_soundEntry: SexSoundEntry, _loudness: SexSoundLoudness, _voiceHandler:VoiceHandler, moanMult:float = 1.0):
	sendFaceGestureEvent("moanLoudness", [_soundEntry, _loudness, _voiceHandler, moanMult])
	sendFaceGestureEvent("orgasm", [])

func onVoiceSound(_soundType: int, _soundEntry: SexSoundEntry, _voiceHandler:VoiceHandler):
	if(_soundType == SexSoundType.Moan):
		doMoan(_soundEntry, _voiceHandler, RNG.randfRange(0.5, 0.8))
	if(_soundType in [SexSoundType.Orgasm, SexSoundType.OrgasmPanting]):
		var loudness:SexSoundLoudness = _soundEntry.getLoudness()
		if(!loudness):
			doMoan(_soundEntry, _voiceHandler, 0.6 if (_soundType == SexSoundType.OrgasmPanting) else 1.0)
		else:
			doMoanLoudness(_soundEntry, loudness, _voiceHandler, 1.0 if (_soundType == SexSoundType.OrgasmPanting) else 1.0)

func moveValueTowards(theVal:float, targetVal:float, speedChange:float) -> float:
	if(theVal > targetVal):
		theVal -= speedChange
		if(theVal < targetVal):
			theVal = targetVal
	elif(theVal < targetVal):
		theVal += speedChange
		if(theVal > targetVal):
			theVal = targetVal
	return theVal

func _process(_delta: float) -> void:
	if(Engine.is_editor_hint()):
		return
	updateFaceExpression(_delta)
	for gesture in gestures:
		gesture.processTimeFinal(_delta)

func updateFaceExpression(_delta: float):
	if(!animTree.tree_root):
		return
	
	setParam(mouthOpenParam, clamp(getFaceValue(FaceValue.MouthOpen), 0.0, 1.0))
	setParam(mouthPantingParam, clamp(getFaceValue(FaceValue.MouthPanting), 0.0, 1.0))
	setParam(eyesClosedParam, clamp(getFaceValue(FaceValue.EyesClosed), 0.0, 1.0))
	setParam(mouthBlepParam, clamp(getFaceValue(FaceValue.MouthBlep), 0.0, 1.0))
	setParam(eyesSexyParam, clamp(getFaceValue(FaceValue.EyesSexy), 0.0, 1.0))
	setParam(browsShyParam, clamp(getFaceValue(FaceValue.BrowsShy), 0.0, 1.0))
	setParam(browsAngryParam, clamp(getFaceValue(FaceValue.BrowsAngry), 0.0, 1.0))
	setParam(lookCrossParam, clamp(getFaceValue(FaceValue.LookCross), 0.0, 1.0))
	setParam(mouthSadParam, clamp(getFaceValue(FaceValue.MouthSad), 0.0, 1.0))
	setParam(mouthSmileParam, clamp(getFaceValue(FaceValue.MouthSmile), 0.0, 1.0))
	setParam(mouthSnarlParam, clamp(getFaceValue(FaceValue.MouthSnarl), 0.0, 1.0))
	
	var lookDirFinal:Vector2 = getFaceVec2(FaceValue.LookDir)
	setParam(lookDirXParam, lookDirFinal.x)
	setParam(lookDirYParam, lookDirFinal.y)

func getFaceValue(theFaceValue:int) -> float:
	if(faceOverride.isFaceValueOverridden(theFaceValue)):
		return faceOverride.getFaceValueOverride(theFaceValue)
	if(theFaceValue == FaceValue.MouthOpen):
		if(gagMouthOverride >= 0.0):
			return gagMouthOverride
	
	var result:float = 0.0
	
	for gesture in gestures:
		if(!gesture.doesProcessValue):
			continue
		var anInfluence:float = gesture.getInfluence()
		if(anInfluence <= 0.0):
			continue
		var anValue:float = gesture.processFaceValue(theFaceValue, result)
		
		result = result*(1.0 - anInfluence) + anValue*anInfluence
	
	return result

func getFaceVec2(theFaceValue:int) -> Vector2:
	if(faceOverride.isFaceValueOverridden(theFaceValue)):
		return faceOverride.getFaceValueOverride(theFaceValue, Vector2(0.0, 0.0))
	
	var result:Vector2 = Vector2(0.0, 0.0)
	
	for gesture in gestures:
		if(!gesture.doesProcessVec2):
			continue
		var anInfluence:float = gesture.getInfluence()
		if(anInfluence <= 0.0):
			continue
		var anValue:Vector2 = gesture.processFaceVec2(theFaceValue, result)
		
		result = result*(1.0 - anInfluence) + anValue*anInfluence
	
	return result

func sortGestures():
	gestures.sort_custom(func(a:FaceGestureBase, b:FaceGestureBase): return a.getPriority() < b.getPriority())

func doTween(tweenID:String, theObj:Object, theVar:String, valPairs:Array) -> Tween:
	if(tweens.has(tweenID)):
		if(tweens[tweenID]):
			tweens[tweenID].kill()
		tweens.erase(tweenID)
	
	var theTween:Tween = create_tween()
	theTween.set_trans(Tween.TRANS_SINE)
	for valPair in valPairs:
		theTween.tween_property(theObj, theVar, valPair[0], valPair[1])
	return theTween

func getMoanMultiplier() -> float:
	return moanMultiplier

func setFaceOverrideData(_data:Dictionary):
	faceOverride.loadData(_data)

func setGagMouthOverride(_val:float = -1.0):
	gagMouthOverride = _val
