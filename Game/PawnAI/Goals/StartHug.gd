extends AIGoalPawnTarget

func _init() -> void:
	id = "StartHug"
	handlingInteractions = ["Talking"]
	importantGoal = true

func isImpossible() -> bool:
	var thePawn := getTarget()
	if(!thePawn || thePawn.isDefeated()):
		return true
	if(thePawn.global_position.distance_squared_to(pawn.global_position) > 625.0): # 25 meters
		return true
	return false

func getScore() -> float:
	return 1.0

func getPlan() -> AIPlan:
	#return makePlan().add("DoSocialInteraction", ["Hug", getTarget(), []])
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

func isSocialInteraction(_interaction:InteractionBase, _action:InteractionAction, _socialInteractionID:String, _args:Array = []) -> bool:
	if(_interaction.id != "Talking"):
		return false
	if(_action.id != "startSocial"):
		return false
	if(_action.args[0].id != _socialInteractionID):
		return false
	if(_action.args[1] != _args):
		return false
	return true

func getInteractionActionScoreOverride(_interaction:InteractionBase, _action:InteractionAction, _score:float) -> float:
	if(isSocialInteraction(_interaction, _action, "Hug")):
		return 1.0
	return _score

func handleInteractionAction(_pawn:CharacterPawn, _interaction:InteractionBase, _action:InteractionAction) -> bool:
	if(_pawn != pawn):
		return false
	if(isSocialInteraction(_interaction, _action, "Hug")):
		satisfyGoal()
		return true
	return false
