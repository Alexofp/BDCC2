extends DollPoseBase

func _init() -> void:
	id = "AllFours"
	animName = "AllFours"
	visibleName = "All fours"
	walkAnim = "CrawlAllFours"
	
	poseType = PoseType.Fullbody
	
	animLibrary = preload("res://Anims/Raw/Poses.glb")
	animLibraryName = "Poses"
	
	noSprint = true
	walkSpeed = CRAWL_SPEED
	walkSupportsArmPose = false
	poseSupportsArmPose = false

func hasCustomCamera() -> bool:
	return true

func processCamera(_springLen:float) -> Vector2:
	if(_springLen <= 0.0):
		return Vector2(0.0, 0.0)
	elif(_springLen <= CLOSE_DISTANCE):
		return Vector2(0.2, 0.525)
	return Vector2(0.3, 0.525)
