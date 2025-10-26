extends RefCounted
class_name SexParticipantInfo

var id:String = ""
var sexRef:WeakRef
var ai:SexParticipantAI



var role:int = SexRole.Dom
var autoConsent:bool = false #false

func setupInfo(_infoDict:Dictionary) -> bool:
	if(!_infoDict.has("id")):
		return false
	id = _infoDict["id"]
	role = _infoDict["role"] if _infoDict.has("role") else SexRole.Dom
	if(Network.isServer()):
		ai = SexParticipantAI.new()
		ai.setParticipant(self)
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
	}

func applyUserPickedOptions(_data:Dictionary):
	autoConsent = SAVE.loadVar(_data, "autoConsent", false)

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
	
	return result

func processInfo(_dt:float):
	if(ai):
		ai.processAI(_dt)

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.I8, role,
		Bins.Bool, autoConsent,
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	role = _data.readI8()
	autoConsent = _data.readBool()
	_data.endLoad()

func saveData() -> Dictionary:
	return {
		role = role,
		autoConsent = autoConsent,
	}

func loadData(_data:Dictionary):
	role = SAVE.loadVar(_data, "role", SexRole.Dom)
	autoConsent = SAVE.loadVar(_data, "autoConsent", false)
