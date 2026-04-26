extends InteractionBase

func _init() -> void:
	id = "DominateDefeated"

func getRequiredRoles(_args:Array) -> Dictionary[int, String]:
	return {
		ROLE_MAIN: "main",
		ROLE_TARGET: "target",
	}

func start(_roles:Dictionary, _args:Array):
	lookAt(ROLE_MAIN, ROLE_TARGET)
	#sayText(ROLE_MAIN, "What's your problem?")
	say(ROLE_MAIN, "OrderDominate", ROLE_TARGET)
	pushDelay(2.0)
	#pushStopInteraction()
	#pushSay(ROLE_TARGET, "What?")
	#pushLookAt(ROLE_TARGET, ROLE_MAIN)

func isRoleAllowedToRecoverFromDefeat(_role:int) -> bool:
	if(_role == ROLE_TARGET):
		return false
	return true

func processRare(_dt:float):
	if(checkTooFarAutoStop()):
		return

func _actions(_role:int):
	if(_role == ROLE_TARGET):
		addAction(action("submit", "Submit completely").setScore(1.0))
		addAction(action("resist", "Deny consent").setScore(0.0))
# OrderDominateDenyConsent OrderDominateUnableToDom OrderDominateAbort
func _do(_role:int, _action:InteractionAction):
	if(_action.id == "resist"):
		setState("resisted")
		pushSay(ROLE_TARGET, "OrderDominateDenyConsent", ROLE_MAIN)
		pushDelay(2.0)
	if(_action.id == "submit"):
		pushSay(ROLE_TARGET, "OrderDominateAnswer", ROLE_MAIN)
		pushDelay(2.0)
		if(!getPawn(ROLE_TARGET).submission.isObeyingPawn(getPawn(ROLE_MAIN)) && !getPawn(ROLE_TARGET).submission.tryMakeObeyPawn(getPawn(ROLE_MAIN))):
			# Something went wrong, abort
			# Should stop the ai goal
			sendAIGoalEvent(ROLE_MAIN, "cancel")
			pushSay(ROLE_MAIN, "OrderDominateUnableToDom", ROLE_MAIN)
			pushDelay(2.0)
			pushStopInteraction()
			return
		pushEvent("startPunish")

func onQueueEvent(_eventID:String, _args:Array):
	if(_eventID == "startPunish"):
		var theMainPawn := getPawn(ROLE_MAIN)
		var theTargetPawn := getPawn(ROLE_TARGET)
		sendAIGoalEvent(ROLE_MAIN, "complete")
		stopInteraction()
		
		if(theMainPawn.isControlledByAnyPlayer()):
			return # Players can just do whatever they want
		
		startInteraction("Defeated", {
			main = theMainPawn,
			target = theTargetPawn,
		})

func resisted_actions(_role:int):
	if(_role == ROLE_MAIN):
		addAction(action("abort", "Leave them alone").setScore(1.0))
		# Some alternative small punishments here that don't involve kinks. Like yoinking some credits

func resisted_do(_role:int, _action:InteractionAction):
	if(_action.id == "abort"):
		# Should stop the ai goal
		sendAIGoalEvent(ROLE_MAIN, "cancel")
		pushSay(ROLE_MAIN, "OrderDominateAbort", ROLE_MAIN)
		pushDelay(2.0)
		pushStopInteraction()
