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
signal onOptionsCacheRecalculated(part)

func _init():
	cachedOptions = getOptions()
	cachedSkinOptions = getSkinOptions()
	var _justForCache = getMeshScene()

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
	emit_signal("onOptionsCacheRecalculated", self)
	if(getCharacter() != null):
		getCharacter().onPartOptionsRecalculated(self)

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

func getMeshPath() -> String:
	return "res://Mesh/Parts/Body/FeminineBody/feminine_body.tscn"

func getMeshScene() -> PackedScene:
	return GlobalRegistry.loadSceneCached(getMeshPath())

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
	dollPart.partRef = weakref(self)
	applyOptionsToDollPart(dollPart)
	dollPart.applyBaseSkinData(getBaseSkinData())
	applySkinOptionsToDollPart(dollPart)

func applyOptionsToDollPart(dollPart:DollPart):
	var theOptions = getOptions()
	
	for optionID in theOptions:
		dollPart.applyOption(optionID, getOptionValue(optionID))

func applySkinOptionsToDollPart(dollPart:DollPart):
	var theOptions = getSkinOptions()
	
	for optionID in theOptions:
		dollPart.applySkinOption(optionID, getSkinOptionValue(optionID))

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
	var currentValue = getSkinOptionValue(valueID)
	savedSkinOptions[valueID] = value
	emit_signal("onSkinOptionChanged", valueID, value)
	checkSkinOptionChanged(valueID, currentValue, value)

func checkSkinOptionChanged(_valueID, _oldValue, _newValue):
	pass

func getTextureVariantsByTypeAndSubType(textureType:String, textureSubType:String, includeTexturePaths:bool=true) -> Array:
	var result = []
	
	var textureVariantIDs = GlobalRegistry.getTextureVariants(textureType, textureSubType).keys()
	for textureVariantID in textureVariantIDs:
		var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(textureType, textureSubType, textureVariantID)
		if(includeTexturePaths):
			result.append([textureVariantID, textureVariant.getVisibleName(), textureVariant.getPreviewTexturePath()])
		else:
			result.append([textureVariantID, textureVariant.getVisibleName()])
		
	return result

func getGroupInfo(_groupID:String) -> Dictionary:
	return {name = _groupID}
