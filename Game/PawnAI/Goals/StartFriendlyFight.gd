extends AIGoalPawnTarget

func _init() -> void:
	id = "StartFriendlyFight"
	handlingInteractions = ["Talking"]
	importantGoal = true

func isImpossible() -> bool:
	var thePawn := getTarget()
	if(!thePawn || thePawn.isDefeated()):
		return true
	if(thePawn.global_position.distance_squared_to(pawn.global_position) > 625.0): # 25 meters
		return true
	return false

func start(_args:Array):
	super.start(_args)

func getScore() -> float:
	return 1.0

func getPlan() -> AIPlan:
	return makePlan().add("DoAction", ["TalkTest", getTarget(), []])

func onPlanCompleted(_plan:AIPlan):
	#satisfyGoal()
	pass

func onPlanFail(_plan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	failGoal()

func onAction(_action:PawnActionBase, _context:PawnActionContext):
	#if(_action.id == "DefeatedHelpGetUp" && _context.target == getTarget()):
	#	satisfyGoal()
	pass

func onDelayedAction(_action:ActionSystemEntry, _context:PawnActionContext):
	pass

func processRare(_dt:float):
	pass

func getInteractionActionScoreOverride(_interaction:InteractionBase, _action:InteractionAction, _score:float) -> float:
	if(_interaction.id == "Talking" && _action.id == "fight"):
		return 1.0
	
	return _score
