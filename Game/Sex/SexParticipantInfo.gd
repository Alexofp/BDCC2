extends RefCounted
class_name SexParticipantInfo

var id:String = ""
var sexRef:WeakRef

var role:int = SexRole.Dom
var autoConsent:bool = false #false

func setupInfo(_infoDict:Dictionary) -> bool:
	if(!_infoDict.has("id")):
		return false
	id = _infoDict["id"]
	role = _infoDict["role"] if _infoDict.has("role") else SexRole.Dom
	return true

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
	if(Network.isServerNotSingleplayer()):
		getSexEngine().syncParticipant(id)

func isDom() -> bool:
	return role == SexRole.Dom

func isSub() -> bool:
	return role == SexRole.Sub

func saveNetworkData() -> Dictionary:
	return {
		role = role,
		autoConsent = autoConsent,
	}

func loadNetworkData(_data:Dictionary):
	role = SAVE.loadVar(_data, "role", SexRole.Dom)
	autoConsent = SAVE.loadVar(_data, "autoConsent", false)
