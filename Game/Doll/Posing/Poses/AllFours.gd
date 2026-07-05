extends DollPoseBase

func _init() -> void:
	id = "AllFours"
	animName = "PoseAllFours"
	walkModeCrawl = true
	visibleName = "All fours"
	orderText = "Get on all fours."
	
	poseType = PoseType.Fullbody
	
	animLibraryName = "Poses"
	
	#walkSpeed = CRAWL_SPEED
	walkSupportsArmPose = false
	poseSupportsArmPose = false

func getAnimName(_boundFlags:int = 0) -> String:
	if(_boundFlags & BuffsHolder.BOUND_ARMS):
		return "PoseKneelStand"
	return animName
