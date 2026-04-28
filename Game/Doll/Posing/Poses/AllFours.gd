extends DollPoseBase

func _init() -> void:
	id = "AllFours"
	animName = "PoseAllFours"
	visibleName = "All fours"
	walkAnim = "WalkCrawl"
	orderText = "Get on all fours."
	
	poseType = PoseType.Fullbody
	
	animLibraryName = "Poses"
	
	noSprint = true
	walkSpeed = CRAWL_SPEED
	walkSupportsArmPose = false
	poseSupportsArmPose = false
