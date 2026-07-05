extends DollPoseBase

func _init() -> void:
	id = "PuppyBelly"
	animName = "PosePuppyBelly"
	walkModeCrawl = true
	visibleName = "Puppy belly"
	orderText = "Show me your belly."
	
	poseType = PoseType.Fullbody
	
	animLibraryName = "Poses"

	walkSupportsArmPose = false
	
	preventsPartialGestures = false
