extends SexPoseBase

func _init() -> void:
	id = "OnFloorSexBentForward"
	sexTypeID = SexType.OnTheFloor
	sexActivityID = SexActivity.Sex

	anim = AnimScene.TestSex

func getVisibleName() -> String:
	return "Bent forward"

func getState(_stateRaw:String) -> String:
	#if(_stateRaw == "tease"):
	#	return "standing"
	
	return _stateRaw
	#return "tease"
