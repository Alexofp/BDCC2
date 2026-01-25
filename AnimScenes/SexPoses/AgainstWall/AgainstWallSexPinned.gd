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

func getPoseText(_poseName:String) -> String:
	if(_poseName == "start"):
		return "{top.You} {top.youVerb grab} {bottom.you} and {top.youVerb pin} {bottom.youHim} against a wall, about to fuck {bottom.yourHis} %%zone%%!"
	return ""
