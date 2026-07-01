extends DollAnimBase

func _init() -> void:
	anims = {
		"ArmsArmbinder": {
			name = "Armbinder",
			anim = "APoseArmbinder",
		},
		"ArmsArmbinderMale": {
			name = "Armbinder male",
			anim = "APoseArmbinderMale",
		},
	}
	
	animType = TYPE_ARMS
	animLibraryName = ARMBINDERANIM_ANIMS
	animLibraryPath = ARMBINDERANIM_ANIMS_PATH
