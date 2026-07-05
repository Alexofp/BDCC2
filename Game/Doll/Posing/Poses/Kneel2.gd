extends DollPoseBase

func _init() -> void:
	id = "Kneel2"
	animName = "PoseKneel2"
	walkModeCrawl = true
	visibleName = "Kneel 2"
	orderText = "Kneel for me."
	
	poseType = PoseType.Fullbody
	
	animLibraryName = "Poses"

	walkSupportsArmPose = false
	
	preventsPartialGestures = false
