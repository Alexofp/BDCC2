extends DollPoseBase

func _init() -> void:
	id = "FlippingOff"
	animName = "ArmsFlippingOff"
	visibleName = "Flipping off"
	orderText = "Show your middle finger."
	
	poseType = PoseType.Arms
	
	animLibraryName = "Poses"

	preventsFullbodyGestures = false
	preventsPartialGestures = false
