extends DollAnimBase

func _init() -> void:
	anims = {
		"Run": {
			name = "Run",
			anim = "Run",
			moveSpeed = DollController.RUN_MULT_DEFAULT,
		},
	}
	
	animType = TYPE_RUN
	animLibraryName = LOCOMOTION_ANIMS
	animLibraryPath = LOCOMOTION_ANIMS_PATH
