extends RefCounted
class_name RefWithOptions

var savedOptions:Dictionary = {}
var cachedOptions:Dictionary = {}

signal onOptionChanged(optionID, newValue)
signal onOptionsCacheRecalculated(part)
signal onUpdatePartTags

func _init():
	cachedOptions = getOptions()

func tellOnUpdatePartTags():
	emit_signal("onUpdatePartTags")

func resetOptionsToDefault():
	var theOptions = getOptions()
	
	for optionKey in theOptions:
		savedOptions[optionKey] = theOptions[optionKey]["default"]

func getOptions() -> Dictionary:
	return {
	}

func recalculateOptionsCache():
	cachedOptions = getOptions()
	emit_signal("onOptionsCacheRecalculated", self)
	#if(getCharacter() != null):
	#	getCharacter().onPartOptionsRecalculated(self)

func getOptionValue(valueID: String, defaultValue = null):
	if(savedOptions.has(valueID)):
		return savedOptions[valueID]
	
	if(cachedOptions.has(valueID) && cachedOptions[valueID].has("default")):
		return cachedOptions[valueID]["default"]
	
	return defaultValue

func setOptionValue(valueID: String, value):
	if(!cachedOptions.has(valueID)):
		return
	
	if(savedOptions.has(valueID) && !((value is Array) || value is Dictionary) && savedOptions[valueID] == value):
		return
	var currentValue = getOptionValue(valueID)
	savedOptions[valueID] = value
	emit_signal("onOptionChanged", valueID, value)
	checkOptionChanged(valueID, currentValue, value)

func checkOptionChanged(_valueID, _oldValue, _newValue):
	pass

func getGroupInfo(_groupID:String) -> Dictionary:
	return {name = _groupID}

func applyEverythingToPart(thePart:GenericPart):
	thePart.partRef = weakref(self)
	applyOptionsToPart(thePart)
	#dollPart.applyBaseSkinData(getBaseSkinData())

func applyOptionsToPart(thePart:GenericPart):
	var theOptions = getOptions()
	
	for optionID in theOptions:
		thePart.applyOption(optionID, getOptionValue(optionID))

func getPartTags() -> Dictionary:
	return {}

func supportsUniqueBaseSkinData() -> bool:
	return false

func getBodypartSlots():
	return {
	}
