extends SexPoseBase

func _init() -> void:
	id = "AgainstWallStartLeanLegUp"
	sexTypeID = SexType.AgainstWall
	sexActivityID = SexType.AgainstWall

	anim = AnimScene.AgainstWallSexStart

func getVisibleName() -> String:
	return "Lean"

func getState(_stateRaw:String) -> String:
	if(_stateRaw == "start"):
		return "backLegUp"
	return _stateRaw

#func canBeUsed(_sexEngine:SexEngine, _sexActivity:SexEngineActivityBase) -> bool:
#	return false # Disabled
