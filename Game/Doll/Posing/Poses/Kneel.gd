extends DollPoseBase

func _init() -> void:
	id = "Kneel"
	animName = "PoseKneel"
	walkModeCrawl = true
	visibleName = "Kneel"
	orderText = "Kneel for me."
	
	poseType = PoseType.Fullbody
	
	animLibraryName = "Poses"

	walkSupportsArmPose = false
	
	preventsPartialGestures = false
