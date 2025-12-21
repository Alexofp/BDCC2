extends DollAnimBase

func _init() -> void:
	id = "PosePuppyBelly"
	animType = TYPE_IDLE
	animVisibleName = "Puppy belly"
	animCanPick = false
	
	animName = "PuppyBelly"
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
