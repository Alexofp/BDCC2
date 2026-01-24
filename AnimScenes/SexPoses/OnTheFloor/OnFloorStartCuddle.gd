extends SexPoseBase

func _init() -> void:
	id = "OnFloorStartCuddle"
	sexTypeID = SexType.OnTheFloor
	sexActivityID = SexType.OnTheFloor

	anim = AnimScene.SexStart

func getVisibleName() -> String:
	return "Cuddle"

func getState(_stateRaw:String) -> String:
	#if(_stateRaw == "normal"):
	#	return "normal"
	if(true):
		return "cuddle"
	
	return _stateRaw
