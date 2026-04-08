extends SexPoseBase

func _init() -> void:
	id = "OnFloorTrib1"
	sexTypeID = SexType.OnTheFloor
	sexActivityID = SexActivity.Tribadism

	anim = AnimScene.Tribadism

func getVisibleName() -> String:
	return "Scissoring"

func getState(_stateRaw:String) -> String:
	#if(_stateRaw == "tease"):
	#	return "standing"
	
	return _stateRaw

func getPoseText(_poseName:String) -> String:
	if(_poseName == "start"):
		return "{top.You} {top.youVerb interlock} legs with {bottom.you}!"
	return ""

func getExtraUndressZones(_role:String, _sexActivity:SexEngineActivityBase) -> Array[int]:
	return [ZoneCover.Thighs]
