extends RefCounted
class_name BaseCharacter

var bodyparts:Dictionary = {}

signal onBodypartChange(slot, newpart)
signal onBodypartOptionChange(slot, optionID, newvalue)
signal onGenericPartChange(id, newpart)
signal onGenericPartOptionChange(id, optionID, newvalue)

func _init():
	var body:BodypartBodyBase = load("res://Game/Character/Bodyparts/Body/FeminineBody.gd").new()
	addBodypart(BodypartSlot.Body, body)
	
	#body.setOptionValue("thickness", 2.0)
	#body.setOptionValue("thickness", 0.0)

func addBodypart(slot:String, part:BodypartBase):
	if(!part.supportsSlot(slot)):
		Log.error("Trying to add a bodypart that doesn't support the selected slot!")
		return
	bodyparts[slot] = part
	part.onOptionChanged.connect(onBodypartOptionChangeCallback.bind(part, slot))
	onBodypartChange.emit(slot, part)
	onGenericPartChange.emit("body:"+slot, part)

func clearBodypart(slot:String):
	if(!bodyparts.has(slot)):
		return
	var part:BodypartBase = bodyparts[slot]
	part.onOptionChanged.disconnect(onBodypartOptionChangeCallback.bind(part, slot))
	bodyparts.erase(slot)
	onBodypartChange.emit(slot, null)
	onGenericPartChange.emit("body:"+slot, null)

func getBodypart(slot:String) -> BodypartBase:
	if(!bodyparts.has(slot)):
		return null
	return bodyparts[slot]

func hasBodypart(slot:String) -> bool:
	return bodyparts.has(slot)

func getBodyparts() -> Dictionary:
	return bodyparts

func onBodypartOptionChangeCallback(optionID:String, value, _part:BodypartBase, slot:String):
	onBodypartOptionChange.emit(slot, optionID, value)
	onGenericPartOptionChange.emit("body:"+slot, optionID, value)

func getGenericParts() -> Dictionary:
	var result:Dictionary = {}
	for bodypartSlot in bodyparts:
		result["body:"+bodypartSlot] = bodyparts[bodypartSlot]
	return result

func getGenericPart(_id:String) -> GenericPart:
	if(_id.begins_with("body:")):
		return getBodypart(_id.split(":", true, 2)[1])
	return null
