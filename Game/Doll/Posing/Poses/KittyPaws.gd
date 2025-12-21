extends DollPoseBase

func _init() -> void:
	id = "KittyPaws"
	animName = "ArmsKittyPaws"
	visibleName = "Kitty paws"
	
	poseType = PoseType.Arms
	
	animLibraryName = "Poses"

	preventsFullbodyGestures = false
	preventsPartialGestures = false
