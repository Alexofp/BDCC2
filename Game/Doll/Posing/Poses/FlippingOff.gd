extends DollPoseBase

func _init() -> void:
	id = "FlippingOff"
	animName = "ArmsFlippingOff"
	visibleName = "Flipping off"
	
	poseType = PoseType.Arms
	
	animLibraryName = "Poses"

	preventsFullbodyGestures = false
	preventsPartialGestures = false
