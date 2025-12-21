extends DollPoseBase

func _init() -> void:
	id = "CuteHands"
	animName = "ArmsCuteHands"
	visibleName = "Cute hands"
	
	poseType = PoseType.Arms
	
	animLibraryName = "Poses"

	preventsFullbodyGestures = false
	preventsPartialGestures = false
