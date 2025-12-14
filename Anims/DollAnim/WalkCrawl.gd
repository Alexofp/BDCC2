extends DollAnimBase

func _init() -> void:
	id = "WalkCrawl"
	animType = TYPE_WALK
	animVisibleName = "Crawl"
	animCanPick = false
	animSupportsArmPoses = false
	
	animName = "CrawlAllFours"
	animLibraryName = POSES_ANIMS
	animLibraryPath = POSES_ANIMS_PATH

func hasCustomCamera() -> bool:
	return true

func processCamera(_springLen:float) -> Vector2:
	if(_springLen <= 0.0):
		return Vector2(0.0, 0.0)
	elif(_springLen <= CLOSE_DISTANCE):
		return Vector2(0.2, 0.525)
	return Vector2(0.3, 0.525)
