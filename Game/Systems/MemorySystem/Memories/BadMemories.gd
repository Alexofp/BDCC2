extends MemorySimpleBank
class_name BadMemories

const Attacked := "Attacked"

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
	}
