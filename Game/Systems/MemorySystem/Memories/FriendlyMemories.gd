extends MemorySimpleBank

func _init() -> void:
	memories = {
		"Hug": {
			F_NAME: "Hug",
			F_DESC: "Getting hugged feels good.",
			F_STACKMULT: 0.7,
			F_STACKMAX: 3,
			F_DURATION: 60,
			F_DURATION_EFFECTS: 30,
			
			F_MOOD: 0.08,
		},
		"Chat": {
			F_NAME: "Chat",
			F_DESC: "I had a good chat.",
			F_STACKMULT: 0.7,
			F_STACKMAX: 3,
			F_DURATION: 60,
			F_DURATION_EFFECTS: 30,
			
			F_MOOD: 0.08,
		},
		"Compliment": {
			F_NAME: "Compliment",
			F_DESC: "I got complimented.",
			F_STACKMULT: 0.7,
			F_STACKMAX: 3,
			F_DURATION: 60,
			F_DURATION_EFFECTS: 30,
			
			F_MOOD: 0.08,
		},
	}
