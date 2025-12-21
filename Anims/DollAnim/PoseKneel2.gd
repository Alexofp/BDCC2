extends DollAnimBase

func _init() -> void:
	id = "PoseKneel2"
	animType = TYPE_IDLE
	animVisibleName = "Kneel 2"
	animCanPick = false
	
	animName = "Kneel2"
	animLibraryName = POSES_ANIMS
	animLibraryPath = POSES_ANIMS_PATH

func hasCustomCamera() -> bool:
	return true

func processCamera(_springLen:float) -> Vector2:
	if(_springLen <= 0.0):
		return Vector2(0.0, 0.0)
	elif(_springLen <= CLOSE_DISTANCE):
		return Vector2(0.2, 0.825)
	return Vector2(0.3, 0.525)
