extends InteractionBase

var didSomething:bool = false

func _init() -> void:
	id = "Talking"

func getRequiredRoles(_args:Array) -> Dictionary[int, String]:
	return {
		ROLE_MAIN: "main",
		ROLE_TARGET: "target",
	}

func start(_roles:Dictionary, _args:Array):
	lookAt(ROLE_MAIN, ROLE_TARGET)
	say(ROLE_MAIN, "Greet", ROLE_TARGET) #"Talk"
	#startAction(ROLE_TARGET, "Follow", [getCharID(ROLE_MAIN)])
	pushDelay(1.0)
	#pushSay(ROLE_TARGET, "What?")
	pushLookAt(ROLE_TARGET, ROLE_MAIN)
	
	#startSubInteraction("someTag", "Chat", {main=ROLE_MAIN, target=ROLE_TARGET}, [])
	#stopSubInteraction()

func processRareAlways():
	if(checkTooFarAutoStop()):
		return

func _actions(_role:int):
	if(_role == ROLE_MAIN):
		var mainPawn := getPawn(ROLE_MAIN)
		var targetPawn := getPawn(ROLE_TARGET)
		
		var allTheInteractions := GlobalRegistry.getInteractionsBySocialType(InteractionType.Talking)
		for theInteraction in allTheInteractions:
			var theActions := theInteraction.getSocialActions(mainPawn, targetPawn)
			
			for theAction in theActions: 
				theAction.id = "startSocial" # A little hacky but whatever
				theAction.args = [theInteraction, theAction.args]
				
				addAction(theAction)
		
		#addAction(action("chat", "Chat", 0.0).setCategory(CATEGORY_FRIENDLY))
		#addAction(action("hug", "Hug", 0.0).setCategory(CATEGORY_FRIENDLY))
		addAction(action("lock", "Lock me up!", 0.0))
		addAction(action("fight", "Friendly fight!", 0.0))
		
		addAction(action("stop", "Never mind", 0.0).setFallback())
		

func _do(_role:int, _action:InteractionAction):
	if(_action.id == "startSocial"):
		var theInteraction:InteractionBase = _action.args[0]
		var theStartArgs:Array = _action.args[1]
		didSomething = true
		startSubInteraction("subInteractionTag", theInteraction.id, {main=getPawn(ROLE_MAIN),target=getPawn(ROLE_TARGET)}, theStartArgs)
		return
	
	if(_action.id == "stop"):
		#sayText(ROLE_MAIN, "Never mind.")
		if(didSomething):
			say(ROLE_MAIN, "EnoughChat", ROLE_TARGET)
		else:
			say(ROLE_MAIN, "NeverMind", ROLE_TARGET)
		
		stopLookAt(ROLE_MAIN)
		stopLookAt(ROLE_TARGET)
		stopInteraction()
	if(_action.id == "lock"):
		state = "lockme"
		sayText(ROLE_MAIN, "Lock me up!")
	if(_action.id == "fight"):
		#startSubInteraction("ff", "FriendlyFight", {main=getPawn(ROLE_MAIN),target=getPawn(ROLE_TARGET)})
		startInteraction("FriendlyFight", {main=getPawn(ROLE_MAIN),target=getPawn(ROLE_TARGET)})
	if(_action.id == "chat"):
		didSomething = true
		startSubInteraction("chat", "Chat", {main=getPawn(ROLE_MAIN),target=getPawn(ROLE_TARGET)})
	if(_action.id == "hug"):
		didSomething = true
		startSubInteraction("hug", "Hug", {main=getPawn(ROLE_MAIN),target=getPawn(ROLE_TARGET)})

func getActions(_role:int):
	#if(state == "lockme"):
	#	return
	#addAction(action("stop", "Never mind", 0.0).setFallback())
	#addAction(action("lock", "Lock me up!", 0.0))
	#addAction(action("fight", "Friendly fight!", 0.0))
	#addAction(action("fight123", "TEST!", 0.0).setDisabled(true))
	pass

func doAction(_role:int, _action:InteractionAction):
	pass

func onQueueEvent(_eventID:String, _args:Array):
	pass

func lockme_plan(_role:int, _action:AIActionBase) -> AIPlan:
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
