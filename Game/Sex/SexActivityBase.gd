extends SexEngineActivityBase
class_name SexActivityBase

func sendEvent(_eventID:String, _args:Array = [], _sendToSelf:bool = true):
	getSexEngine().sendSexActivityEvent(_eventID, _args)
	if(_sendToSelf):
		onEvent(_eventID, _args)
	
func isSub(_role:String) -> bool:
	if(!roleToID.has(_role)):
		return false
	return getSexEngine().getSexType().isSubCharID(roleToID[_role])

func isDom(_role:String) -> bool:
	if(!roleToID.has(_role)):
		return false
	return getSexEngine().getSexType().isDomCharID(roleToID[_role])

func isSwitch(_role:String) -> bool:
	if(!roleToID.has(_role)):
		return false
	return getSexEngine().getSexType().isSwitchCharID(roleToID[_role])
