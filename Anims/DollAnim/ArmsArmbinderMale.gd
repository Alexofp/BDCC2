extends DollAnimBase

func _init() -> void:
	anims = {
		"ArmsArmbinderMale": {
			name = "Armbinder male",
			anim = "APoseArmbinderMale",
		},
	}
	
	animType = TYPE_ARMS
	animLibraryName = ARMBINDERANIMMALE_ANIMS
	animLibraryPath = ARMBINDERANIMMALE_ANIMS_PATH
