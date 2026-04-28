extends DollPoseBase

func _init() -> void:
	id = "CoveringUp"
	animName = "ArmsCoveringUp"
	visibleName = "Covering up"
	orderText = "Cover yourself up."
	
	poseType = PoseType.Arms
	
	animLibraryName = "Poses"

	preventsFullbodyGestures = false
	preventsPartialGestures = false
