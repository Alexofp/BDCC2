extends Node3D
class_name Doll

var characterRef:WeakRef

var parts:Dictionary = {}
var attachPoints:Dictionary = {}

func setCharacter(theChar:BaseCharacter):
	var currentChar := getChar()
	if(currentChar != null):
		currentChar.onGenericPartChange.disconnect(onCharPartChange)
		currentChar.onGenericPartOptionChange.disconnect(onCharPartOptionChange)
	
	characterRef = weakref(theChar)
	updateFromCharacter()
	theChar.onGenericPartChange.connect(onCharPartChange)
	theChar.onGenericPartOptionChange.connect(onCharPartOptionChange)

func getChar() -> BaseCharacter:
	if(characterRef == null):
		return null
	return characterRef.get_ref()

func getCharacter() -> BaseCharacter:
	if(characterRef == null):
		return null
	return characterRef.get_ref()

func onCharPartOptionChange(slot:String, optionID:String, newvalue):
	if(!parts.has(slot)):
		Log.error("Doll doesn't have a part that the character has")
		return
	var dollPart:Node3D = parts[slot]
	if(dollPart is DollPart):
		dollPart.applyOption(optionID, newvalue)

func onCharPartChange(slot:String, _newpart):
	updatePartFromCharacter(slot)

func clear():
	for slot in parts:
		var bodypartDollPart:DollPart = parts[slot]
		bodypartDollPart.queue_free()
	parts.clear()

func updateFromCharacter():
	clear()
	var character := getChar()
	if(character == null):
		return
	for bodypartSlot in character.getGenericParts():
		updatePartFromCharacter(bodypartSlot)

func updatePartFromCharacter(bodypartSlot:String):
	var part:GenericPart = getChar().getGenericPart(bodypartSlot)
	if(part == null):
		if(parts.has(bodypartSlot)):
			parts[bodypartSlot].queue_free()
			parts.erase(bodypartSlot)
		return
		
	var dollScene := part.createScene()
	if(dollScene == null):
		return
	
	parts[bodypartSlot] = dollScene
	add_child(dollScene)
	
	if(dollScene is DollPart):
		var partOptions:Dictionary = part.getOptions()
		for optionID in partOptions:
			dollScene.applyOption(optionID, part.getOptionValue(optionID))

func setupAttachPoint(attachPoint):
	var attachPointName:String = attachPoint.pointName
	
	assert(!attachPoints.has(attachPointName), "TRYING TO ADD AN ATTACH POINT WITH THE EXISTING NAME "+str(attachPointName))
	
	attachPoints[attachPointName] = attachPoint

func removeAttachPoint(attachPoint):
	var attachPointName:String = attachPoint.pointName
	
	assert(attachPoints.has(attachPointName), "TRYING TO REMOVE AN ATTACH POINT THAT WAS NEVER ADDED "+str(attachPointName))
	assert(attachPoints[attachPointName] == attachPoint, "TRYING TO REMOVE A WRONG ATTACH POINT")
	
	attachPoints.erase(attachPointName)

func getAttachPoint(pointName:String) -> DollAttachPoint:
	if(!attachPoints.has(pointName)):
		return null
	return attachPoints[pointName]
