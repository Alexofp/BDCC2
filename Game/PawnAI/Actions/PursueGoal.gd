extends AIActionBase

func _init() -> void:
	id = "PursueGoal"

func start(_args:Array):
	pass

func isImpossible() -> bool:
	if(!ai.goalHandler.getCurrentGoal()):
		return true
	return false

func onEnd():
	pass

func plan() -> AIPlan:
	return ai.goalHandler.getCurrentGoal().getPlan()

func onPlanCompleted(_plan:AIPlan):
	ai.goalHandler.onPlanCompleted(_plan)

func onPlanFail(_plan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	ai.goalHandler.onPlanFail(_plan, _failedAction, _failStatus)

func onGettingHit(_attackContext:AttackContext) -> bool:
	#var theInteraction := getInteraction()
	#return theInteraction.onGettingHit(theInteraction.getRoleOf(getPawn()), _attackContext)
	return false

func isHandlingCombat() -> bool:
	#var theInteraction := getInteraction()
	#return theInteraction.isHandlingCombat(theInteraction.getRoleOf(getPawn()))
	return false

func think():
	pass

func onSubActionResult(_tag:String, _status:int, _result:Array):
	pass

func onSubEvent(_eventID:String, _args:Array):
	pass
