extends RefCounted
class_name SexParticipantInfo

var id:String = ""
var sexRef:WeakRef

var role:int = SexEngine.ROLE_DOM
var autoConsent:bool = true #false

func setSexEngine(theSexEngine:SexEngine):
	sexRef = weakref(theSexEngine)

func getSexEngine() -> SexEngine:
	if(!sexRef):
		return null
	return sexRef.get_ref()

func getChar() -> BaseCharacter:
	return GM.characterRegistry.getCharacter(id)

func isAutoConsentEnabled() -> bool:
	return autoConsent

func willConsentToAnything() -> bool:
	# Add extra checks that force consent here
	return isAutoConsentEnabled()

func syncMe():
	if(Network.isServerNotSingleplayer()):
		getSexEngine().syncParticipant(id)

func isSub() -> bool:
	return getSexEngine().getSexType().isSubCharID(id)

func isDom() -> bool:
	return getSexEngine().getSexType().isDomCharID(id)

func isSwitch() -> bool:
	return getSexEngine().getSexType().isSwitchCharID(id)

func saveNetworkData() -> Dictionary:
	return {
		role = role,
		autoConsent = autoConsent,
	}

func loadNetworkData(_data:Dictionary):
	role = SAVE.loadVar(_data, "role", SexEngine.ROLE_SWITCH)
	autoConsent = SAVE.loadVar(_data, "autoConsent", false)
