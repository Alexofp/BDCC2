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

func getPoseText(_poseName:String) -> String:
	if(_poseName == "start"):
		return "{top.You} {top.youVerb grab} {bottom.your} leg and {top.youVerb raise} it, about to fuck {bottom.yourHis} %%zone%%!"
	return ""

func getExtraUndressZones(_role:String, _sexActivity:SexEngineActivityBase) -> Array[int]:
	if(_role == "bottom"):
		return [ZoneCover.Thighs,]
	return []
