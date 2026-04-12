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
var animScenes: Dictionary = {}
var sexVoices: Dictionary = {}
var voiceActors: Dictionary = {}
var species:Dictionary = {}
var items:Dictionary = {}
var itemRefs:Dictionary = {}
var clothingSceneSelectors:Array = []
var dollPoses:Dictionary = {}
var aiActions:Dictionary = {}
var aiActionRefs:Dictionary[String, AIActionBase] = {}
var aiActionsBasicAI:Array[AIActionBase]
var interactions:Dictionary = {}
var interactionRefs:Dictionary = {}
var interactionsBySocialType:Dictionary[int, Array] = {}
var dollGestures:Dictionary = {}
var personalityStats:Dictionary[String, PersonalityStatBase] = {}
var fetishes:Dictionary[String, FetishBase] = {}
var sexGoalRefs:Dictionary[String, SexGoalBase] = {}
var sexGoals:Dictionary = {}
var sexTaskRefs:Dictionary[String, SexTaskBase] = {}
var dollAnims:Dictionary[String, DollAnimBase] = {}
var dollAnimsByType:Dictionary[int, Array] = {}
var sexPoses:Dictionary[String, SexPoseBase] = {}
var sexPosesByActivityID:Dictionary[String, Array] = {}
var pawnActions:Dictionary[String, PawnActionBase] = {}
var pawnActionsAlwaysSelf:Array[PawnActionBase] = []
var pawnActionsAlwaysOtherPawn:Array[PawnActionBase] = []
var pawnQuickActionsAlwaysSelf:Array[PawnActionBase] = []
var pawnQuickActionsAlwaysOtherPawn:Array[PawnActionBase] = []
var combatMoveRefs:Dictionary[String, CombatMoveBase]
var combatMoveByActivationType:Dictionary[int, Array]
var aiCombosByID:Dictionary[String, AIComboBase]
var aiCombos:Array[AIComboBase]
var aiGoals:Dictionary#[String, AIGoalBase]
var aiGoalRefs:Dictionary[String, AIGoalBase]
var aiGoalsStaticRefs:Array[AIGoalBase]
var mainReactionBank:ReactionBank = ReactionBank.new()
var coupleAnimRefs:Dictionary[String, CoupleAnimBase]
var socialInteractions:Dictionary
var memories:Dictionary[String, MemoryBase]
var sexDialogueChains:Dictionary#[String, SexDialogueChain]
var sexDialogueChainRefs:Dictionary[String, SexDialogueChain]

signal initialized

var shaderTracker:ShaderCompilationTracker

var dollAnimTreeCache:Dictionary[String, AnimationNode] = {}
var dollAnimTreeLayerCache:Dictionary[String, Dictionary] = {}
var mainSkeletonBoneData:MainSkeletonBoneData = MainSkeletonBoneData.new()
var dollAnimLibraries:Dictionary[String, String] = {}

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
	mainSkeletonBoneData.doCalc()
	shaderTracker = ShaderCompilationTracker.new()
	add_child(shaderTracker)
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
	
	registerBodypartsFolder("res://Game/Character/Bodyparts/Body/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Head/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Hair/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Ear/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Tail/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Penis/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Horn/")
	
	registerTextureVariantsFolder("res://Mesh/Parts/SharedTextures/")
	
	registerSexActivityFolder("res://Game/Sex/SideActivities/")
	registerSexActivityFolder("res://Game/Sex/SexActivities/")
	registerSexActivityFolder("res://Game/Sex/SexTypes/")
	registerPersonalityStatFolder("res://Game/SexInfo/PersonalityStats/")
	registerFetishFolder("res://Game/SexInfo/Fetishes/")
	registerSexGoalFolder("res://Game/SexInfo/SexGoals/")
	registerSexTaskFolder("res://Game/SexInfo/SexTask/")
	registerSexPoseFolder("res://AnimScenes/SexPoses/")
	
	registerPawnAcitonFolder("res://Game/Interactable/PawnActions/")
	
	registerAnimSceneFolder("res://AnimScenes/Defs/")
	
	registerVoiceActorFolder("res://Sounds/VoiceActors/")
	registerSexVoiceFolder("res://Sounds/Voices/")
	registerSexSoundFolder("res://Sounds/VoiceBanks/")
	
	registerSpeciesFolder("res://Game/Character/Species/")
	
	registerItemFolder("res://Inventory/Items/")
	registerClothingSelectorFolder("res://Inventory/ClothingSelectors/")
	sortClothingSelectors()
	
	registerDollAnimFolder("res://Anims/DollAnim/")
	registerDollPoseFolder("res://Game/Doll/Posing/Poses/")
	registerDollGestureFolder("res://Game/Doll/Posing/Gestures/")
	
	registerAIActionFolder("res://Game/PawnAI/Actions/")
	registerInteractionFolder("res://Game/PawnAI/Interactions/")
	registerInteractionFolder("res://Game/PawnAI/SubInteractions/")
	registerAIGoalFolder("res://Game/PawnAI/Goals/")
	registerAIGoalFolder("res://Game/PawnAI/GoalsStatic/")
	#loadMainReactionBankFolder("res://Reactions/Main/")
	reloadReactionBanks()
	
	registerCombatMoveFolder("res://Game/Combat/Moves/")
	registerAIComboFolder("res://Game/Combat/AICombos/")
	
	registerCoupleAnimsFolder("res://Game/Systems/CoupleAnimsSystem/Anims/")
	registerSocialInteractionFolder("res://Game/PawnAI/SocialInteractions/")
	registerMemoriesFolder("res://Game/Systems/MemorySystem/Memories/")
	
	registerSexDialogueChains("res://Game/Sex/SexDialogueChains/")
	
	# After all the registrations
	GM.presets = CharacterPresetHolder.new() # Depends on Doll Anims
	
	sortPawnActionsArrayByPriority(pawnActionsAlwaysSelf)
	sortPawnActionsArrayByPriority(pawnActionsAlwaysOtherPawn)
	sortPawnActionsArrayByPriority(pawnQuickActionsAlwaysSelf)
	sortPawnActionsArrayByPriority(pawnQuickActionsAlwaysOtherPawn)
	
	for actType in combatMoveByActivationType:
		sortCombatMoveArrayByPriority(combatMoveByActivationType[actType])
	
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
	
	if(object is SexEngineActivityBase):
		sexActivities[object.id] = loadedClass
		sexActivityRefs[object.id] = object

func registerSexActivityFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerSexActivity(scriptPath)

func createSexActivity(id: String) -> SexEngineActivityBase:
	if(sexActivities.has(id)):
		return sexActivities[id].new()
	else:
		Log.Printerr("ERROR: sex activity with the id "+str(id)+" wasn't found")
		return null

func getSexActivities():
	return sexActivityRefs

func getSexActivityRef(id: String) -> SexEngineActivityBase:
	if(sexActivityRefs.has(id)):
		return sexActivityRefs[id]
	else:
		Log.Printerr("ERROR: sex activity with the id "+str(id)+" wasn't found")
		return null

func getAnySexActivityRef(id: String) -> SexEngineActivityBase:
	if(sexActivityRefs.has(id)):
		return sexActivityRefs[id]
	else:
		Log.Printerr("ERROR: sex activity with the id "+str(id)+" wasn't found")
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
		if(object.groupBasicAI):
			aiActionsBasicAI.append(object)

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

func getAIActionRefs() -> Dictionary[String, AIActionBase]:
	return aiActionRefs

func getAIActionRef(id: String) -> AIActionBase:
	if(aiActionRefs.has(id)):
		return aiActionRefs[id]
	else:
		Log.Printerr("ERROR: ai action with the id "+str(id)+" wasn't found")
		return null

func getAIActionGroupBasicAI() -> Array[AIActionBase]:
	return aiActionsBasicAI

func registerInteraction(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is InteractionBase):
		interactions[object.id] = loadedClass
		interactionRefs[object.id] = object
		
		for socialType in object.registerForInteractionType:
			if(!interactionsBySocialType.has(socialType)):
				var newAr:Array[InteractionBase] = [object]
				interactionsBySocialType[socialType] = newAr
			else:
				interactionsBySocialType[socialType].append(object)

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

func getInteractionsBySocialType(_type:int) -> Array[InteractionBase]:
	if(!interactionsBySocialType.has(_type)):
		return []
	return interactionsBySocialType[_type]




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


func registerSexTask(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is SexTaskBase):
		sexTaskRefs[object.id] = object

func registerSexTaskFolder(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder)
	for scriptPath in scripts:
		registerSexTask(scriptPath)

func getSexTaskRef(id: String) -> SexTaskBase:
	if(sexTaskRefs.has(id)):
		return sexTaskRefs[id]
	else:
		Log.Printerr("ERROR: sex task with the id "+str(id)+" wasn't found")
		return null

func getSexTaskForTaskID(id: String) -> SexTaskBase:
	if(sexTaskRefs.has(id)):
		return sexTaskRefs[id]
	elif(sexTaskRefs.has("Default")):
		return sexTaskRefs["Default"]
	else:
		Log.Printerr("ERROR: sex task with the id "+str(id)+" wasn't found")
		return null


func registerDollAnim(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is DollAnimBase):
		object.calcFinalAnimName()
		
		for _id in object.anims:
			dollAnims[_id] = object
		
		if(!object.animLibraryName.is_empty() && !object.animLibraryPath.is_empty()):
			if(!dollAnimLibraries.has(object.animLibraryName)):
				dollAnimLibraries[object.animLibraryName] = object.animLibraryPath

		if(!dollAnimsByType.has(object.animType)):
			var newAr:Array[DollAnimBase] = [object]
			dollAnimsByType[object.animType] = newAr
		else:
			dollAnimsByType[object.animType].append(object)

func registerDollAnimFolder(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder)
	for scriptPath in scripts:
		registerDollAnim(scriptPath)

func getDollAnim(id: String) -> DollAnimBase:
	if(dollAnims.has(id)):
		return dollAnims[id]
	else:
		Log.Printerr("ERROR: doll anim with the id "+str(id)+" wasn't found")
		return null

func getDollAnims() -> Dictionary[String, DollAnimBase]:
	return dollAnims

func hasDollAnim(_id:String) -> bool:
	if(!dollAnims.has(_id)):
		return false
	return true

func getDollAnimsByType(_type:int) -> Array[DollAnimBase]: #Array[DollAnimBase]
	if(!dollAnimsByType.has(_type)):
		return []
	return dollAnimsByType[_type]

func getPickableAnimsFor(_type:int) -> Array[Array]:
	var result:Array[Array] = []
	
	var allTheAnims :=getDollAnimsByType(_type)
	for theAnim in allTheAnims:
		if(!theAnim.animCanPick):
			continue
		for animID in theAnim.anims:
			result.append([animID, theAnim.getVisibleName(animID)])
	
	return result





func registerSexPose(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is SexPoseBase):
		sexPoses[object.id] = object
		if(!sexPosesByActivityID.has(object.sexActivityID)):
			var newAr:Array[SexPoseBase] = [object]
			sexPosesByActivityID[object.sexActivityID] = newAr
		else:
			sexPosesByActivityID[object.sexActivityID].append(object)

func registerSexPoseFolder(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder)
	for scriptPath in scripts:
		registerSexPose(scriptPath)

func getSexPose(id: String) -> SexPoseBase:
	if(sexPoses.has(id)):
		return sexPoses[id]
	else:
		Log.Printerr("ERROR: sex pose with the id "+str(id)+" wasn't found")
		return null

func getSexPoseNoError(id: String) -> SexPoseBase:
	if(sexPoses.has(id)):
		return sexPoses[id]
	else:
		return null

func getSexPosesForActivityID(id: String) -> Array[SexPoseBase]:
	if(sexPosesByActivityID.has(id)):
		return sexPosesByActivityID[id]
	return []



func sortPawnActionsArrayByPriority(_ar:Array[PawnActionBase]):
	_ar.sort_custom(func(a:PawnActionBase, b:PawnActionBase): return a.alwaysPriority > b.alwaysPriority)

func registerPawnAction(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is PawnActionBase):
		pawnActions[object.id] = object
		if(object.alwaysCheckBitfield & PawnActionBase.CHECK_SELF):
			pawnActionsAlwaysSelf.append(object)
		if(object.alwaysCheckBitfield & PawnActionBase.CHECK_OTHER):
			pawnActionsAlwaysOtherPawn.append(object)
		if(object.alwaysCheckBitfield & PawnActionBase.CHECK_SELF_QUICKACTION):
			pawnQuickActionsAlwaysSelf.append(object)
		if(object.alwaysCheckBitfield & PawnActionBase.CHECK_OTHER_QUICKACTION):
			pawnQuickActionsAlwaysOtherPawn.append(object)

func registerPawnAcitonFolder(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder)
	for scriptPath in scripts:
		registerPawnAction(scriptPath)

func getPawnAction(id: String) -> PawnActionBase:
	if(pawnActions.has(id)):
		return pawnActions[id]
	else:
		Log.Printerr("ERROR: pawn action with the id "+str(id)+" wasn't found")
		return null





func sortCombatMoveArrayByPriority(_ar:Array[CombatMoveBase]):
	_ar.sort_custom(func(a:CombatMoveBase, b:CombatMoveBase): return a.priority > b.priority)

func registerCombatMove(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is CombatMoveBase):
		combatMoveRefs[object.id] = object
		
		if(!combatMoveByActivationType.has(object.activateType)):
			var newAr:Array[CombatMoveBase] = [object]
			combatMoveByActivationType[object.activateType] = newAr
		else:
			combatMoveByActivationType[object.activateType].append(object)

func registerCombatMoveFolder(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder)
	for scriptPath in scripts:
		registerCombatMove(scriptPath)

func getCombatMove(id: String) -> CombatMoveBase:
	if(combatMoveRefs.has(id)):
		return combatMoveRefs[id]
	else:
		Log.Printerr("ERROR: combat move with the id "+str(id)+" wasn't found")
		return null

func getCombatMovesByActivationType(_act:int) -> Array[CombatMoveBase]:
	if(!combatMoveByActivationType.has(_act)):
		var res:Array[CombatMoveBase]
		return res
	return combatMoveByActivationType[_act]

func reloadCombatMoves():
	Log.Print("Reloading combat moves")
	combatMoveRefs.clear()
	combatMoveByActivationType.clear()
	
	registerCombatMoveFolder("res://Game/Combat/Moves/")
	for actType in combatMoveByActivationType:
		sortCombatMoveArrayByPriority(combatMoveByActivationType[actType])
	
	aiCombos.clear()
	aiCombosByID.clear()
	registerAIComboFolder("res://Game/Combat/AICombos/")





func registerAICombo(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is AIComboBase):
		if(!object.enabled):
			return
		aiCombos.append(object)
		aiCombosByID[object.id] = object

func registerAIComboFolder(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder)
	for scriptPath in scripts:
		registerAICombo(scriptPath)

func getAICombo(id: String) -> AIComboBase:
	if(aiCombosByID.has(id)):
		return aiCombosByID[id]
	else:
		Log.Printerr("ERROR: AI combo with the id "+str(id)+" wasn't found")
		return null

func getAICombos() -> Array[AIComboBase]:
	return aiCombos




func registerAIGoal(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is AIGoalBase):
		aiGoals[object.id] = loadedClass
		aiGoalRefs[object.id] = object
		if(object.isStaticGoal()):
			aiGoalsStaticRefs.append(object)

func registerAIGoalFolder(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder)
	for scriptPath in scripts:
		registerAIGoal(scriptPath)

func getAIGoalRef(id: String) -> AIGoalBase:
	if(aiGoalRefs.has(id)):
		return aiGoalRefs[id]
	else:
		Log.Printerr("ERROR: AI goal with the id "+str(id)+" wasn't found")
		return null

func createAIGoal(id: String) -> AIGoalBase:
	if(aiGoals.has(id)):
		return aiGoals[id].new()
	else:
		Log.Printerr("ERROR: AI goal with the id "+str(id)+" wasn't found")
		return null

func getAIGoalsStaticRefs() -> Array[AIGoalBase]:
	return aiGoalsStaticRefs



var reactionLexer:ReactionSystemLexer = ReactionSystemLexer.new()
var reactionParser:ReactionSystemParser = ReactionSystemParser.new()
func loadMainReactionBank(_path:String) -> bool:
	var theText := Util.readFile(_path)
	var theLexerStuff := reactionLexer.parse(theText)
	if(theLexerStuff.hadErrors):
		Log.Printerr("LEXER ERRORS IN REACTION FILE: "+_path)
		for theError in theLexerStuff.errors:
			Log.Printerr(theError)
		return false
	
	var theParserStuff := reactionParser.parseLexerResult(theLexerStuff)
	if(theParserStuff.hadErrors):
		Log.Printerr("PARSER ERRORS IN REACTION FILE: "+_path)
		for theError in theParserStuff.errors:
			Log.Printerr(theError)
		return false
	
	var newBank:ReactionBank = ReactionBank.new()
	newBank.defs = theParserStuff.defs
	newBank.fills = theParserStuff.fills
	
	mainReactionBank.merge(newBank)
	return true
	
func loadMainReactionBankFolder(folder: String):
	var scripts = Util.getFilesInFolderSmart(folder, "txt")
	for scriptPath in scripts:
		loadMainReactionBank(scriptPath)

func reloadReactionBanks():
	if(!mainReactionBank.defs.is_empty()):
		Log.Print("Reloading dialogue reaction banks")
	mainReactionBank.reset()# = ReactionBank.new()
	loadMainReactionBankFolder("res://Reactions/Main/")




func registerCoupleAnim(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is CoupleAnimBase):
		coupleAnimRefs[object.id] = object

func registerCoupleAnimsFolder(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder)
	for scriptPath in scripts:
		registerCoupleAnim(scriptPath)

func getCoupleAnim(id: String) -> CoupleAnimBase:
	if(coupleAnimRefs.has(id)):
		return coupleAnimRefs[id]
	else:
		Log.Printerr("ERROR: couple anim with the id "+str(id)+" wasn't found")
		return null



func registerSocialInteraction(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is SocialInteractionBase):
		socialInteractions[object.id] = loadedClass

func registerSocialInteractionFolder(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder)
	for scriptPath in scripts:
		registerSocialInteraction(scriptPath)

func createSocialInteraction(id: String) -> SocialInteractionBase:
	if(socialInteractions.has(id)):
		return socialInteractions[id].new()
	else:
		Log.Printerr("ERROR: social interaction with the id "+str(id)+" wasn't found")
		return null

func hasSocialInteraction(id: String) -> bool:
	return socialInteractions.has(id)

#func getSocialInteractionRefs() -> Array[SocialInteractionBase]:
#	return aiGoalsStaticRefs




func registerMemory(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is MemoryBase):
		memories[object.id] = object
	elif(object is MemorySimpleBank):
		var theMemories:Array[MemorySimple] = object.createMemories()
		for theMemory in theMemories:
			memories[theMemory.id] = theMemory

func registerMemoriesFolder(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder)
	for scriptPath in scripts:
		registerMemory(scriptPath)

func getMemory(id: String) -> MemoryBase:
	if(memories.has(id)):
		return memories[id]
	else:
		Log.Printerr("ERROR: memory with the id "+str(id)+" wasn't found")
		return null

func hasMemory(id: String) -> bool:
	return memories.has(id)




func registerSexDialogueChain(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is SexDialogueChain):
		sexDialogueChains[object.id] = loadedClass
		sexDialogueChainRefs[object.id] = object

func registerSexDialogueChains(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder)
	for scriptPath in scripts:
		registerSexDialogueChain(scriptPath)

func createSexDialogueChain(id: String) -> SexDialogueChain:
	if(sexDialogueChains.has(id)):
		return sexDialogueChains[id].new()
	else:
		Log.Printerr("ERROR: sex dialogue chain with the id "+str(id)+" wasn't found")
		return null

func getSexDialogueChainRef(id:String) -> SexDialogueChain:
	if(sexDialogueChainRefs.has(id)):
		return sexDialogueChainRefs[id]
	else:
		Log.Printerr("ERROR: sex dialogue chain with the id "+str(id)+" wasn't found")
		return null
