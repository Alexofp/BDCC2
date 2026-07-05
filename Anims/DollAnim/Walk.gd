extends DollAnimBase

func _init() -> void:
	anims = {
		"WalkUnisex": {
			name = "Unisex",
			anim = "WalkUnisex",
		},
		"WalkFem": {
			name = "Feminine",
			anim = "WalkFem",
		},
	}
	
	animCanPick = true
	animType = TYPE_WALK
	animLibraryName = LOCOMOTION_ANIMS
	animLibraryPath = LOCOMOTION_ANIMS_PATH
