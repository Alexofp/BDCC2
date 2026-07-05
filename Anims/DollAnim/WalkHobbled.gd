extends DollAnimBase

func _init() -> void:
	anims = {
		"WalkHobbled": {
			name = "Hobbled",
			anim = "WalkHobbled",
			moveSpeed = 0.5,
		},
		"WalkHobbledFast": {
			name = "Hobbled faster",
			anim = "WalkHobbledFast",
			moveSpeed = 1.0,
			animSpeed = 1.5,
		},
	}
	
	animType = TYPE_WALK
	animCanPick = false
	animLibraryName = LOCOMOTION_ANIMS
	animLibraryPath = LOCOMOTION_ANIMS_PATH
