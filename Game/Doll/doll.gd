extends Node3D
class_name Doll

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var animation_tree: LayeredAnimPlayer = %AnimationTree
@onready var parts_node: Node3D = %Parts

@onready var body_skeleton: BodySkeleton = %BodySkeleton
@onready var voice_handler: VoiceHandler = %VoiceHandler

@onready var alpha_mask_texture: MyLayeredTexture = %AlphaMaskTexture

@export var disableInternalAnimPlayer:bool = false
@onready var hover_text_advanced: HoverTextAdvanced = %HoverTextAdvanced
@onready var radial_doll_bars: Node3D = %RadialDollBars

@onready var look_at_modifier_chest: LookAtModifier3D = %LookAtModifierChest
@onready var look_at_modifier_neck: LookAtModifier3D = %LookAtModifierNeck
@onready var look_at_modifier_head: LookAtModifier3D = %LookAtModifierHead
@onready var look_at_target: Node3D = %LookAtTarget
@onready var look_at_eyes: Node3D = %LookAtEyes
@onready var look_at_target_default: Node3D = %LookAtTargetDefault
@onready var skeleton_hit_modifier: SkeletonHitModifier = %SkeletonHitModifier
@onready var blindness_quad_effect: MeshInstance3D = %BlindnessQuadEffect

const LOCOMOTION_OTHER = 0
const LOCOMOTION_STAND = 1
const LOCOMOTION_WALK = 2
const LOCOMOTION_RUN = 3
const LOCOMOTION_FALL = 4

var locomotionState:int = LOCOMOTION_STAND
var lookAtNode:Node3D = null
var expressionState:int = DollExpressionState.Normal
var characterRef:WeakRef

var parts:Array[Dictionary] = [{}, {}]
var partPaths:Array[Dictionary] = [{}, {}]
var attachPoints:Dictionary = {}

var animationPartFlags:Dictionary = {} #Used to make the tail go out of the way during sex for example
var cachedPartFlags:Dictionary = {}

var openMouthTemp:bool = false
var struggleTimer:float = 0.0

var holeData:DollHoleData = DollHoleData.new()
var holeDataSubs:Array[Array] = [[], []] # Which parts should receive the updated hole data values
var holeDataDirty:bool = false

signal onGesturePlay(gestureID, playFullBody, playPartial)

func updateAnimPlayer():
	updateAnimPlayerSpecific(animation_player)

const DefaultAnimLibs = [
	["GestureAnims", preload("res://Anims/Raw/GestureAnims.glb")],
]

static func updateAnimPlayerSpecific(_animPlayer:AnimationPlayer):
	for defaultEntry in DefaultAnimLibs:
		var theAnimLibName:String = defaultEntry[0]
		if(!_animPlayer.has_animation_library(theAnimLibName)):
			_animPlayer.add_animation_library(theAnimLibName, defaultEntry[1])
	
	for libID in GlobalRegistry.dollAnimLibraries:
		var libPath:String = GlobalRegistry.dollAnimLibraries[libID]

		if(!_animPlayer.has_animation_library(libID)):
			_animPlayer.add_animation_library(libID, load(libPath))
		
func playGestureRaw(_animTree:AnimationTree, _gestureID:String, _playFullBody:bool=true, playPartialBody:bool=true):
	if(!_animTree):
		_animTree = animation_tree
	var theGesture := GlobalRegistry.getDollGesture(_gestureID)
	if(theGesture == null):
		return
	if(_playFullBody && theGesture.playFullBody):
		_animTree.playLayer(animation_tree.LAYER_GESTURE_FULLBODY, _gestureID)
		pass
	if(playPartialBody && theGesture.playPartial):
		_animTree.playLayer(animation_tree.LAYER_GESTURE, _gestureID)

func playGesture(_gestureID:String, _playFullBody:bool=true, playPartialBody:bool=true):
	playGestureRaw(animation_tree, _gestureID, _playFullBody, playPartialBody)
	onGesturePlay.emit(_gestureID, _playFullBody, playPartialBody)
	
func stopGesture(stopFullBody:bool = true, stopPartical:bool = true):
	if(stopFullBody):
		animation_tree.stopLayer(animation_tree.LAYER_GESTURE_FULLBODY)
		#animation_tree["parameters/Locomotion/Idle/FullBodyGesture/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT
	if(stopPartical):
		animation_tree.stopLayer(animation_tree.LAYER_GESTURE)
		#animation_tree["parameters/BodyGesture/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT

func _ready() -> void:
	updateAnimPlayer()
	if(disableInternalAnimPlayer):
		animation_player.active = false
		animation_tree.active = false
	
	#setIdlePoseEnabled(true)
	#setIdlePose("Kneel")

func setCharacter(theChar:BaseCharacter):
	var currentChar := getChar()
	if(currentChar != null):
		currentChar.onChange.disconnect(onCharChange)
		currentChar.getBodyMess().onChange.disconnect(onUpdateBodyMess)
	
	characterRef = weakref(theChar)
	updateFromCharacter()
	
	theChar.onChange.connect(onCharChange)
	theChar.getBodyMess().onChange.connect(onUpdateBodyMess)
	
	voice_handler.setCharID(theChar.getID() if theChar else "")
	radial_doll_bars.setCharacter(theChar)

func onCharChange(_change:BaseCharChange):
	var theType := _change.getType()
	
	if(theType == BaseCharChange.PART):
		onCharPartChange(_change.genericType, _change.slot)
	elif(theType == BaseCharChange.PART_OPTION):
		onCharPartOptionChange(_change.genericType, _change.slot, _change.optionID, _change.value)
		if(_change.genericType == BaseCharacter.GENERIC_BODYPARTS && _change.slot == BodypartSlot.Head && _change.optionID == "skinType"):
			updateAutoSkinParts()
	elif(theType == BaseCharChange.CHAR_OPTION):
		onCharOptionChange(_change.optionID)
	elif(theType == BaseCharChange.PART_FILTER):
		updatePartFilter()
	elif(theType == BaseCharChange.AUTO_SKIN_UPDATE):
		updateAutoSkinParts()
	
	# Match is slower apparently. Uncomment me when that's no longer the case
	#match theType:
		#BaseCharChange.PART:
			#onCharPartChange(_change.genericType, _change.slot)
		#BaseCharChange.PART_OPTION:
			#onCharPartOptionChange(_change.genericType, _change.slot, _change.optionID, _change.value)
			#if(_change.genericType == BaseCharacter.GENERIC_BODYPARTS && _change.slot == BodypartSlot.Head && _change.optionID == "skinType"):
				#updateAutoSkinParts()
		#BaseCharChange.CHAR_OPTION:
			#onCharOptionChange(_change.optionID)
		#BaseCharChange.PART_FILTER:
			#updatePartFilter()
		#BaseCharChange.AUTO_SKIN_UPDATE:
			#updateAutoSkinParts()

func updateAutoSkinParts():
	if(parts.is_empty()):
		return
	var theChar:BaseCharacter = getCharacter()
	if(!theChar):
		return
	for bodypartSlot in parts[BaseCharacter.GENERIC_BODYPARTS]:
		if(!theChar.hasBodypart(bodypartSlot)):
			continue
		var theBodypart:BodypartBase = theChar.getBodypart(bodypartSlot)
		if(theBodypart.getSkinTypeRaw() == SkinType.Auto):
			var theDollPart:DollPart = parts[BaseCharacter.GENERIC_BODYPARTS][bodypartSlot]
			if(theDollPart):
				theDollPart.triggerSkinDataUpdate()

func getChar() -> BaseCharacter:
	if(characterRef == null):
		return null
	return characterRef.get_ref()

func getCharacter() -> BaseCharacter:
	if(characterRef == null):
		return null
	return characterRef.get_ref()

func onUpdateBodyMess():
	for theSpecificParts in parts:
		for partID in theSpecificParts:
			var dollPart = theSpecificParts[partID]
			if(dollPart is DollPart):
				dollPart.updateBodyMess()

func getBodyMess() -> FluidsOnBodyProfile:
	return getChar().getBodyMess()

func onCharOptionChange(_change:String):
	var theChar := getCharacter()
	if(!theChar):
		return
	
	if(_change == "voice"):
		voice_handler.setVoiceProfile(theChar.getVoiceProfile())
	
	if(_change == CharOption.idlePose || _change == CharOption.idleAnim || _change == CharOption.poseArms):
		updatePose()
	
	var theValue = theChar.getSyncOptionValue(_change)
	for theSpecificParts in parts:
		for partID in theSpecificParts:
			var dollPart = theSpecificParts[partID]
			if(dollPart is DollPart):
				dollPart.applyCharOptionFinal(_change, theValue)

func onCharBodypartSkinTypeChange(slot:int, _theSkinType:int, skinTypeData:SkinTypeData):
	if(!parts[BaseCharacter.GENERIC_BODYPARTS].has(slot)):
		# # part might be in the process of being loaded so this is fine
		#Log.error("Doll doesn't have a part that the character has")
		return
	var dollPart:Node3D = parts[BaseCharacter.GENERIC_BODYPARTS][slot]
	if(dollPart is DollPart):
		dollPart.applySkinTypeDataFinal(_theSkinType, skinTypeData)

func onCharPartOptionChange(_genericType:int, slot:int, optionID:String, newvalue):
	if(!parts[_genericType].has(slot)):
		# # part might be in the process of being loaded so this is fine
		#Log.error("Doll doesn't have a part that the character has")
		return
	var dollPart:Node3D = parts[_genericType][slot]
	if(dollPart is DollPart):
		dollPart.applyOptionFinal(optionID, newvalue)
	
	if(_genericType == BaseCharacter.GENERIC_BODYPARTS):
		var theClothingParts:Dictionary = parts[BaseCharacter.GENERIC_CLOTHING]
		for theOtherPartSlot in theClothingParts:
			var theOtherPart = theClothingParts[theOtherPartSlot]
			if(theOtherPart is DollPart):
				if(slot in theOtherPart.getSyncedBodypartSlots()):
					theOtherPart.applySyncedBodypartOption(slot, optionID, newvalue)

func updatePartFromCharacterDelayed(_genericType:int, slot:int):
	for existingEntry in partUpdateQueue:
		if(existingEntry[0] == _genericType && existingEntry[1] == slot):
			return
	partUpdateQueue.append([_genericType, slot])

func onCharPartChange(_genericType:int, slot:int, _newpart = null):
	#updatePartFromCharacter(_genericType, slot)
	updatePartFromCharacterDelayed(_genericType, slot)
	
	if(_genericType == BaseCharacter.GENERIC_BODYPARTS):
		checkAllClothingScenes()

func clear():
	for theSpecificParts in parts:
		for slot in theSpecificParts:
			var bodypartDollPart:Node = theSpecificParts[slot]
			bodypartDollPart.queue_free()
	parts = [{}, {}]
	partPaths = [{}, {}]

func _physics_process(_delta: float) -> void:
	if(!partUpdateQueue.is_empty()):
		partUpdateQueueTimer -= _delta
		if(partUpdateQueueTimer <= 0.0):
			partUpdateQueueTimer = 0.1
			var theEntry:Array = partUpdateQueue.pop_front()
			if(isPartUpdateHappening(theEntry[0], theEntry[1])):
				partUpdateQueue.append([theEntry[0], theEntry[1]])
			else:
				updatePartFromCharacter(theEntry[0], theEntry[1])
	
	if(struggleTimer > 0.0):
		struggleTimer -= _delta
		if(struggleTimer <= 0.0):
			struggleTimer = 0.0
			skeleton_hit_modifier.stopStruggle()
	
	updateBodyStuff()

func _process(_delta: float) -> void:
	processLookAt(_delta)
	
var partUpdateQueue:Array = []
var partUpdateQueueTimer:float = 0.0
var partUpdateHappening:Array = []

func addPartUpdateHappening(_genericType:int, _slot:int):
	partUpdateHappening.append([_genericType, _slot])
func isPartUpdateHappening(_genericType:int, _slot:int) -> bool:
	for _entry in partUpdateHappening:
		if(_entry[0] == _genericType && _entry[1] == _slot):
			return true
	return false
func removePartUpdateHappening(_genericType:int, _slot:int):
	for _i in partUpdateHappening.size():
		var theEntry:Array = partUpdateHappening[_i]
		if(theEntry[0] == _genericType && theEntry[1] == _slot):
			partUpdateHappening.remove_at(_i)
			return
	return

func updateFromCharacter():
	clear()
	var character := getChar()
	if(character == null):
		return
	
	var genericParts:Dictionary = character.getGenericParts()
	for genericType in genericParts:
		for bodypartSlot in genericParts[genericType]:
			#partUpdateQueue.append([genericType, bodypartSlot])
			updatePartFromCharacterDelayed(genericType, bodypartSlot)
			#updatePartFromCharacter(genericType, bodypartSlot)

	for optionID in character.getSyncOptions():
		onCharOptionChange(optionID)

func clearOutPart(genericType:int, bodypartSlot:int):
	if(genericType < 0 || genericType >= parts.size()):
		return
	var theDollPart:DollPart = getDollPart(genericType, bodypartSlot)
	if(parts[genericType].has(bodypartSlot)):
		parts[genericType][bodypartSlot].queue_free()
		parts[genericType].erase(bodypartSlot)
		triggerDollPartFlagsUpdate()
	if(partPaths[genericType].has(bodypartSlot)):
		partPaths[genericType].erase(bodypartSlot)
	if(theDollPart):
		partRemovedUpdatedIt(genericType, bodypartSlot, theDollPart)

# Use this function to update everything when a dollPart gets added
func partAddedUpdateIt(genericType:int, bodypartSlot:int, _part:GenericPart, _dollPart:DollPart):
	_dollPart.setPenisTargets(penisTargetHoleNode, penisTargetInsideNode)
	_dollPart.setExpressionState(expressionState)
	_dollPart.updateBodyMess()
	if(_dollPart.shouldUpdateAlphaMask()):
		triggerAlphaMaskUpdate()
	_dollPart.onSpawn(genericType, bodypartSlot, _part.id)
	
	if(genericType == BaseCharacter.GENERIC_BODYPARTS && bodypartSlot == BodypartSlot.Body):
		updateExtraLayer()
	elif(genericType == BaseCharacter.GENERIC_CLOTHING && bodypartSlot == InventorySlot.Suit):
		updateExtraLayer()
	
	if(_dollPart.shouldSubscribeToDollHoleData()):
		_dollPart.applyDollHoleData(holeData)
		holeDataSubs[genericType].append(bodypartSlot)

# Use this function to update everything when a dollPart gets removed
func partRemovedUpdatedIt(genericType:int, bodypartSlot:int, _dollPart:DollPart):
	if(_dollPart && genericType == BaseCharacter.GENERIC_CLOTHING && bodypartSlot == InventorySlot.Suit):
		updateExtraLayer()
	if(_dollPart && _dollPart.getBodyAlphaMask()):
		triggerAlphaMaskUpdate()
	#if(_dollPart.shouldSubscribeToDollHoleData()): # Doesn't work because dollPart.getPart() is null by this point
	if(genericType >= 0 && genericType < holeDataSubs.size()):
		holeDataSubs[genericType].erase(bodypartSlot)
	pass

func updatePartFromCharacter(genericType:int, bodypartSlot:int):
	var part:GenericPart = getChar().getGenericPart(genericType, bodypartSlot)
	if(part == null):
		clearOutPart(genericType, bodypartSlot)
		return
	
	clearOutPart(genericType, bodypartSlot)
	if(shouldBeFilteredOut(genericType, bodypartSlot)):
		return
	
	var partScenePath:String = part.getScenePath(bodypartSlot)
	if(partScenePath == ""):
		return
	partPaths[genericType][bodypartSlot] = partScenePath
	
	addPartUpdateHappening(genericType, bodypartSlot)
	
	var cachedPart := part
	var dollSceneScene:PackedScene = await ThreadedResourceLoader.asyncLoadRequest(partScenePath)
	#var theCallback := func(dollSceneScene:PackedScene, cachedPart):
	if(true):
		if(shouldBeFilteredOut(genericType, bodypartSlot)):
			removePartUpdateHappening(genericType, bodypartSlot)
			return
		if(!getChar() || getChar().getGenericPart(genericType, bodypartSlot) != cachedPart):
			#print("SWITCHERUUU")
			removePartUpdateHappening(genericType, bodypartSlot)
			return
		#print(dollSceneScene)
		if(!self || !is_instance_valid(self) || dollSceneScene == null || dollSceneScene.resource_path != cachedPart.getScenePath(bodypartSlot)):
			removePartUpdateHappening(genericType, bodypartSlot)
			return
		var dollScene := dollSceneScene.instantiate()
		if(dollScene.scene_file_path != cachedPart.getScenePath(bodypartSlot)):
			dollScene.queue_free()
			removePartUpdateHappening(genericType, bodypartSlot)
			return
		dollScene.visible = false
		parts_node.add_child(dollScene)
		
		await get_tree().create_timer(0.1).timeout
		if(!dollScene):
			removePartUpdateHappening(genericType, bodypartSlot)
			return
		if(!getChar() || getChar().getGenericPart(genericType, bodypartSlot) != cachedPart):
			dollScene.queue_free()
			removePartUpdateHappening(genericType, bodypartSlot)
			return
		parts[genericType][bodypartSlot] = dollScene
		partPaths[genericType][bodypartSlot] = dollScene.scene_file_path

		if(dollScene is DollPart):
			dollScene.visible = true
			dollScene.setDoll(self)
			dollScene.setPart(part)
			
			var partOptions:Dictionary = part.getOptionsFinal()
			for optionID in partOptions:
				dollScene.applyOptionFinal(optionID, part.getOptionValue(optionID))
			
			if(part.supportsSkinTypes()):
				var theData:SkinTypeData = part.getSkinTypeData()
				if(theData != null):
					dollScene.applySkinTypeDataFinal(part.getSkinType(), theData)
			
			for syncOptionID in getCharacter().getSyncOptions():
				dollScene.applyCharOptionFinal(syncOptionID, getCharacter().getSyncOptionValue(syncOptionID))
			
			var syncedBodypartSlots:Array = dollScene.getSyncedBodypartSlots()
			for otherBodypartSlot in syncedBodypartSlots:
				var theOtherPart:GenericPart = getChar().getBodypart(otherBodypartSlot)
				if(theOtherPart == null):
					continue
				for optionID in theOtherPart.getOptionsFinal():
					dollScene.applySyncedBodypartOption(otherBodypartSlot, optionID, theOtherPart.getOptionValue(optionID))
			
			partAddedUpdateIt(genericType, bodypartSlot, cachedPart, dollScene)
					
		triggerDollPartFlagsUpdate()
		removePartUpdateHappening(genericType, bodypartSlot)
		
	#ThreadedResourceLoader.loadCallback(partScenePath, theCallback.bind(part))
	
	#if(true):
		#return
	#
	#var dollScene := part.createScene(bodypartSlot)
	#
	#if(dollScene == null):
		#return
	#
	#parts[genericType][bodypartSlot] = dollScene
	#add_child(dollScene)
	#
	#if(dollScene is DollPart):
		#dollScene.setDoll(self)
		#dollScene.setPart(part)
		#
		#var partOptions:Dictionary = part.getOptions()
		#for optionID in partOptions:
			#dollScene.applyOptionFinal(optionID, part.getOptionValue(optionID))
		#
		#if(part.supportsSkinTypes()):
			#var theData:SkinTypeData = part.getSkinTypeData()
			#if(theData != null):
				#dollScene.applySkinTypeDataFinal(theData)
		#
		#dollScene.setPenisTargets(penisTargetHoleNode, penisTargetInsideNode)
				#
	#triggerDollPartFlagsUpdate()

signal attachPointSetupChanged

func setupAttachPoint(attachPoint):
	var attachPointName:String = attachPoint.pointName
	
	#assert(!attachPoints.has(attachPointName), "TRYING TO ADD AN ATTACH POINT WITH THE EXISTING NAME "+str(attachPointName))
	
	attachPoints[attachPointName] = attachPoint
	attachPointSetupChanged.emit()

func removeAttachPoint(attachPoint):
	var attachPointName:String = attachPoint.pointName
	
	#assert(attachPoints.has(attachPointName), "TRYING TO REMOVE AN ATTACH POINT THAT WAS NEVER ADDED "+str(attachPointName))
	#assert(attachPoints[attachPointName] == attachPoint, "TRYING TO REMOVE A WRONG ATTACH POINT")
	
	if(attachPoints.has(attachPointName) && attachPoints[attachPointName] == attachPoint):
		attachPoints.erase(attachPointName)
		attachPointSetupChanged.emit()

func getAttachPoint(pointName:String) -> DollAttachPoint:
	if(!attachPoints.has(pointName)):
		return null
	return attachPoints[pointName]

func isFirstPerson() -> bool:
	return false

func getCurrentLocomotionAnim() -> String:
	return currentLocomotionAnim

var currentLocomotionAnim:String = ""
var locomotionSupportsArmPoses:bool = true
func travelLocomotion(_newState:String, _speed:float = 1.0, _resetIfSame:bool = false):
	#if(_newState != "Idle"):
	#	stopGesture(true, false)
	#var state_machine:AnimationNodeStateMachinePlayback = animation_tree["parameters/Locomotion/playback"]
	#if(state_machine.get_current_node() != _newState):
	#	state_machine.travel(_newState)
	if(GlobalRegistry.hasDollAnim(_newState)):
		var theAnim:DollAnimBase = GlobalRegistry.getDollAnim(_newState)
		locomotionSupportsArmPoses = theAnim.doesAnimSupportArmPoses(_newState)
	else:
		locomotionSupportsArmPoses = true
	currentLocomotionAnim = _newState
	animation_tree.playLayer(animation_tree.LAYER_LOCOMOTION, _newState, _speed, _resetIfSame)
	#animTree.getLayer(XXX).getPoint(0.0).playPlayer(YYY, animID)

func isWalking() -> bool:
	return locomotionState == LOCOMOTION_WALK

func isStanding() -> bool:
	return locomotionState == LOCOMOTION_STAND

var currentWalkAnim:String = "unisex"
var currentIdleAnim:String = "normal1"
func setWalkAnim(_walkAnim:String):
	currentWalkAnim = _walkAnim

func setIdleAnim(_walkAnim:String):
	currentIdleAnim = _walkAnim

func animStand():
	locomotionState = LOCOMOTION_STAND
	travelLocomotion(currentIdleAnim)

func animAttack():
	locomotionState = LOCOMOTION_STAND
	stopGesture(true, true)
	travelLocomotion("punch", 1.0, true)

func animCombat(_space:Vector2, _combatAnim:String = "combat"):
	if(_space.length_squared() < 0.01):
		locomotionState = LOCOMOTION_STAND
	else:
		locomotionState = LOCOMOTION_WALK
	stopGesture(true, false)
	travelLocomotion(_combatAnim, 1.0)
	animation_tree.setBlend2DPos(animation_tree.LAYER_LOCOMOTION, _combatAnim, _space)

func animWalk():
	locomotionState = LOCOMOTION_WALK
	stopGesture(true, false)
	travelLocomotion(currentWalkAnim)

func animRun():
	locomotionState = LOCOMOTION_RUN
	stopGesture(true, false)
	travelLocomotion("run")

func animFall():
	locomotionState = LOCOMOTION_FALL
	stopGesture(true, false)
	travelLocomotion("fall")

func animIdle(_anim:String):
	locomotionState = LOCOMOTION_STAND
	stopGesture(true, false)
	travelLocomotion(_anim)

func setAnimPlayerEnabled(newEn:bool):
	#animation_player.active = newEn
	animation_player.active = false
	animation_tree.active = newEn

var dollAlphaMaskDirty:bool = false
func triggerAlphaMaskUpdate():
	if(dollAlphaMaskDirty):
		return
	_on_alpha_mask_texture_on_texture_updated(null)
	dollAlphaMaskDirty = true
	updateAlphaMask.call_deferred()

func updateAlphaMask():
	alpha_mask_texture.clearLayers()
	
	for inventorySlot in parts[BaseCharacter.GENERIC_CLOTHING]:
		var theItemPart = parts[BaseCharacter.GENERIC_CLOTHING][inventorySlot]
		if(theItemPart is DollPart):
			var theAlphaMask = theItemPart.getBodyAlphaMask()
			if(!theAlphaMask):
				continue
			alpha_mask_texture.addBlendAddLayer(theAlphaMask)
	
	dollAlphaMaskDirty = false

func setAnimationPartFlags(_flags:Dictionary):
	if(animationPartFlags == _flags):
		return
	animationPartFlags = _flags
	triggerDollPartFlagsUpdate()

var dollPartFlagsDirty:bool = false
func triggerDollPartFlagsUpdate():
	if(dollPartFlagsDirty):
		return
	dollPartFlagsDirty = true
	updateDollPartFlags.call_deferred()

func updateDollPartFlags():
	cachedPartFlags = {}
	
	for theSpecificParts in parts:
		for partID in theSpecificParts:
			var dollPart = theSpecificParts[partID]
			if(dollPart is DollPart):
				dollPart.gatherPartFlags(cachedPartFlags)
	
	for flag in animationPartFlags:
		cachedPartFlags[flag] = animationPartFlags[flag]
	
	for theSpecificParts in parts:
		for partID in theSpecificParts:
			var dollPart = theSpecificParts[partID]
			if(dollPart is DollPart):
				dollPart.applyPartFlagsFinal(cachedPartFlags)
	
	dollPartFlagsDirty = false

func getCachedPartFlag(_id:String, _default:Variant) -> Variant:
	if(!cachedPartFlags.has(_id)):
		return _default
	return cachedPartFlags[_id]

var penisTargetHoleNode:Node3D
var penisTargetInsideNode:Node3D
func setPenisTargets(_holeNode:Node3D, _insideNode:Node3D):
	penisTargetHoleNode = _holeNode
	penisTargetInsideNode = _insideNode
	for theSpecificParts in parts:
		for partID in theSpecificParts:
			var dollPart = theSpecificParts[partID]
			if(dollPart is DollPart):
				dollPart.setPenisTargets(penisTargetHoleNode, penisTargetInsideNode)

func getVaginaHoleNode() -> DollOpenableHole:
	return body_skeleton.getVaginaHoleNode()

func getVaginaInsideNode() -> Node3D:
	return body_skeleton.getVaginaInsideNode()

func getAnusHoleNode() -> DollOpenableHole:
	return body_skeleton.getAnusHoleNode()

func getAnusInsideNode() -> Node3D:
	return body_skeleton.getAnusInsideNode()

func alignPenisToPenisGuide():
	setPenisTargets(body_skeleton.getPenisGuide1(), body_skeleton.getPenisGuide2())

func alignPenisToVagina(otherDoll:Doll):
	if(!otherDoll):
		setPenisTargets(null, null)
		return
	setPenisTargets(otherDoll.getVaginaHoleNode(), otherDoll.getVaginaInsideNode())

func alignPenisToAnus(otherDoll:Doll):
	if(!otherDoll):
		setPenisTargets(null, null)
		return
	setPenisTargets(otherDoll.getAnusHoleNode(), otherDoll.getAnusInsideNode())

func getBodySkeleton() -> BodySkeleton:
	return body_skeleton

func getExpressionState() -> int:
	return expressionState

func setExpressionState(newExpression:int):
	expressionState = newExpression
	updateExpressionState()

func updateExpressionState():
	var theExpressionState:int = expressionState
	if(openMouthTemp):
		theExpressionState = DollExpressionState.OpenMouth
	
	for theSpecificParts in parts:
		for partID in theSpecificParts:
			var dollPart = theSpecificParts[partID]
			if(dollPart is DollPart):
				dollPart.setExpressionState(theExpressionState)
				var theFaceAnimator:FaceAnimator = dollPart.getFaceAnimator()
				if(theFaceAnimator):
					theFaceAnimator.setExpressionState(theExpressionState)

func getDollPart(genericType:int, slot:int) -> DollPart:
	if(genericType < 0 || genericType >= parts.size()):
		return null
	if(!parts[genericType].has(slot)):
		return null
	var dollPart:Node3D = parts[genericType][slot]
	# BaseCharacter.GENERIC_BODYPARTS
	if(dollPart is DollPart):
		return dollPart
	return null

func getPartCachedPath(genericType:int, slot:int) -> String:
	if(genericType < 0 || genericType >= partPaths.size()):
		return ""
	if(!partPaths[genericType].has(slot)):
		return ""
	return partPaths[genericType][slot]

func getGenericPart(genericType:int, slot:int) -> GenericPart:
	var theChar:BaseCharacter = getCharacter()
	if(!theChar):
		return null
	return theChar.getGenericPart(genericType, slot)

## Re-create clothing in case they don't fit the current bodyparts anymore
func checkAllClothingScenes():
	var theChar:BaseCharacter = getCharacter()
	if(!theChar):
		return
	var theInv:Inventory = theChar.getInventory()
	for invSlot in theInv.getEquippedItems():
		var theItem:ItemBase = theInv.getEquippedItem(invSlot)
		
		var theScenePath:String = theItem.getScenePath(invSlot)
		if(theScenePath != getPartCachedPath(BaseCharacter.GENERIC_CLOTHING, invSlot)):
			#print("RE-CREATING "+str(InventorySlot.getName(invSlot))+" "+theScenePath+" "+getPartCachedPath(BaseCharacter.GENERIC_CLOTHING, invSlot))
			#updatePartFromCharacter(BaseCharacter.GENERIC_CLOTHING, invSlot)
			updatePartFromCharacterDelayed(BaseCharacter.GENERIC_CLOTHING, invSlot)

func getVoiceHandler() -> VoiceHandler:
	return voice_handler

func _on_voice_handler_on_sound(soundType: int, soundEntry: SexSoundEntry) -> void:
	var theHead:DollPart = getDollPart(BaseCharacter.GENERIC_BODYPARTS, BodypartSlot.Head)
	if(!theHead):
		return
	var faceAnimator:FaceAnimator = theHead.getFaceAnimator()
	if(!faceAnimator):
		return
	faceAnimator.onVoiceSound(soundType, soundEntry, voice_handler)

func _on_voice_handler_on_event(_eventID: String, _args: Array) -> void:
	var theHead:DollPart = getDollPart(BaseCharacter.GENERIC_BODYPARTS, BodypartSlot.Head)
	if(!theHead):
		return
	var faceAnimator:FaceAnimator = theHead.getFaceAnimator()
	if(!faceAnimator):
		return
	faceAnimator.sendFaceGestureEvent(_eventID, _args)

func doCumVisible(cumForward:bool):
	var thePenis:DollPart = getDollPart(BaseCharacter.GENERIC_BODYPARTS, BodypartSlot.Penis)
	if(!thePenis):
		return
	var penisHandler:PenisHandler = thePenis.getPenisHandler()
	if(!penisHandler):
		return
	penisHandler.cum(cumForward)

@onready var breast_l_wiggle: DMWBWiggleRotationModifier3D = %BreastLWiggle
@onready var breast_r_wiggle: DMWBWiggleRotationModifier3D = %BreastRWiggle

func setBreastWiggleMod(_mod:float):
	breast_l_wiggle.influenceActualMax = _mod
	breast_l_wiggle.active = _mod > 0.0
	breast_r_wiggle.influenceActualMax = _mod
	breast_r_wiggle.active = _mod > 0.0

func _on_alpha_mask_texture_on_texture_updated(newTexture: Texture2D) -> void:
	var theBody:DollPart = getDollPart(BaseCharacter.GENERIC_BODYPARTS, BodypartSlot.Body)
	if(theBody):
		theBody.updateBodyAlphaMask(newTexture)

func shouldBeFilteredOut(genericType:int, bodypartSlot:int) -> bool:
	var thePart:GenericPart = getGenericPart(genericType, bodypartSlot)
	if(!thePart):
		return false
	return thePart.shouldBeFilteredOut()

func updatePartFilter():
	var character := getChar()
	if(character == null):
		return
	var genericParts:Dictionary = character.getGenericParts()
	for genericType in genericParts:
		for bodypartSlot in genericParts[genericType]:
			var dollPartExists:bool = (getDollPart(genericType, bodypartSlot) != null)
			var shouldFilter:bool = shouldBeFilteredOut(genericType, bodypartSlot)
			
			if(dollPartExists && shouldFilter):
				clearOutPart(genericType, bodypartSlot)
			elif(!dollPartExists && !shouldFilter):
				#updatePartFromCharacter(genericType, bodypartSlot)
				updatePartFromCharacterDelayed(genericType, bodypartSlot)

func updatePose(theAnimationTree:LayeredAnimPlayer = null):
	var theChar:BaseCharacter = getChar()
	if(!theChar):
		#setIdleAnim("normal1")
		return
	#setIdleAnim(theChar.getIdleAnim())
	var _isLocomotion:bool = false
	if(!theAnimationTree):
		theAnimationTree = animation_tree
		_isLocomotion = true
	
	var theArmsPose:String = ""
	
	var theArmsPoseID:String = theChar.getPoseArms()
	if(!theArmsPoseID.is_empty()):
		if(!_isLocomotion || locomotionSupportsArmPoses):
			var theDollPose := GlobalRegistry.getDollPose(theArmsPoseID)
			theArmsPose = theDollPose.getAnimName() if theDollPose else ""
	
	if(cachedPartFlags.has("ArmsPose") && !cachedPartFlags["ArmsPose"].is_empty()):
		theArmsPose = cachedPartFlags["ArmsPose"]
	
	if(!theArmsPose.is_empty()):
		theAnimationTree.playLayer(animation_tree.LAYER_ARMS_OVERRIDE, theArmsPose)
	else:
		theAnimationTree.stopLayer(animation_tree.LAYER_ARMS_OVERRIDE)

	#playSubAnims()
	
func _on_visible_on_screen_enabler_3d_screen_entered() -> void:
	parts_node.visible = true

func _on_visible_on_screen_enabler_3d_screen_exited() -> void:
	parts_node.visible = false

func isDollEnabled() -> bool:
	return parts_node.visible

func getHoverText() -> HoverTextAdvanced:
	return hover_text_advanced

func getRadialDollBars() -> Node3D:
	return radial_doll_bars

func setLookAtModifiersInfluence(_inf:float):
	look_at_modifier_head.active = (_inf > 0.0)
	look_at_modifier_neck.active = (_inf > 0.0)
	look_at_modifier_chest.active = (_inf > 0.0)
	
	look_at_modifier_head.influence = _inf
	look_at_modifier_neck.influence = _inf*0.75
	look_at_modifier_chest.influence = _inf*0.5

func getLookAtModifiersInfluence() -> float:
	return look_at_modifier_head.influence

var lookAtTimer:float = 0.0

func processLookAt(_dt:float):
	if(!lookAtNode):
		var theInf:float = look_at_modifier_head.influence
		if(theInf > 0.0):
			theInf -= _dt*3.0
			theInf = clamp(theInf, 0.0, 1.0)
			setLookAtModifiersInfluence(theInf)
			if(theInf <= 0.0):
				look_at_target.position = look_at_target_default.position
		return
	else:
		var theInf:float = look_at_modifier_head.influence
		if(theInf < 1.0):
			theInf += _dt*3.0
			theInf = clamp(theInf, 0.0, 1.0)
			setLookAtModifiersInfluence(theInf)
		
		var desiredPos:Vector3 = lookAtNode.global_position
		var dirTo:Vector3 = desiredPos - look_at_target.global_position
		var theDist:float = dirTo.length()
		
		if(!isLookAtCustom):
			lookAtTimer -= _dt
			if(lookAtTimer <= 0.0 || theDist > 10.0):
				lookAtNode = null
				return
		
		if(theDist > 0.01):
			dirTo = dirTo.normalized()
			look_at_target.global_position += dirTo*_dt*min(theDist, 5.0)*5.0


		
func lookAt(_node:Node3D, _howLong:float = 10.0):
	lookAtNode = _node
	lookAtTimer = _howLong
	isLookAtCustom = false

func getEyesNode() -> Node3D:
	return look_at_eyes


@onready var look_at_target_custom: Node3D = %LookAtTargetCustom
var isLookAtCustom:bool = false

func lookAtClear():
	isLookAtCustom = false
	lookAtTimer = 0.0
	lookAtNode = null

func lookAtCustom(thePos:Vector3):
	look_at_target_custom.position = thePos
	lookAtNode = look_at_target_custom
	isLookAtCustom = true

func doFaceTalkAnim(_len:float):
	voice_handler.sendEvent("talk", [_len])




func getExtraLayerData() -> Dictionary:
	var thePart := getDollPart(BaseCharacter.GENERIC_CLOTHING, InventorySlot.Suit)
	if(thePart):
		return thePart.getExtraLayerData()
	return {}

#const SUIT = {
	#color = Color.WHITE,
	#albedo = "res://Mesh/Clothing/LatexSuit/Textures/LatexSuitAlbedo.png",
	#normal = "res://Mesh/Clothing/LatexSuit/Textures/LatexSuitNormal.png",
	#orm = "res://Mesh/Clothing/LatexSuit/Textures/LatexSuitORM.png",
	#rim = 50.0,
	#rim_tint = 0.0,
#}

var extraLayerRaw:Dictionary = {}
var extraLayer:Dictionary = {}
func updateExtraLayer():
	var theData := getExtraLayerData()
	if(theData.is_empty()):
		extraLayerRaw.clear()
		extraLayer.clear()
	else:
		for fieldID in ["color", "rim", "rim_tint"]:
			extraLayer[fieldID] = theData[fieldID]
		for texID in ["albedo", "normal", "orm"]:
			if(!extraLayerRaw.has(texID) || extraLayerRaw[texID] != theData[texID]):
				extraLayerRaw[texID] = theData[texID]
				
				#extraLayer[texID] = MyStreamedTexture.make(theData[texID])
				
				#TODO: Will probably produce bugs when we quickly switch this stuff
				var theTexturePath:String = theData[texID]
				var theTexture := await ThreadedResourceLoader.asyncLoadRequest(theTexturePath)#MyStreamedTexture.make(theData[texID])
				var theFinalData := getExtraLayerData()
				if(!theFinalData.is_empty() && theFinalData.has(texID) && theTexturePath == theFinalData[texID]):
					extraLayer[texID] = theTexture
	
	# apply to bodyparts
	var theBody := getDollPart(BaseCharacter.GENERIC_BODYPARTS, BodypartSlot.Body)
	if(theBody):
		theBody.applyExtraLayerData(extraLayer)

func getFinalExtraLayerData() -> Dictionary:
	return extraLayer

func skeletonBoneGlobalOffset(skel: Skeleton3D, bone_name: String, local_offset: Vector3) -> Vector3:
	var idx = skel.find_bone(bone_name)
	if idx == -1:
		push_error("Bone '%s' not found." % bone_name)
		return Vector3.ZERO
	var bone_pose := skel.get_bone_global_pose(idx)
	return skel.to_global(bone_pose * (local_offset))

func getBonePos(boneName:String, theOffset:Vector3) -> Vector3:
	return skeletonBoneGlobalOffset(body_skeleton.skeleton_3d, boneName, theOffset)

func setMouthOpenTemporary(_newOpen:bool):
	openMouthTemp = _newOpen
	updateExpressionState()

func applyHitRandom(_strength:float):
	if(!isDollEnabled()):
		return
	skeleton_hit_modifier.applyHit("chest", Vector3(randf_range(-1.0, 1.0),randf_range(-1.0, 1.0),randf_range(-1.0, 1.0)).normalized(), _strength)

const HIT_AREA_MIDDLE = 0
const HIT_AREA_HIGH = 1
const HIT_AREA_LOW = 2
func applyHitSpecific(_strength:float, _dir:Vector3, _globalSpace:bool = true, _hitArea:int = HIT_AREA_MIDDLE):
	if(!isDollEnabled()):
		return
	if(_globalSpace):
		_dir = global_basis.inverse() * _dir
		_dir.z *= -1.0
	if(_hitArea == HIT_AREA_HIGH):
		skeleton_hit_modifier.applyHit("chest", _dir, _strength*0.5, 1.0)
		skeleton_hit_modifier.applyHit("neck", _dir, _strength*2.0, 0.7)
	elif(_hitArea == HIT_AREA_LOW):
		skeleton_hit_modifier.applyHit("shin.L", _dir, _strength*3.0, 0.6)
		skeleton_hit_modifier.applyHit("chest", _dir, -_strength*2.0, 0.5)
	else:
		skeleton_hit_modifier.applyHit("chest", _dir, _strength*1.0, 1.0)
		skeleton_hit_modifier.applyHit("head", -_dir, _strength*3.0, 0.3)

func doStruggleAnimFor(_time:float):
	if(!isDollEnabled()):
		return
	struggleTimer = maxf(_time, struggleTimer)
	if(!skeleton_hit_modifier.isStruggling()):
		skeleton_hit_modifier.startStruggle(0.3, 0.5, 1.2, 1.8)
	
func updateBodyStuff():
	#var theBreastWiggle:float = 0.0
	var theWidth:float = 0.0
	var theBody:DollPart = getDollPart(BaseCharacter.GENERIC_BODYPARTS, BodypartSlot.Body)
	if(theBody):
		theWidth = theBody.getShouldersWidth()
		#theBreastWiggle = theBody.getBreastsWigglePhysics()
	
	body_skeleton.setShoulderWidthInfluence(theWidth)
	#breast_l_wiggle.influence = theBreastWiggle
	#breast_l_wiggle.active = (theBreastWiggle > 0.0)
	#breast_r_wiggle.influence = theBreastWiggle
	#breast_r_wiggle.active = (theBreastWiggle > 0.0)

func getPenisGirth() -> float:
	var theStrapon:DollPart = getDollPart(BaseCharacter.GENERIC_CLOTHING, InventorySlot.UnderwearBottom)
	if(theStrapon && theStrapon.supportsPenisGirth()):
		return theStrapon.getPenisGirth()
	
	var thePenis:DollPart = getDollPart(BaseCharacter.GENERIC_BODYPARTS, BodypartSlot.Penis)
	if(thePenis && thePenis.supportsPenisGirth()):
		return thePenis.getPenisGirth()
	return 1.0

func triggerHoleDataUpdate():
	if(holeDataDirty):
		return
	holeDataDirty = true
	updateDollHoleData.call_deferred()

func updateDollHoleData():
	holeDataDirty = false
	for genericType in holeDataSubs.size():
		var theEntries:Array = holeDataSubs[genericType]
		var theEntriesAm:int = theEntries.size()
		
		for _i in theEntriesAm:
			var _indx:int = theEntriesAm - _i - 1
			var theSlot:int = theEntries[_indx]
			
			var thePart := getDollPart(genericType, theSlot)
			if(!thePart): # Part poofed or something, might be an error
				Log.Printerr("updateDollHoleData() doll part doesn't exist: Generic type:"+str(genericType)+" Slot:"+str(theSlot))
				theEntries.remove_at(_indx)
				continue
			
			thePart.applyDollHoleData(holeData)

func animEvent(_eventID:String):
	if(_eventID == "step"):
		Audio.playSound3DAdvanced(self, preload("res://Sounds/Footsteps/Concrete.tres"), -5.0)
#	print(_eventID)
