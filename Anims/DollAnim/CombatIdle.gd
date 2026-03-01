extends DollAnimBase

func _init() -> void:
	anims = {
		"CollapseIdle": {
			name = "CollapseIdle",
			anim = "CollapseIdle",
		},
		"CollapseFlyingIdle": {
			name = "CollapseFlyingIdle",
			anim = "CollapseFlyingIdle",
		},
	}
	animType = TYPE_IDLE
	animLibraryName = COMBAT_ANIMS
	animLibraryPath = COMBAT_ANIMS_PATH
