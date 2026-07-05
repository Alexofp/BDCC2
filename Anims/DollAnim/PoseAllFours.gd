extends DollAnimBase

func _init() -> void:
	anims = {
		"PoseAllFours": {
			name = "All fours",
			anim = "AllFours",
		},
		"PoseKneelStand": {
			name = "Kneel stand",
			anim = "KneelStand",
		},
	}
	
	animType = TYPE_IDLE
	animCanPick = false
	animSupportsArmPoses = false
	
	animLibraryName = POSES_ANIMS
	animLibraryPath = POSES_ANIMS_PATH

func hasCustomCamera(_id:String) -> bool:
	return true

func processCamera(_id:String, _springLen:float) -> Vector2:
	if(_springLen <= 0.0):
		return Vector2(0.0, 0.0)
	elif(_springLen <= CLOSE_DISTANCE):
		return Vector2(0.2, 0.525)
	return Vector2(0.3, 0.525)

func getLookAtMods(_id:String) -> Vector3:
	return Vector3(0.5, 0.5, 0.0)
