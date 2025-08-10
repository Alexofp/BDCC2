extends DollPoseBase

func _init() -> void:
	id = "ShowHands"
	animName = "ShowHands"
	visibleName = "Show hands"
	
	poseType = PoseType.Arms
	
	animLibrary = preload("res://Anims/Raw/Poses.glb")
	animLibraryName = "Poses"

	preventsFullbodyGestures = false
	preventsPartialGestures = false
