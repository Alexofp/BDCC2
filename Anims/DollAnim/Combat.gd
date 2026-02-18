extends DollAnimBase

func _init() -> void:
	anims = {
		"Punch": {
			name = "Punch",
			anim = "Punch1",
			loopLength = 0.6,
			looped = false,
		},
		"Punch2": {
			name = "Punch 2",
			anim = "Punch2",
			loopLength = 0.8,
			looped = false,
		},
		"DodgeRoll": {
			name = "Dodge roll",
			anim = "DodgeRoll",
			loopLength = 1.0,
			looped = false,
		},
	}
	animType = TYPE_COMBAT
	animLibraryName = COMBAT_ANIMS
	animLibraryPath = COMBAT_ANIMS_PATH
