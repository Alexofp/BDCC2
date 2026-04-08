extends SexPoseBase

func _init() -> void:
	id = "SoloStart"
	sexTypeID = SexType.Solo
	sexActivityID = SexType.Solo

	anim = AnimScene.SoloSex

func getVisibleName() -> String:
	return "Standing"

func getState(_stateRaw:String) -> String:
	return _stateRaw
