extends SexPoseBase

func _init() -> void:
	id = "SoloRub"
	sexTypeID = SexType.Solo
	sexActivityID = SexActivity.SoloRub

	anim = AnimScene.SoloSex

func getVisibleName() -> String:
	return "Standing"

func getState(_stateRaw:String) -> String:
	return _stateRaw

func getPoseText(_poseName:String) -> String:
	if(_poseName == "start"):
		return "{top.You} {top.youVerb bring} {top.yourHis} hand to {top.yourHis} %%zone%%."
	return ""
