extends DollPoseBase

func _init() -> void:
	id = "Kneel2"
	animName = "PoseKneel2"
	visibleName = "Kneel 2"
	walkAnim = "WalkCrawl"
	
	poseType = PoseType.Fullbody
	
	animLibraryName = "Poses"

	noSprint = true
	walkSpeed = CRAWL_SPEED
	walkSupportsArmPose = false
	
	preventsPartialGestures = false
