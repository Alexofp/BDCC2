extends DollPoseBase

func _init() -> void:
	id = "ArmsBehindBack"
	animName = "ArmsBehindBack"
	visibleName = "Arms behind back"
	orderText = "Hands behind your back."
	
	poseType = PoseType.Arms
	
	animLibraryName = "Poses"

	preventsPartialGestures = false
	preventsFullbodyGestures = false
