extends AIGoalStatic

func _init() -> void:
	id = "Despawn"

func getScore() -> float:
	if(pawn.isControlledByAnyPlayer()):
		return 0.0
	if(GM.main.doesPawnHavePlayerDataAndPlayerIsGone(pawn)): # Pawns of disconnected players try to leave asap
		return 1.0
	if(pawn.howLongOut > WorldPawnSpawner.PawnGoToSleepAfter):
		return 0.5
	elif(pawn.howLongOut > WorldPawnSpawner.PawnGoToSleepAfter*0.6):
		return 0.01
	elif(pawn.howLongOut > WorldPawnSpawner.PawnGoToSleepAfter*0.8):
		return 0.05
	elif(pawn.howLongOut > WorldPawnSpawner.PawnGoToSleepAfter*0.9):
		return 0.1
	return 0.0

func getPlan() -> AIPlan:
	return makePlan().add("Despawn")
