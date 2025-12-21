extends DollPoseBase

func _init() -> void:
	id = "PuppyBelly"
	animName = "PosePuppyBelly"
	visibleName = "Puppy belly"
	walkAnim = "WalkCrawl"
	
	poseType = PoseType.Fullbody
	
	animLibraryName = "Poses"

	noSprint = true
	walkSpeed = CRAWL_SPEED
	walkSupportsArmPose = false
	
	preventsPartialGestures = false
