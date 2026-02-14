extends RefCounted
class_name BaseCharacter

var id:String = ""
var bodyparts:Dictionary[int, BodypartBase] = {}
var skinTypes:SkinTypeProfile = SkinTypeProfile.new()

var charName:String = "New character"
var lastCharName:String = ""
var gender:GenderPronounsProfile = GenderPronounsProfile.new()
var species:SpeciesProfile = SpeciesProfile.new()
var bodySize:float = 0.0
var thickness:float = 1.0 #0 = thin, 2 = thick
var chubbyness:float = 0.0
var buttSize:float = 0.0
var smoothBody:float = 0.0
var muscles:float = 0.0
var pregnantTest:float = 0.0
var voice:VoiceProfile = VoiceProfile.new()
var inventory:Inventory = Inventory.new()
var idleAnim:String = "IdleUnisex"
var walkAnim:String = "WalkUnisex"
var idlePose:String = ""
var poseArms:String = ""
var personality:Personality = Personality.new()
var fetishHolder:FetishHolder = FetishHolder.new()

var charState:CharState = CharState.new()
var fluids:FluidsOnBodyProfile = FluidsOnBodyProfile.new()

signal onChange(change:BaseCharChange)

const GENERIC_BODYPARTS = 0
const GENERIC_CLOTHING = 1

func getID() -> String:
	return id

func deinit():
	inventory.unregister()

func _init():
	inventory.register()
	
	skinTypes.skinTypeChanged.connect(onSkinTypeChanged)
	
	inventory.onEquippedItemChange.connect(onInventoryEquipItemChange)
	inventory.onEquippedItemOptionChange.connect(onInventoryEquipItemOptionChangeCallback)
	inventory.setCharacter(self)
	
	#inventory.setEquippedItem(InventorySlot.Eyes, GlobalRegistry.createItem("Blindfold"))
	
	charState.setCharacter(self)
	
	personality.setChar(self)
	personality.onStatsUpdated.connect(func():
		onChange.emit(BaseCharChange.createPersonalityUpdate())
		)
	fetishHolder.setChar(self)
	fetishHolder.onFetishesUpdated.connect(func():
		onChange.emit(BaseCharChange.createFetishesUpdate())
		)
	
	var body:BodypartBodyBase = load("res://Game/Character/Bodyparts/Body/FeminineBody.gd").new()
	addBodypart(BodypartSlot.Body, body)
	
	addBodypart(BodypartSlot.Head, load("res://Game/Character/Bodyparts/Head/HumanFeminineHead.gd").new())
	addBodypart(BodypartSlot.Hair, load("res://Game/Character/Bodyparts/Hair/Ponytail1.gd").new())
	
	#body.setOptionValue("thickness", 2.0)
	#body.setOptionValue("thickness", 0.0)
	pass

func onSkinTypeChanged(_skinType:int, _skinTypeData:SkinTypeData):
	#triggerUpdateAllSkinTypes()
	onChange.emit(BaseCharChange.createCharOptionChange(CharOption.skinTypes))

func onInventoryEquipItemChange(_slot:int, _item:ItemBase):
	updatePartFilter()
	onChange.emit(BaseCharChange.createPartChange(GENERIC_CLOTHING, _slot))
	triggerLeashpointUpdate()
	
func onInventoryEquipItemOptionChangeCallback(optionID:String, value, _part:ItemBase, slot:int):
	onChange.emit(BaseCharChange.createPartOptionChange(GENERIC_CLOTHING, slot, optionID, value))

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
	triggerCheckSkinTypesList()
	onChange.emit(BaseCharChange.createPartChange(GENERIC_BODYPARTS, slot))
	updateAllAutoSkinTypes(slot)
	triggerLeashpointUpdate()

func clearBodypart(slot:int):
	if(!bodyparts.has(slot)):
		return
	var part:BodypartBase = bodyparts[slot]
	part.currentSlot = -1
	part.onOptionChanged.disconnect(onBodypartOptionChangeCallback.bind(part, slot))
	part.setCharacter(null)
	bodyparts.erase(slot)
	triggerCheckSkinTypesList()
	onChange.emit(BaseCharChange.createPartChange(GENERIC_BODYPARTS, slot))
	updateAllAutoSkinTypes(slot)
	triggerLeashpointUpdate()

func getBodypart(slot:int) -> BodypartBase:
	if(!bodyparts.has(slot)):
		return null
	return bodyparts[slot]

func hasBodypart(slot:int) -> bool:
	return bodyparts.has(slot)

func getBodyparts() -> Dictionary[int, BodypartBase]:
	return bodyparts

func onBodypartOptionChangeCallback(optionID:String, value, _part:BodypartBase, slot:int):
	onChange.emit(BaseCharChange.createPartOptionChange(GENERIC_BODYPARTS, slot, optionID, value))
	#if(slot == BodypartSlot.Head && optionID == "skinType"):
	#	updateAllAutoSkinTypes(slot)
	if(optionID == "skinType"):
		triggerCheckSkinTypesList()
	
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

# This method is much slower but it keeps properties between parts
func addGenericPartTryKeepProperties(_genericType:int, slot:int, part:GenericPart):
	var curPart := getGenericPart(_genericType, slot)
	if(part && curPart && part.supportsPropertyCopyOnBodypartSwitch() && curPart.supportsPropertyCopyOnBodypartSwitch()):
		#var curData := curPart.saveData().duplicate(true)
		
		var curPList:Array[String] = curPart.getListOfPropertiesToCopy()
		var newPList:Array[String] = part.getListOfPropertiesToCopy()
		
		#var newData:Dictionary = {}
		for theNewProperty in newPList:
			if(!curPList.has(theNewProperty)):
				continue
			part.applyOption(theNewProperty, curPart.getOptionValue(theNewProperty))
			#newData["options"][theNewProperty] = curData["options"][theNewProperty]
		
		#part.loadData(newData)
	addGenericPart(_genericType, slot, part)

func removeGenericPart(_genericType:int, slot:int):
	if(_genericType == GENERIC_BODYPARTS):
		clearBodypart(slot)
		return
	if(_genericType == GENERIC_CLOTHING):
		inventory.clearSlot(slot)
		return
	Log.Printerr("Trying to remove a generic part of unknown type: "+str(_genericType))

## Gathers the dictionary of all currently used skin types, {skinType1 = true, skinType2 = true}
func calculateAllUsedSkinTypes() -> Dictionary:
	var result:Dictionary = {}
	
	for bodypartSlot in bodyparts:
		var theBodypart:BodypartBase = bodyparts[bodypartSlot]
		
		var theSkinType:int = theBodypart.getSkinType()
		if(SkinType.isActualSkinType(theSkinType) && !result.has(theSkinType)):
			result[theSkinType] = true
	return result

var checkingSkinTypesList:bool = false
func triggerCheckSkinTypesList():
	if(checkingSkinTypesList):
		return
	checkingSkinTypesList = true
	checkSkinTypesList.call_deferred()

var updatingLeashpoints:bool = false
var cachedLeashpoints:Dictionary[String, Array]
func triggerLeashpointUpdate():
	if(updatingLeashpoints):
		return
	updatingLeashpoints = true
	updateLeashPoints.call_deferred()

func updateLeashPoints():
	updatingLeashpoints = false
	cachedLeashpoints = calculateAllLeashingPoints()
	onChange.emit(BaseCharChange.createLeashPointsUpdate())

## Gathers the list of all currently used skin types and then makes sure all skin types have an entry in our base skin types dictionary.
## For example, adds fur skin type data if we add cat ears to a human.
## Will also automatically remove any skin types that aren't in use.
func checkSkinTypesList():
	checkingSkinTypesList = false
	if(Network.isClient()):
		return
	var whatWeShouldHave:Dictionary = calculateAllUsedSkinTypes()
	
	for ourSkinType in skinTypes.skinTypes.keys():
		if(!whatWeShouldHave.has(ourSkinType)):
			skinTypes.remove(ourSkinType)
	
	for newSkinType in whatWeShouldHave:
		skinTypes.create(newSkinType)

func getAllUsedSkinTypes() -> Dictionary:
	return skinTypes.skinTypes

func getBaseSkinTypeData(skinType:int, createIfNoExists:bool = true) -> SkinTypeData:
	if(createIfNoExists):
		skinTypes.create(skinType)
	return skinTypes.getSkinType(skinType)

func setBaseSkinTypeData(theSkinType:int, skinTypeData:SkinTypeData):
	skinTypes.setSkinType(theSkinType, skinTypeData)

func getBaseSkinTypeDatas() -> Dictionary:
	return skinTypes.skinTypes

func getSkinTypeOf(bodypartSlot:int) -> int:
	if(!hasBodypart(bodypartSlot)):
		return SkinType.None
	var theBodypart:BodypartBase = bodyparts[bodypartSlot]
	if(!theBodypart.supportsSkinTypes()):
		return SkinType.None
	return theBodypart.getSkinType()

func updateAllAutoSkinTypes(theBodypartSlot:int):
	if(theBodypartSlot != BodypartSlot.Head):
		return
	
	onChange.emit(BaseCharChange.createAutoSkinUpdate())

## Main method for setting the skin data of a bodypart. If you pass null data, the base data will be used
func setSkinTypeDataForSlot(bodypartSlot:int, newSkinType:int, newSkinData:SkinTypeData):
	if(!hasBodypart(bodypartSlot)):
		return
	var theBodypart:BodypartBase = bodyparts[bodypartSlot]
	if(!theBodypart.supportsSkinTypes()):
		return
	theBodypart.setOptionValue("skinType", newSkinType)
	theBodypart.setOptionValue("skinDataOverride", newSkinData)

func updateSkinForSlot(bodypartSlot:int):
	if(!hasBodypart(bodypartSlot)):
		return
	var theBodypart:BodypartBase = bodyparts[bodypartSlot]
	if(!theBodypart.supportsSkinTypes()):
		return
	var theSkinData:SkinTypeData = theBodypart.getSkinTypeData()
	if(theSkinData == null):
		return
	onChange.emit(BaseCharChange.createPartOptionChange(BaseCharacter.GENERIC_BODYPARTS, bodypartSlot, "skinDataOverride", theSkinData))
	
func updateAllSkinTypes():
	#checkSkinTypesList()
	for bodypartSlot in bodyparts:
		updateSkinForSlot(bodypartSlot)

var isUpdatingAllSkinTypes:bool = false
## Same as updateAllSkinTypes() but this has a built-in auto-debouncing.
## This means, it will only actually update every 0.2 seconds
func triggerUpdateAllSkinTypes():
	#checkSkinTypesList()
	if(isUpdatingAllSkinTypes):
		return
	isUpdatingAllSkinTypes = true
	await OPTIONS.get_tree().create_timer(0.2).timeout 
	checkSkinTypesList()
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

func getLastName() -> String:
	return lastCharName

func getFullName() -> String:
	return charName + ((" "+lastCharName) if !lastCharName.is_empty() else "")

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
		CharOption.lastName: {
			name = "Last name (optional)",
			type = "stringWindow",
			value = lastCharName,
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
		CharOption.bodySize: {
			name = "Body size",
			type = "slider",
			min = 0.0,
			max = 1.0,
			value = bodySize,
		},
		CharOption.thickness: {
			name = "Thickness",
			type = "slider",
			min = 0.0,
			max = 2.0,
			value = thickness,
		},
		CharOption.chubbyness: {
			name = "Chubbyness",
			type = "slider",
			min = 0.0,
			max = 1.0,
			value = chubbyness,
		},
		CharOption.buttSize: {
			name = "Butt size",
			type = "slider",
			min = 0.0,
			max = 1.0,
			value = buttSize,
		},
		CharOption.smoothBody: {
			name = "Smooth body",
			type = "slider",
			min = 0.0,
			max = 1.0,
			value = smoothBody,
		},
		CharOption.muscles: {
			name = "Muscles",
			type = "slider",
			min = 0.0,
			max = 1.0,
			value = muscles,
		},
		CharOption.pregnantTest: {
			name = "Pregnant (test)",
			type = "slider",
			min = 0.0,
			max = 1.0,
			value = pregnantTest,
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
			values = GlobalRegistry.getPickableAnimsFor(DollAnimBase.TYPE_IDLE),
			editors = [GenericPart.EDITOR_PART, GenericPart.EDITOR_INTERACT],
		},
		CharOption.walkAnim: {
			name = "Walk style",
			type = "selector",
			value = walkAnim,
			values = GlobalRegistry.getPickableAnimsFor(DollAnimBase.TYPE_WALK),
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
		CharOption.lastName,
		CharOption.gender,
		CharOption.species,
		CharOption.bodySize,
		CharOption.thickness,
		CharOption.chubbyness,
		CharOption.buttSize,
		CharOption.smoothBody,
		CharOption.muscles,
		CharOption.pregnantTest,
		CharOption.voice,
		CharOption.idleAnim,
		CharOption.walkAnim,
		CharOption.idlePose,
		CharOption.poseArms,
		CharOption.skinTypes,
		"bodyMess",
	]

func getSyncOptionValue(_id:String):
	if(_id == CharOption.name):
		return charName
	elif(_id == CharOption.lastName):
		return lastCharName
	elif(_id == CharOption.gender):
		return gender.saveData()
	elif(_id == CharOption.species):
		return species.saveData()
	elif(_id == CharOption.bodySize):
		return bodySize
	elif(_id == CharOption.thickness):
		return thickness
	elif(_id == CharOption.chubbyness):
		return chubbyness
	elif(_id == CharOption.buttSize):
		return buttSize
	elif(_id == CharOption.smoothBody):
		return smoothBody
	elif(_id == CharOption.muscles):
		return muscles
	elif(_id == CharOption.pregnantTest):
		return pregnantTest
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
	elif(_id == CharOption.skinTypes):
		return skinTypes.saveData()
	elif(_id == "bodyMess"):
		return fluids.saveData()

func applyCharChange(_id:String, _value):
	if(_id == CharOption.name):
		charName = _value
	elif(_id == CharOption.lastName):
		lastCharName = _value
	elif(_id == CharOption.gender):
		gender.loadData(_value)
	elif(_id == CharOption.species):
		species.loadData(_value)
	elif(_id == CharOption.bodySize):
		bodySize = _value
	elif(_id == CharOption.thickness):
		thickness = _value
	elif(_id == CharOption.chubbyness):
		chubbyness = _value
	elif(_id == CharOption.buttSize):
		buttSize = _value
	elif(_id == CharOption.smoothBody):
		smoothBody = _value
	elif(_id == CharOption.muscles):
		muscles = _value
	elif(_id == CharOption.pregnantTest):
		pregnantTest = _value
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
	elif(_id == CharOption.skinTypes):
		skinTypes.loadData(_value)
	elif(_id == "bodyMess"):
		fluids.loadData(_value)
		
	onChange.emit(BaseCharChange.createCharOptionChange(_id))

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
			setSkinTypeDataForSlot(bodypartSlot, bodypartEntry["skinType"], null)
		
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
			var theWalkAnim := theDollPose.getWalkAnimName()
			if(!theWalkAnim.is_empty()):
				return theWalkAnim
	
	if(inventory.shouldHobbleLegs()):
		return "WalkHobbled"
	return walkAnim
	
func getIdleAnim() -> String:
	if(idlePose != ""):
		var theDollPose:DollPoseBase = GlobalRegistry.getDollPose(idlePose)
		if(theDollPose):
			var theIdleAnim := theDollPose.getAnimName()
			if(!theIdleAnim.is_empty()):
				return theIdleAnim
	
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
		onChange.emit(BaseCharChange.createPartFilterUpdate())

func triggerPartFilterChangeSignal():
	onChange.emit(BaseCharChange.createPartFilterUpdate())

func getIdlePose() -> String:
	return idlePose

func getPoseArms() -> String:
	return poseArms

func isFullbodyGesturesBlocked() -> bool:
	if(idlePose != ""):
		var thePose:DollPoseBase = GlobalRegistry.getDollPose(idlePose)
		if(thePose && thePose.doesPreventFullbodyGestures()):
			return true
	if(poseArms != ""):
		var thePose:DollPoseBase = GlobalRegistry.getDollPose(poseArms)
		if(thePose && thePose.doesPreventFullbodyGestures()):
			return true
	return false
	
func isPartialGesturesBlocked() -> bool:
	if(idlePose != ""):
		var thePose:DollPoseBase = GlobalRegistry.getDollPose(idlePose)
		if(thePose && thePose.doesPreventPartialGestures()):
			return true
	if(poseArms != ""):
		var thePose:DollPoseBase = GlobalRegistry.getDollPose(poseArms)
		if(thePose && thePose.doesPreventPartialGestures()):
			return true
	return false

func notifyPresetApplied():
	onChange.emit(BaseCharChange.createPresetApplied())

func isControlledByAnyPlayer() -> bool:
	return Network.getPlayerIDWhoControls(getID()) >= 0

func isUs() -> bool:
	var myInfo := Network.getMyPlayerInfo()
	if(!myInfo):
		return false
	var thePlayerCharID:String = myInfo.charID
	return getID() == thePlayerCharID

func getSimpleGameTextParserText(_id:String, _command:String, _arg:String) -> SGTPResult:
	if(_command == "name"):
		return SGTPResult.make(getName())
	if(_command == "nameS"):
		return SGTPResult.make(getName()+"'s")
	elif(_command == "you"):
		return SGTPResult.make("you" if isUs() else getName())
	elif(_command == "your"):
		return SGTPResult.make("your" if isUs() else getName()+"'s")
		
	elif(_command == "he"):
		return SGTPResult.make(gender.heShe())
	elif(_command == "youHe"):
		return SGTPResult.make("you" if isUs() else gender.heShe())
		
	elif(_command == "isAre"):
		return SGTPResult.make(gender.isAre())
	elif(_command == "youAre"):
		return SGTPResult.make("are" if isUs() else gender.isAre())
		
	elif(_command == "his"):
		return SGTPResult.make(gender.hisHer())
	elif(_command == "yourHis"):
		return SGTPResult.make("your" if isUs() else gender.hisHer())
		
	elif(_command == "him"):
		return SGTPResult.make(gender.himHer())
	elif(_command == "youHim"):
		return SGTPResult.make("you" if isUs() else gender.himHer())
		
	elif(_command == "himself"):
		return SGTPResult.make(gender.himselfHerself())
	elif(_command == "yourself"):
		return SGTPResult.make("yourself" if isUs() else gender.himselfHerself())
		
	elif(_command == "verb"):
		var verbSplit := Util.splitOnFirst(_arg, "|")
		if(gender.hasS()):
			return SGTPResult.make(verbSplit[1] if verbSplit.size() > 1 else (verbSplit[0]+"s"))
		return SGTPResult.make(verbSplit[0])
	elif(_command == "youVerb"):
		var verbSplit := Util.splitOnFirst(_arg, "|")
		if(!isUs() && gender.hasS()):
			return SGTPResult.make(verbSplit[1] if verbSplit.size() > 1 else (verbSplit[0]+"s"))
		return SGTPResult.make(verbSplit[0])
	
	elif(_command == "penis"):
		if(isWearingStrapon()):
			return SGTPResult.make("strapon")
		#TODO: Fix the sex calling this too many times?
		#return SGTPResult.make(RNG.pick(["penis", "cock", "dick"]))
		return SGTPResult.make("penis")
	
	return null

func hasPenis() -> bool:
	return hasBodypart(BodypartSlot.Penis)

## Should return true if the character has a penis and it's not blocked by something like a chastity cage
func hasReachablePenis() -> bool:
	return hasPenis()

func isWearingStrapon() -> bool:
	return getInventory().isWearingStrapon()

func hasReachablePenisOrStrapon() -> bool:
	return hasReachablePenis() || isWearingStrapon()

func hasVagina() -> bool:
	return true #TODO: Implement me
	
## Should return true if the character has a vagina and it's not blocked by something like chastity belt or chastity piercings
func hasReachableVagina() -> bool:
	return hasVagina()

func hasAnus() -> bool:
	return true

## Should return true if the character has an anus (always true) and it's not blocked by something like a pear of anguish or whatever
func hasReachableAnus() -> bool:
	return hasAnus()

func isBlind() -> bool:
	if(inventory.hasSlotEquipped(InventorySlot.Eyes)):
		var theItem := inventory.getEquippedItem(InventorySlot.Eyes)
		if(theItem.shouldBlindCharacter()):
			return true
	
	return false

func isZoneCovered(_zone:int) -> bool:
	return inventory.isZoneCovered(_zone)

func getFirstItemThatCovers(_zone:int) -> ItemBase:
	return inventory.getFirstItemThatCovers(_zone)

func canWearStrapon() -> bool:
	if(!hasReachablePenis()):
		return true
	return false

func hasLeashingPoint(_point:String) -> bool:
	if(updatingLeashpoints):
		cachedLeashpoints = calculateAllLeashingPoints()
		updatingLeashpoints = false
	return cachedLeashpoints.has(_point)

func getAllLeashingPoints() -> Dictionary[String, Array]:
	if(updatingLeashpoints):
		cachedLeashpoints = calculateAllLeashingPoints()
		updatingLeashpoints = false
	return cachedLeashpoints

func calculateAllLeashingPoints() -> Dictionary[String, Array]:
	var result:Dictionary[String, Array]
	
	for bodypartSlot in bodyparts:
		var theBodypart:BodypartBase = bodyparts[bodypartSlot]
		var theTargets := theBodypart.getLeashTargets()
		if(theTargets.is_empty()):
			continue
		var theAr:Array[int] = [GENERIC_BODYPARTS, bodypartSlot]
		for leashPointID in theTargets:
			result[leashPointID] = theAr
	
	for invSlot in inventory.equipped:
		var theItem := inventory.getEquippedItem(invSlot)
		if(!theItem):
			continue
		var theTargets := theItem.getLeashTargets()
		var theAr:Array[int] = [GENERIC_CLOTHING, invSlot]
		for leashPointID in theTargets:
			result[leashPointID] = theAr
	
	return result

func processHit(_attackContext:AttackContext):
	var theAttack := _attackContext.attack
	var theDamageMult:float = theAttack.damage
	
	charState.addPain(theDamageMult*0.1)

func saveNetworkData() -> Bins:
	var ar:Array = [
		Bins.I8, bodyparts.size(),
	]
	for bodypartSlot in bodyparts:
		var theBodypart:BodypartBase = bodyparts[bodypartSlot]
		ar.append_array([Bins.I8, bodypartSlot])
		ar.append_array([Bins.StrShort, theBodypart.id])
		ar.append_array([Bins.BINS, theBodypart.saveNetworkData()])
		
	for syncOption in getSyncOptions():
		ar.append_array([Bins.Var, getSyncOptionValue(syncOption)])
	
	ar.append_array([Bins.BINS, charState.saveNetworkData()])
	ar.append_array([Bins.BINS, inventory.saveNetworkData()])
	ar.append_array([Bins.BINS, personality.saveNetworkData()])
	ar.append_array([Bins.BINS, fetishHolder.saveNetworkData()])
	
	return Bins.saveStartEnd(ar)

func loadNetworkData(_data:Bins):
	_data.loadStart()
	
	clearBodyparts()
	var theBodypartAm:int = _data.readI8()
	for _i in range(theBodypartAm):
		var bodypartSlot:int = _data.readI8()
		var bodypartID:String = _data.readStrShort()
		var bodypartData:Bins = _data.readBins()
		
		if(bodypartID == ""):
			Log.Printerr("Empty bodypart ID received in BaseCharacter.loadData")
			continue
		var theBodypart:BodypartBase = GlobalRegistry.createBodypart(bodypartID)
		if(!theBodypart):
			Log.Printerr("Bad bodypart id in BaseCharacter.loadData, id='"+str(bodypartID)+"'")
			continue
		theBodypart.loadNetworkData(bodypartData)
		addBodypart(bodypartSlot, theBodypart)

	for syncOption in getSyncOptions():
		applyCharChange(syncOption, _data.readVar())
	
	charState.loadNetworkData(_data.readBins())
	inventory.loadNetworkData(_data.readBins())
	personality.loadNetworkData(_data.readBins())
	fetishHolder.loadNetworkData(_data.readBins())
	
	_data.endLoad()

func saveData() -> Dictionary:
	var bodypartsData:Dictionary = {}
	for bodypartSlot in bodyparts:
		var theBodypart:BodypartBase = bodyparts[bodypartSlot]
		bodypartsData[str(bodypartSlot)] = {
			id = theBodypart.id,
			data = theBodypart.saveData(),
		}
	
	var charData:Dictionary = {}
	for syncOption in getSyncOptions():
		charData[syncOption] = getSyncOptionValue(syncOption)
	
	return {
		bodyparts = bodypartsData,
		charData = charData,
		charState = charState.saveData(),
		inventory = inventory.saveData(),
		personality = personality.saveData(),
		fetishHolder = fetishHolder.saveData(),
	}

func loadData(_data:Dictionary):
	if(_data.has("bodyparts")):
		clearBodyparts()
		
		var bodypartsData:Dictionary = SAVE.loadVar(_data, "bodyparts", {})
		for bodypartSlotStr in bodypartsData:
			var bodypartData:Dictionary = SAVE.loadVar(bodypartsData, str(bodypartSlotStr), {})
			var bodypartID:String = SAVE.loadVar(bodypartData, "id", "")
			if(bodypartID == ""):
				Log.Printerr("Empty bodypart ID received in BaseCharacter.loadData")
				continue
			var theBodypart:BodypartBase = GlobalRegistry.createBodypart(bodypartID)
			if(!theBodypart):
				Log.Printerr("Bad bodypart id in BaseCharacter.loadData, id='"+str(bodypartID)+"'")
				continue
			theBodypart.loadData(SAVE.loadVar(bodypartData, "data", {}))
			addBodypart(int(bodypartSlotStr), theBodypart)
	
	if(_data.has("charData")):
		var charData:Dictionary = SAVE.loadVar(_data, "charData", {})
		for syncOption in charData:
			applyCharChange(syncOption, charData[syncOption])
	
	if(_data.has("charState")):
		charState.loadData(SAVE.loadVar(_data, "charState", {}))
	
	if(_data.has("inventory")):
		inventory.loadData(SAVE.loadVar(_data, "inventory", {}))
	
	if(_data.has("personality")):
		personality.loadData(SAVE.loadVar(_data, "personality", {}))
	
	if(_data.has("fetishHolder")):
		fetishHolder.loadData(SAVE.loadVar(_data, "fetishHolder", {}))
