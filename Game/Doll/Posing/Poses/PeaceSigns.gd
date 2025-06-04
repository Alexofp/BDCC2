extends DollPoseBase

func _init() -> void:
	id = "PeaceSigns"
	animName = "PeaceSigns"
	visibleName = "Peace signs"
	
	poseType = PoseType.Arms
	
	animLibrary = preload("res://Anims/Raw/Poses.glb")
	animLibraryName = "Poses"
