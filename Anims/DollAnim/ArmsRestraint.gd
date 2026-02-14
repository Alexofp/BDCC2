extends DollAnimBase

func _init() -> void:
	anims = {
		"ArmsArmbinder": {
			name = "Armbinder",
			anim = "APoseArmbinder",
		},
		"ArmsCuffedBehindBack": {
			name = "Cuffed behind back",
			anim = "CuffedBehindBack",
		},
		"ArmsCuffedFront": {
			name = "Cuffed front",
			anim = "CuffedFront",
		},
	}
	
	animType = TYPE_ARMS
	animLibraryName = RESTRAINT_ANIMS
	animLibraryPath = RESTRAINT_ANIMS_PATH
