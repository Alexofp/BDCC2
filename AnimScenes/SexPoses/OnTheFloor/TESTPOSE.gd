extends SexPoseBase

func _init() -> void:
	id = "TESTPOSE"
	sexTypeID = SexType.OnTheFloor
	sexActivityID = SexType.OnTheFloor

	anim = AnimScene.SexSideways

func getVisibleName() -> String:
	return "TEST"

func getState(_stateRaw:String) -> String:
	#if(_stateRaw == "normal"):
	#	return "normal"
	if(true):
		return "tease"
	
	return _stateRaw

func canBeUsed(_sexEngine:SexEngine, _sexActivity:SexEngineActivityBase) -> bool:
	return false#false # Disabled
