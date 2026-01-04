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
	var theActions:Array = [
		action("sex", "Start sex", 0.0),
	]
	
	if(GM.leashSystem.hasLeash(
			LeashPointConnection.createPawnLeashpoint(getCharID(ROLE_MAIN), "leashholder.R"),
			LeashPointConnection.createPawnLeashpoint(getCharID(ROLE_TARGET), "collar"),
	)):
		theActions.append(action("unleash", "Unleash!", 0.0))
	else:
		theActions.append(action("leash", "Leash!", 0.0))
	
	theActions.append(action("stop", "Never mind", 0.0))
	
	return theActions

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
		var newSex := SexStartConf.new()
		newSex.sexType = SexType.OnTheFloor
		newSex.addRole("dom", getCharID(ROLE_MAIN), SexRole.Dom)
		newSex.addRole("sub", getCharID(ROLE_TARGET), SexRole.Sub)
		newSex.pos = getPawn(ROLE_MAIN).global_position
		newSex.ang = getPawn(ROLE_MAIN).global_rotation
		GM.sexManager.startSex(newSex)
		stopInteraction()
	if(_actionID == "leash"):
		stopLookAt(ROLE_MAIN)
		stopLookAt(ROLE_TARGET)
		GM.leashSystem.connectLeash(
			LeashPointConnection.createPawnLeashpoint(getCharID(ROLE_MAIN), "leashholder.R"),
			LeashPointConnection.createPawnLeashpoint(getCharID(ROLE_TARGET), "collar"),
			LeashSettings.createSimple().setSourcePull(1.5).setTargetPull(1.0),
		)
		stopInteraction()
	if(_actionID == "unleash"):
		stopLookAt(ROLE_MAIN)
		stopLookAt(ROLE_TARGET)
		GM.leashSystem.removeLeash(
			LeashPointConnection.createPawnLeashpoint(getCharID(ROLE_MAIN), "leashholder.R"),
			LeashPointConnection.createPawnLeashpoint(getCharID(ROLE_TARGET), "collar"),
		)
		stopInteraction()

func getInterruptActions(_role:int, _newCharID:String) -> Array:
	return [
		#interuptAction("startTalk", "Hey!", 0.0),
	]

func doInterruptAction(_role:int, _newCharID:String, _actionID:String, _args:Array):
	pass

func onQueueEvent(_eventID:String, _args:Array):
	pass
