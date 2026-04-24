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

func getLookAtMods(_id:String) -> Vector3:
	return Vector3(0.0, 0.0, 0.0)
