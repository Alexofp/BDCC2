extends MemorySimpleBank
class_name FriendlyMemories

const Hug := "Hug"
const Chat := "Chat"
const Compliment := "Compliment"

func _init() -> void:
	memories = {
		Hug: {
			F_NAME: "Hug",
			F_DESC: "Getting hugged feels good.",
			F_STACKMULT: 0.5,
			F_STACKMAX: 3,
			F_DURATION: 120,
			#F_DURATION_EFFECTS: 30,
			
			F_MOOD: MoodValues.new().setMood(2.0),
		},
		Chat: {
			F_NAME: "Chat",
			F_DESC: "I had a good chat.",
			F_STACKMULT: 0.7,
			F_STACKMAX: 5,
			F_DURATION: 120,
			#F_DURATION_EFFECTS: 60,
			
			F_MOOD: MoodValues.new().setMood(1.1),
		},
		Compliment: {
			F_NAME: "Compliment",
			F_DESC: "I got complimented.",
			F_STACKMULT: 0.5,
			F_STACKMAX: 3,
			F_DURATION: 120,
			#F_DURATION_EFFECTS: 30,
			
			F_MOOD: MoodValues.new().setMood(1.5),
		},
	}
