extends DollPoseBase

func _init() -> void:
	id = "Inspection"
	animName = "PoseInspection"
	visibleName = "Inspection"
	
	poseType = PoseType.Fullbody
	
	animLibraryName = "Poses"

	preventsPartialGestures = false
	preventsFullbodyGestures = true
