extends SexPoseBase

func _init() -> void:
	id = "OnFloorStartNormal"
	sexTypeID = SexType.OnTheFloor
	sexActivityID = SexType.OnTheFloor

	anim = AnimScene.SexStart

func getVisibleName() -> String:
	return "Normal"

func getState(_stateRaw:String) -> String:
	#if(_stateRaw == "normal"):
	#	return "normal"
	
	return _stateRaw
