extends DollPoseBase

func _init() -> void:
	id = "Kneel"
	animName = "PoseKneel"
	visibleName = "Kneel"
	walkAnim = "WalkCrawl"
	orderText = "Kneel for me."
	
	poseType = PoseType.Fullbody
	
	animLibraryName = "Poses"

	noSprint = true
	walkSpeed = CRAWL_SPEED
	walkSupportsArmPose = false
	
	preventsPartialGestures = false
