extends RefCounted
class_name BaseCharacter

var id:String = ""
var bodyparts:Dictionary = {}
var skinTypes:Dictionary = {}

signal onBodypartChange(slot, newpart)
signal onBodypartOptionChange(slot, optionID, newvalue)
signal onGenericPartChange(genericType, id, newpart)
signal onGenericPartOptionChange(genericType, id, optionID, newvalue)
signal onBodypartSkinTypeChange(slot, skinType, skinTypeData)
signal onBodypartSkinTypeOverrideSwitch(slot)
signal onBaseSkinTypeChange(skinType, skinTypeData)

const GENERIC_BODYPARTS = "body"
const GENERIC_CLOTHING = "clo"

func getID() -> String:
	return id

func _init():
	var body:BodypartBodyBase = load("res://Game/Character/Bodyparts/Body/FeminineBody.gd").new()
	addBodypart(BodypartSlot.Body, body)
	
	addBodypart(BodypartSlot.Head, load("res://Game/Character/Bodyparts/Head/HumanFeminineHead.gd").new())
	addBodypart(BodypartSlot.Hair, load("res://Game/Character/Bodyparts/Hair/Ponytail1.gd").new())
	
	#body.setOptionValue("thickness", 2.0)
	#body.setOptionValue("thickness", 0.0)

func addBodypart(slot:String, part:BodypartBase):
	if(part == null):
		clearBodypart(slot)
		return
	if(!part.supportsSlot(slot)):
		Log.error("Trying to add a bodypart that doesn't support the selected slot!")
		return
	if(bodyparts.has(slot)):
		clearBodypart(slot)
	bodyparts[slot] = part
	part.currentSlot = slot
	part.onOptionChanged.connect(onBodypartOptionChangeCallback.bind(part, slot))
	part.setCharacter(self)
	checkSkinTypesList()
	onBodypartChange.emit(slot, part)
	onGenericPartChange.emit(GENERIC_BODYPARTS, slot, part)

func clearBodypart(slot:String):
	if(!bodyparts.has(slot)):
		return
	var part:BodypartBase = bodyparts[slot]
	part.currentSlot = ""
	part.onOptionChanged.disconnect(onBodypartOptionChangeCallback.bind(part, slot))
	part.setCharacter(null)
	bodyparts.erase(slot)
	checkSkinTypesList()
	onBodypartChange.emit(slot, null)
	onGenericPartChange.emit(GENERIC_BODYPARTS, slot, null)

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
	onGenericPartOptionChange.emit(GENERIC_BODYPARTS, slot, optionID, value)

func getGenericParts() -> Dictionary:
	var result:Dictionary = {}
	
	var bodypartResult:Dictionary = {}
	for bodypartSlot in bodyparts:
		bodypartResult[bodypartSlot] = bodyparts[bodypartSlot]
	result[GENERIC_BODYPARTS] = bodypartResult
	
	# Implement clothing
	result[GENERIC_CLOTHING] = {}
	return result

func getGenericPart(_genericType:String, _id:String) -> GenericPart:
	if(_genericType == GENERIC_BODYPARTS):
		return getBodypart(_id)
	if(_genericType == GENERIC_CLOTHING):
		assert(false, "IMPLEMENT ME")
	return null

#func addBodypart(slot:String, part:BodypartBase):
func addGenericPart(_genericType:String, slot:String, part:GenericPart):
	if(_genericType == GENERIC_BODYPARTS):
		addBodypart(slot, part)
		return
	if(_genericType == GENERIC_CLOTHING):
		assert(false, "IMPLEMENT ME")
		return
	Log.Printerr("Trying to add a generic part of unknown type: "+str(_genericType))

func removeGenericPart(_genericType:String, slot:String):
	if(_genericType == GENERIC_BODYPARTS):
		clearBodypart(slot)
		return
	if(_genericType == GENERIC_CLOTHING):
		assert(false, "IMPLEMENT ME")
		return
	Log.Printerr("Trying to remove a generic part of unknown type: "+str(_genericType))

## Gathers the dictionary of all currently used skin types, {skinType1 = true, skinType2 = true}
func calculateAllUsedSkinTypes() -> Dictionary:
	var result:Dictionary = {}
	
	for bodypartSlot in bodyparts:
		var theBodypart:BodypartBase = bodyparts[bodypartSlot]
		
		var theSkinType:String = theBodypart.getSkinType()
		if(theSkinType != "" && !result.has(theSkinType)):
			result[theSkinType] = true
	return result

## Gathers the list of all currently used skin types and then makes sure all skin types have an entry in our base skin types dictionary.
## For example, adds fur skin type data if we add cat ears to a human.
## Will also automatically remove any skin types that aren't in use.
func checkSkinTypesList():
	var whatWeShouldHave:Dictionary = calculateAllUsedSkinTypes()
	
	# This breaks in multiplayer
	#for ourSkinType in skinTypes.keys():
		#if(!whatWeShouldHave.has(ourSkinType)):
			#skinTypes.erase(ourSkinType)
			#onBaseSkinTypeChange.emit(ourSkinType, null)
		
	for newSkinType in whatWeShouldHave:
		if(skinTypes.has(newSkinType)):
			continue
		
		var newSkinTypeData:SkinTypeData = SkinTypeData.new()
		newSkinTypeData.skinType = newSkinType
		skinTypes[newSkinType] = newSkinTypeData
		onBaseSkinTypeChange.emit(newSkinType, newSkinTypeData)

func getAllUsedSkinTypes() -> Dictionary:
	return skinTypes

func getBaseSkinTypeData(skinType:String, createIfNoExists:bool = true) -> SkinTypeData:
	if(!skinTypes.has(skinType)):
		if(createIfNoExists):
			checkSkinTypesList()
			return skinTypes[skinType]
		return null
	return skinTypes[skinType]

func setBaseSkinTypeData(theSkinType:String, skinTypeData:SkinTypeData):
	if(skinTypeData == null):
		if(skinTypes.has(theSkinType)):
			skinTypes.erase(theSkinType)
			triggerUpdateAllSkinTypes() # Maybe change this
		return
	skinTypes[theSkinType] = skinTypeData
	onBaseSkinTypeChange.emit(skinTypeData.skinType, skinTypeData)
	triggerUpdateAllSkinTypes() # Maybe change this

func getBaseSkinTypeDatas() -> Dictionary:
	return skinTypes

## Main method for setting the skin type of a bodypart. Will throw an error if you try to pass in an unsupported skin type
func setSkinTypeForSlot(bodypartSlot:String, newSkinType:String):
	if(!hasBodypart(bodypartSlot)):
		return
	var theBodypart:BodypartBase = bodyparts[bodypartSlot]
	if(!theBodypart.supportsSkinTypes()):
		return
	var supportedSkinTypes:Dictionary = theBodypart.getSupportedSkinTypes()
	if(!supportedSkinTypes.has(newSkinType) || !supportedSkinTypes[newSkinType]):
		Log.Printerr("Trying to assign an unsupported skin type '"+str(newSkinType)+"' to a '"+str(theBodypart.id)+"'")
		return
	var oldSkinType:String = theBodypart.skinType
	theBodypart.skinType = newSkinType
	if(theBodypart.skinDataOverride != null):
		theBodypart.skinDataOverride.skinType = newSkinType
	# Could call updateSkinForSlot() but this is faster
	onBodypartSkinTypeChange.emit(bodypartSlot, theBodypart.getSkinType(), theBodypart.getSkinTypeData())
	if(oldSkinType != theBodypart.skinType):
		onBodypartSkinTypeOverrideSwitch.emit(bodypartSlot)

## Main method for setting the skin data of a bodypart. If you pass null data, the base data will be used
func setSkinTypeDataForSlot(bodypartSlot:String, newSkinData:SkinTypeData):
	if(!hasBodypart(bodypartSlot)):
		return
	var theBodypart:BodypartBase = bodyparts[bodypartSlot]
	if(!theBodypart.supportsSkinTypes()):
		return
	var hadOverrideBefore:bool = (theBodypart.skinDataOverride != null)
	var haveOverrideNow:bool = (newSkinData != null)
	var oldSkinType:String = theBodypart.skinType
	theBodypart.skinDataOverride = newSkinData
	theBodypart.skinType = newSkinData.skinType if newSkinData else theBodypart.skinType
	# Could call updateSkinForSlot() but this is faster
	onBodypartSkinTypeChange.emit(bodypartSlot, theBodypart.getSkinType(), theBodypart.getSkinTypeData())
	if(hadOverrideBefore != haveOverrideNow || oldSkinType != theBodypart.skinType):
		onBodypartSkinTypeOverrideSwitch.emit(bodypartSlot)
	
func updateSkinForSlot(bodypartSlot:String):
	if(!hasBodypart(bodypartSlot)):
		return
	var theBodypart:BodypartBase = bodyparts[bodypartSlot]
	if(!theBodypart.supportsSkinTypes()):
		return
	var theSkinData:SkinTypeData = theBodypart.getSkinTypeData()
	if(theSkinData == null):
		return
	onBodypartSkinTypeChange.emit(bodypartSlot, theBodypart.getSkinType(), theSkinData)

func updateAllSkinTypes():
	checkSkinTypesList()
	for bodypartSlot in bodyparts:
		updateSkinForSlot(bodypartSlot)

var isUpdatingAllSkinTypes:bool = false
## Same as updateAllSkinTypes() but this has a built-in auto-debouncing.
## This means, it will only actually update every 0.2 seconds
func triggerUpdateAllSkinTypes():
	checkSkinTypesList()
	if(isUpdatingAllSkinTypes):
		return
	isUpdatingAllSkinTypes = true
	#await OPTIONS.get_tree().create_timer(0.2).timeout 
	updateAllSkinTypes()
	isUpdatingAllSkinTypes = false
	
func clearBodyparts():
	for bodypartSlot in bodyparts.keys():
		clearBodypart(bodypartSlot)
	
func saveNetworkData() -> Dictionary:
	var skinTypesData:Dictionary = {}
	for skinType in skinTypes:
		skinTypesData[skinType] = skinTypes[skinType].saveNetworkData()
	
	var bodypartsData:Dictionary = {}
	for bodypartSlot in bodyparts:
		var theBodypart:BodypartBase = bodyparts[bodypartSlot]
		bodypartsData[bodypartSlot] = {
			id = theBodypart.id,
			data = theBodypart.saveNetworkData(),
		}
	
	return {
		skinTypes = skinTypesData,
		bodyparts = bodypartsData,
	}

func loadNetworkData(_data:Dictionary):
	if(_data.has("skinTypes")):
		skinTypes.clear()
		var skinTypesData:Dictionary = SAVE.loadVar(_data, "skinTypes", {})
		for skinType in skinTypesData:
			var newSkinType:SkinTypeData = SkinTypeData.new()
			newSkinType.loadNetworkData(SAVE.loadVar(skinTypesData, skinType, {}))
			setBaseSkinTypeData(skinType, newSkinType)
			#skinTypes[skinType] = newSkinType
		
		triggerUpdateAllSkinTypes()
	
	if(_data.has("bodyparts")):
		clearBodyparts()
		
		var bodypartsData:Dictionary = SAVE.loadVar(_data, "bodyparts", {})
		for bodypartSlot in bodypartsData:
			var bodypartData:Dictionary = SAVE.loadVar(bodypartsData, bodypartSlot, {})
			var bodypartID:String = SAVE.loadVar(bodypartData, "id", "")
			if(bodypartID == ""):
				Log.Printerr("Empty bodypart ID received in BaseCharacter.loadNetworkData")
				continue
			var theBodypart:BodypartBase = GlobalRegistry.createBodypart(bodypartID)
			if(!theBodypart):
				Log.Printerr("Bad bodypart id in BaseCharacter.loadNetworkData, id='"+str(bodypartID)+"'")
				continue
			theBodypart.loadNetworkData(SAVE.loadVar(bodypartData, "data", {}))
			addBodypart(bodypartSlot, theBodypart)
