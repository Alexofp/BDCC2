extends InteractionBase

func _init() -> void:
	id = "Annoyed"

func getRequiredRoles(_args:Array) -> Dictionary[int, String]:
	return {
		ROLE_MAIN: "main",
		ROLE_TARGET: "target",
	}

func start(_roles:Dictionary, _args:Array):
	lookAt(ROLE_MAIN, ROLE_TARGET)
	#sayText(ROLE_MAIN, "What's your problem?")
	if(_args.size() > 0):
		pushDelay(_args[0])
	say(ROLE_MAIN, "Annoyed", ROLE_TARGET)
	pushStopInteraction()
	#pushSay(ROLE_TARGET, "What?")
	#pushLookAt(ROLE_TARGET, ROLE_MAIN)

func processRare(_dt:float):
	if(getDistanceBetween(ROLE_MAIN, ROLE_TARGET) > 10.0):
		stopInteraction()
