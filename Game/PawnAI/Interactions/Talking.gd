extends InteractionBase

func _init() -> void:
	id = "Talking"

func getRequiredRoles(_args:Array) -> Dictionary[int, String]:
	return {
		ROLE_MAIN: "main",
		ROLE_TARGET: "target",
	}

func start(_roles:Dictionary, _args:Array):
	lookAt(ROLE_MAIN, ROLE_TARGET)
	say(ROLE_MAIN, "Talk", ROLE_TARGET)
	#startAction(ROLE_TARGET, "Follow", [getCharID(ROLE_MAIN)])
	pushDelay(1.0)
	#pushSay(ROLE_TARGET, "What?")
	pushLookAt(ROLE_TARGET, ROLE_MAIN)

func processRare():
	if(getDistanceBetween(ROLE_MAIN, ROLE_TARGET) > 10.0):
		stopInteraction()

func getActions(_role:int):
	#if(state == "lockme"):
	#	return
	addAction(action("stop", "Never mind", 0.0))
	addAction(action("lock", "Lock me up!", 0.0))
	addAction(action("fight", "Friendly fight!", 0.0))

func doAction(_role:int, _action:InteractionAction):
	if(_action.id == "stop"):
		#sayText(ROLE_MAIN, "Never mind.")
		stopLookAt(ROLE_MAIN)
		stopLookAt(ROLE_TARGET)
		stopInteraction()
	if(_action.id == "lock"):
		setState("lockme")
		sayText(ROLE_MAIN, "Lock me up!")
	if(_action.id == "fight"):
		startInteraction("FriendlyFight", {main=ROLE_MAIN,target=ROLE_TARGET})

func onQueueEvent(_eventID:String, _args:Array):
	pass

func plan(_role:int, _action:AIActionBase) -> AIPlan:
	if(state == "lockme" && _role == ROLE_TARGET):
		var someStocks := GM.world.getNearbyStocks(getPawn(_role).global_position, 100.0)
		if(!someStocks):
			setState("")
			stopInteraction()
			return
		return _action.makePlan("lockIntoStocks").add("ForcePawnSit", [getPawn(ROLE_MAIN), someStocks])
	
	if(_role == ROLE_MAIN):
		return _action.makePlan().add("Follow", [getPawn(ROLE_TARGET)])
	elif(_role == ROLE_TARGET):
		return _action.makePlan().add("Follow", [getPawn(ROLE_MAIN)])
	
	return null

func onPlanCompleted(_role:int, _action:AIActionBase, _plan:AIPlan):
	if(_plan.id == "lockIntoStocks"):
		stopInteraction()

func onPlanFail(_role:int, _action:AIActionBase, _plan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	if(_plan.id == "lockIntoStocks"):
		stopInteraction()

func think(_role:int, _pawn:CharacterPawn, _ai:PawnAI, _action:AIActionBase):
	pass
		
func onSubActionResult(_role:int, _pawn:CharacterPawn, _ai:PawnAI, _action:AIActionBase, _tag:String, _status:int, _result:Array):
	pass
