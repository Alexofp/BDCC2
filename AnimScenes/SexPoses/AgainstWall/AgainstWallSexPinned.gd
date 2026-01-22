extends SexPoseBase

func _init() -> void:
	id = "AgainstWallSexPinned"
	sexTypeID = SexType.AgainstWall
	sexActivityID = SexActivity.Sex

	anim = AnimScene.AgainstWallSexPinned

func getVisibleName() -> String:
	return "Pinned"

func getState(_stateRaw:String) -> String:
	#if(_stateRaw == "normal"):
	#	return "normal"
	#if(true):
	#	return "cum"
	
	return _stateRaw

#func canBeUsed(_sexEngine:SexEngine, _sexActivity:SexEngineActivityBase) -> bool:
#	return false # Disabled
