extends InteractionSocialBase

func _init() -> void:
	id = "DefeatLockUp"
	socialActionName = "Lock up"
	socialDefaultScore = 1.0
	#socialActionCategory = CATEGORY_FRIENDLY
	
	registerForInteractionType = [InteractionType.Defeated]

func start(_roles:Dictionary, _args:Array):
	lookAt(ROLE_MAIN, ROLE_TARGET)
	say(ROLE_MAIN, "DefeatLockUpStart", ROLE_TARGET) #"Talk"
	#startAction(ROLE_TARGET, "Follow", [getCharID(ROLE_MAIN)])
	pushDelay(1.0)
	#pushSay(ROLE_TARGET, "What?")
	#pushLookAt(ROLE_TARGET, ROLE_MAIN)
	
	#startSubInteraction("someTag", "Chat", {main=ROLE_MAIN, target=ROLE_TARGET}, [])
	#stopSubInteraction()

#func processRareAlways(_dt:float):
#	if(checkTooFarAutoStop()):
#		return
#
#func _actions(_role:int):
	#if(_role == ROLE_MAIN):
		#var mainPawn := getPawn(ROLE_MAIN)
		#var targetPawn := getPawn(ROLE_TARGET)
		#
		#var haveVeryImportantButtons:bool = false
		#if(true):
			#var allTheInteractions := GlobalRegistry.getInteractionsBySocialType(InteractionType.VeryImportant)
			#for theInteraction in allTheInteractions:
				#var theActions := theInteraction.getSocialActions(mainPawn, targetPawn)
				#
				#for theAction in theActions: 
					#theAction.id = "startSocial" # A little hacky but whatever
					#theAction.args = [theInteraction, theAction.args]
					#addAction(theAction)
					#haveVeryImportantButtons = true
#
		#if(!haveVeryImportantButtons):
			#var allTheInteractions := GlobalRegistry.getInteractionsBySocialType(InteractionType.Talking)
			#for theInteraction in allTheInteractions:
				#var theActions := theInteraction.getSocialActions(mainPawn, targetPawn)
				#
				#for theAction in theActions: 
					#theAction.id = "startSocial" # A little hacky but whatever
					#theAction.args = [theInteraction, theAction.args]
					#
					#addAction(theAction)
			#
			##addAction(action("chat", "Chat", 0.0).setCategory(CATEGORY_FRIENDLY))
			##addAction(action("hug", "Hug", 0.0).setCategory(CATEGORY_FRIENDLY))
			#addAction(action("lock", "Lock me up!", 0.0))
			#addAction(action("fight", "Friendly fight!", 0.0))
			#
			#addAction(action("stop", "Never mind", 0.0).setFallback())
		#
#
#func _do(_role:int, _action:InteractionAction):
	#if(_action.id == "startSocial"):
		#var theInteraction:InteractionBase = _action.args[0]
		#var theStartArgs:Array = _action.args[1]
		#didSomething = true
		#startSubInteraction("subInteractionTag", theInteraction.id, {main=getPawn(ROLE_MAIN),target=getPawn(ROLE_TARGET)}, theStartArgs)
		#return
	#
	#if(_action.id == "stop"):
		##sayText(ROLE_MAIN, "Never mind.")
		#if(didSomething):
			#say(ROLE_MAIN, "EnoughChat", ROLE_TARGET)
		#else:
			#say(ROLE_MAIN, "NeverMind", ROLE_TARGET)
		#
		#stopLookAt(ROLE_MAIN)
		#stopLookAt(ROLE_TARGET)
		#stopInteraction()
	#if(_action.id == "lock"):
		#state = "lockme"
		#sayText(ROLE_MAIN, "Lock me up!")
	#if(_action.id == "fight"):
		##startSubInteraction("ff", "FriendlyFight", {main=getPawn(ROLE_MAIN),target=getPawn(ROLE_TARGET)})
		#startInteraction("FriendlyFight", {main=getPawn(ROLE_MAIN),target=getPawn(ROLE_TARGET)})

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

func timeToSex_plan(_role:int, _action:AIActionBase) -> AIPlan:
	if(_role == ROLE_MAIN):
		var theTarget := getPawn(ROLE_TARGET)
		var theStocksProp := theTarget.getSitPropHandler()
		if(!theStocksProp || !theStocksProp.canStartSexOnProp([getPawn(ROLE_MAIN), theTarget])):
			stopInteraction()
			return null
		return _action.makePlan("doSex").add("DoAction", ["Generic", theStocksProp, ["use"]])
	return super.plan(_role, _action)

func onSexEngineResult(_result:SexEngineResult):
	pushSay(ROLE_MAIN, "DefeatLockUpAfterSex", ROLE_TARGET)
	pushDelay(2.0)
	pushStopInteraction()

func doingSex_plan(_role:int, _action:AIActionBase) -> AIPlan:
	return null

func _plan(_role:int, _action:AIActionBase) -> AIPlan:
	if(_role == ROLE_MAIN):
		var someStocks := GM.world.getNearbyStocks(getPawn(_role).global_position, 100.0)
		if(!someStocks):
			setState("")
			stopInteraction()
			return
		return _action.makePlan("lockIntoStocks").add("ForcePawnSit", [getPawn(ROLE_TARGET), someStocks])
	return super.plan(_role, _action)

func onPlanCompleted(_role:int, _action:AIActionBase, _thePlan:AIPlan):
	if(_thePlan.id == "doSex"):
		setState("doingSex")
	if(_thePlan.id == "lockIntoStocks"):
		var theTarget := getPawn(ROLE_TARGET)
		var theStocksProp := theTarget.getSitPropHandler()
		
		if(RNG.chance(100) && theStocksProp && theStocksProp.canStartSexOnProp([getPawn(ROLE_MAIN), theTarget])):
			setState("timeToSex")
			pushSay(ROLE_MAIN, "DefeatLockUpSex", ROLE_TARGET)
			pushDelay(3.0)
		else:
			setState("afterLock")
			pushSay(ROLE_MAIN, "DefeatLockUpEnd", ROLE_TARGET)
			pushDelay(2.0)
			pushStopInteraction()

func onPlanFail(_role:int, _action:AIActionBase, _thePlan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	#if(_thePlan.id == "lockIntoStocks"):
	stopInteraction()

func onGettingHit(_role:int, _attackContext:AttackContext) -> bool:
	#if(_attackContext.attacker != getPawn(ROLE_MAIN) && _attackContext.attacker != getPawn(ROLE_TARGET)):
	#	stopInteraction()
	#	return false
	#return true
	stopInteraction()
	return false

func isHandlingCombat(_role:int) -> bool:
	return true
