extends Node3D
class_name AnimSceneBase

var sitters:Dictionary = {}
var penisTarget:Dictionary = {}

var states:Dictionary = {}
var startState:String = ""

var oneShots:Dictionary = {}

var state:String = ""
var currentStateSpeed:float = 1.0

var animLibraries:Dictionary = {}
var animData:Dictionary = {}

const HOLE_VAGINA = 0
const HOLE_ANUS = 1

const PENISTARGET_SITTER_HOLE = 0

signal onAnimUpdate
signal onPawnSwitch(id, pawn)
signal onDollSwitch(id, doll)
signal onAnimEvent(eventID, args)
signal onAnimPlay(state)

var speedSwitchTimer:Timer

var mainAnimPlayer:AnimationPlayer
var mainAnimTree:AnimationTree

const CONF_BASESPEED = "baseSpeed"
const CONF_SPEEDMULT_MIN = "speedMultMin"
const CONF_SPEEDMULT_MAX = "speedMultMax"
const CONF_TIMEDSPEEDSWITCH_MIN = "timedSpeedSwitchMin"
const CONF_TIMEDSPEEDSWITCH_MAX = "timedSpeedSwitchMax"
const CONF_ANIMEVENTS = "animEvents"
const CONF_HIDETAGS = "hideTags"

var dollBlendTreeBase:AnimationNodeBlendTree = preload("res://Game/Doll/Util/DollBlendTreeBase.tres")

# Anim support toggles
var supportsArmbinderAnim:bool = true
var supportsCuffedAnim:bool = true


func _ready() -> void:
	speedSwitchTimer = Timer.new()
	add_child(speedSwitchTimer)
	speedSwitchTimer.autostart = false
	speedSwitchTimer.one_shot = true
	speedSwitchTimer.timeout.connect(onSpeedSwitchTimer)
	
	setupScene()

func setupScene() -> void:
	pass

func sendAnimationEvent(_eventID:String):
	onAnimationEvent(_eventID)
	onAnimEvent.emit(_eventID, [])

func onAnimationEvent(_eventID:String):
	print("UNHANDLED ANIMATION EVENT ID "+str(_eventID))

func startSpeedSwitchTimer():
	speedSwitchTimer.stop()
	var currentStateData:Dictionary = getCurrentStateData()
	if(currentStateData.is_empty()):
		return

	var theTimedSpeedSwitchMin:float = currentStateData[CONF_TIMEDSPEEDSWITCH_MIN] if currentStateData.has(CONF_TIMEDSPEEDSWITCH_MIN) else 0.0
	var theTimedSpeedSwitchMax:float = currentStateData[CONF_TIMEDSPEEDSWITCH_MAX] if currentStateData.has(CONF_TIMEDSPEEDSWITCH_MAX) else 0.0
	if(theTimedSpeedSwitchMin > theTimedSpeedSwitchMax):
		return
	var timeNextSwitch:float = RNG.randfRange(theTimedSpeedSwitchMin, theTimedSpeedSwitchMax)
	if(timeNextSwitch > 0.0):
		speedSwitchTimer.start(timeNextSwitch)
	
var tween:Tween
func onSpeedSwitchTimer():
	var currentStateData:Dictionary = getCurrentStateData()
	if(currentStateData.is_empty()):
		return
	
	var theSpeedMultMin:float = currentStateData[CONF_SPEEDMULT_MIN] if currentStateData.has(CONF_SPEEDMULT_MIN) else 1.0
	var theSpeedMultMax:float = currentStateData[CONF_SPEEDMULT_MAX] if currentStateData.has(CONF_SPEEDMULT_MAX) else 1.0
	if(theSpeedMultMin > theSpeedMultMax):
		return
	
	var newSpeed:float = RNG.randfRange(theSpeedMultMin, theSpeedMultMax)
	
	
	if tween:
		tween.kill()
		tween = null
	tween = create_tween()
	tween.tween_method(setStateSpeedTween.bind(state), getStateSpeed(state), newSpeed, 0.2)
	#print("NEW SPEED = "+str(newSpeed))
	#setStateSpeed(state, newSpeed)
	
	
	startSpeedSwitchTimer()

func alignPenisToSitterHole(theID:String, otherID:String, holeID:int):
	penisTarget[theID] = {
		type = PENISTARGET_SITTER_HOLE,
		id = otherID,
		hole = holeID,
	}
	updatePenisTargetFor(theID)

func alignPenisReset(theID:String):
	if(!penisTarget.has(theID)):
		return
	penisTarget.erase(theID)
	updatePenisTargetFor(theID)

func addAnimLibrary(theID:String, thePath:String):
	animLibraries[theID] = thePath

func setStartState(stateID:String):
	startState = stateID

func addAdditiveOneshot(oneshotID:String, animByPose:Dictionary, baseAnimByPose:Dictionary, _theSettings:Dictionary = {}):
	oneShots[oneshotID] = {
		anims = animByPose,
		baseAnims = baseAnimByPose,
		settings = _theSettings,
	}

func addState(stateID:String, animByPose:Dictionary, stateSettings:Dictionary = {}):
	var theStateInfo:Dictionary = {
		anims = animByPose,
		connections = {},
	}
	
	theStateInfo[CONF_BASESPEED] = stateSettings[CONF_BASESPEED] if stateSettings.has(CONF_BASESPEED) else 1.0
	theStateInfo[CONF_SPEEDMULT_MIN] = stateSettings[CONF_SPEEDMULT_MIN] if stateSettings.has(CONF_SPEEDMULT_MIN) else 1.0
	theStateInfo[CONF_SPEEDMULT_MAX] = stateSettings[CONF_SPEEDMULT_MAX] if stateSettings.has(CONF_SPEEDMULT_MAX) else 1.0
	theStateInfo[CONF_TIMEDSPEEDSWITCH_MIN] = stateSettings[CONF_TIMEDSPEEDSWITCH_MIN] if stateSettings.has(CONF_TIMEDSPEEDSWITCH_MIN) else 0.0
	theStateInfo[CONF_TIMEDSPEEDSWITCH_MAX] = stateSettings[CONF_TIMEDSPEEDSWITCH_MAX] if stateSettings.has(CONF_TIMEDSPEEDSWITCH_MAX) else 0.0
	theStateInfo[CONF_ANIMEVENTS] = stateSettings[CONF_ANIMEVENTS] if stateSettings.has(CONF_ANIMEVENTS) else []
	theStateInfo[CONF_HIDETAGS] = stateSettings[CONF_HIDETAGS] if stateSettings.has(CONF_HIDETAGS) else {}
	
	states[stateID] = theStateInfo

func connectStates(state1:String, state2:String, interpolationTime:float = 0.2, isOneWay:bool = false, isAuto:bool = false):
	var stateinfo1:Dictionary = states[state1]
	var stateinfo2:Dictionary = states[state2]
	
	stateinfo1["connections"][state2] = {time=interpolationTime, auto=isAuto}
	if(!isOneWay):
		stateinfo2["connections"][state1] = {time=interpolationTime, auto=isAuto}

func updateAllAnimTrees():
	for seatID in sitters:
		updateAnimPlayerFor(seatID)
	
	calculateStateAnimData()
	updateMainAnimTree()
	
	for seatID in sitters:
		updateAnimTreeFor(seatID)

func updateAnimPlayerFor(seatID:String):
	var seatInfo:Dictionary = sitters[seatID]
	var animPlayer:AnimationPlayer = seatInfo["anim"]
	
	animPlayer.add_animation_library("RestraintAnims", preload("res://Anims/Raw/RestraintAnims.glb"))
	for animLibraryID in animLibraries:
		animPlayer.add_animation_library(animLibraryID, load(animLibraries[animLibraryID]))
	
	Doll.updateAnimPlayerSpecific(animPlayer)

func calculateStateAnimData():
	animData.clear()
	
	var seatID:String = sitters.keys()[0]
	var seatInfo:Dictionary = sitters[seatID]
	var animPlayer:AnimationPlayer = seatInfo["anim"]
	
	for stateID in states:
		var stateInfo:Dictionary = states[stateID]
		var animName:String = stateInfo["anims"][seatID]
		var theAnimation:Animation = animPlayer.get_animation(animName)
		
		animData[stateID] = {
			len = theAnimation.length,
			loop = theAnimation.loop_mode,
			step = theAnimation.step,
		}
	
	for oneshotID in oneShots:
		var oneshotData:Dictionary = oneShots[oneshotID]
		var oneshotAnimName:String = oneshotData["anims"][seatID]
		var theAnimation:Animation = animPlayer.get_animation(oneshotAnimName)
		
		animData[oneshotID] = {
			len = theAnimation.length,
			loop = theAnimation.loop_mode,
			step = theAnimation.step,
		}
		
func updateMainAnimTree():
	if(mainAnimPlayer):
		mainAnimPlayer.queue_free()
		mainAnimPlayer = null
	if(mainAnimTree):
		mainAnimTree.queue_free()
		mainAnimTree = null
	
	mainAnimPlayer = AnimationPlayer.new()
	mainAnimPlayer.name = "MainAnimPlayer"
	mainAnimPlayer.root_node = NodePath("..")
	add_child(mainAnimPlayer)
	mainAnimTree = AnimationTree.new()
	mainAnimTree.name = "MainAnimTree"
	mainAnimTree.root_node = NodePath("..")
	add_child(mainAnimTree)
	mainAnimTree.anim_player = mainAnimTree.get_path_to(mainAnimPlayer)
	
	var mainAnimationLibrary:AnimationLibrary = AnimationLibrary.new()
	
	for stateID in states:
		var stateInfo:Dictionary = states[stateID]
		var newAnim:Animation = Animation.new()
		
		newAnim.step = animData[stateID]["step"]
		newAnim.length = animData[stateID]["len"]
		newAnim.loop_mode = animData[stateID]["loop"]
		
		var newTrack = newAnim.add_track(Animation.TYPE_METHOD)
		newAnim.track_set_path(newTrack, NodePath("."))
		
		var animEvents:Array = stateInfo[CONF_ANIMEVENTS] if stateInfo.has(CONF_ANIMEVENTS) else []
		for theAnimEvent in animEvents:
			var theTime:float = float(theAnimEvent[0])
			var theArg:String = theAnimEvent[1]
			
			newAnim.track_insert_key(newTrack, theTime, {
				method = "sendAnimationEvent",
				args = [theArg],
			})
		#newAnim.track_set_key_value()
		
		mainAnimationLibrary.add_animation(stateID, newAnim)
	
	for oneshotID in oneShots:
		var oneShotInfo:Dictionary = oneShots[oneshotID]
		var newAnim:Animation = Animation.new()
		
		newAnim.step = animData[oneshotID]["step"]
		newAnim.length = animData[oneshotID]["len"]
		newAnim.loop_mode = animData[oneshotID]["loop"]
		
		var newTrack = newAnim.add_track(Animation.TYPE_METHOD)
		newAnim.track_set_path(newTrack, NodePath("."))
		
		var theSettings:Dictionary = oneShotInfo["settings"] if oneShotInfo.has("settings") else {}
		var animEvents:Array = theSettings[CONF_ANIMEVENTS] if theSettings.has(CONF_ANIMEVENTS) else []
		
		for theAnimEvent in animEvents:
			var theTime:float = float(theAnimEvent[0])
			var theArg:String = theAnimEvent[1]
			
			newAnim.track_insert_key(newTrack, theTime, {
				method = "sendAnimationEvent",
				args = [theArg],
			})
		
		mainAnimationLibrary.add_animation(oneshotID, newAnim)
	
	mainAnimPlayer.add_animation_library("main", mainAnimationLibrary)
	
	updateAnimTreeFor("MAIN")

func animEventOnFrame(theFrame:float, theArg:String) -> Array:
	return [theFrame/30.0, theArg] # Assumes the animation is 30 fps

func updateAnimTreeFor(seatID:String):
	var animTree:AnimationTree
	var isMain:bool = false
	
	if(seatID == "MAIN"):
		animTree = mainAnimTree
		isMain = true
	else:
		var seatInfo:Dictionary = sitters[seatID]
		animTree = seatInfo["tree"]
	
	var theStateMachine := AnimationNodeStateMachine.new()
	for stateID in states:
		var stateInfo:Dictionary = states[stateID]
		
		var blendTreeNode := AnimationNodeBlendTree.new()
		theStateMachine.add_node(stateID, blendTreeNode)
		
		var timeScaleNode := AnimationNodeTimeScale.new()
		blendTreeNode.add_node("timeScale", timeScaleNode)
		
		var animNode := AnimationNodeAnimation.new()
		animNode.animation = stateInfo["anims"][seatID] if !isMain else ("main/"+stateID)
		blendTreeNode.add_node("anim", animNode)
		
		blendTreeNode.connect_node("timeScale", 0, "anim")
		blendTreeNode.connect_node("output", 0, "timeScale")
		#theStateMachine.add_node(stateID, animNode)
	
	var startTrans := AnimationNodeStateMachineTransition.new()
	startTrans.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
	theStateMachine.add_transition("Start", startState, startTrans)
	
	for stateID in states:
		var stateInfo:Dictionary = states[stateID]
		var stateConnections:Dictionary = stateInfo["connections"]
		
		for otherStateID in stateConnections:
			var connectionInfo:Dictionary = stateConnections[otherStateID]
			var interpolationTime:float = connectionInfo["time"]
			var autoAdvanceAtEnd:bool = connectionInfo["auto"] if connectionInfo.has("auto") else false
			var stateTrans := AnimationNodeStateMachineTransition.new()
			stateTrans.xfade_time = interpolationTime
			stateTrans.xfade_curve = preload("res://AnimScenes/SmoothInterpolation.tres")
			if(autoAdvanceAtEnd):
				stateTrans.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
				stateTrans.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
			#stateTrans.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_SYNC
			theStateMachine.add_transition(stateID, otherStateID, stateTrans)
	
	var finalBlendTree:AnimationNodeBlendTree = AnimationNodeBlendTree.new()
	
	finalBlendTree.add_node("statemachine", theStateMachine)
	
	var currentStateName:String = "statemachine"
	
	for oneshotID in oneShots:
		if(isMain):
			var oneshotAnimName:String = "main/"+oneshotID
			if(true):
				var animNode := AnimationNodeAnimation.new()
				animNode.animation = oneshotAnimName
				finalBlendTree.add_node(oneshotID+"_anim", animNode)
			var oneshotNode := AnimationNodeOneShot.new()
			oneshotNode.mix_mode = AnimationNodeOneShot.MIX_MODE_ADD
			finalBlendTree.add_node(oneshotID, oneshotNode)
			finalBlendTree.connect_node(oneshotID, 0, currentStateName)
			finalBlendTree.connect_node(oneshotID, 1, oneshotID+"_anim")
		else:
			var oneshotData:Dictionary = oneShots[oneshotID]
			var oneshotAnimName:String = oneshotData["anims"][seatID]
			var oneshotBaseAnimName:String = oneshotData["baseAnims"][seatID]
			#var _settings:Dictionary = oneshotData["settings"]
			
			if(true):
				var animNode := AnimationNodeAnimation.new()
				animNode.animation = oneshotAnimName
				finalBlendTree.add_node(oneshotID+"_anim", animNode)
			if(true):
				var animNode := AnimationNodeAnimation.new()
				animNode.animation = oneshotBaseAnimName
				finalBlendTree.add_node(oneshotID+"_base", animNode)
			
			var subNode := AnimationNodeSub2.new()
			finalBlendTree.add_node(oneshotID+"_sub", subNode)
			finalBlendTree.connect_node(oneshotID+"_sub", 0, oneshotID+"_anim")
			finalBlendTree.connect_node(oneshotID+"_sub", 1, oneshotID+"_base")
			#finalBlendTree.connect_node(oneshotID+"_sub", 1, "statemachine")
			
			var oneshotNode := AnimationNodeOneShot.new()
			oneshotNode.mix_mode = AnimationNodeOneShot.MIX_MODE_ADD
			finalBlendTree.add_node(oneshotID, oneshotNode)
			
			finalBlendTree.connect_node(oneshotID, 0, currentStateName)
			finalBlendTree.connect_node(oneshotID, 1, oneshotID+"_sub")
			
		currentStateName = oneshotID
		
		
	finalBlendTree.connect_node("output", 0, currentStateName)
	
	var finalFinalBlendTree:AnimationNodeBlendTree
	if(!isMain):
		finalFinalBlendTree = dollBlendTreeBase.duplicate(true)
		finalFinalBlendTree.add_node("blendtree", finalBlendTree)
		finalFinalBlendTree.connect_node("RestraintAnims_BRIDGE", 0, "blendtree")
		
		Doll.updateAnimTreeWithPoses(finalFinalBlendTree, true)
	else:
		finalFinalBlendTree = AnimationNodeBlendTree.new()
		finalFinalBlendTree.add_node("blendtree", finalBlendTree)
		finalFinalBlendTree.connect_node("output", 0, "blendtree")
	
	#animTree.tree_root = theStateMachine
	animTree.tree_root = finalFinalBlendTree
	
	if(!isMain):
		for oneshotID in oneShots:
			animTree["parameters/blendtree/"+oneshotID+"_sub/sub_amount"] = 1.0
		
	for stateID in states:
		var stateInfo:Dictionary = states[stateID]
		animTree["parameters/blendtree/statemachine/"+stateID+"/timeScale/scale"] = stateInfo[CONF_BASESPEED] if stateInfo.has(CONF_BASESPEED) else 1.0

func setSitter(theSeat:String, thePawn:CharacterPawn):
	if(!sitters.has(theSeat)):
		Log.error("No seat with the id "+theSeat+" found")
		return
	var theSitSpot:PoseSpot = sitters[theSeat]["spot"]
	if(!thePawn):
		theSitSpot.unSit()
		return
	if(theSitSpot.hasSitter()):
		return
	theSitSpot.doSit(thePawn)

func addSeat(theID:String, theSpot:PoseSpot):
	var newAnimPlayer:AnimationPlayer = AnimationPlayer.new()
	newAnimPlayer.active = false
	add_child(newAnimPlayer)
	
	var newTree:AnimationTree = AnimationTree.new()
	add_child(newTree)
	newTree.active = false
	newTree.anim_player = newTree.get_path_to(newAnimPlayer)
	
	sitters[theID] = {
		spot = theSpot,
		tree = newTree,
		anim = newAnimPlayer,
	}
	theSpot.onPawnSwitch.connect(onSeatPawnSwitchFunc.bind(theID))
	theSpot.onDollSwitch.connect(onSeatDollSwitchFunc.bind(theID))

func onSeatPawnSwitchFunc(_newPawn:CharacterPawn, theID:String):
	onPawnSwitch.emit(theID, _newPawn)

func onSeatDollSwitchFunc(_newDoll:DollController, theID:String):
	updateAnim()
	onDollSwitch.emit(theID, _newDoll)

func updateAnim():
	for sitterID in sitters:
		deferUpdateAnimSitter.call_deferred(sitterID)
	deferUpdateMainAnimTree.call_deferred()
	
	onAnimUpdate.emit()
	doCharChecksAfterPlay()

func deferUpdateMainAnimTree():
	mainAnimTree["parameters/blendtree/statemachine/playback"].start(state, true)

func deferUpdateAnimSitter(sitterID:String):
	var sitterInfo:Dictionary = sitters[sitterID]
	var animTree:AnimationTree = sitterInfo["tree"]
	
	var sitDoll:DollController = getSitterDoll(sitterID)
	
	if(sitDoll):
		applyAnimPlayer(sitDoll, animTree)
		animTree.active = true
		animTree["parameters/blendtree/statemachine/playback"].start(state, true)
	else:
		animTree.active = false
		animTree.root_node = NodePath("")
	
	updatePenisTargetFor(sitterID)

func updateRestraintAnimsFor(sitterID:String):
	var sitDoll:DollController = getSitterDoll(sitterID)
	if(!sitDoll):
		return
	var theDoll:Doll = sitDoll.getDoll()
	if(!theDoll):
		return
	var sitterInfo:Dictionary = sitters[sitterID]
	var animTree:AnimationTree = sitterInfo["tree"]
	if(supportsArmbinderAnim):
		animTree["parameters/ArmBinder_Blend/blend_amount"] = 1.0 if theDoll.isArmbinderPoseEnabled() else 0.0
	if(supportsCuffedAnim):
		animTree["parameters/CuffedBehindBack_Blend/blend_amount"] = 1.0 if theDoll.isCuffedBehindBackPoseEnabled() else 0.0
	
	#TODO: Maybe improve this?
	var theChar:BaseCharacter = theDoll.getChar()
	if(theChar):
		var theArmsPoseID:String = theChar.getPoseArms()
		var theArmsPose:DollPoseBase = GlobalRegistry.getDollPose(theArmsPoseID) if theArmsPoseID != "" else null
		theDoll.setArmsAnim(theArmsPoseID if theArmsPose else "", animTree)

var checkTime:float = 0.0
func _process(_delta: float) -> void:
	checkTime -= _delta
	if(checkTime <= 0.0):
		for sitterID in sitters:
			updateRestraintAnimsFor(sitterID)
		checkTime = 0.1

func updatePenisTargetFor(sitterID:String):
	var sitDoll:DollController = getSitterDoll(sitterID)
	if(!sitDoll):
		return

	var foundPenisTarget:bool = false
	if(penisTarget.has(sitterID)):
		var penisTargetInfo:Dictionary = penisTarget[sitterID]
		var targetType:int = penisTargetInfo["type"]
		if(targetType == PENISTARGET_SITTER_HOLE):
			var otherSitterID:String = penisTargetInfo["id"]
			var holeID:int = penisTargetInfo["hole"]
			
			var otherDollController:DollController = getSitterDoll(otherSitterID)
			if(otherDollController):
				var ourDoll:Doll = sitDoll.getDoll()
				var otherDoll:Doll = otherDollController.getDoll()
				
				if(holeID == HOLE_VAGINA):
					ourDoll.alignPenisToVagina(otherDoll)
				else:
					ourDoll.alignPenisToAnus(otherDoll)
				foundPenisTarget = true
	if(!foundPenisTarget):
		var ourDoll:Doll = sitDoll.getDoll()
		ourDoll.alignPenisToAnus(null)

func setStateSpeedTween(theSpeed:float, theState:String):
	setStateSpeed(theState, theSpeed)

func setStateSpeed(theState:String, theSpeed:float):
	if(!states.has(theState)):
		return
	var stateInfo:Dictionary = states[theState]
	var baseSpeed:float = (stateInfo[CONF_BASESPEED] if stateInfo.has(CONF_BASESPEED) else 1.0)
	for sitterID in sitters:
		var sitterInfo:Dictionary = sitters[sitterID]
		var animTree:AnimationTree = sitterInfo["tree"]
		
		animTree["parameters/blendtree/statemachine/"+theState+"/timeScale/scale"] = theSpeed * baseSpeed
	mainAnimTree["parameters/blendtree/statemachine/"+theState+"/timeScale/scale"] = theSpeed * baseSpeed

func getStateSpeed(theState:String) -> float:
	if(!states.has(theState)):
		return 1.0
	return mainAnimTree["parameters/blendtree/statemachine/"+theState+"/timeScale/scale"]

func doCharChecksAfterPlay():
	for sitterID in sitters:
		var theSitter := getSitter(sitterID)
		if(!theSitter):
			continue
		var theChar:BaseCharacter = theSitter.getCharacter()
		theChar.triggerUpdatePartFilter()

func playState(newState:String, setToState:bool=false):
	setStateSpeed(state, 1.0)
	
	state = newState
	
	setStateSpeed(state, 1.0)
	startSpeedSwitchTimer()
	
	if(setToState):
		updateAnim()
		onPlayState(newState)
		return
	for sitterID in sitters:
		var sitterInfo:Dictionary = sitters[sitterID]
		var animTree:AnimationTree = sitterInfo["tree"]
		
		var animTreePlayback:AnimationNodeStateMachinePlayback = animTree["parameters/blendtree/statemachine/playback"]
		animTreePlayback.travel(newState)
	var mainAnimTreePlayback:AnimationNodeStateMachinePlayback = mainAnimTree["parameters/blendtree/statemachine/playback"]
	mainAnimTreePlayback.travel(newState)
	onPlayState(newState)
	doCharChecksAfterPlay()

func getRoleByCharID(_charID:String) -> String:
	for roleID in sitters:
		var thePawn:CharacterPawn = getSitter(roleID)
		if(!thePawn):
			continue
		if(thePawn.getCharID() == _charID):
			return roleID
	return ""

func getSexHideTagsFor(_charID:String) -> Array:
	var theRole:String = getRoleByCharID(_charID)
	if(theRole == ""):
		return []
	var stateInfo:Dictionary = getCurrentStateData() 
	var theHideTags:Dictionary = stateInfo[CONF_HIDETAGS] if stateInfo.has(CONF_HIDETAGS) else {}
	if(!theHideTags.has(theRole)):
		return []
	return theHideTags[theRole]
	
# Maybe this isn't needed?
func onPlayState(_state:String):
	onAnimPlay.emit(state)
	
func playOneShot(oneshotID:String):
	for sitterID in sitters:
		var sitterInfo:Dictionary = sitters[sitterID]
		var animTree:AnimationTree = sitterInfo["tree"]
		
		animTree["parameters/blendtree/"+oneshotID+"/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	mainAnimTree["parameters/blendtree/"+oneshotID+"/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	onOneShot(oneshotID)

func onOneShot(_oneshotID:String):
	pass
	
func setState(newState:String):
	state = newState
	updateAnim()

func getSeats() -> Dictionary:
	return sitters

func getSitter(theID:String) -> CharacterPawn:
	var theSpot:PoseSpot = getSpot(theID)
	if(!theSpot):
		return null
	return theSpot.getSitterPawn()

func getSitterDoll(theID:String) -> DollController:
	var theSpot:PoseSpot = getSpot(theID)
	if(!theSpot):
		return null
	return theSpot.getSitterDoll()

func getSpot(theID:String) -> PoseSpot:
	if(!sitters.has(theID)):
		return null
	return sitters[theID]["spot"]

func applyAnimPlayer(user: DollController, theAnimPlayer:AnimationMixer):
	user.getBodySkeleton().resetBones()
	theAnimPlayer.root_node = theAnimPlayer.get_path_to(user.getBodySkeleton())

func getState() -> String:
	return state

func getCurrentStateData() -> Dictionary:
	return states[state] if states.has(state) else {}

func getSexHideTags(_role:String) -> Array:
	var currentStateData:Dictionary = getCurrentStateData()
	if(!currentStateData.has(CONF_HIDETAGS)):
		return []
	var allHideTags:Dictionary = currentStateData[CONF_HIDETAGS]
	return allHideTags[_role] if allHideTags.has(_role) else []

var soundPlap := preload("res://Sounds/Plaps/RandomPlapSound.tres")

func sendSoundEvent(_theRole:String, _eventID:String, _args:Array = []):
	var theDoll := getSitterDoll(_theRole)
	if(!theDoll):
		return
	theDoll.getDoll().getVoiceHandler().sendEvent(_eventID, _args)

func doPlap(_theDomRole:String, theRole:String):
	var theDoll := getSitterDoll(theRole)
	if(!theDoll):
		return
	Audio.playSound3D(theDoll, soundPlap)
	
	sendSoundEvent(_theDomRole, "plap")
	sendSoundEvent(theRole, "plapped")

var cumInsideSound := preload("res://Sounds/Cum/CumInsideSound.tres")
func doCumInsideNoise(_theDomRole:String, theRole:String):
	var theDoll := getSitterDoll(theRole)
	if(!theDoll):
		return
	Audio.playSound3D(theDoll, cumInsideSound)
	#sendSoundEvent(_theDomRole, "plap")
	#sendSoundEvent(theRole, "plapped")
func doCumInsideEffect(_theDomRole:String, _theRole:String):
	var theDoll := getSitterDoll(_theDomRole)
	if(!theDoll):
		return
	theDoll.getDoll().doCumVisible(false)
	
func doCumOutsideEffect(_theDomRole:String):
	var theDoll := getSitterDoll(_theDomRole)
	if(!theDoll):
		return
	theDoll.getDoll().doCumVisible(true)

func doMoan(theRole:String, moanSpeed:int = SexSoundSpeed.Slow, mouthState:int = SexSoundMouth.Opened, howManyNoisesToIgnore:int=0, overrideIntensity:int = -1):
	var theDoll := getSitterDoll(theRole)
	if(!theDoll):
		return
	theDoll.getDoll().getVoiceHandler().doMoan(moanSpeed, mouthState, howManyNoisesToIgnore, overrideIntensity)

func doOrgasmNoise(theRole:String):
	var theDoll := getSitterDoll(theRole)
	if(!theDoll):
		return
	theDoll.getDoll().getVoiceHandler().doOrgasm()

func doSquirtVagina(theRole:String, amountMult:float = 1.0, speedMult:float = 1.0, timeMult:float = 1.0, spreadMult:float = 1.0):
	var theDoll := getSitterDoll(theRole)
	if(!theDoll):
		return
	theDoll.getDoll().getBodySkeleton().doSquirtVagina(amountMult, speedMult, timeMult, spreadMult)

func saveNetworkData() -> Dictionary:
	return {
		state = state,
		penisTarget = penisTarget,
	}

func loadNetworkData(_data:Dictionary):
	state = SAVE.loadVar(_data, "state", "")
	penisTarget = SAVE.loadVar(_data, "penisTarget", {})
	
	updateAnim()
