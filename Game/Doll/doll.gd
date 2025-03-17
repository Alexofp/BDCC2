extends Node3D
class_name Doll

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var body_skeleton: BodySkeleton = %BodySkeleton

@export var disableInternalAnimPlayer:bool = false

var characterRef:WeakRef

var parts:Dictionary = {
	BaseCharacter.GENERIC_BODYPARTS: {},
	BaseCharacter.GENERIC_CLOTHING: {},
}
var attachPoints:Dictionary = {}

func _ready() -> void:
	if(disableInternalAnimPlayer):
		animation_player.active = false

func setCharacter(theChar:BaseCharacter):
	var currentChar := getChar()
	if(currentChar != null):
		currentChar.onGenericPartChange.disconnect(onCharPartChange)
		currentChar.onGenericPartOptionChange.disconnect(onCharPartOptionChange)
		currentChar.onBodypartSkinTypeChange.disconnect(onCharBodypartSkinTypeChange)
	
	characterRef = weakref(theChar)
	updateFromCharacter()
	theChar.onGenericPartChange.connect(onCharPartChange)
	theChar.onGenericPartOptionChange.connect(onCharPartOptionChange)
	theChar.onBodypartSkinTypeChange.connect(onCharBodypartSkinTypeChange)

func getChar() -> BaseCharacter:
	if(characterRef == null):
		return null
	return characterRef.get_ref()

func getCharacter() -> BaseCharacter:
	if(characterRef == null):
		return null
	return characterRef.get_ref()

func onCharBodypartSkinTypeChange(slot:String, _theSkinType:String, skinTypeData:SkinTypeData):
	if(!parts[BaseCharacter.GENERIC_BODYPARTS].has(slot)):
		Log.error("Doll doesn't have a part that the character has")
		return
	var dollPart:Node3D = parts[BaseCharacter.GENERIC_BODYPARTS][slot]
	if(dollPart is DollPart):
		dollPart.applySkinTypeDataFinal(skinTypeData)

func onCharPartOptionChange(_genericType:String, slot:String, optionID:String, newvalue):
	if(!parts[_genericType].has(slot)):
		Log.error("Doll doesn't have a part that the character has")
		return
	var dollPart:Node3D = parts[_genericType][slot]
	if(dollPart is DollPart):
		dollPart.applyOption(optionID, newvalue)

func onCharPartChange(_genericType:String, slot:String, _newpart):
	updatePartFromCharacter(_genericType, slot)

func clear():
	for genericType in parts:
		for slot in parts[genericType]:
			var bodypartDollPart:DollPart = parts[genericType][slot]
			bodypartDollPart.queue_free()
	parts = {
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

func updatePartFromCharacter(genericType:String, bodypartSlot:String):
	var part:GenericPart = getChar().getGenericPart(genericType, bodypartSlot)
	if(part == null):
		if(parts[genericType].has(bodypartSlot)):
			parts[genericType][bodypartSlot].queue_free()
			parts[genericType].erase(bodypartSlot)
		return
		
	if(parts[genericType].has(bodypartSlot)):
		parts[genericType][bodypartSlot].queue_free()
		parts[genericType].erase(bodypartSlot)
		
	var partScenePath:String = part.getScenePath(bodypartSlot)
	var theCallback := func(dollSceneScene:PackedScene, cachedPart):
		if(getChar().getGenericPart(genericType, bodypartSlot) != cachedPart):
			#print("SWITCHERUUU")
			return
		if(!self || !is_instance_valid(self)):
			return
		#print(dollSceneScene)
		if(dollSceneScene == null):
			return
		var dollScene := dollSceneScene.instantiate()
		parts[genericType][bodypartSlot] = dollScene
		add_child(dollScene)
		if(dollScene is DollPart):
			dollScene.setDoll(self)
			dollScene.setPart(part)
			
			var partOptions:Dictionary = part.getOptions()
			for optionID in partOptions:
				dollScene.applyOption(optionID, part.getOptionValue(optionID))
			
			if(part.supportsSkinTypes()):
				var theData:SkinTypeData = part.getSkinTypeData()
				if(theData != null):
					dollScene.applySkinTypeDataFinal(theData)
			
			dollScene.setPenisTargets(penisTargetHoleNode, penisTargetInsideNode)
					
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

func animStand():
	if(animation_player.assigned_animation != "BodyAnims/Idle"):
		animation_player.play("BodyAnims/Idle", 0.2)

func animWalk():
	if(animation_player.assigned_animation != "BodyAnims/Walk"):
		animation_player.play("BodyAnims/Walk", 0.2)

func animRun():
	if(animation_player.assigned_animation != "BodyAnims/Run"):
		animation_player.play("BodyAnims/Run", 0.2)

func animFall():
	if(animation_player.assigned_animation != "BodyAnims/Falling"):
		animation_player.play("BodyAnims/Falling", 0.15)

func animSit():
	if(animation_player.assigned_animation != "BasicAnims/Sit"):
		animation_player.play("BasicAnims/Sit", 0.15)

func setAnimPlayerEnabled(newEn:bool):
	animation_player.active = newEn

var dollPartFlagsDirty:bool = false
func triggerDollPartFlagsUpdate():
	if(dollPartFlagsDirty):
		return
	dollPartFlagsDirty = true
	updateDollPartFlags.call_deferred()

func updateDollPartFlags():
	var allTheFlags:Dictionary = {}
	
	for genericType in parts:
		for partID in parts[genericType]:
			var dollPart = parts[genericType][partID]
			if(dollPart is DollPart):
				dollPart.gatherPartFlags(allTheFlags)
	
	for genericType in parts:
		for partID in parts[genericType]:
			var dollPart = parts[genericType][partID]
			if(dollPart is DollPart):
				dollPart.applyPartFlags(allTheFlags)
	
	dollPartFlagsDirty = false

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
