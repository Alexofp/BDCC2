extends RefCounted
class_name BaseBodypart

var id:String = "error"
var bodypartType = BodypartType.Generic

var savedOptions:Dictionary = {}
var savedSkinOptions:Dictionary = {}
var cachedOptions:Dictionary = {}
var cachedSkinOptions:Dictionary = {}
var bodyparts:Dictionary = {}

var rootRef: WeakRef
var parentPart: WeakRef

var baseSkinDataOverride:BaseSkinData = null

signal onOptionChanged(optionID, newValue)
signal onSkinOptionChanged(optionID, newValue)
signal onBodypartChanged(ourBodypart, slot, newBodypart)
signal onBodypartRemoved(ourBodypart, slot, removedBodypart)
signal onBaseSkinDataOverrideChanged(part, newSkinData)

func _init():
	cachedOptions = getOptions()
	cachedSkinOptions = getSkinOptions()

func getVisibleName():
	return "ERROR"

func resetOptionsToDefault():
	var theOptions = getOptions()
	
	for optionKey in theOptions:
		savedOptions[optionKey] = theOptions[optionKey]["default"]

func getCharacter() -> BaseCharacter:
	if(rootRef == null):
		return null
	return rootRef.get_ref()

func getParentBodypart() -> BaseBodypart:
	if(parentPart == null):
		return null
	return parentPart.get_ref()

func getOptions() -> Dictionary:
	return {
	}

func recalculateOptionsCache():
	cachedOptions = getOptions()
	cachedSkinOptions = getSkinOptions()

func getOptionValue(valueID: String, defaultValue = null):
	if(savedOptions.has(valueID)):
		return savedOptions[valueID]
	
	if(cachedOptions.has(valueID) && cachedOptions[valueID].has("default")):
		return cachedOptions[valueID]["default"]
	
	return defaultValue

func setOptionValue(valueID: String, value):
	if(!cachedOptions.has(valueID)):
		return
	
	if(savedOptions.has(valueID) && savedOptions[valueID] == value):
		return
	savedOptions[valueID] = value
	emit_signal("onOptionChanged", valueID, value)

func getMeshScene() -> PackedScene:
	return null

func getBodypart(slot:String) -> BaseBodypart:
	if(!bodyparts.has(slot)):
		return null
	return bodyparts[slot]

func getBodyparts() -> Dictionary:
	return bodyparts

func setBodypart(slot:String, bodypart: BaseBodypart) -> BaseBodypart:
	bodyparts[slot] = bodypart
	bodypart.rootRef = rootRef
	bodypart.parentPart = weakref(self)
	getCharacter().tellBodypartAdded(self, slot, bodypart)
	emit_signal("onBodypartChanged", self, slot, bodypart)
	return bodypart

func hasBodypart(slot: String) -> bool:
	if(!bodyparts.has(slot) || bodyparts[slot] == null):
		return false
	
	return true

func removeBodypart(slot:String) -> bool:
	if(!bodyparts.has(slot) || bodyparts[slot] == null):
		return false
	
	var removedBodypart:BaseBodypart = bodyparts[slot]
	
	for bodypartSlot in removedBodypart.getBodyparts():
		if(!removedBodypart.hasBodypart(bodypartSlot)):
			removedBodypart.removeBodypart(bodypartSlot)
	
	bodyparts.erase(slot)
	getCharacter().tellBodypartRemoved(self, slot, removedBodypart)
	return true

func getSlotOfPart(childpart: BaseBodypart):
	for slot in bodyparts:
		if(bodyparts[slot] == childpart):
			return slot
	return null

func getBodypartType() -> String:
	return bodypartType

func getBodypartSlots():
	return {
	}

func applyEverythingToDollPart(dollPart:DollPart):
	applyOptionsToDollPart(dollPart)
	dollPart.applyBaseSkinData(getBaseSkinData())

func applyOptionsToDollPart(dollPart:DollPart):
	var theOptions = getOptions()
	
	for optionID in theOptions:
		dollPart.applyOption(optionID, getOptionValue(optionID))

func supportsUniqueBaseSkinData() -> bool:
	return true

func getBaseSkinData() -> BaseSkinData:
	if(baseSkinDataOverride != null):
		return baseSkinDataOverride
	
	var theChar = getCharacter()
	if(theChar == null):
		return null
	
	return theChar.getBaseSkinData()

func setBaseSkinDataOverride(newData:BaseSkinData):
	baseSkinDataOverride = newData
	emit_signal("onBaseSkinDataOverrideChanged", self, getBaseSkinData())

func getSkinOptions() -> Dictionary:
	return {
		
	}

func getSkinOptionValue(valueID: String, defaultValue = null):
	if(savedSkinOptions.has(valueID)):
		return savedSkinOptions[valueID]
	
	if(cachedSkinOptions.has(valueID) && cachedSkinOptions[valueID].has("default")):
		return cachedSkinOptions[valueID]["default"]
	
	return defaultValue

func setSkinOptionValue(valueID: String, value):
	if(!cachedSkinOptions.has(valueID)):
		return
	
	if(savedSkinOptions.has(valueID) && savedSkinOptions[valueID] == value):
		return
	savedSkinOptions[valueID] = value
	emit_signal("onSkinOptionChanged", valueID, value)
