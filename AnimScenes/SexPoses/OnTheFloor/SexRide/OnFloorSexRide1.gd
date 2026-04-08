extends SexPoseBase

func _init() -> void:
	id = "OnFloorSexRide1"
	sexTypeID = SexType.OnTheFloor
	sexActivityID = SexActivity.SexRide

	anim = AnimScene.SexCowgirl

func getVisibleName() -> String:
	return "Cowgirl"

func getState(_stateRaw:String) -> String:
	#if(_stateRaw == "tease"):
	#	return "standing"
	
	return _stateRaw

func getPoseText(_poseName:String) -> String:
	if(_poseName == "start"):
		return "{bottom.You} {bottom.youVerb stradle} {top.your} hips and {bottom.youVerb prepare} to ride {top.yourHis} penis with {bottom.yourHis} %%zone%%!"
	return ""

func getExtraUndressZones(_role:String, _sexActivity:SexEngineActivityBase) -> Array[int]:
	if(_role == "bottom"):
		return [ZoneCover.Thighs,]
	return []
