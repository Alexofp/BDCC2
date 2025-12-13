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
