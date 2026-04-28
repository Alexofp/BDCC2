extends DollPoseBase

func _init() -> void:
	id = "PeaceSigns"
	animName = "ArmsPeaceSigns"
	visibleName = "Peace signs"
	orderText = "Do peace signs for me."
	
	poseType = PoseType.Arms
	
	animLibraryName = "Poses"

	preventsFullbodyGestures = false
	preventsPartialGestures = false
