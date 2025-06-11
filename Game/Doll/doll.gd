extends Node3D
class_name Doll

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var animation_tree: AnimationTree = %AnimationTree
@onready var parts_node: Node3D = %Parts

@onready var body_skeleton: BodySkeleton = %BodySkeleton
@onready var voice_handler: VoiceHandler = %VoiceHandler

@onready var alpha_mask_texture: MyLayeredTexture = %AlphaMaskTexture

@export var disableInternalAnimPlayer:bool = false

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
const POSES_TO_ADD = [
	"Kneel",
]

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

#AnimationRootNode
static func updateAnimTreeWithPoses(theTree:AnimationRootNode, noFullBody:bool = false):
	if(!(theTree is AnimationNodeBlendTree)):
		Log.Printerr("Bad anim tree")
		return
	if(theTree.has_node("UPDATED_WITH_POSES")):
		return
	theTree.add_node("UPDATED_WITH_POSES", AnimationNodeAnimation.new())
	
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
		currentChar.onGenericPartChange.disconnect(onCharPartChange)
		currentChar.onGenericPartOptionChange.disconnect(onCharPartOptionChange)
		currentChar.onBodypartSkinTypeChange.disconnect(onCharBodypartSkinTypeChange)
		currentChar.onCharOptionChange.disconnect(onCharOptionChange)
		currentChar.onPartFilterChange.disconnect(updatePartFilter)
		currentChar.getBodyMess().onChange.disconnect(onUpdateBodyMess)
	
	characterRef = weakref(theChar)
	updateFromCharacter()
	theChar.onGenericPartChange.connect(onCharPartChange)
	theChar.onGenericPartOptionChange.connect(onCharPartOptionChange)
	theChar.onBodypartSkinTypeChange.connect(onCharBodypartSkinTypeChange)
	theChar.onCharOptionChange.connect(onCharOptionChange)
	theChar.onPartFilterChange.connect(updatePartFilter)
	theChar.getBodyMess().onChange.connect(onUpdateBodyMess)
	
	voice_handler.setCharID(theChar.getID() if theChar else "")

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
				dollPart.applyCharOption(_change, theValue)

func onCharBodypartSkinTypeChange(slot:int, _theSkinType:String, skinTypeData:SkinTypeData):
	if(!parts[BaseCharacter.GENERIC_BODYPARTS].has(slot)):
		# # part might be in the process of being loaded so this is fine
		#Log.error("Doll doesn't have a part that the character has")
		return
	var dollPart:Node3D = parts[BaseCharacter.GENERIC_BODYPARTS][slot]
	if(dollPart is DollPart):
		dollPart.applySkinTypeDataFinal(skinTypeData)

func onCharPartOptionChange(_genericType:int, slot:int, optionID:String, newvalue):
	if(!parts[_genericType].has(slot)):
		# # part might be in the process of being loaded so this is fine
		#Log.error("Doll doesn't have a part that the character has")
		return
	var dollPart:Node3D = parts[_genericType][slot]
	if(dollPart is DollPart):
		dollPart.applyOption(optionID, newvalue)
	
	if(_genericType == BaseCharacter.GENERIC_BODYPARTS):
		var theClothingParts:Dictionary = parts[BaseCharacter.GENERIC_CLOTHING]
		for theOtherPartSlot in theClothingParts:
			var theOtherPart = theClothingParts[theOtherPartSlot]
			if(theOtherPart is DollPart):
				if(slot in theOtherPart.getSyncedBodypartSlots()):
					theOtherPart.applySyncedBodypartOption(slot, optionID, newvalue)

func onCharPartChange(_genericType:int, slot:int, _newpart):
	updatePartFromCharacter(_genericType, slot)
	
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

func updateFromCharacter():
	clear()
	var character := getChar()
	if(character == null):
		return
	
	var genericParts:Dictionary = character.getGenericParts()
	for genericType in genericParts:
		for bodypartSlot in genericParts[genericType]:
			updatePartFromCharacter(genericType, bodypartSlot)

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
	
	var theCallback := func(dollSceneScene:PackedScene, cachedPart):
		if(shouldBeFilteredOut(genericType, bodypartSlot)):
			return
		if(getChar().getGenericPart(genericType, bodypartSlot) != cachedPart):
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
				dollScene.applyOption(optionID, part.getOptionValue(optionID))
			
			if(part.supportsSkinTypes()):
				var theData:SkinTypeData = part.getSkinTypeData()
				if(theData != null):
					dollScene.applySkinTypeDataFinal(theData)
			
			for syncOptionID in getCharacter().getSyncOptions():
				dollScene.applyCharOption(syncOptionID, getCharacter().getSyncOptionValue(syncOptionID))
			
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
					
		triggerDollPartFlagsUpdate()
		
	ThreadedResourceLoader.loadCallback(partScenePath, theCallback.bind(part))
	
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
			#dollScene.applyOption(optionID, part.getOptionValue(optionID))
		#
		#if(part.supportsSkinTypes()):
			#var theData:SkinTypeData = part.getSkinTypeData()
			#if(theData != null):
				#dollScene.applySkinTypeDataFinal(theData)
		#
		#dollScene.setPenisTargets(penisTargetHoleNode, penisTargetInsideNode)
				#
	#triggerDollPartFlagsUpdate()

func setupAttachPoint(attachPoint):
	var attachPointName:String = attachPoint.pointName
	
	#assert(!attachPoints.has(attachPointName), "TRYING TO ADD AN ATTACH POINT WITH THE EXISTING NAME "+str(attachPointName))
	
	attachPoints[attachPointName] = attachPoint

func removeAttachPoint(attachPoint):
	var attachPointName:String = attachPoint.pointName
	
	#assert(attachPoints.has(attachPointName), "TRYING TO REMOVE AN ATTACH POINT THAT WAS NEVER ADDED "+str(attachPointName))
	#assert(attachPoints[attachPointName] == attachPoint, "TRYING TO REMOVE A WRONG ATTACH POINT")
	
	if(attachPoints.has(attachPointName) && attachPoints[attachPointName] == attachPoint):
		attachPoints.erase(attachPointName)

func getAttachPoint(pointName:String) -> DollAttachPoint:
	if(!attachPoints.has(pointName)):
		return null
	return attachPoints[pointName]

func isFirstPerson() -> bool:
	return false

func getLocomotionPlayback() -> AnimationNodeStateMachinePlayback:
	return animation_tree["parameters/Locomotion/playback"]

func travelLocomotion(_newState:String):
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
				dollPart.applyPartFlags(cachedPartFlags)
	
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

	for genericType in parts:
		for partID in parts[genericType]:
			var dollPart = parts[genericType][partID]
			if(dollPart is DollPart):
				dollPart.setExpressionState(expressionState)
				var theFaceAnimator:FaceAnimator = dollPart.getFaceAnimator()
				if(theFaceAnimator):
					theFaceAnimator.setExpressionState(newExpression)

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
			updatePartFromCharacter(BaseCharacter.GENERIC_CLOTHING, invSlot)

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
				updatePartFromCharacter(genericType, bodypartSlot)

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
		setIdleAnim(theIdlePose.getAnimName())
	
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
