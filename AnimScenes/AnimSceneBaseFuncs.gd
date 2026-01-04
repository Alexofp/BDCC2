extends Node3D
class_name AnimSceneBaseFuncs

var id:String = "" # Used for anim tree caching

const TAIL_OUT_OF_THE_WAY_FLAGS = {
	TailSex = true,
}

class Sitter:
	var spot:PoseSpot
	var tree:DollLayeredAnimPlayer
	var anim:AnimationPlayer

var sitters:Dictionary[String, Sitter] = {}
var penisTarget:Dictionary = {}

class PropSlot:
	var spot:PropSpot
	var tree:AnimationTree
	var anim:AnimationPlayer
	
	var animLibraries:Dictionary = {}
	func addAnimLibrary(theID:String, thePath:String):
		animLibraries[theID] = thePath
	
var props:Dictionary[String, PropSlot] = {}

class AnimSceneState:
	static func create(_id:String, _anims:Dictionary[String, String]) -> AnimSceneState:
		var theState:AnimSceneState = AnimSceneState.new()
		theState.id = _id
		theState.anims = _anims
		return theState
	func setBaseSpeed(_sp:float) -> AnimSceneState:
		baseSpeed = _sp
		return self
	func setAnimEvents(_events:Array) -> AnimSceneState:
		animEvents = _events
		return self
	func setHideTags(_hideTags:Dictionary) -> AnimSceneState:
		hideTags = _hideTags
		return self
	func setFlags(_flags:Dictionary) -> AnimSceneState:
		flags = _flags
		return self
	func setSpeedAutoSwitch(_speedMultMin:float, _speedMultMax:float, _timeMin:float, _timeMax:float) -> AnimSceneState:
		speedMultMin = _speedMultMin
		speedMultMax = _speedMultMax
		timedSpeedSwitchMin = _timeMin
		timedSpeedSwitchMax = _timeMax
		return self
	#func setPropAnims(_propAnims:Dictionary[String, String]) -> AnimSceneState:
	#	propAnims = _propAnims
	#	return self
	
	var id:String = ""
	
	var anims:Dictionary[String, String]
	var connections:Dictionary
	#var propAnims:Dictionary[String, String]
	
	var baseSpeed:float = 1.0
	var speedMultMin:float = 1.0
	var speedMultMax:float = 1.0
	var timedSpeedSwitchMin:float = 0.0
	var timedSpeedSwitchMax:float = 0.0
	
	var animEvents:Array
	var hideTags:Dictionary
	var flags:Dictionary

var states:Dictionary[String, AnimSceneState] = {}
var startState:String = ""

const LAYER_ONESHOT = 0
const LAYER_ADD3 = 1

class AnimSceneExtraLayerBase:
	var id:String = ""
	func getType() -> int:
		return -1

class AnimSceneExtraLayerOneshot extends AnimSceneExtraLayerBase:
	func getType() -> int:
		return LAYER_ONESHOT
	static func create(_id:String, _animByPose:Dictionary[String, String], _baseAnimByPose:Dictionary[String, String]) -> AnimSceneExtraLayerOneshot:
		var theLayer := AnimSceneExtraLayerOneshot.new()
		theLayer.id = _id
		theLayer.anims = _animByPose
		theLayer.baseAnims = _baseAnimByPose
		return theLayer
	func setAnimEvents(_events:Array) -> AnimSceneExtraLayerOneshot:
		animEvents = _events
		return self

	var anims:Dictionary[String, String]
	var baseAnims:Dictionary[String, String]
	var animEvents:Array

class AnimSceneExtraLayerAdd3 extends AnimSceneExtraLayerBase:
	func getType() -> int:
		return LAYER_ADD3
	static func create(_id:String, _animByPosePlus:Dictionary[String, String], _animByPoseMinus:Dictionary[String, String], _baseAnimByPose:Dictionary[String, String]) -> AnimSceneExtraLayerAdd3:
		var theLayer := AnimSceneExtraLayerAdd3.new()
		theLayer.id = _id
		theLayer.animsPlus = _animByPosePlus
		theLayer.animsMinus = _animByPoseMinus
		theLayer.baseAnims = _baseAnimByPose
		return theLayer
		
	var animsPlus:Dictionary[String, String]
	var animsMinus:Dictionary[String, String]
	var baseAnims:Dictionary[String, String]

#var oneShots:Dictionary = {}
var extraLayers:Array[AnimSceneExtraLayerBase] = []
var extraLayersByID:Dictionary[String, AnimSceneExtraLayerBase] = {}

var state:String = ""
var currentStateSpeed:float = 1.0

var animLibraries:Dictionary = {}
var animData:Dictionary = {}

const PENISTARGET_SITTER_HOLE = 0
const PENISTARGET_PENIS_GUIDE = 1

signal onPawnSwitch(id, pawn)
signal onDollSwitch(id, doll)
signal onAnimEvent(eventID, args)
signal onAnimPlay(state)

var speedSwitchTimer:Timer

var mainAnimPlayer:AnimationPlayer
var mainAnimTree:AnimationTree

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
	updateAllAnimTrees()
	setState(startState)

func setupScene() -> void:
	pass

func sendAnimationEvent(_eventID:String):
	onAnimationEvent(_eventID)
	onAnimEvent.emit(_eventID, [])

func onAnimationEvent(_eventID:String):
	print("UNHANDLED ANIMATION EVENT ID "+str(_eventID))

func startSpeedSwitchTimer():
	speedSwitchTimer.stop()
	var currentStateData:AnimSceneState = getCurrentStateData()
	if(!currentStateData):
		return

	var theTimedSpeedSwitchMin:float = currentStateData.timedSpeedSwitchMin
	var theTimedSpeedSwitchMax:float = currentStateData.timedSpeedSwitchMax
	if(theTimedSpeedSwitchMin > theTimedSpeedSwitchMax):
		return
	var timeNextSwitch:float = RNG.randfRange(theTimedSpeedSwitchMin, theTimedSpeedSwitchMax)
	if(timeNextSwitch > 0.0):
		speedSwitchTimer.start(timeNextSwitch)
	
var tween:Tween
func onSpeedSwitchTimer():
	var currentStateData:AnimSceneState = getCurrentStateData()
	if(!currentStateData):
		return
	
	var theSpeedMultMin:float = currentStateData.speedMultMin
	var theSpeedMultMax:float = currentStateData.speedMultMax
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

func alignPenisToPenisGuides(theID:String):
	penisTarget[theID] = {
		type = PENISTARGET_PENIS_GUIDE,
	}
	updatePenisTargetFor(theID)

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

func addPropAnimLibrary(propID:String, theID:String, thePath:String):
	if(!props.has(propID)):
		return
	props[propID].addAnimLibrary(theID, thePath)

func setStartState(stateID:String):
	startState = stateID

func addExtraLayer(_layer:AnimSceneExtraLayerBase):
	extraLayers.append(_layer)
	extraLayersByID[_layer.id] = _layer

func addState(_id:String, _anims:Dictionary[String, String]) -> AnimSceneState:
	var theState := AnimSceneState.create(_id, _anims)
	addStateRaw(theState)
	return theState

func addStateRaw(_animState:AnimSceneState):
	states[_animState.id] = _animState

func connectStates(state1:String, state2:String, interpolationTime:float = 0.2, isOneWay:bool = false, isAuto:bool = false):
	var stateinfo1:AnimSceneState = states[state1]
	var stateinfo2:AnimSceneState = states[state2]
	
	stateinfo1.connections[state2] = {time=interpolationTime, auto=isAuto}
	if(!isOneWay):
		stateinfo2.connections[state1] = {time=interpolationTime, auto=isAuto}

func updateAllAnimTrees():
	pass

# Adds all doll poses animation libraries
func updateAnimPlayerFor(seatID:String):
	var seatInfo:Sitter = sitters[seatID]
	var animPlayer:AnimationPlayer = seatInfo.anim
	
	for animLibraryID in animLibraries:
		animPlayer.add_animation_library(animLibraryID, load(animLibraries[animLibraryID]))
	
	Doll.updateAnimPlayerSpecific(animPlayer)

#func calculateStateAnimData():
#	pass
		
#func updateMainAnimTree():
#	pass

func animEventOnFrame(theFrame:float, theArg:String) -> Array:
	return [theFrame/30.0, theArg] # Assumes the animation is 30 fps

#func updateAnimTreeFor(_seatID:String):
#	pass

func setSitter(theSeat:String, thePawn:CharacterPawn):
	if(!sitters.has(theSeat)):
		Log.error("No seat with the id "+theSeat+" found")
		return
	var theSitSpot:PoseSpot = sitters[theSeat].spot
	if(!thePawn):
		theSitSpot.unSit()
		return
	if(theSitSpot.hasSitter()):
		theSitSpot.unSit()
		#return
	theSitSpot.doSit(thePawn)

func setProp(theSeat:String, theProp:Node3D):
	if(!props.has(theSeat)):
		Log.error("No prop with the id "+theSeat+" found")
		return
	var theSitSpot:PropSpot = props[theSeat].spot
	if(!theProp):
		#theSitSpot.unSit()
		theSitSpot.freeSpot()
		return
	if(theSitSpot.hasProp()):
		if(theSitSpot.getProp() == theProp):
			return
		#theSitSpot.unSit()
		theSitSpot.freeSpot()
		#return
	theSitSpot.setProp(theProp)
	#theSitSpot.doSit(thePawn)

func addPropSpot(_theID:String, _theSpot:PropSpot):
	var newAnimPlayer:AnimationPlayer = AnimationPlayer.new()
	newAnimPlayer.active = false
	add_child(newAnimPlayer)
	
	var newTree:AnimationTree = AnimationTree.new()
	add_child(newTree)
	newTree.active = false
	newTree.anim_player = newTree.get_path_to(newAnimPlayer)
	
	var newSitter:PropSlot = PropSlot.new()
	newSitter.spot = _theSpot
	newSitter.tree = newTree
	newSitter.anim = newAnimPlayer
	
	props[_theID] = newSitter
	_theSpot.onPropSwitch.connect(onSeatPropSwitchFunc.bind(_theID))
	
func onSeatPropSwitchFunc(_newPawn:Node3D, _oldNode:Node3D, _theID:String):
	updateAnim()
	pass

func addSeat(theID:String, theSpot:PoseSpot):
	var newAnimPlayer:AnimationPlayer = AnimationPlayer.new()
	newAnimPlayer.active = false
	add_child(newAnimPlayer)
	
	var newTree:DollLayeredAnimPlayer = DollLayeredAnimPlayer.new()
	add_child(newTree)
	newTree.active = false
	newTree.anim_player = newTree.get_path_to(newAnimPlayer)
	
	var newSitter:Sitter = Sitter.new()
	newSitter.spot = theSpot
	newSitter.tree = newTree
	newSitter.anim = newAnimPlayer
	
	sitters[theID] = newSitter
	theSpot.onPawnSwitch.connect(onSeatPawnSwitchFunc.bind(theID))
	theSpot.onDollSwitch.connect(onSeatDollSwitchFunc.bind(theID))

func onSeatPawnSwitchFunc(_newPawn:CharacterPawn, theID:String):
	onPawnSwitch.emit(theID, _newPawn)

func onSeatDollSwitchFunc(_newDoll:DollController, _oldDoll:DollController, theID:String):
	updateAnim()
	onDollSwitch.emit(theID, _newDoll)
	
	if(_oldDoll):
		_oldDoll.onGesturePlay.disconnect(onSitterGesturePlay.bind(theID))
	if(_newDoll):
		_newDoll.onGesturePlay.connect(onSitterGesturePlay.bind(theID))
	
func onSitterGesturePlay(_gestureID:String, _playFull:bool, _playPartial:bool, _id:String):
	if(!sitters.has(_id)):
		return
	var sitterInfo:Sitter = sitters[_id]
	var animTree:AnimationTree = sitterInfo.tree
	var sitDoll:DollController = getSitterDoll(_id)
	if(!sitDoll):
		return
	var theDoll:Doll = sitDoll.getDoll()
	if(!theDoll):
		return
	theDoll.playGestureRaw(animTree, _gestureID, false, _playPartial)

func updateAnim():
	pass

func deferUpdateMainAnimTree():
	pass

func deferUpdateAnimSitter(_sitterID:String):
	pass

func updateRestraintAnimsFor(sitterID:String):
	var sitDoll:DollController = getSitterDoll(sitterID)
	if(!sitDoll):
		return
	var theDoll:Doll = sitDoll.getDoll()
	if(!theDoll):
		return
	var sitterInfo:Sitter = sitters[sitterID]
	var animTree:AnimationTree = sitterInfo.tree
	
	theDoll.updatePose(animTree)

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
				
				if(holeID == AnimSceneHole.Vagina):
					ourDoll.alignPenisToVagina(otherDoll)
				else:
					ourDoll.alignPenisToAnus(otherDoll)
				foundPenisTarget = true
		elif(targetType == PENISTARGET_PENIS_GUIDE):
			var ourDoll:Doll = sitDoll.getDoll()
			if(ourDoll):
				ourDoll.alignPenisToPenisGuide()
				foundPenisTarget = true
		
	if(!foundPenisTarget):
		var ourDoll:Doll = sitDoll.getDoll()
		if(ourDoll):
			ourDoll.alignPenisToAnus(null)

func setStateSpeedTween(theSpeed:float, theState:String):
	setStateSpeed(theState, theSpeed)

func setStateSpeed(theState:String, theSpeed:float):
	if(!states.has(theState)):
		return
	var stateInfo:AnimSceneState = states[theState]
	var baseSpeed:float = stateInfo.baseSpeed
	for sitterID in sitters:
		var sitterInfo:Sitter = sitters[sitterID]
		var animTree:AnimationTree = sitterInfo.tree
		
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

func playState(_newState:String, _setToState:bool=false, _theAnimArgs:Dictionary = {}):
	pass

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
	var stateInfo:AnimSceneState = getCurrentStateData() 
	var theHideTags:Dictionary = stateInfo.hideTags
	if(!theHideTags.has(theRole)):
		return []
	return theHideTags[theRole]
	
# Maybe this isn't needed?
func onPlayState(_state:String, _args:Dictionary):
	onAnimPlay.emit(state)

# Should be used for changing stuff that depends on the doll's values or items
func updateAnimWhenDollsChange():
	pass

func getExtraLayerType(_id:String) -> int:
	if(!extraLayersByID.has(_id)):
		return -1
	return extraLayersByID[_id].getType()

func setAdd3Value(_id:String, _val:float):
	if(getExtraLayerType(_id) != LAYER_ADD3):
		Log.Printerr("BAD ID FOR ADD 3: "+str(_id))
		return
	for sitterID in sitters:
		var sitterInfo:Sitter = sitters[sitterID]
		var animTree:AnimationTree = sitterInfo.tree

		animTree["parameters/blendtree/"+_id+"/add_amount"] = _val
	mainAnimTree["parameters/blendtree/"+_id+"/add_amount"] = _val

func playOneShot(oneshotID:String):
	if(getExtraLayerType(oneshotID) != LAYER_ONESHOT):
		Log.Printerr("BAD ID FOR ONE SHOT: "+str(oneshotID))
		return
	
	for sitterID in sitters:
		var sitterInfo:Sitter = sitters[sitterID]
		var animTree:AnimationTree = sitterInfo.tree
		
		animTree["parameters/blendtree/"+oneshotID+"/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	mainAnimTree["parameters/blendtree/"+oneshotID+"/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	onOneShot(oneshotID)

func onOneShot(_oneshotID:String):
	pass

func getDollPenisGirth(_sitterID:String) -> float:
	var theDoll := getSitterDoll(_sitterID)
	if(!theDoll):
		return 1.0
	var theActualDoll:Doll = theDoll.getDoll()
	if(theActualDoll):
		return theActualDoll.getPenisGirth()
	return 1.0

func getAverageBodyPos(_calcMaxY:bool = true) -> Vector3:
	var poses:Array[Vector3] = []
	for sitterID in sitters:
		var theSitterPawn := getSitter(sitterID)
		var theSitterDoll := getSitterDoll(sitterID)
		
		if(theSitterDoll):
			poses.append(theSitterDoll.getGlobalChestBonePosition())
		elif(theSitterPawn):
			poses.append(theSitterPawn.global_position)
	
	if(poses.is_empty()):
		return global_position
	if(poses.size() == 1):
		return poses[0]
	var theDiv:float = 1.0/float(poses.size())
	var finalPos:Vector3 = Vector3()
	var maxY:float = poses[0].y
	for thePos in poses:
		finalPos += thePos*theDiv
		if(thePos.y > maxY):
			maxY = thePos.y
	if(_calcMaxY):
		finalPos.y = maxY
	return finalPos
	
func setState(newState:String):
	state = newState
	updateAnim()

func getSeats() -> Dictionary:
	return sitters

func hasSitter(theID:String) -> bool:
	if(getSitter(theID)):
		return true
	return false

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
	return sitters[theID].spot

func getSpotProp(theID:String) -> PropSpot:
	if(!props.has(theID)):
		return null
	return props[theID].spot

func applyAnimPlayer(user: DollController, theAnimPlayer:AnimationMixer):
	user.getBodySkeleton().resetBones()
	theAnimPlayer.root_node = theAnimPlayer.get_path_to(user.getBodySkeleton())

func getState() -> String:
	return state

func getCurrentStateData() -> AnimSceneState:
	return states[state] if states.has(state) else null

func getSexHideTags(_role:String) -> Array:
	var currentStateData:AnimSceneState = getCurrentStateData()
	var allHideTags:Dictionary = currentStateData.hideTags
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

func doSquirtVagina(theRole:String, amountMult:float = 1.0, speedMult:float = 1.0, timeMult:float = 1.0, spreadMult:float = 1.0, angle:float = 0.0):
	#speedMult = 1.0
	#spreadMult = 22.0
	#amountMult = 1.0
	var theDoll := getSitterDoll(theRole)
	if(!theDoll):
		return
	theDoll.getDoll().getBodySkeleton().doSquirtVagina(amountMult, speedMult, timeMult, spreadMult, angle)

func saveNetworkData() -> Bins:
	var data := Bins.saveStart([
		Bins.StrShort, state,
		Bins.Var, penisTarget,
	])
	return data.endSave()

func loadNetworkData(_data:Bins):
	_data.loadStart()
	state = _data.readStrShort()
	penisTarget = _data.readVar()
	_data.endLoad()
	
	updateAnim()

func saveData() -> Dictionary:
	return {
		state = state,
		penisTarget = penisTarget,
	}

func loadData(_data:Dictionary):
	state = SAVE.loadVar(_data, "state", "")
	penisTarget = SAVE.loadVar(_data, "penisTarget", {})
	
	updateAnim()
