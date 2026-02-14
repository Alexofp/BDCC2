extends DollAnimBase

func _init() -> void:
	anims = {
		"WalkHobbled": {
			name = "Hobbled",
			anim = "WalkHobbled",
		},
	}
	
	animType = TYPE_WALK
	animCanPick = false
	animLibraryName = LOCOMOTION_ANIMS
	animLibraryPath = LOCOMOTION_ANIMS_PATH
