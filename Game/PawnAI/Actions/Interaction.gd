extends AIActionBase

func _init() -> void:
	id = "Interaction"

func start(_args:Array):
	pass

func isImpossible() -> bool:
	if(!getInteraction()):
		return true
	return false

func onEnd():
	pass

func processAction(_dt:float):
	pass

func plan() -> AIPlan:
	var theInteraction := getInteraction()
	if(!theInteraction):
		return null
	return theInteraction.planFor(getPawn(), self)

func onPlanCompleted(_plan:AIPlan):
	var theInteraction := getInteraction()
	if(!theInteraction):
		return
	return theInteraction.onPlanCompletedFor(getPawn(), self, _plan)

func onPlanFail(_plan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	var theInteraction := getInteraction()
	if(!theInteraction):
		return
	return theInteraction.onPlanFailFor(getPawn(), self, _plan, _failedAction, _failStatus)

func handleInteractionStateChange(_interaction:InteractionBase) -> bool:
	replan()
	return true

func onGettingHit(_attackContext:AttackContext) -> bool:
	var theInteraction := getInteraction()
	return theInteraction && theInteraction.onGettingHitFor(getPawn(), _attackContext)

func isHandlingCombat() -> bool:
	var theInteraction := getInteraction()
	return theInteraction && theInteraction.isHandlingCombatFor(getPawn())

func think():
	var theInteraction := getInteraction()
	if(!theInteraction):
		completeAction()
		return
	var thePawn := getPawn()
	theInteraction.thinkFor(thePawn, self)
	
	# Action selection
	var theActions := theInteraction.getActionsFor(thePawn)
	var fullScore:float = 0.0
	var fullFallbackScore:float = 0.0
	var theWeightMap:Dictionary[InteractionAction, float]
	var theFallbackMap:Dictionary[InteractionAction, float]
	for theAction in theActions:
		if(theAction.disabled):
			continue
		var actionScore:float = theAction.score
		actionScore = ai.goalHandler.getInteractionActionScoreOverride(theInteraction, theAction, actionScore)
		if(theAction.fallbackScore > 0.0):
			theFallbackMap[theAction] = theAction.fallbackScore
			fullFallbackScore += theAction.fallbackScore
		if(theAction.timeoutTime > 0.0 && theInteraction.timeoutTime >= theAction.timeoutTime):
			actionScore = maxf(actionScore, theAction.timeoutScore)
		
		if(actionScore <= 0.0):
			continue
		fullScore += actionScore
		theWeightMap[theAction] = actionScore
	
	if(theWeightMap.is_empty() && !theFallbackMap.is_empty() && RNG.chance(fullFallbackScore * 100.0)):
		var theFallbackActionToDo:InteractionAction = RNG.pickWeightedDict(theFallbackMap)
		theInteraction.doActionFor(thePawn, theFallbackActionToDo)
		return
	
	if(theWeightMap.is_empty() || !RNG.chance(fullScore * 100.0)):
		return
	var theActionToDo:InteractionAction = RNG.pickWeightedDict(theWeightMap)
	if(!theActionToDo):
		return
	theInteraction.doActionFor(thePawn, theActionToDo)

func onSubActionResult(_tag:String, _status:int, _result:Array):
	var theInteraction := getInteraction()
	if(!theInteraction):
		return
	var theRole:int = theInteraction.getRoleOf(getPawn())
	if(theRole < 0):
		return
	theInteraction.onSubActionResult(theRole, getPawn(), ai, self, _tag, _status, _result)

func onSubEvent(_eventID:String, _args:Array):
	pass

func getDebugText() -> String:
	var theInteraction := getInteraction()
	if(theInteraction):
		return theInteraction.id
	return ""
