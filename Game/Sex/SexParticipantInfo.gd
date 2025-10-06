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

func canDoDomActions() -> bool:
	return isDom() || getSexEngine().canDoDomActions(id)

func getID() -> String:
	return id

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
