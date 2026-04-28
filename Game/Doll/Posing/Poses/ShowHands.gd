extends DollPoseBase

func _init() -> void:
	id = "ShowHands"
	animName = "ArmsShowHands"
	visibleName = "Show hands"
	orderText = "Show me your hands."
	
	poseType = PoseType.Arms
	
	animLibraryName = "Poses"

	preventsFullbodyGestures = false
	preventsPartialGestures = false
