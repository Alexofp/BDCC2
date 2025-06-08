extends DollPoseBase

func _init() -> void:
	id = "FlippingOff"
	animName = "FlippingOff"
	visibleName = "Flipping off"
	
	poseType = PoseType.Arms
	
	animLibrary = preload("res://Anims/Raw/Poses.glb")
	animLibraryName = "Poses"
