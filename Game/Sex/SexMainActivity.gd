extends SexEngineActivityBase
class_name SexMainActivity

func getActivityType() -> int:
	return ACTIVITY_MAIN

func sendEvent(_eventID:String, _args:Array = [], _sendToSelf:bool = true):
	getSexEngine().sendSexActivityEvent(_eventID, _args)
	if(_sendToSelf):
		onEvent(_eventID, _args)
	
