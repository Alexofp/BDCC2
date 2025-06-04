extends DollPoseBase

func _init() -> void:
	id = "ArmsBehindBack"
	animName = "ArmsBehindBack"
	visibleName = "Arms behind back"
	
	poseType = PoseType.Arms
	
	animLibrary = preload("res://Anims/Raw/Poses.glb")
	animLibraryName = "Poses"
