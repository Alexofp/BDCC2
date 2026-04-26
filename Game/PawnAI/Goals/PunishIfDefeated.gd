extends AIGoalPawnTarget

func _init() -> void:
	id = "PunishIfDefeated"
	importantGoal = true
	goalTimeout = 120.0
	handlingInteractions = ["DominateDefeated"]

func isImpossible() -> bool:
	var thePawn := getTarget()
	#if(!thePawn || !thePawn.isDefeated()):
	#	return true
	if(thePawn.global_position.distance_squared_to(pawn.global_position) > 625.0): # 25 meters
		return true
	return false

func getScore() -> float:
	return 1.0

func getKeepScore() -> float:
	if(getTarget().hasInteraction()):
		return 0.0
	return super.getKeepScore()

func getPlan() -> AIPlan:
	return makePlan().add("DoAction", ["DefeatedStartPunish", getTarget(), []])

func onPlanCompleted(_plan:AIPlan):
	satisfyGoal()

func onPlanFail(_plan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	failGoal()

# Not implemented but also useless
func onAction(_action:PawnActionBase, _context:PawnActionContext):
	if(_action.id == "DefeatedStartPunish" && _context.target == getTarget()):
		satisfyGoal()

func onDelayedAction(_action:ActionSystemEntry, _context:PawnActionContext):
	pass

func processRare(_dt:float):
	pass

# Currently useless really
func handleInteractionAction(_pawn:CharacterPawn, _interaction:InteractionBase, _action:InteractionAction) -> bool:
	var _isUs:bool = (_pawn == pawn)
	if(_isUs && _interaction.id == "DominateDefeated"):
		if(_action.id == "abort"):
			cancelGoal()
			return true
	return false

func handleInteractionEvent(_interaction:InteractionBase, _eventID:String, _args:Array) -> bool:
	if(_interaction.id == "DominateDefeated"):
		if(_eventID == "complete"):
			satisfyGoal()
			return true
		if(_eventID == "cancel"):
			cancelGoal()
			return true
	return false
