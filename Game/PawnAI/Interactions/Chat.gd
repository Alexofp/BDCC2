extends InteractionBase

func _init() -> void:
	id = "Chat"

func getRequiredRoles(_args:Array) -> Dictionary[int, String]:
	return {
		ROLE_MAIN: "main",
		ROLE_TARGET: "target",
	}

func start(_roles:Dictionary, _args:Array):
	#lookAt(ROLE_MAIN, ROLE_TARGET)
	#sayText(ROLE_MAIN, "What's your problem?")
	say(ROLE_MAIN, "WannaChat", ROLE_TARGET)
	pushDelay(2.0)

func _actions(_role:int):
	if(_role == ROLE_TARGET):
		addAction(action("yes", "Yes", 1.0))
		addAction(action("no", "No", 0.0))

func _do(_role:int, _action:InteractionAction):
	if(_action.id == "yes"):
		#state = "chat"
		say(ROLE_TARGET, "Sure", ROLE_MAIN)
		pushDelay(3.0)
		pushSay(ROLE_MAIN, "Talk", ROLE_TARGET)
		pushDelay(4.0)
		pushSay(ROLE_TARGET, "Talk", ROLE_MAIN)
		pushDelay(4.0)
		pushEvent("addAffection")
		pushStopInteraction()
	if(_action.id == "no"):
		say(ROLE_TARGET, "No", ROLE_MAIN)
		pushDelay(2.0)
		pushEvent("remAffection")
		pushStopInteraction()

func onQueueEvent(_eventID:String, _args:Array):
	if(_eventID == "addAffection"):
		getPawn(ROLE_MAIN).addSmallText("Affection+", Color.GREEN)
		getPawn(ROLE_TARGET).addSmallText("Affection+", Color.GREEN)
	if(_eventID == "remAffection"):
		getPawn(ROLE_MAIN).addSmallText("Affection-", Color.RED)
		getPawn(ROLE_TARGET).addSmallText("Affection-", Color.RED)

func processRare():
	if(getDistanceBetween(ROLE_MAIN, ROLE_TARGET) > 10.0):
		stopInteraction()

func plan(_role:int, _action:AIActionBase) -> AIPlan:
	if(_role == ROLE_MAIN):
		return _action.makePlan().add("Face", [getPawn(ROLE_TARGET)])
	elif(_role == ROLE_TARGET):
		return _action.makePlan().add("Face", [getPawn(ROLE_MAIN)])
	return null
