extends AIGoalStatic

func _init() -> void:
	id = "Obey"
	importantGoal = true

func getScore() -> float:
	if(!pawn.submission.isObeying()):
		return 0.0
	return 69.0

func getKeepScore() -> float:
	if(!pawn.submission.isObeying()):
		return 0.0
	return super.getKeepScore()

func getPlan() -> AIPlan:
	return makePlan().add("Obey")
