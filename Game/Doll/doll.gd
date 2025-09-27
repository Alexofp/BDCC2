extends Node3D
class_name Doll

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var animation_tree: AnimationTree = %AnimationTree
@onready var parts_node: Node3D = %Parts

@onready var body_skeleton: BodySkeleton = %BodySkeleton
@onready var voice_handler: VoiceHandler = %VoiceHandler

@onready var alpha_mask_texture: MyLayeredTexture = %AlphaMaskTexture

@export var disableInternalAnimPlayer:bool = false
@onready var hover_text: Label3D = %HoverText

@onready var look_at_modifier_chest: LookAtModifier3D = %LookAtModifierChest
@onready var look_at_modifier_neck: LookAtModifier3D = %LookAtModifierNeck
@onready var look_at_modifier_head: LookAtModifier3D = %LookAtModifierHead
@onready var look_at_target: Node3D = %LookAtTarget
@onready var look_at_eyes: Node3D = %LookAtEyes
@onready var look_at_target_default: Node3D = %LookAtTargetDefault

var lookAtNode:Node3D = null

var expressionState:int = DollExpressionState.Normal

var characterRef:WeakRef

var parts:Dictionary = {
	BaseCharacter.GENERIC_BODYPARTS: {},
	BaseCharacter.GENERIC_CLOTHING: {},
}
var partPaths:Dictionary = {
	BaseCharacter.GENERIC_BODYPARTS: {},
	BaseCharacter.GENERIC_CLOTHING: {},
}
var attachPoints:Dictionary = {}

var cachedPartFlags:Dictionary = {}

const WALK_UNISEX = "unisex"
const WALK_HOBBLED = "hobbled"
const WALK_FEM = "fem"
const WALK_PICKABLE_ANIMS:Array = [
	[WALK_UNISEX, "Unisex"],
	[WALK_FEM, "Feminine"],
]

const IDLE_NORMAL1 = "normal1"
const IDLE_NORMAL2 = "normal2"
const IDLE_SEXY = "sexy"
const IDLE_PICKABLE_ANIMS:Array = [
	[IDLE_NORMAL1, "Normal"],
	[IDLE_NORMAL2, "Normal Alt"],
	[IDLE_SEXY, "Sexy"],
]

static var addedPosesToTree:bool = false

var openMouthTemp:bool = false

signal onGesturePlay(gestureID, playFullBody, playPartial)

func updateAnimPlayer():
	updateAnimPlayerSpecific(animation_player)
	
static func updateAnimPlayerSpecific(_animPlayer:AnimationPlayer):
	for poseID in GlobalRegistry.getDollPoses():
		var theDollPose:DollPoseBase = GlobalRegistry.getDollPose(poseID)
		if(theDollPose.animLibrary != null && theDollPose.animLibraryName != ""):
			if(!_animPlayer.has_animation_library(theDollPose.animLibraryName)):
				_animPlayer.add_animation_library(theDollPose.animLibraryName, theDollPose.animLibrary)
	
func updateAnimTreeOnce():
	updateAnimTreeWithPoses(dollBlendTree)

func playGesture(_gestureID:String, _playFullBody:bool=true, playPartialBody:bool=true):
	var theGesture := GlobalRegistry.getDollGesture(_gestureID)
	if(theGesture == null):
		return
	if(_playFullBody && theGesture.playFullBody):
		if(!animation_tree["parameters/Locomotion/Idle/FullBodyGesture/active"]):
			animation_tree["parameters/Locomotion/Idle/FullBodyGesture/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		animation_tree["parameters/Locomotion/Idle/FullBodyGesture_Selector/transition_request"] = _gestureID
	if(playPartialBody && theGesture.playPartial):
		if(!animation_tree["parameters/BodyGesture/active"]):
			animation_tree["parameters/BodyGesture/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		animation_tree["parameters/BodyGesture_Selector/transition_request"] = _gestureID
	onGesturePlay.emit(_gestureID, _playFullBody, playPartialBody)
	
func stopGesture(stopFullBody:bool = true, stopPartical:bool = true):
	if(stopFullBody):
		animation_tree["parameters/Locomotion/Idle/FullBodyGesture/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT
	if(stopPartical):
		animation_tree["parameters/BodyGesture/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT

#AnimationRootNode
static func updateAnimTreeWithPoses(theTree:AnimationRootNode, noFullBody:bool = false):
	if(!(theTree is AnimationNodeBlendTree)):
		Log.Printerr("Bad anim tree")
		return
	if(theTree.has_node("UPDATED_WITH_POSES")):
		return
	theTree.add_node("UPDATED_WITH_POSES", AnimationNodeAnimation.new())
	
	if(true):
		#var theLocomotion:AnimationNodeStateMachine = theTree.get_node("Locomotion")
		#var theLocIdle:AnimationNodeBlendTree = theLocomotion.get_node("Idle")
		var theGestureSelector:AnimationNodeTransition = theTree.get_node("BodyGesture_Selector")
		var _i:int = theGestureSelector.get_input_count()
		
		for gestureID in GlobalRegistry.getDollGestures():
			var theDollGesture:DollGestureBase = GlobalRegistry.getDollGesture(gestureID)
			var newAnim:AnimationNodeAnimation = AnimationNodeAnimation.new()
			newAnim.animation = theDollGesture.getAnimName()
			theTree.add_node("gesture_"+gestureID, newAnim)
			
			theGestureSelector.add_input(gestureID)
			
			theTree.connect_node("BodyGesture_Selector", _i, "gesture_"+gestureID)
			_i += 1
	
	if(!noFullBody):
		var theLocomotion:AnimationNodeStateMachine = theTree.get_node("Locomotion")
		var theLocIdle:AnimationNodeBlendTree = theLocomotion.get_node("Idle")
		var theGestureSelector:AnimationNodeTransition = theLocIdle.get_node("FullBodyGesture_Selector")
		var _i:int = theGestureSelector.get_input_count()
		
		for gestureID in GlobalRegistry.getDollGestures():
			var theDollGesture:DollGestureBase = GlobalRegistry.getDollGesture(gestureID)
			var newAnim:AnimationNodeAnimation = AnimationNodeAnimation.new()
			newAnim.animation = theDollGesture.getAnimName()
			theLocIdle.add_node("gesture_"+gestureID, newAnim)
			
			theGestureSelector.add_input(gestureID)
			
			theLocIdle.connect_node("FullBodyGesture_Selector", _i, "gesture_"+gestureID)
			_i += 1
	
	if(!noFullBody):
		var theLocomotion:AnimationNodeStateMachine = theTree.get_node("Locomotion")
		var theLocIdle:AnimationNodeBlendTree = theLocomotion.get_node("Idle")
		var thePoseIdleSelector:AnimationNodeTransition = theLocIdle.get_node("Idle_Selector")
		var _i:int = thePoseIdleSelector.get_input_count()
		
		for poseID in GlobalRegistry.getDollPoses():
			var theDollPose:DollPoseBase = GlobalRegistry.getDollPose(poseID)
			if(theDollPose.poseType != DollPoseBase.PoseType.Fullbody):
				continue
			var newAnim:AnimationNodeAnimation = AnimationNodeAnimation.new()
			newAnim.animation = theDollPose.animLibraryName+"/"+theDollPose.getAnimName()
			theLocIdle.add_node(poseID, newAnim)
			
			thePoseIdleSelector.add_input(poseID)
			
			theLocIdle.connect_node("Idle_Selector", _i, poseID)
			_i += 1
	if(!noFullBody):
		var theLocomotion:AnimationNodeStateMachine = theTree.get_node("Locomotion")
		var theLocWalk:AnimationNodeBlendTree = theLocomotion.get_node("Walk")
		var thePoseWalkSelector:AnimationNodeTransition = theLocWalk.get_node("Walk_Selector")
		var _i:int = thePoseWalkSelector.get_input_count()
		
		for poseID in GlobalRegistry.getDollPoses():
			var theDollPose:DollPoseBase = GlobalRegistry.getDollPose(poseID)
			if(theDollPose.poseType != DollPoseBase.PoseType.Fullbody):
				continue
			if(theDollPose.getWalkAnimName() == ""):
				continue
			var newAnim:AnimationNodeAnimation = AnimationNodeAnimation.new()
			newAnim.animation = theDollPose.animLibraryName+"/"+theDollPose.getWalkAnimName()
			theLocWalk.add_node(poseID, newAnim)
			
			thePoseWalkSelector.add_input(poseID)
			
			theLocWalk.connect_node("Walk_Selector", _i, poseID)
			_i += 1
	
	if(true):
		var theArmsSelector:AnimationNodeTransition = theTree.get_node("Arms_Selector")
		var _i:int = theArmsSelector.get_input_count()
		for poseID in GlobalRegistry.getDollPoses():
			var theDollPose:DollPoseBase = GlobalRegistry.getDollPose(poseID)
			if(theDollPose.poseType != DollPoseBase.PoseType.Arms):
				continue
			var newAnim:AnimationNodeAnimation = AnimationNodeAnimation.new()
			newAnim.animation = theDollPose.animLibraryName+"/"+theDollPose.getAnimName()
			theTree.add_node("arms_"+poseID, newAnim)
			
			theArmsSelector.add_input(poseID)
			
			theTree.connect_node("Arms_Selector", _i, "arms_"+poseID)
			_i += 1

var dollBlendTree := preload("res://Game/Doll/Util/DollBlendTree.tres")

func _init():
	if(!addedPosesToTree):
		updateAnimTreeOnce()
		addedPosesToTree = true

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
	if(!parts.has(BaseCharacter.GENERIC_BODYPARTS)):
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
	for genericType in parts:
		for partID in parts[genericType]:
			var dollPart = parts[genericType][partID]
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
	for genericType in parts:
		for partID in parts[genericType]:
			var dollPart = parts[genericType][partID]
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
	for genericType in parts:
		for slot in parts[genericType]:
			var bodypartDollPart:Node = parts[genericType][slot]
			bodypartDollPart.queue_free()
	parts = {
		BaseCharacter.GENERIC_BODYPARTS: {},
		BaseCharacter.GENERIC_CLOTHING: {},
	}
	partPaths = {
		BaseCharacter.GENERIC_BODYPARTS: {},
		BaseCharacter.GENERIC_CLOTHING: {},
	}

func _physics_process(_delta: float) -> void:
	if(!partUpdateQueue.is_empty()):
		partUpdateQueueTimer -= _delta
		if(partUpdateQueueTimer <= 0.0):
			partUpdateQueueTimer = 0.3
			var theEntry:Array = partUpdateQueue.pop_front()
			updatePartFromCharacter(theEntry[0], theEntry[1])

func _process(_delta: float) -> void:
	processLookAt(_delta)
	
var partUpdateQueue:Array = []
var partUpdateQueueTimer:float = 0.0
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
	var theDollPart:DollPart = getDollPart(genericType, bodypartSlot)
	if(theDollPart && theDollPart.getBodyAlphaMask()):
		triggerAlphaMaskUpdate()
	if(parts[genericType].has(bodypartSlot)):
		parts[genericType][bodypartSlot].queue_free()
		parts[genericType].erase(bodypartSlot)
		triggerDollPartFlagsUpdate()
	if(partPaths[genericType].has(bodypartSlot)):
		partPaths[genericType].erase(bodypartSlot)
	if(theDollPart && genericType == BaseCharacter.GENERIC_CLOTHING && bodypartSlot == InventorySlot.Suit):
		updateExtraLayer()

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
	
	var cachedPart := part
	var dollSceneScene:PackedScene = await ThreadedResourceLoader.asyncLoadRequest(partScenePath)
	#var theCallback := func(dollSceneScene:PackedScene, cachedPart):
	if(true):
		if(shouldBeFilteredOut(genericType, bodypartSlot)):
			return
		if(!getChar() || getChar().getGenericPart(genericType, bodypartSlot) != cachedPart):
			#print("SWITCHERUUU")
			return
		if(!self || !is_instance_valid(self)):
			return
		#print(dollSceneScene)
		if(dollSceneScene == null):
			return
		if(dollSceneScene.resource_path != cachedPart.getScenePath(bodypartSlot)):
			return
		var dollScene := dollSceneScene.instantiate()
		if(dollScene.scene_file_path != cachedPart.getScenePath(bodypartSlot)):
			dollScene.queue_free()
			return
		parts[genericType][bodypartSlot] = dollScene
		partPaths[genericType][bodypartSlot] = dollScene.scene_file_path
		parts_node.add_child(dollScene)
		if(dollScene is DollPart):
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
			
			dollScene.setPenisTargets(penisTargetHoleNode, penisTargetInsideNode)
			dollScene.setExpressionState(expressionState)
			dollScene.updateBodyMess()
			if(dollScene.getBodyAlphaMask()):
				triggerAlphaMaskUpdate()
			dollScene.onSpawn(genericType, bodypartSlot, cachedPart.id)
			
			if(genericType == BaseCharacter.GENERIC_BODYPARTS && bodypartSlot == BodypartSlot.Body):
				updateExtraLayer()
			elif(genericType == BaseCharacter.GENERIC_CLOTHING && bodypartSlot == InventorySlot.Suit):
				updateExtraLayer()
					
		triggerDollPartFlagsUpdate()
		
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

func getLocomotionPlayback() -> AnimationNodeStateMachinePlayback:
	return animation_tree["parameters/Locomotion/playback"]

func travelLocomotion(_newState:String):
	if(_newState != "Idle"):
		stopGesture(true, false)
	var state_machine:AnimationNodeStateMachinePlayback = animation_tree["parameters/Locomotion/playback"]
	if(state_machine.get_current_node() != _newState):
		state_machine.travel(_newState)

func isWalking() -> bool:
	var state_machine:AnimationNodeStateMachinePlayback = animation_tree["parameters/Locomotion/playback"]
	return state_machine.get_current_node() == "Walk"

func isStanding() -> bool:
	var state_machine:AnimationNodeStateMachinePlayback = animation_tree["parameters/Locomotion/playback"]
	return state_machine.get_current_node() == "Idle"

func setWalkAnim(_walkAnim:String):
	animation_tree["parameters/Locomotion/Walk/Walk_Selector/transition_request"] = _walkAnim

func setIdleAnim(_walkAnim:String):
	animation_tree["parameters/Locomotion/Idle/Idle_Selector/transition_request"] = _walkAnim

func animStand():
	#body_skeleton.resetBones()
	#const theAnimName = "LocomotionAnims/Idle"
	#const theAnimName = "LocomotionAnims/IdleLong"
	#const theAnimName = "LocomotionAnims/IdleSexy"
	#if(animation_player.assigned_animation != theAnimName):
	#	animation_player.play(theAnimName, 0.2)
	travelLocomotion("Idle")

func animWalk():
	#const theAnimName = "LocomotionAnims/WalkUnisex"
	#const theAnimName = "LocomotionAnims/WalkFem"
	#if(animation_player.assigned_animation != theAnimName):
	#	animation_player.play(theAnimName, 0.2)
	travelLocomotion("Walk")

func animRun():
	#const theAnimName = "LocomotionAnims/Run"
	#if(animation_player.assigned_animation != theAnimName):
	#	animation_player.play(theAnimName, 0.2)
	travelLocomotion("Run")

func animFall():
	#const theAnimName = "LocomotionAnims/Fall"
	#if(animation_player.assigned_animation != theAnimName):
	#	animation_player.play(theAnimName, 0.15)
	travelLocomotion("Fall")

#func animSit():
	#const theAnimName = "BasicAnims/Sit"
	#if(animation_player.assigned_animation != theAnimName):
		#animation_player.play(theAnimName, 0.15)

var animArmbinder:bool = false
func setArmbinderPoseEnabled(_en:bool):
	animArmbinder = _en
	animation_tree["parameters/ArmBinder_Blend/blend_amount"] = 1.0 if _en else 0.0
func isArmbinderPoseEnabled() -> bool:
	return animArmbinder

var animCuffedBehindBack:bool = false
func setCuffedBehindBackPoseEnabled(_en:bool):
	animCuffedBehindBack = _en
	animation_tree["parameters/CuffedBehindBack_Blend/blend_amount"] = 1.0 if _en else 0.0
func isCuffedBehindBackPoseEnabled() -> bool:
	return animCuffedBehindBack

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

var dollPartFlagsDirty:bool = false
func triggerDollPartFlagsUpdate():
	if(dollPartFlagsDirty):
		return
	dollPartFlagsDirty = true
	updateDollPartFlags.call_deferred()

func updateDollPartFlags():
	cachedPartFlags = {}
	
	for genericType in parts:
		for partID in parts[genericType]:
			var dollPart = parts[genericType][partID]
			if(dollPart is DollPart):
				dollPart.gatherPartFlags(cachedPartFlags)
	
	for genericType in parts:
		for partID in parts[genericType]:
			var dollPart = parts[genericType][partID]
			if(dollPart is DollPart):
				dollPart.applyPartFlagsFinal(cachedPartFlags)
	
	if(cachedPartFlags.has("ArmbinderPose") && cachedPartFlags["ArmbinderPose"]):
		setArmbinderPoseEnabled(true)
	else:
		setArmbinderPoseEnabled(false)
	
	if(cachedPartFlags.has("CuffedBehindBackPose") && cachedPartFlags["CuffedBehindBackPose"]):
		setCuffedBehindBackPoseEnabled(true)
	else:
		setCuffedBehindBackPoseEnabled(false)
	
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
	for genericType in parts:
		for partID in parts[genericType]:
			var dollPart = parts[genericType][partID]
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
	
	for genericType in parts:
		for partID in parts[genericType]:
			var dollPart = parts[genericType][partID]
			if(dollPart is DollPart):
				dollPart.setExpressionState(theExpressionState)
				var theFaceAnimator:FaceAnimator = dollPart.getFaceAnimator()
				if(theFaceAnimator):
					theFaceAnimator.setExpressionState(theExpressionState)

func getDollPart(genericType:int, slot:int) -> DollPart:
	if(!parts.has(genericType)):
		return null
	if(!parts[genericType].has(slot)):
		return null
	var dollPart:Node3D = parts[genericType][slot]
	# BaseCharacter.GENERIC_BODYPARTS
	if(dollPart is DollPart):
		return dollPart
	return null

func getPartCachedPath(genericType:int, slot:int) -> String:
	if(!partPaths.has(genericType)):
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
	breast_l_wiggle.influence = _mod
	breast_r_wiggle.influence = _mod

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

func setArmsAnim(_walkAnim:String, theAnimTree:AnimationTree = null):
	if(!theAnimTree):
		theAnimTree = animation_tree
	if(_walkAnim == ""):
		theAnimTree["parameters/Arms_Blend/blend_amount"] = 0.0
	else:
		theAnimTree["parameters/Arms_Blend/blend_amount"] = 1.0
		theAnimTree["parameters/Arms_Selector/transition_request"] = _walkAnim

func updatePose():
	var theChar:BaseCharacter = getChar()
	if(!theChar):
		setIdleAnim("normal1")
		return
	var theIdlePoseID:String = theChar.getIdlePose()
	var theIdlePose:DollPoseBase = GlobalRegistry.getDollPose(theIdlePoseID) if theIdlePoseID != "" else null
	if(!theIdlePose):
		setIdleAnim(theChar.getIdleAnim())
	else:
		setIdleAnim(theIdlePoseID)#theIdlePose.getAnimName())
	
	if(theIdlePose && ((isStanding() && !theIdlePose.doesPoseSupportArmPoses()) || (isWalking() && !theIdlePose.doesWalkSupportArmPoses()))):
		setArmsAnim("")
	else:
		var theArmsPoseID:String = theChar.getPoseArms()
		var theArmsPose:DollPoseBase = GlobalRegistry.getDollPose(theArmsPoseID) if theArmsPoseID != "" else null
		setArmsAnim(theArmsPoseID if theArmsPose else "")


func _on_visible_on_screen_enabler_3d_screen_entered() -> void:
	parts_node.visible = true

func _on_visible_on_screen_enabler_3d_screen_exited() -> void:
	parts_node.visible = false

func getHoverText() -> Label3D:
	return hover_text

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
