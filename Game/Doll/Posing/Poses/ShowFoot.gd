extends DollPoseBase

func _init() -> void:
	id = "ShowFoot"
	animName = "ShowLegs"
	visibleName = "Show foot"
	
	poseType = PoseType.Fullbody
	
	animLibrary = preload("res://Anims/Raw/Poses.glb")
	animLibraryName = "Poses"
