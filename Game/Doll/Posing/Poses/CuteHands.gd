extends DollPoseBase

func _init() -> void:
	id = "CuteHands"
	animName = "ArmsCuteHands"
	visibleName = "Cute hands"
	orderText = "Show me your cute hands."
	
	poseType = PoseType.Arms
	
	animLibraryName = "Poses"

	preventsFullbodyGestures = false
	preventsPartialGestures = false
