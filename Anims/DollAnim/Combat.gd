extends DollAnimBase

func _init() -> void:
	anims = {
		"Punch": {
			name = "Punch",
			anim = "Punch",
			loopLength = 1.0,
			looped = false,
		},
		"Punch2": {
			name = "Punch 2",
			anim = "Punch",
			loopLength = 0.5,
			looped = false,
		},
	}
	animType = TYPE_COMBAT
	animLibraryName = COMBAT_ANIMS
	animLibraryPath = COMBAT_ANIMS_PATH
