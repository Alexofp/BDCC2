extends DollAnimBase

func _init() -> void:
	anims = {
		"ArmsAboveHead": {
			name = "Arms above head",
			anim = "ArmsAboveHead",
		},
		"ArmsBehindBack": {
			name = "Arms behind back",
			anim = "ArmsBehindBack",
		},
		"ArmsCoveringUp": {
			name = "Covering up",
			anim = "CoveringUp",
		},
		"ArmsCuteHands": {
			name = "Cute hands",
			anim = "CuteHands",
		},
		"ArmsFlippingOff": {
			name = "Flipping off",
			anim = "FlippingOff",
		},
		"ArmsKittyPaws": {
			name = "Kitty paws",
			anim = "KittyPaws",
		},
		"ArmsPeaceSigns": {
			name = "Peace signs",
			anim = "PeaceSigns",
		},
		"ArmsShowHands": {
			name = "Show hands",
			anim = "ShowHands",
		},
	}
	
	animType = TYPE_ARMS
	animLibraryName = POSES_ANIMS
	animLibraryPath = POSES_ANIMS_PATH
