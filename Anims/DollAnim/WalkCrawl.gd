extends DollAnimBase

func _init() -> void:
	anims = {
		"WalkCrawl": {
			name = "Crawl",
			anim = "CrawlAllFours",
			moveSpeed = 0.5,
			animSpeed = 1.0,
		},
		"WalkCrawlFast": {
			name = "Crawl faster",
			anim = "CrawlAllFoursFast",
			moveSpeed = 1.0,
			animSpeed = 1.5,
		},
		"WalkKneelWalk": {
			name = "Kneel walk",
			anim = "KneelWalk",
			moveSpeed = 0.5,
		},
		"WalkKneelWalkFast": {
			name = "Kneel walk faster",
			anim = "KneelWalk",
			moveSpeed = 1.0,
			animSpeed = 2.0,
		},
	}
	
	animType = TYPE_WALK
	animCanPick = false
	animSupportsArmPoses = false
	animLibraryName = POSES_ANIMS
	animLibraryPath = POSES_ANIMS_PATH

func hasCustomCamera(_id:String) -> bool:
	return true

func processCamera(_id:String, _springLen:float) -> Vector2:
	if(_springLen <= 0.0):
		return Vector2(0.0, 0.0)
	elif(_springLen <= CLOSE_DISTANCE):
		return Vector2(0.2, 0.525)
	return Vector2(0.3, 0.525)

func getLookAtMods(_id:String) -> Vector3:
	return Vector3(0.0, 0.0, 0.0)
