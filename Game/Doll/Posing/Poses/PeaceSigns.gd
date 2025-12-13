extends DollPoseBase

func _init() -> void:
	id = "PeaceSigns"
	animName = "ArmsPeaceSigns"
	visibleName = "Peace signs"
	
	poseType = PoseType.Arms
	
	animLibraryName = "Poses"

	preventsFullbodyGestures = false
	preventsPartialGestures = false
