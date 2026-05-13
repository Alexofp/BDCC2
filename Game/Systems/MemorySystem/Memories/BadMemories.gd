extends MemorySimpleBank
class_name BadMemories

const Attacked := "Attacked"
const Insulted := "Insulted"
const Defeated := "Defeated"

func _init() -> void:
	memories = {
		Attacked: {
			F_NAME: "Got attacked",
			F_DESC: "I got attacked.",
			F_STACKMULT: 0.5,
			F_STACKMAX: 3,
			F_DURATION: 600,
			#F_DURATION_EFFECTS: 30,
			
			F_MOOD: MoodValues.new().setAnger(2.0),
		},
		Insulted: {
			F_NAME: "Insulted",
			F_DESC: "I got insulted.",
			F_STACKMULT: 0.5,
			F_STACKMAX: 3,
			F_DURATION: 600,
			#F_DURATION_EFFECTS: 30,
			
			F_MOOD: MoodValues.new().setAnger(1.1).setMood(-0.7),
		},
		Defeated: {
			F_NAME: "Defeated",
			F_DESC: "I got defeated.",
			F_STACKMULT: 0.1,
			F_STACKMAX: 3,
			F_DURATION: 600,
			#F_DURATION_EFFECTS: 30,
			
			F_MOOD: MoodValues.new().setMood(-0.4),
		},
	}
