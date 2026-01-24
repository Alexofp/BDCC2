extends SexPoseBase

func _init() -> void:
	id = "OnFloorSexSideways"
	sexTypeID = SexType.OnTheFloor
	sexActivityID = SexActivity.Sex

	anim = AnimScene.SexSideways

func getVisibleName() -> String:
	return "Sideways"

func getState(_stateRaw:String) -> String:
	#if(_stateRaw == "tease"):
	#	return "standing"
	
	return _stateRaw
	#return "tease"
