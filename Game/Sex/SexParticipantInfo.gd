extends RefCounted
class_name SexParticipantInfo

var id:String = ""
var sexRef:WeakRef
var ai:SexParticipantAI
var pawn:CharacterPawn

var role:int = SexRole.Dom
var autoConsent:bool = false #false
var pcAuto:bool = false # Process AI even if we are the player

var freeStraponUniqueID:int = -1

func setupInfo(_infoDict:Dictionary) -> bool:
	if(!_infoDict.has("id")):
		return false
	id = _infoDict["id"]
	role = _infoDict["role"] if _infoDict.has("role") else SexRole.Dom
	#if(Network.isServer()):
	ai = SexParticipantAI.new()
	ai.setParticipant(self)
	pawn = GM.pawnRegistry.getPawn(id)
	return true

func onSexStart():
	if(ai):
		ai.onSexStart()

func notifyThingHappened():
	if(ai):
		ai.notifyThingHappened()

func notifyThingHappenedNeedsReaction():
	if(ai):
		ai.notifyThingHappenedNeedsReaction()



func isPlayer() -> bool:
	var theChar := getChar()
	if(!theChar):
		return false
	return theChar.isControlledByAnyPlayer()

func setSexEngine(theSexEngine:SexEngine):
	sexRef = weakref(theSexEngine)

func getSexEngine() -> SexEngine:
	if(!sexRef):
		return null
	return sexRef.get_ref()

func getChar() -> BaseCharacter:
	return GM.characterRegistry.getCharacter(id)

func isAutoConsentToggledOn() -> bool:
	return autoConsent

func isAutoConsent() -> bool:
	# Add extra checks that force consent here
	return isAutoConsentToggledOn()

func syncMe():
	var theEngine := getSexEngine()
	if(!theEngine):
		return
	if(Network.isServerNotSingleplayer()):
		theEngine.syncParticipant(id)

func syncUserOptions():
	var theEngine := getSexEngine()
	if(!theEngine):
		return
	theEngine.askSetParticipantUserPickedOptions(getID(), getUserPickedOptions())

func isDom() -> bool:
	return role == SexRole.Dom

func isSub() -> bool:
	return role == SexRole.Sub

func canDoDomActions() -> bool:
	return isDom() || getSexEngine().canDoDomActions(id)

func getID() -> String:
	return id

func getUserPickedOptions() -> Dictionary:
	return {
		autoConsent = autoConsent,
		pcAuto = pcAuto,
	}

func applyUserPickedOptions(_data:Dictionary):
	autoConsent = SAVE.loadVar(_data, "autoConsent", false)
	pcAuto = SAVE.loadVar(_data, "pcAuto", false)

func getStatusTextArray() -> Array[String]:
	var result:Array[String] = []
	
	if(role == SexRole.Dom):
		result.append("Dominant")
	if(role == SexRole.Sub):
		if(canDoDomActions()):
			result.append("Submissive (acts as dom)")
		else:
			result.append("Submissive")
	if(autoConsent):
		result.append("Auto-allow")
	if(pcAuto && isPlayer()):
		result.append("AI-controlled player")
	
	if(ai):
		var theAiInfo := ai.getVisibleAIInfo()
		if(!theAiInfo.is_empty()):
			result.append(Util.join(theAiInfo, ", "))
	
	return result

func processInfo(_dt:float):
	if(ai):
		ai.processAI(_dt)

func exposeToFetish(_fetishID:String, _intensity:float, _isPerf:bool, _isReceiv:bool):
	if(ai):
		ai.exposeToFetish(_fetishID, _intensity, _isPerf, _isReceiv)

func taskScore(_taskID:String, _target:SexParticipantInfo) -> float:
	if(!ai || !ai.shouldProcessAI()):
		return 0.0
	return ai.taskScore(_taskID, _target.getID())

func taskScoreReceive(_taskID:String, _target:SexParticipantInfo) -> float:
	if(!ai || !ai.shouldProcessAI()):
		return 0.0
	return ai.taskScoreReceive(_taskID, _target.getID())

#func taskScore(_taskID:String, _args:Array) -> float:
	#if(!ai || !ai.shouldProcessAI()):
		#return 0.0
	#return ai.taskScore(_taskID, _args)

func sendTaskEvent(_taskID:String, _targetInfo:SexParticipantInfo, _event:int):
	if(!ai):
		return
	ai.sendTaskEvent(_taskID, _targetInfo, _event)

func canWearFreeStrapon() -> bool:
	var theSexEngine:SexEngine = getSexEngine()
	if(!theSexEngine):
		return false
	
	if(freeStraponUniqueID < 0):
		return true
	
	for charID in theSexEngine.participants:
		var theInfo:SexParticipantInfo = theSexEngine.participants[charID]
		var theChar := theInfo.getChar()
		if(!theChar):
			continue
		var theInv:Inventory = theChar.getInventory()
		
		var theItem := theInv.findItemByUniqueID(freeStraponUniqueID)
		if(theItem):
			return false
	return true

func setFreeStraponUniqueID(_uid:int):
	freeStraponUniqueID = _uid

func getPawn() -> CharacterPawn:
	return pawn

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.I8, role,
		Bins.Bool, autoConsent,
		Bins.Bool, pcAuto,
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	role = _data.readI8()
	autoConsent = _data.readBool()
	pcAuto = _data.readBool()
	_data.endLoad()

func saveData() -> Dictionary:
	return {
		role = role,
		autoConsent = autoConsent,
		pcAuto = pcAuto,
	}

func loadData(_data:Dictionary):
	role = SAVE.loadVar(_data, "role", SexRole.Dom)
	autoConsent = SAVE.loadVar(_data, "autoConsent", false)
	pcAuto = SAVE.loadVar(_data, "pcAuto", false)
