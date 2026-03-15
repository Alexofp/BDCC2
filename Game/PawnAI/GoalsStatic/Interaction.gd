extends AIGoalStatic

func _init() -> void:
	id = "Interaction"
	importantGoal = true

func getScore() -> float:
	if(!pawn.hasInteraction()):
		return 0.0
	return 100.0

func getPlan() -> AIPlan:
	return makePlan().add("Interaction")
