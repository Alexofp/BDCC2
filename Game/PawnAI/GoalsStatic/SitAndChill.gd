extends AIGoalStatic

func _init() -> void:
	id = "SitAndChill"

func getScore() -> float:
	if(pawn.isSittingSomewhere()):
		return 0.0
	return 0.2

func getPlan() -> AIPlan:
	return makePlan().add("SitAndChill")
