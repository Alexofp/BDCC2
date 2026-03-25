extends DollAnimBase

func _init() -> void:
	anims = {
		"Hug_1": {
			name = "Hug_1",
			anim = "Hug_1",
		},
		"Hug_2": {
			name = "Hug_2",
			anim = "Hug_2",
		},
	}
	animType = TYPE_COUPLE
	animLibraryName = FRIENDLY_ANIMS
	animLibraryPath = FRIENDLY_ANIMS_PATH
