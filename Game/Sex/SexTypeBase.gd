extends SexEngineActivityBase
class_name SexTypeBase

func getActivityType() -> int:
	return ACTIVITY_SEXTYPE

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, ["dom", "sub"])

func startMainActivity(activityID:String, _roles:Dictionary, _args:Dictionary = {}) -> SexMainActivity:
	var sexEngine:SexEngine = getSexEngine()
	
	return sexEngine.startMainActivity(activityID, _roles, _args)

func onMainActivityEnded(_activityID:String):
	doRun()

func sendEvent(_eventID:String, _args:Array = [], _sendToSelf:bool = true):
	getSexEngine().sendSexTypeEvent(_eventID, _args)
	if(_sendToSelf):
		onEvent(_eventID, _args)

func hasMainActivity() -> bool:
	if(getSexEngine().sexActivity):
		return true
	return false
