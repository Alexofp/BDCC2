extends DollAnimBase

func _init() -> void:
	anims = {
		"PoseInspection": {
			name = "Inspection",
			anim = "Inspection",
		},
		"PoseKneel": {
			name = "Kneel",
			anim = "Kneel",
		},
		"PoseKneel2": {
			name = "Kneel 2",
			anim = "Kneel2",
		},
		"PosePuppyBelly": {
			name = "Puppy belly",
			anim = "PuppyBelly",
		},
		"PoseShowFoot": {
			name = "Show foot",
			anim = "ShowLegs",
		},
	}
	
	animType = TYPE_IDLE
	animCanPick = false
	animLibraryName = POSES_ANIMS
	animLibraryPath = POSES_ANIMS_PATH

func hasCustomCamera(_id:String) -> bool:
	if(_id == "PoseInspection"):
		return false
	if(_id == "PoseShowFoot"):
		return false
	return true

func processCamera(_id:String, _springLen:float) -> Vector2:
	if(_springLen <= 0.0):
		return Vector2(0.0, 0.0)
	elif(_springLen <= CLOSE_DISTANCE):
		return Vector2(0.2, 0.825)
	return Vector2(0.3, 0.525)
