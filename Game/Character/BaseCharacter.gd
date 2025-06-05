extends RefCounted
class_name BaseCharacter

var id:String = ""
var bodyparts:Dictionary[int, BodypartBase] = {}
var skinTypes:Dictionary = {}

var charName:String = "New character"
var gender:GenderPronounsProfile = GenderPronounsProfile.new()
var species:SpeciesProfile = SpeciesProfile.new()
var thickness:float = 1.0
var weightDistribution:float = 0.0
var muscles:float = 0.0
var voice:VoiceProfile = VoiceProfile.new()
var inventory:Inventory = Inventory.new()
var walkAnim:String = Doll.WALK_UNISEX
var idleAnim:String = Doll.IDLE_NORMAL1
var idlePose:String = ""
var poseArms:String = ""

var charState:CharState = CharState.new()
var fluids:FluidsOnBodyProfile = FluidsOnBodyProfile.new()

signal onBodypartChange(slot, newpart)
signal onBodypartOptionChange(slot, optionID, newvalue)
signal onGenericPartChange(genericType, id, newpart)
signal onGenericPartOptionChange(genericType, id, optionID, newvalue)
signal onBodypartSkinTypeChange(slot, skinType, skinTypeData)
signal onBodypartSkinTypeOverrideSwitch(slot)
signal onBaseSkinTypeChange(skinType, skinTypeData)
signal onCharOptionChange(changeID)
signal onEquippedItemChange(slot, newItem)
signal onPartFilterChange

const GENERIC_BODYPARTS = 0
const GENERIC_CLOTHING = 1

func getID() -> String:
	return id

func _init():
	inventory.onEquippedItemChange.connect(onInventoryEquipItemChange)
	inventory.onEquippedItemOptionChange.connect(onInventoryEquipItemOptionChangeCallback)
	inventory.setCharacter(self)
	
	#inventory.setEquippedItem(InventorySlot.Eyes, GlobalRegistry.createItem("Blindfold"))
	
	charState.setCharacter(self)
	
	var body:BodypartBodyBase = load("res://Game/Character/Bodyparts/Body/FeminineBody.gd").new()
	addBodypart(BodypartSlot.Body, body)
	
	addBodypart(BodypartSlot.Head, load("res://Game/Character/Bodyparts/Head/HumanFeminineHead.gd").new())
	addBodypart(BodypartSlot.Hair, load("res://Game/Character/Bodyparts/Hair/Ponytail1.gd").new())
	
	#body.setOptionValue("thickness", 2.0)
	#body.setOptionValue("thickness", 0.0)
	pass

func onInventoryEquipItemChange(_slot:int, _item:ItemBase):
	updatePartFilter()
	onEquippedItemChange.emit(_slot, _item)
	onGenericPartChange.emit(GENERIC_CLOTHING, _slot, _item)

func onInventoryEquipItemOptionChangeCallback(optionID:String, value, _part:ItemBase, slot:int):
	onGenericPartOptionChange.emit(GENERIC_CLOTHING, slot, optionID, value)

func addBodypart(slot:int, part:BodypartBase):
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

func clearBodypart(slot:int):
	if(!bodyparts.has(slot)):
		return
	var part:BodypartBase = bodyparts[slot]
	part.currentSlot = -1
	part.onOptionChanged.disconnect(onBodypartOptionChangeCallback.bind(part, slot))
	part.setCharacter(null)
	bodyparts.erase(slot)
	checkSkinTypesList()
	onBodypartChange.emit(slot, null)
	onGenericPartChange.emit(GENERIC_BODYPARTS, slot, null)

func getBodypart(slot:int) -> BodypartBase:
	if(!bodyparts.has(slot)):
		return null
	return bodyparts[slot]

func hasBodypart(slot:int) -> bool:
	return bodyparts.has(slot)

func getBodyparts() -> Dictionary[int, BodypartBase]:
	return bodyparts

func onBodypartOptionChangeCallback(optionID:String, value, _part:BodypartBase, slot:int):
	onBodypartOptionChange.emit(slot, optionID, value)
	onGenericPartOptionChange.emit(GENERIC_BODYPARTS, slot, optionID, value)

func getGenericParts() -> Dictionary:
	var result:Dictionary = {}
	
	var bodypartResult:Dictionary = {}
	for bodypartSlot in bodyparts:
		bodypartResult[bodypartSlot] = bodyparts[bodypartSlot]
	result[GENERIC_BODYPARTS] = bodypartResult
	
	var itemResult:Dictionary = {}
	for invSlot in inventory.getEquippedItems():
		itemResult[invSlot] = inventory.getEquippedItem(invSlot)
	result[GENERIC_CLOTHING] = itemResult
	return result

func getGenericPart(_genericType:int, _id:int) -> GenericPart:
	if(_genericType == GENERIC_BODYPARTS):
		return getBodypart(_id)
	if(_genericType == GENERIC_CLOTHING):
		return inventory.getEquippedItem(_id)
	return null

#func addBodypart(slot:String, part:BodypartBase):
func addGenericPart(_genericType:int, slot:int, part:GenericPart):
	if(_genericType == GENERIC_BODYPARTS):
		addBodypart(slot, part)
		return
	if(_genericType == GENERIC_CLOTHING):
		inventory.setEquippedItem(slot, part)
		return
	Log.Printerr("Trying to add a generic part of unknown type: "+str(_genericType))

func removeGenericPart(_genericType:int, slot:int):
	if(_genericType == GENERIC_BODYPARTS):
		clearBodypart(slot)
		return
	if(_genericType == GENERIC_CLOTHING):
		inventory.removeEquippedItem(slot)
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
func setSkinTypeForSlot(bodypartSlot:int, newSkinType:String):
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
func setSkinTypeDataForSlot(bodypartSlot:int, newSkinData:SkinTypeData):
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
	
func updateSkinForSlot(bodypartSlot:int):
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
	
func getGenderProfile() -> GenderPronounsProfile:
	return gender

func getGenderName() -> String:
	return gender.getGenderName()

func getName() -> String:
	return charName

func getSexVoiceID() -> String:
	return voice.getSexVoiceID()

func getSexVoice() -> SexVoiceBase:
	return voice.getSexVoice()

func getVoiceProfile() -> VoiceProfile:
	return voice

func getCharOptionsFinalWithValues() -> Dictionary:
	return getCharOptions()

func getCharOptions() -> Dictionary:
	return {
		CharOption.name: {
			name = "Name",
			type = "stringWindow",
			value = charName,
			charNameFilter = true,
		},
		CharOption.gender: {
			name = "Gender",
			type = "genderProfile",
			value = gender.saveData(),
		},
		CharOption.species: {
			name = "Species",
			type = "speciesProfile",
			value = species.saveData(),
		},
		CharOption.thickness: {
			name = "Thickness",
			type = "slider",
			min = 0.0,
			max = 2.0,
			value = thickness,
		},
		CharOption.weightDistribution: {
			name = "Weight distribution",
			type = "slider",
			min = 0.0,
			max = 1.0,
			value = weightDistribution,
		},
		CharOption.muscles: {
			name = "Muscles",
			type = "slider",
			min = 0.0,
			max = 1.0,
			value = muscles,
		},
		CharOption.voice: {
			name = "Voice",
			type = "sexVoice",
			value = voice.saveData(),
		},
		CharOption.idleAnim: {
			name = "Idle style",
			type = "selector",
			value = idleAnim,
			values = Doll.IDLE_PICKABLE_ANIMS,
			editors = [GenericPart.EDITOR_PART, GenericPart.EDITOR_INTERACT],
		},
		CharOption.walkAnim: {
			name = "Walk style",
			type = "selector",
			value = walkAnim,
			values = Doll.WALK_PICKABLE_ANIMS,
			editors = [GenericPart.EDITOR_PART, GenericPart.EDITOR_INTERACT],
		},
		"bodyMess": {
			name = "Body mess",
			type = "bodyMess",
			value = fluids.saveData(),
			editors = [GenericPart.EDITOR_INTERACT],
		},
	}

func getSyncOptions() -> Array[String]:
	return [
		CharOption.name,
		CharOption.gender,
		CharOption.species,
		CharOption.thickness,
		CharOption.weightDistribution,
		CharOption.muscles,
		CharOption.voice,
		CharOption.idleAnim,
		CharOption.walkAnim,
		CharOption.idlePose,
		CharOption.poseArms,
		"bodyMess",
	]

func getSyncOptionValue(_id:String):
	if(_id == CharOption.name):
		return charName
	elif(_id == CharOption.gender):
		return gender.saveData()
	elif(_id == CharOption.species):
		return species.saveData()
	elif(_id == CharOption.thickness):
		return thickness
	elif(_id == CharOption.weightDistribution):
		return weightDistribution
	elif(_id == CharOption.muscles):
		return muscles
	elif(_id == CharOption.voice):
		return voice.saveData()
	elif(_id == CharOption.idleAnim):
		return idleAnim
	elif(_id == CharOption.walkAnim):
		return walkAnim
	elif(_id == CharOption.idlePose):
		return idlePose
	elif(_id == CharOption.poseArms):
		return poseArms
	elif(_id == "bodyMess"):
		return fluids.saveData()

func applyCharChange(_id:String, _value):
	if(_id == CharOption.name):
		charName = _value
	elif(_id == CharOption.gender):
		gender.loadData(_value)
	elif(_id == CharOption.species):
		species.loadData(_value)
	elif(_id == CharOption.thickness):
		thickness = _value
	elif(_id == CharOption.weightDistribution):
		weightDistribution = _value
	elif(_id == CharOption.muscles):
		muscles = _value
	elif(_id == CharOption.voice):
		voice.loadData(_value)
	elif(_id == CharOption.idleAnim):
		idleAnim = _value
	elif(_id == CharOption.walkAnim):
		walkAnim = _value
	elif(_id == CharOption.idlePose):
		idlePose = _value
	elif(_id == CharOption.poseArms):
		poseArms = _value
	elif(_id == "bodyMess"):
		fluids.loadData(_value)
		
	onCharOptionChange.emit(_id)

func processTime(_dt:float):
	charState.processTime(_dt)

func getBodyMess() -> FluidsOnBodyProfile:
	return fluids

func getCharState() -> CharState:
	return charState

func addArousal(_howMuch:float):
	charState.addArousal(_howMuch)

func setArousal(_howMuch:float):
	charState.setArousal(_howMuch)

func getArousal() -> float:
	return charState.getArousal()

func resetToBaseEditorState():
	for bodypartSlot in bodyparts.keys():
		removeGenericPart(GENERIC_BODYPARTS, bodypartSlot)
	
	var speciesMain:SpeciesBase = GlobalRegistry.getSpecies(species.getMainSpeciesID())
	
	var bodypartsTemplate:Dictionary = speciesMain.getCharacterCreatorPartsTemplate(gender.getGender())
	
	for bodypartSlot in bodypartsTemplate:
		var bodypartEntry:Dictionary = bodypartsTemplate[bodypartSlot]
		var bodypartID:String = bodypartEntry["id"]
		var bodypartData:Dictionary = bodypartEntry["data"] if bodypartEntry.has("data") else {}
		
		var theBodypart:BodypartBase = GlobalRegistry.createBodypart(bodypartID)
		if(!theBodypart):
			continue
		addBodypart(bodypartSlot, theBodypart)
		if(bodypartEntry.has("skinType")):
			setSkinTypeForSlot(bodypartSlot, bodypartEntry["skinType"])
		
		for optionID in bodypartData:
			theBodypart.setOptionValue(optionID, bodypartData[optionID])

func hasBodypartID(_partID:String) -> bool:
	for bodypartSlot in bodyparts:
		if(bodyparts[bodypartSlot].id == _partID):
			return true
	return false

func getInventory() -> Inventory:
	return inventory

func getWalkAnim() -> String:
	if(idlePose != ""):
		var theDollPose:DollPoseBase = GlobalRegistry.getDollPose(idlePose)
		if(theDollPose):
			if(theDollPose.getWalkAnimName() != ""):
				return idlePose
		
	if(inventory.shouldHobbleLegs()):
		return Doll.WALK_HOBBLED
	return walkAnim
	
func getIdleAnim() -> String:
	return idleAnim

func getWalkSpeed() -> float:
	if(inventory.shouldHobbleLegs()):
		return 0.5
	if(idlePose != ""):
		var theDollPose:DollPoseBase = GlobalRegistry.getDollPose(idlePose)
		if(theDollPose):
			return theDollPose.getWalkSpeedMult()
	return 1.0

func canSprint() -> bool:
	if(inventory.shouldHobbleLegs()):
		return false
	if(idlePose != ""):
		var theDollPose:DollPoseBase = GlobalRegistry.getDollPose(idlePose)
		if(theDollPose):
			if(theDollPose.preventsSprint()):
				return false
	return true
	
func getJumpHeight() -> float:
	if(inventory.shouldHobbleLegs()):
		return 0.5
	return 1.0

func triggerUpdatePartFilter():
	updatePartFilter()

func updatePartFilter():
	var theSex:SexEngine = GM.sexManager.getSexEngineOfCharID(getID())
	var theSexHideTags:Array = theSex.getSexHideTagsFor(getID()) if theSex else []
	
	var shouldEmit:bool = false
	for slot in inventory.getEquippedItems():
		var theItem:ItemBase = inventory.getEquippedItem(slot)
		
		var currentVal:bool = theItem.internalHidePart
		
		var finalVal:bool = false
		var theItemHideTags:Dictionary = theItem.getSexHideTags()
		for theTag in theSexHideTags:
			if(theItemHideTags.has(theTag)):
				finalVal = true
				break
		
		if(finalVal != currentVal):
			shouldEmit = true
		theItem.internalHidePart = finalVal
	if(shouldEmit):
		onPartFilterChange.emit()

func triggerPartFilterChangeSignal():
	onPartFilterChange.emit()

func getIdlePose() -> String:
	return idlePose

func getPoseArms() -> String:
	return poseArms

func saveNetworkData() -> Dictionary:
	var skinTypesData:Dictionary = {}
	for skinType in skinTypes:
		skinTypesData[skinType] = skinTypes[skinType].saveNetworkData()
	
	var bodypartsData:Dictionary = {}
	for bodypartSlot in bodyparts:
		var theBodypart:BodypartBase = bodyparts[bodypartSlot]
		bodypartsData[str(bodypartSlot)] = {
			id = theBodypart.id,
			data = theBodypart.saveNetworkData(),
		}
	
	var charData:Dictionary = {}
	for syncOption in getSyncOptions():
		charData[syncOption] = getSyncOptionValue(syncOption)
	
	return {
		skinTypes = skinTypesData,
		bodyparts = bodypartsData,
		charData = charData,
		charState = charState.saveNetworkedData(),
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
		for bodypartSlotStr in bodypartsData:
			var bodypartData:Dictionary = SAVE.loadVar(bodypartsData, str(bodypartSlotStr), {})
			var bodypartID:String = SAVE.loadVar(bodypartData, "id", "")
			if(bodypartID == ""):
				Log.Printerr("Empty bodypart ID received in BaseCharacter.loadNetworkData")
				continue
			var theBodypart:BodypartBase = GlobalRegistry.createBodypart(bodypartID)
			if(!theBodypart):
				Log.Printerr("Bad bodypart id in BaseCharacter.loadNetworkData, id='"+str(bodypartID)+"'")
				continue
			theBodypart.loadNetworkData(SAVE.loadVar(bodypartData, "data", {}))
			addBodypart(int(bodypartSlotStr), theBodypart)
	
	if(_data.has("charData")):
		var charData:Dictionary = SAVE.loadVar(_data, "charData", {})
		for syncOption in charData:
			applyCharChange(syncOption, charData[syncOption])
	
	if(_data.has("charState")):
		charState.loadNetworkedData(SAVE.loadVar(_data, "charState", {}))
