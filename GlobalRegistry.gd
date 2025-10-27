extends Node
#class_name GlobalRegistry # and so we meet again

var beganInit:bool = false
var finishedInit:bool = false

var lastUniqueItemID:int = 0

var bodyparts: Dictionary = {}
var bodypartRefs: Dictionary = {}
var textureVariants:Dictionary = {}
var textureVariantsByType:Dictionary = {}
var sexActivities: Dictionary = {}
var sexActivityRefs: Dictionary = {}
var sexSideActivities: Dictionary = {}
var sexSideActivityRefs: Dictionary = {}
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
var dollGestures:Dictionary = {}
var personalityStats:Dictionary[String, PersonalityStatBase] = {}
var fetishes:Dictionary[String, FetishBase] = {}
var sexGoalRefs:Dictionary[String, SexGoalBase] = {}
var sexGoals:Dictionary = {}

signal initialized

class CustomLogger extends Logger:
	func _log_message(message: String, _error: bool) -> void:
		_log_message_defer.call_deferred(message, _error)
	
	func _log_message_defer(message: String, _error: bool) -> void:
		if(!Console):
			return
		#CustomLoggerUI.get_node("Panel/RichTextLabel").text += message
		Console.print_line(message.trim_suffix("\n"))

	func _log_error(
			function: String,
			file: String,
			line: int,
			code: String,
			rationale: String,
			_editor_notify: bool,
			error_type: int,
			script_backtraces: Array[ScriptBacktrace]
	) -> void:
		_log_error_defer.call_deferred(function, file, line, code, rationale, _editor_notify, error_type, script_backtraces)

	func _log_error_defer(
			function: String,
			file: String,
			line: int,
			code: String,
			rationale: String,
			_editor_notify: bool,
			error_type: int,
			script_backtraces: Array[ScriptBacktrace]
	) -> void:
		if(!Console):
			return
		var prefix := ""
		# The column at which to print the trace. Should match the length of the
		# unformatted text above it.
		var trace_indent := 0

		match error_type:
			ERROR_TYPE_ERROR:
				prefix = "[color=#f54][b]ERROR:[/b]"
				trace_indent = 6
			ERROR_TYPE_WARNING:
				prefix = "[color=#fd4][b]WARNING:[/b]"
				trace_indent = 8
			ERROR_TYPE_SCRIPT:
				prefix = "[color=#f4f][b]SCRIPT ERROR:[/b]"
				trace_indent = 13
			ERROR_TYPE_SHADER:
				prefix = "[color=#4bf][b]SHADER ERROR:[/b]"
				trace_indent = 13

		var trace := "%*s %s (%s:%s)" % [trace_indent, "at:", function, file, line]
		var script_backtraces_text := ""
		for backtrace in script_backtraces:
			script_backtraces_text += backtrace.format(trace_indent - 3) + "\n"

		#CustomLoggerUI.get_node("Panel/RichTextLabel").text += "%s %s %s[/color]\n[color=#999]%s[/color]\n[color=#999]%s[/color]" % [
		Console.print_line("%s %s %s[/color]\n[color=#999]%s[/color]\n[color=#999]%s[/color]" % [
				prefix,
				code,
				rationale,
				trace,
				script_backtraces_text,
			])

func _init() -> void:
	OS.add_logger(CustomLogger.new())

func _ready() -> void:
	Console.enable_on_release_build = true
	Console.canvas_layer.layer = 4009
	doInit()

func doInit():
	if(beganInit):
		return
	beganInit = true
	
	await get_tree().process_frame
	await get_tree().process_frame
	var start := Time.get_ticks_usec()
	
	GM.presets = CharacterPresetHolder.new()
	
	registerBodypartsFolder("res://Game/Character/Bodyparts/Body/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Head/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Hair/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Ear/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Tail/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Penis/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Horn/")
	
	registerTextureVariantsFolder("res://Mesh/Parts/SharedTextures/")
	
	registerSexActivityFolder("res://Game/Sex/SexActivities/")
	registerSexSideActivityFolder("res://Game/Sex/SideActivities/")
	registerSexTypeFolder("res://Game/Sex/SexTypes/")
	registerPersonalityStatFolder("res://Game/SexInfo/PersonalityStats/")
	registerFetishFolder("res://Game/SexInfo/Fetishes/")
	registerSexGoalFolder("res://Game/SexInfo/SexGoals/")
	
	registerAnimSceneFolder("res://AnimScenes/Defs/")
	
	registerVoiceActorFolder("res://Sounds/VoiceActors/")
	registerSexVoiceFolder("res://Sounds/Voices/")
	registerSexSoundFolder("res://Sounds/VoiceBanks/")
	
	registerSpeciesFolder("res://Game/Character/Species/")
	
	registerItemFolder("res://Inventory/Items/")
	registerClothingSelectorFolder("res://Inventory/ClothingSelectors/")
	sortClothingSelectors()
	
	registerDollPoseFolder("res://Game/Doll/Posing/Poses/")
	registerDollGestureFolder("res://Game/Doll/Posing/Gestures/")
	
	registerAIActionFolder("res://Game/PawnAI/Actions/")
	registerSoloGoalFolder("res://Game/PawnAI/SoloGoals/")
	registerInteractionFolder("res://Game/PawnAI/Interactions/")
	
	var end := Time.get_ticks_usec()
	var worker_time:float = (end-start)/1000000.0
	
	Log.Print("GlobalRegistry: Registered everything in %s seconds" % [worker_time])
	finishedInit = true
	initialized.emit()


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
		#var theSubType:String = object.subType
		if(theType != ""):
			if(!textureVariantsByType.has(theType)):
				textureVariantsByType[theType] = {}
			#if(!textureVariantsByType[theType].has(theSubType)):
			#	textureVariantsByType[theType][theSubType] = []
		
		for texVar in object.getVariants():
			textureVariants[texVar.id] = texVar
			if(theType != ""):
				var theSubType:String = texVar.subType
				if(!textureVariantsByType[theType].has(theSubType)):
					textureVariantsByType[theType][theSubType] = []
				
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
	
	if(object is SexMainActivity):
		sexActivities[object.id] = loadedClass
		sexActivityRefs[object.id] = object

func registerSexActivityFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerSexActivity(scriptPath)

func createSexActivity(id: String) -> SexMainActivity:
	if(sexActivities.has(id)):
		return sexActivities[id].new()
	else:
		Log.Printerr("ERROR: sex activity with the id "+str(id)+" wasn't found")
		return null

func getSexActivities():
	return sexActivityRefs

func getSexActivityRef(id: String) -> SexMainActivity:
	if(sexActivityRefs.has(id)):
		return sexActivityRefs[id]
	else:
		Log.Printerr("ERROR: sex activity with the id "+str(id)+" wasn't found")
		return null

func getAnySexActivityRef(id: String) -> SexEngineActivityBase:
	if(sexActivityRefs.has(id)):
		return sexActivityRefs[id]
	elif(sexSideActivityRefs.has(id)):
		return sexSideActivityRefs[id]
	elif(sexTypeRefs.has(id)):
		return sexTypeRefs[id]
	else:
		Log.Printerr("ERROR: sex activity with the id "+str(id)+" wasn't found")
		return null


func registerSexSideActivity(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is SexSideActivity):
		sexSideActivities[object.id] = loadedClass
		sexSideActivityRefs[object.id] = object

func registerSexSideActivityFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerSexSideActivity(scriptPath)

func createSexSideActivity(id: String) -> SexSideActivity:
	if(sexSideActivities.has(id)):
		return sexSideActivities[id].new()
	else:
		Log.Printerr("ERROR: sex side activity with the id "+str(id)+" wasn't found")
		return null

func getSexSideActivities():
	return sexSideActivityRefs

func getSexSideActivityRef(id: String) -> SexSideActivity:
	if(sexSideActivityRefs.has(id)):
		return sexSideActivityRefs[id]
	else:
		Log.Printerr("ERROR: sex side activity with the id "+str(id)+" wasn't found")
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
			if(!theSound):
				printerr("Sound is bad: "+str(finalPath))
				continue
			
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


func createGenericPart(_genericType:int, _partID:String) -> GenericPart:
	if(_genericType == BaseCharacter.GENERIC_BODYPARTS && _partID != ""):
		return createBodypart(_partID)
	elif(_genericType == BaseCharacter.GENERIC_CLOTHING && _partID != ""):
		return createItem(_partID)
	Log.Printerr("createGenericPart() got an uknown generic type: "+str(_genericType)+", part id = "+str(_partID))
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




func registerDollGesture(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is DollGestureBase):
		dollGestures[object.id] = object

func registerDollGestureFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerDollGesture(scriptPath)

func getDollGestures() -> Dictionary:
	return dollGestures

func getDollGesture(id: String) -> DollGestureBase:
	if(dollGestures.has(id)):
		return dollGestures[id]
	else:
		Log.Printerr("ERROR: doll gesture with the id "+str(id)+" wasn't found")
		return null




func registerPersonalityStat(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is PersonalityStatBase):
		personalityStats[object.id] = object

func registerPersonalityStatFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerPersonalityStat(scriptPath)

func getPersonalityStats() -> Dictionary[String, PersonalityStatBase]:
	return personalityStats

func getPersonalityStatIDsSorted() -> Array[String]:
	var theIDs:Array[String] = personalityStats.keys()
	theIDs.sort_custom(func(a:String, b:String): return getPersonalityStat(a).priority > getPersonalityStat(b).priority)
	return theIDs

func getPersonalityStat(id: String) -> PersonalityStatBase:
	if(personalityStats.has(id)):
		return personalityStats[id]
	else:
		Log.Printerr("ERROR: personality stat with the id "+str(id)+" wasn't found")
		return null


func registerFetish(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is FetishBase):
		fetishes[object.id] = object

func registerFetishFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerFetish(scriptPath)

func getFetishes() -> Dictionary[String, FetishBase]:
	return fetishes

func getFetish(id: String) -> FetishBase:
	if(fetishes.has(id)):
		return fetishes[id]
	else:
		Log.Printerr("ERROR: fetish with the id "+str(id)+" wasn't found")
		return null


func registerSexGoal(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is SexGoalBase):
		sexGoals[object.id] = loadedClass
		sexGoalRefs[object.id] = object

func registerSexGoalFolder(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder)
	for scriptPath in scripts:
		registerSexGoal(scriptPath)

func createSexGoal(id: String) -> SexGoalBase:
	if(sexGoals.has(id)):
		return sexGoals[id].new()
	else:
		Log.Printerr("ERROR: sex goal with the id "+str(id)+" wasn't found")
		return null

func getSexGoalRefs() -> Dictionary[String, SexGoalBase]:
	return sexGoalRefs

func getSexGoalRef(id: String) -> SexGoalBase:
	if(sexGoalRefs.has(id)):
		return sexGoalRefs[id]
	else:
		Log.Printerr("ERROR: sex goal with the id "+str(id)+" wasn't found")
		return null

func getSexGoalRefsForFetishPerforming(_fetishID:String) -> Array[SexGoalBase]:
	var result:Array[SexGoalBase] = []
	for goalID in sexGoalRefs:
		var theGoal:SexGoalBase = sexGoalRefs[goalID]
		if(theGoal.fetishesPerformer.has(_fetishID)):
			result.append(theGoal)
	return result

func getSexGoalRefsForFetishReceiving(_fetishID:String) -> Array[SexGoalBase]:
	var result:Array[SexGoalBase] = []
	for goalID in sexGoalRefs:
		var theGoal:SexGoalBase = sexGoalRefs[goalID]
		if(theGoal.fetishesReceiver.has(_fetishID)):
			result.append(theGoal)
	return result
