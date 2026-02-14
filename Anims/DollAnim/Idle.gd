extends DollAnimBase

func _init() -> void:
	anims = {
		"IdleUnisex": {
			name = "Unisex",
			anim = "Idle",
		},
		"IdleFem": {
			name = "Feminine",
			anim = "IdleSexy",
		},
		"IdleMasc": {
			name = "Masculine",
			anim = "IdleLong",
		},
	}
	animType = TYPE_IDLE
	animLibraryName = LOCOMOTION_ANIMS
	animLibraryPath = LOCOMOTION_ANIMS_PATH
