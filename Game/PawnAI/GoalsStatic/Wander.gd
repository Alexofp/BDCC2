extends AIGoalStatic

func _init() -> void:
	id = "Wander"

func getScore() -> float:
	return 0.2

func getPlan() -> AIPlan:
	return makePlan().add("Wander")
