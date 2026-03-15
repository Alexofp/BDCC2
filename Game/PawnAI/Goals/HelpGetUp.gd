extends AIGoalPawnTarget

func _init() -> void:
	id = "HelpGetUp"
	importantGoal = true

func isImpossible() -> bool:
	var thePawn := getTarget()
	if(!thePawn || !thePawn.isDefeated()):
		return true
	if(thePawn.global_position.distance_squared_to(pawn.global_position) > 625.0): # 25 meters
		return true
	return false

func start(_args:Array):
	super.start(_args)

func getScore() -> float:
	return 1.0

func getPlan() -> AIPlan:
	return makePlan().add("DoAction", ["DefeatedHelpGetUp", getTarget(), []])

func onPlanCompleted(_plan:AIPlan):
	satisfyGoal()

func onPlanFail(_plan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	failGoal()

func onAction(_action:PawnActionBase, _context:PawnActionContext):
	if(_action.id == "DefeatedHelpGetUp" && _context.target == getTarget()):
		satisfyGoal()

func onDelayedAction(_action:ActionSystemEntry, _context:PawnActionContext):
	pass

func processRare(_dt:float):
	pass
