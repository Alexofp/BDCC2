extends DollPoseBase

func _init() -> void:
	id = "Kneel"
	animName = "PoseKneel"
	visibleName = "Kneel"
	walkAnim = "WalkCrawl"
	
	poseType = PoseType.Fullbody
	
	animLibraryName = "Poses"

	noSprint = true
	walkSpeed = CRAWL_SPEED
	walkSupportsArmPose = false
	
	preventsPartialGestures = false

func hasCustomCamera() -> bool:
	return true

func processCamera(_springLen:float) -> Vector2:
	if(_springLen <= 0.0):
		return Vector2(0.0, 0.0)
	elif(_springLen <= CLOSE_DISTANCE):
		return Vector2(0.2, 0.825)
	return Vector2(0.3, 0.525)
