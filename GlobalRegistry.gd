extends Node
#class_name GlobalRegistry # and so we meet again

var wasInit:bool = false

var lastUniqueItemID:int = 0

var bodyparts: Dictionary = {}
var bodypartRefs: Dictionary = {}
var textureVariants:Dictionary = {}
var textureVariantsByType:Dictionary = {}
var sexActivities: Dictionary = {}
var sexActivityRefs: Dictionary = {}
var sexTypes: Dictionary = {}
var sexTypeRefs: Dictionary = {}
var animScenes: Dictionary = {}
var sexVoices: Dictionary = {}
var voiceActors: Dictionary = {}
var species:Dictionary = {}
var items:Dictionary = {}
var itemRefs:Dictionary = {}
var clothingSceneSelectors:Array = []
var dollPoses:Dictionary = {}
var aiActions:Dictionary = {}
var aiActionRefs:Dictionary = {}
var soloGoals:Dictionary = {}
var soloGoalRefs:Dictionary = {}
var interactions:Dictionary = {}
var interactionRefs:Dictionary = {}

func _init() -> void:
	doInit()

func doInit():
	if(wasInit):
		return
	wasInit = true
	registerBodypartsFolder("res://Game/Character/Bodyparts/Body/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Head/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Hair/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Ear/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Tail/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Penis/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Horn/")
	
	registerTextureVariantsFolder("res://Mesh/Parts/SharedTextures/")
	
	registerSexActivityFolder("res://Game/Sex/SexActivities/")
	registerSexTypeFolder("res://Game/Sex/SexTypes/")
	
	registerAnimSceneFolder("res://AnimScenes/Defs/")
	
	registerVoiceActorFolder("res://Sounds/VoiceActors/")
	registerSexVoiceFolder("res://Sounds/Voices/")
	registerSexSoundFolder("res://Sounds/VoiceBanks/")
	
	registerSpeciesFolder("res://Game/Character/Species/")
	
	registerItemFolder("res://Inventory/Items/")
	registerClothingSelectorFolder("res://Inventory/ClothingSelectors/")
	sortClothingSelectors()
	
	registerDollPoseFolder("res://Game/Doll/Posing/Poses/")
	
	registerAIActionFolder("res://Game/PawnAI/Actions/")
	registerSoloGoalFolder("res://Game/PawnAI/SoloGoals/")
	registerInteractionFolder("res://Game/PawnAI/Interactions/")
	
	Log.Print("GlobalRegistry: Registered everything")


func registerBodypart(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is BodypartBase):
		bodyparts[object.id] = loadedClass
		bodypartRefs[object.id] = object
		
		var textureVariantsPaths:Array = object.getTextureVariantsPaths()
		for thePath in textureVariantsPaths:
			registerTextureVariant(thePath)

func registerBodypartsFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerBodypart(scriptPath)

func createBodypart(id: String) -> BodypartBase:
	if(bodyparts.has(id)):
		return bodyparts[id].new()
	else:
		Log.Printerr("ERROR: bodypart with the id "+str(id)+" wasn't found")
		return null

func getBodyparts():
	return bodypartRefs

func getBodypartRef(id: String) -> BodypartBase:
	if(bodypartRefs.has(id)):
		return bodypartRefs[id]
	else:
		Log.Printerr("ERROR: bodypart with the id "+str(id)+" wasn't found")
		return null

func getBodypartIDsForSlot(bodypartSlot:int):
	var result:Array = []
	
	for bodypartID in bodypartRefs:
		if(bodypartRefs[bodypartID].supportsSlot(bodypartSlot)):
			result.append(bodypartID)
	
	return result

func getBodypartIDsOfType(bodypartType:int):
	var result:Array = []
	
	for bodypartID in bodypartRefs:
		if(bodypartRefs[bodypartID].getBodypartType() == bodypartType):
			result.append(bodypartID)
	
	return result


func registerTextureVariant(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is TextureVariantMany):
		var theType:String = object.type
		var theSubType:String = object.subType
		if(theType != ""):
			if(!textureVariantsByType.has(theType)):
				textureVariantsByType[theType] = {}
			if(!textureVariantsByType[theType].has(theSubType)):
				textureVariantsByType[theType][theSubType] = []
		
		for texVar in object.getVariants():
			textureVariants[texVar.id] = texVar
			if(theType != ""):
				textureVariantsByType[theType][theSubType].append(texVar.id)
		
	elif(object is TextureVariant):
		var theType:String = object.type
		var theSubType:String = object.subType
		textureVariants[object.id] = object
		if(theType != ""):
			if(!textureVariantsByType.has(theType)):
				textureVariantsByType[theType] = {}
			if(!textureVariantsByType[theType].has(theSubType)):
				textureVariantsByType[theType][theSubType] = []
			textureVariantsByType[theType][theSubType].append(object.id)

func registerTextureVariantsFolder(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder)
	for scriptPath in scripts:
		registerTextureVariant(scriptPath)

func getTextureVariant(id: String) -> TextureVariant:
	if(textureVariants.has(id)):
		return textureVariants[id]
	else:
		Log.Printerr("ERROR: texture variant with the id "+str(id)+" wasn't found")
		return null

func getTextureVariantsIDsOfTypeAndSubType(theType:String, theSubType:String) -> Array:
	if(!textureVariantsByType.has(theType)):
		return []
	if(!textureVariantsByType[theType].has(theSubType)):
		return []
	return textureVariantsByType[theType][theSubType]




func registerSexActivity(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is SexActivityBase):
		sexActivities[object.id] = loadedClass
		sexActivityRefs[object.id] = object

func registerSexActivityFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerSexActivity(scriptPath)

func createSexActivity(id: String) -> SexActivityBase:
	if(sexActivities.has(id)):
		return sexActivities[id].new()
	else:
		Log.Printerr("ERROR: sex activity with the id "+str(id)+" wasn't found")
		return null

func getSexActivities():
	return sexActivityRefs

func getSexActivityRef(id: String) -> SexActivityBase:
	if(sexActivityRefs.has(id)):
		return sexActivityRefs[id]
	else:
		Log.Printerr("ERROR: sex activity with the id "+str(id)+" wasn't found")
		return null




func registerSexType(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is SexTypeBase):
		sexTypes[object.id] = loadedClass
		sexTypeRefs[object.id] = object

func registerSexTypeFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerSexType(scriptPath)

func createSexType(id: String) -> SexTypeBase:
	if(sexTypes.has(id)):
		return sexTypes[id].new()
	else:
		Log.Printerr("ERROR: sex type with the id "+str(id)+" wasn't found")
		return null

func getSexTypes():
	return sexTypeRefs

func getSexTypeRef(id: String) -> SexTypeBase:
	if(sexTypeRefs.has(id)):
		return sexTypeRefs[id]
	else:
		Log.Printerr("ERROR: sex type with the id "+str(id)+" wasn't found")
		return null




func registerAnimScene(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is AnimDefBase):
		animScenes[object.id] = object

func registerAnimSceneFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerAnimScene(scriptPath)

func getAnimScenes():
	return animScenes

func getAnimScene(id: String) -> AnimDefBase:
	if(animScenes.has(id)):
		return animScenes[id]
	else:
		Log.Printerr("ERROR: anim scene with the id "+str(id)+" wasn't found")
		return null



func registerVoiceActor(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is VoiceActor):
		voiceActors[object.id] = object

func registerVoiceActorFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerVoiceActor(scriptPath)

func getVoiceActors():
	return voiceActors

func getVoiceActor(id: String) -> VoiceActor:
	if(voiceActors.has(id)):
		return voiceActors[id]
	else:
		Log.Printerr("ERROR: voice actor with the id "+str(id)+" wasn't found")
		return null




func registerSexVoice(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is SexVoiceBase):
		sexVoices[object.id] = object

func registerSexVoiceFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerSexVoice(scriptPath)

func getSexVoices():
	return sexVoices

func getSexVoice(id: String) -> SexVoiceBase:
	if(sexVoices.has(id)):
		return sexVoices[id]
	else:
		Log.Printerr("ERROR: sex voice with the id "+str(id)+" wasn't found")
		return null


func registerSexSoundBank(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(!(object is SexSoundBank)):
		return
	var sexSoundBank:SexSoundBank = object
	
	for soundsEntry in sexSoundBank.sounds:
		var entryType:int = soundsEntry["type"]
		var soundIntensity:int = soundsEntry["intensity"] if soundsEntry.has("intensity") else SexSoundIntensity.Low
		var soundSpeed:int = soundsEntry["speed"] if soundsEntry.has("speed") else SexSoundSpeed.Slow
		var mouthState:int = soundsEntry["mouth"] if soundsEntry.has("mouth") else SexSoundMouth.Opened
		
		var basePath:String = soundsEntry["basePath"] if soundsEntry.has("basePath") else ""
		var soundEntries:Array = []
		for soundActualEntry in soundsEntry["sounds"]:
			var thePath:String = soundActualEntry["path"]
			var backTrim:float = soundActualEntry["trimBack"] if soundActualEntry.has("trimBack") else 0.0
			
			var finalPath:String = basePath.path_join(thePath) if basePath != "" else thePath
			var theSound:AudioStream = load(finalPath)
			
			var newEntry:SexSoundEntry = SexSoundEntry.new()
			newEntry.type = entryType
			newEntry.path = finalPath
			newEntry.trimBack = backTrim
			newEntry.length = theSound.get_length()
			newEntry.intensity = soundIntensity
			newEntry.speed = soundSpeed
			newEntry.mouth = mouthState
			soundEntries.append(newEntry)
		
		var voiceID:String = soundsEntry["voice"]
		var voiceActor:String = soundsEntry["voiceActor"]
		
		var theVoice:SexVoiceBase = getSexVoice(voiceID)
		if(!theVoice):
			continue
		if(!theVoice.voiceActors.has(voiceActor)):
			theVoice.voiceActors.append(voiceActor)
		theVoice.addManySoundEntries(soundEntries, entryType, mouthState, soundIntensity, soundSpeed)

func registerSexSoundFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerSexSoundBank(scriptPath)



func registerSpecies(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is SpeciesBase):
		species[object.id] = object

func registerSpeciesFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerSpecies(scriptPath)

func getSpeciesAll():
	return species

func getSpecies(id: String) -> SpeciesBase:
	if(species.has(id)):
		return species[id]
	else:
		Log.Printerr("ERROR: species with the id "+str(id)+" wasn't found")
		return null


func generateUniqueItemID() -> int:
	lastUniqueItemID += 1
	return lastUniqueItemID - 1



func registerItem(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is ItemBase):
		items[object.id] = loadedClass
		itemRefs[object.id] = object
		
		var theClothingSelectorPaths:Array= object.getClothingSelectorPaths()
		for thePath in theClothingSelectorPaths:
			registerClothingSelector(thePath)

func registerItemFolder(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder)
	for scriptPath in scripts:
		registerItem(scriptPath)

func createItem(id: String, genID:bool = true) -> ItemBase:
	if(items.has(id)):
		var theItem:ItemBase = items[id].new()
		if(genID):
			theItem.uniqueID = generateUniqueItemID()
		return theItem
	else:
		Log.Printerr("ERROR: item with the id "+str(id)+" wasn't found")
		return null

func getItemRefs() -> Dictionary:
	return itemRefs

func getItemRef(id: String) -> ItemBase:
	if(itemRefs.has(id)):
		return itemRefs[id]
	else:
		Log.Printerr("ERROR: item with the id "+str(id)+" wasn't found")
		return null


func registerClothingSelector(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is ClothingSceneSelector):
		clothingSceneSelectors.append(object)
		#items[object.id] = loadedClass
		#itemRefs[object.id] = object

func registerClothingSelectorFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerClothingSelector(scriptPath)

func sortClothingSelectors():
	clothingSceneSelectors.sort_custom(func(a:ClothingSceneSelector, b:ClothingSceneSelector): return a.priority < b.priority)

func getClothingSelectors() -> Array:
	return clothingSceneSelectors




func registerDollPose(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is DollPoseBase):
		dollPoses[object.id] = object

func registerDollPoseFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerDollPose(scriptPath)

func getDollPoses() -> Dictionary:
	return dollPoses

func getDollPose(id: String) -> DollPoseBase:
	if(dollPoses.has(id)):
		return dollPoses[id]
	else:
		Log.Printerr("ERROR: doll pose with the id "+str(id)+" wasn't found")
		return null


func registerAIAction(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is AIActionBase):
		aiActions[object.id] = loadedClass
		aiActionRefs[object.id] = object

func registerAIActionFolder(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder)
	for scriptPath in scripts:
		registerAIAction(scriptPath)

func createAIAction(id: String) -> AIActionBase:
	if(aiActions.has(id)):
		return aiActions[id].new()
	else:
		Log.Printerr("ERROR: ai action with the id "+str(id)+" wasn't found")
		return null

func getAIActionRefs() -> Dictionary:
	return aiActionRefs

func getAIActionRef(id: String) -> AIActionBase:
	if(aiActionRefs.has(id)):
		return aiActionRefs[id]
	else:
		Log.Printerr("ERROR: ai action with the id "+str(id)+" wasn't found")
		return null


func registerInteraction(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is InteractionBase):
		interactions[object.id] = loadedClass
		interactionRefs[object.id] = object

func registerInteractionFolder(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder)
	for scriptPath in scripts:
		registerInteraction(scriptPath)

func createInteraction(id: String) -> InteractionBase:
	if(interactions.has(id)):
		return interactions[id].new()
	else:
		Log.Printerr("ERROR: interaction with the id "+str(id)+" wasn't found")
		return null

func getInteractionRefs() -> Dictionary:
	return interactionRefs

func getInteractionRef(id: String) -> InteractionBase:
	if(interactionRefs.has(id)):
		return interactionRefs[id]
	else:
		Log.Printerr("ERROR: interaction with the id "+str(id)+" wasn't found")
		return null


func registerSoloGoal(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is SoloGoalBase):
		soloGoals[object.id] = loadedClass
		soloGoalRefs[object.id] = object

func registerSoloGoalFolder(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder)
	for scriptPath in scripts:
		registerSoloGoal(scriptPath)

func createSoloGoal(id: String) -> SoloGoalBase:
	if(soloGoals.has(id)):
		return soloGoals[id].new()
	else:
		Log.Printerr("ERROR: solo goal with the id "+str(id)+" wasn't found")
		return null

func getSoloGoalsRefs() -> Dictionary:
	return soloGoalRefs

func getSoloGoalRef(id: String) -> SoloGoalBase:
	if(soloGoalRefs.has(id)):
		return soloGoalRefs[id]
	else:
		Log.Printerr("ERROR: solo goal with the id "+str(id)+" wasn't found")
		return null
