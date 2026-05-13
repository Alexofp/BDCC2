extends InteractionBase

var didSomething:bool = false
var socialContext:SocialInteractionContext = SocialInteractionContext.new()

func _init() -> void:
	id = "Defeated"

func getRequiredRoles(_args:Array) -> Dictionary[int, String]:
	return {
		ROLE_MAIN: "main",
		ROLE_TARGET: "target", # Defeated npc/pc
	}

func start(_roles:Dictionary, _args:Array):
	socialContext.setup(getPawn(ROLE_MAIN), getPawn(ROLE_TARGET))
	lookAt(ROLE_MAIN, ROLE_TARGET)
	say(ROLE_MAIN, "DefeatedWhatDo", ROLE_TARGET) #"Talk"
	pushDelay(1.0)
	#pushLookAt(ROLE_TARGET, ROLE_MAIN)

func processRareAlways(_dt:float):
	if(checkTooFarAutoStop()):
		return

func _actions(_role:int):
	if(_role == ROLE_MAIN):
		var allTheInteractions := GlobalRegistry.getInteractionsBySocialType(InteractionType.Defeated)
		for theInteraction in allTheInteractions:
			var theActions := theInteraction.getSocialActions(socialContext)
			
			for theAction in theActions: 
				theAction.id = "startSocial" # A little hacky but whatever
				theAction.args = [theInteraction, theAction.args]
				
				addAction(theAction)
		
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

func plan(_role:int, _action:AIActionBase) -> AIPlan:
	if(_role == ROLE_MAIN):
		return _action.makePlan().add("ApproachPawn", [getPawn(ROLE_TARGET)])
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

func onGettingHit(_role:int, _attackContext:AttackContext) -> bool:
	#if(_attackContext.attacker != getPawn(ROLE_MAIN) && _attackContext.attacker != getPawn(ROLE_TARGET)):
	#	stopInteraction()
	#	return false
	#return true
	stopInteraction()
	return false

func isHandlingCombat(_role:int) -> bool:
	return true

func onSubInteractionEnd(_interaction:InteractionBase):
	stopInteraction()
