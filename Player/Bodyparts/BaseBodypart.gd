extends RefWithOptions
class_name BaseBodypart

var id:String = "error"
var bodypartType = BodypartType.Generic

var bodyparts:Dictionary = {}
var extraParts:Array = []

var rootRef: WeakRef
var parentPart: WeakRef

var baseSkinDataOverride:BaseSkinData = null

signal onBodypartChanged(ourBodypart, slot, newBodypart)
signal onBodypartRemoved(ourBodypart, slot, newBodypart)
signal onBaseSkinDataOverrideChanged(part, newSkinData)
signal onExtraPartAdded(ourBodypart, extraPart)
signal onExtraPartRemoved(ourBodypart, extraPart)

func _init():
	super._init()
	var _justForCache = getMeshScene()

func getVisibleName():
	return "ERROR"

func getCharacter() -> BaseCharacter:
	if(rootRef == null):
		return null
	return rootRef.get_ref()

func getParentBodypart() -> BaseBodypart:
	if(parentPart == null):
		return null
	return parentPart.get_ref()




func addExtraPart(extraPart: BodypartExtra) -> BodypartExtra:
	assert(extraPart.parentPart == null)
	assert(extraPart.rootRef == null)
	
	extraParts.append(extraPart)
	extraPart.rootRef = rootRef
	extraPart.parentPart = weakref(self)
	getCharacter().tellExtraAdded(self, extraPart)
	emit_signal("onExtraPartAdded", self, extraPart)
	return extraPart

func removeExtraPart(extraPart: BodypartExtra) -> bool:
	assert(extraPart.getParentBodypart() == self)
	if(extraPart.getParentBodypart() != self):
		return false
	
	extraParts.erase(extraPart)
	getCharacter().tellExtraRemoved(self, extraPart)
	emit_signal("onExtraPartRemoved", self, extraPart)
	return true

func getExtraParts() -> Array:
	return extraParts

# Cache this somehow?
func getBodypartPath() -> Array:
	var result = []
	
	var theParent:BaseBodypart = getParentBodypart()
	var currentPart = self
	while(theParent != null):
		result.insert(0, theParent.getSlotOfPart(currentPart))
		currentPart = theParent
		theParent = theParent.getParentBodypart()
		
	return result

func recalculateOptionsCache():
	super.recalculateOptionsCache()
	if(getCharacter() != null):
		getCharacter().onPartOptionsRecalculated(self)

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
	emit_signal("onBodypartRemoved", self, slot, removedBodypart)
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
	
func applyEverythingToPart(dollPart:GenericPart):
	super.applyEverythingToPart(dollPart)
	if(dollPart is DollPart):
		dollPart.applyBaseSkinData(getBaseSkinData())

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
