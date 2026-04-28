extends DollPoseBase

func _init() -> void:
	id = "PuppyBelly"
	animName = "PosePuppyBelly"
	visibleName = "Puppy belly"
	walkAnim = "WalkCrawl"
	orderText = "Show me your belly."
	
	poseType = PoseType.Fullbody
	
	animLibraryName = "Poses"

	noSprint = true
	walkSpeed = CRAWL_SPEED
	walkSupportsArmPose = false
	
	preventsPartialGestures = false
