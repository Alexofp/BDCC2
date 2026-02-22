extends DollAnimBase

func _init() -> void:
	anims = {
		"Punch": {
			name = "Punch",
			anim = "Punch1",
			loopLength = 0.6,
			looped = false,
		},
		"Punch2": {
			name = "Punch 2",
			anim = "Punch2",
			loopLength = 0.8,
			looped = false,
		},
		"Punch3": {
			name = "Punch 3",
			anim = "Punch3",
			loopLength = 0.8,
			looped = false,
		},
		"PunchSuperman": {
			name = "Punch Superman",
			anim = "PunchSuperman",
			loopLength = 1.0,
			looped = false,
		},
		"DodgeRoll": {
			name = "Dodge roll",
			anim = "DodgeRoll",
			loopLength = 1.0,
			looped = false,
		},
		"Kick": {
			name = "Kick",
			anim = "Kick1",
			loopLength = 1.0,
			looped = false,
		},
		"Kick2": {
			name = "Kick 2",
			anim = "Kick2",
			loopLength = 1.0,
			looped = false,
		},
		"Kick3": {
			name = "Kick 3",
			anim = "Kick3",
			loopLength = 1.3,
			looped = false,
		},
		"KickAirKnee": {
			name = "Kick air knee",
			anim = "KickAirKnee",
			loopLength = 1.0,
			looped = false,
		},
		"LegSweep": {
			name = "Leg sweep",
			anim = "LegSweep",
			loopLength = 1.0,
			looped = false,
		},
		"CollapseToCombat": {
			name = "CollapseToCombat",
			anim = "CollapseToCombat",
			#loopLength = 1.0,
			#looped = false,
		},
		"CollapseFromCombat": {
			name = "CollapseFromCombat",
			anim = "CollapseFromCombat",
			#loopLength = 1.0,
			#looped = false,
		},
		"GettingHitStrong": {
			name = "GettingHitStrong",
			anim = "GettingHitStrong",
			#loopLength = 1.0,
			#looped = false,
		},
	}
	animType = TYPE_COMBAT
	animLibraryName = COMBAT_ANIMS
	animLibraryPath = COMBAT_ANIMS_PATH
