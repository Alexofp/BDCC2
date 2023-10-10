extends RefCounted
class_name BaseBodypart

var id:String = "error"
var savedOptions:Dictionary = {}
var cachedOptions:Dictionary = {}
var bodyparts:Dictionary = {}

var rootRef: WeakRef

signal onOptionChanged(optionID, newValue)
signal onBodypartChanged(ourBodypart, slot, newBodypart)

func _init():
	cachedOptions = getOptions()

func resetOptionsToDefault():
	var theOptions = getOptions()
	
	for optionKey in theOptions:
		savedOptions[optionKey] = theOptions[optionKey]["default"]

func getCharacter() -> BaseCharacter:
	if(rootRef == null):
		return null
	return rootRef.get_ref()

func getOptions() -> Dictionary:
	return {
	}

func getOptionValue(valueID: String):
	if(savedOptions.has(valueID)):
		return savedOptions[valueID]
	
	if(cachedOptions.has(valueID) && cachedOptions[valueID].has("default")):
		return cachedOptions[valueID]["default"]
	
	return null

func setOptionValue(valueID: String, value):
	if(!cachedOptions.has(valueID)):
		return
	
	if(savedOptions.has(valueID) && savedOptions[valueID] == value):
		return
	savedOptions[valueID] = value
	emit_signal("onOptionChanged", valueID, value)

func getMeshScene() -> PackedScene:
	return null

func getBodypart(slot:String):
	if(!bodyparts.has(slot)):
		return null
	return bodyparts[slot]

func getBodyparts() -> Dictionary:
	return bodyparts

func setBodypart(slot:String, bodypart: BaseBodypart) -> BaseBodypart:
	bodyparts[slot] = bodypart
	bodypart.rootRef = rootRef
	getCharacter().onBodypartChange(self, slot, bodypart)
	emit_signal("onBodypartChanged", self, slot, bodypart)
	return bodypart

func getBodypartSlots():
	return {
	}
