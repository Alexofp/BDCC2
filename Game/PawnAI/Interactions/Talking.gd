extends InteractionBase

func _init() -> void:
	id = "Talking"

func start(_roles:Dictionary, _args:Array):
	involve(ROLE_MAIN, _roles["main"])
	involve(ROLE_TARGET, _roles["target"])
	
	lookAt(ROLE_MAIN, ROLE_TARGET)
	sayText(ROLE_MAIN, "Hey!")
	startAction(ROLE_TARGET, "Follow", [getCharID(ROLE_MAIN)])
	pushDelay(2.0)
	pushSay(ROLE_TARGET, "What?")
	pushLookAt(ROLE_TARGET, ROLE_MAIN)

func processRare():
	if(getDistanceBetween(ROLE_MAIN, ROLE_TARGET) > 10.0):
		stopInteraction()

func getActions(_role:int) -> Array:
	return [
		action("sex", "Start sex", 0.0),
		action("stop", "Never mind", 0.0),
	]

func doAction(_role:int, _actionID:String, _args:Array):
	if(_actionID == "stop"):
		sayText(ROLE_MAIN, "Never mind.")
		stopLookAt(ROLE_MAIN)
		stopLookAt(ROLE_TARGET)
		stopInteraction()
	if(_actionID == "sex"):
		#TODO: Starting sex should automatically make the doll stop looking
		stopLookAt(ROLE_MAIN)
		stopLookAt(ROLE_TARGET)
		GM.sexManager.startSex(SexType.OnTheFloor, {dom={id=getCharID(ROLE_MAIN),role=SexRole.Dom}, sub={id=getCharID(ROLE_TARGET),role=SexRole.Sub}}, {}, getPawn(ROLE_MAIN).global_position, getPawn(ROLE_MAIN).global_rotation)
		stopInteraction()

func getInterruptActions(_role:int, _newCharID:String) -> Array:
	return [
		#interuptAction("startTalk", "Hey!", 0.0),
	]

func doInterruptAction(_role:int, _newCharID:String, _actionID:String, _args:Array):
	pass

func onQueueEvent(_eventID:String, _args:Array):
	pass
