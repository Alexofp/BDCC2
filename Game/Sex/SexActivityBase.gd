extends SexEngineActivityBase
class_name SexActivityBase

func sendEvent(_eventID:String, _args:Array = [], _sendToSelf:bool = true):
	getSexEngine().sendSexActivityEvent(_eventID, _args)
	if(_sendToSelf):
		onEvent(_eventID, _args)
	
