extends DollPoseBase

func _init() -> void:
	id = "ArmsAboveHead"
	animName = "ArmsAboveHead"
	visibleName = "Arms above head"
	orderText = "Hands above your head."
	
	poseType = PoseType.Arms
	
	animLibraryName = "Poses"

	preventsPartialGestures = false
	preventsFullbodyGestures = false
