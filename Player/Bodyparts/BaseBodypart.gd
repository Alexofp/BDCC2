extends RefCounted
class_name BaseBodypart

var id:String = "error"
var savedOptions:Dictionary = {}
var cachedOptions:Dictionary = {}

signal onOptionChanged(optionID, newValue)

func _init():
	cachedOptions = getOptions()

func resetOptionsToDefault():
	var theOptions = getOptions()
	
	for optionKey in theOptions:
		savedOptions[optionKey] = theOptions[optionKey]["default"]

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
