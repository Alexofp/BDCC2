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
	return theInteraction.plan(theInteraction.getRoleOf(getPawn()), self)

func onPlanCompleted(_plan:AIPlan):
	var theInteraction := getInteraction()
	if(!theInteraction):
		return
	return theInteraction.onPlanCompleted(theInteraction.getRoleOf(getPawn()), self, _plan)

func onPlanFail(_plan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	var theInteraction := getInteraction()
	if(!theInteraction):
		return
	return theInteraction.onPlanFail(theInteraction.getRoleOf(getPawn()), self, _plan, _failedAction, _failStatus)

func handleInteractionStateChange(_interaction:InteractionBase) -> bool:
	replan()
	return true

func onGettingHit(_attackContext:AttackContext) -> bool:
	var theInteraction := getInteraction()
	return theInteraction && theInteraction.onGettingHit(theInteraction.getRoleOf(getPawn()), _attackContext)

func isHandlingCombat() -> bool:
	var theInteraction := getInteraction()
	return theInteraction && theInteraction.isHandlingCombat(theInteraction.getRoleOf(getPawn()))

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
	var theWeightMap:Dictionary[InteractionAction, float]
	for theAction in theActions:
		var actionScore:float = theAction.score
		actionScore = ai.goalHandler.getInteractionActionScoreOverride(theInteraction, theAction, actionScore)
		
		if(actionScore <= 0.0):
			continue
		fullScore += actionScore
		theWeightMap[theAction] = actionScore
	
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
