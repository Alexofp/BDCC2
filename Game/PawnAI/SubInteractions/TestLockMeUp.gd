extends InteractionSocialBase

func _init() -> void:
	id = "TestLockMeUp"
	socialActionName = "Lock me up"
	socialActionCategory = CATEGORY_TEST
	
	socialFlags = SOCIALFLAG_SHOULD_END_TALKING
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = 5.0

func canDoSocialAction(_c:SocialInteractionContext) -> bool:
	return true

func start(_roles:Dictionary, _args:Array):
	sayText(ROLE_MAIN, "Lock me up!")

func _plan(_role:int, _action:AIActionBase) -> AIPlan:
	if(_role == ROLE_TARGET):
		var someStocks := GM.world.getNearbyStocks(getPawn(_role).global_position, 100.0)
		if(!someStocks):
			setState("")
			stopInteraction()
			return
		return _action.makePlan("lockIntoStocks").add("ForcePawnSit", [getPawn(ROLE_MAIN), someStocks])
	return plan(_role, _action)

func plan(_role:int, _action:AIActionBase) -> AIPlan:
	if(_role == ROLE_MAIN):
		return _action.makePlan().add("Face", [getPawn(ROLE_TARGET)])
	elif(_role == ROLE_TARGET):
		return _action.makePlan().add("Face", [getPawn(ROLE_MAIN)])
	return null

func onPlanCompleted(_role:int, _action:AIActionBase, _pplan:AIPlan):
	if(_pplan.id == "lockIntoStocks"):
		stopInteraction()

func onPlanFail(_role:int, _action:AIActionBase, _pplan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	if(_pplan.id == "lockIntoStocks"):
		stopInteraction()
