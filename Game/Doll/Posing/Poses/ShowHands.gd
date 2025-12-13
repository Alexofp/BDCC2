extends DollPoseBase

func _init() -> void:
	id = "ShowHands"
	animName = "ArmsShowHands"
	visibleName = "Show hands"
	
	poseType = PoseType.Arms
	
	animLibraryName = "Poses"

	preventsFullbodyGestures = false
	preventsPartialGestures = false
