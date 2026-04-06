extends AIGoalPawnTarget

func _init() -> void:
	id = "PunishIfDefeated"
	importantGoal = true
	goalTimeout = 120.0

func isImpossible() -> bool:
	var thePawn := getTarget()
	#if(!thePawn || !thePawn.isDefeated()):
	#	return true
	if(thePawn.global_position.distance_squared_to(pawn.global_position) > 625.0): # 25 meters
		return true
	return false

func getScore() -> float:
	return 1.0

func getPlan() -> AIPlan:
	return makePlan().add("DoAction", ["DefeatedStartPunish", getTarget(), []])

func onPlanCompleted(_plan:AIPlan):
	satisfyGoal()

func onPlanFail(_plan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	failGoal()

func onAction(_action:PawnActionBase, _context:PawnActionContext):
	if(_action.id == "DefeatedStartPunish" && _context.target == getTarget()):
		satisfyGoal()

func onDelayedAction(_action:ActionSystemEntry, _context:PawnActionContext):
	pass

func processRare(_dt:float):
	pass
