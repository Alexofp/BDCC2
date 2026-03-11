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
	sayText(ROLE_MAIN, "Hey!")
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

func doAction(_role:int, _action:InteractionAction):
	if(_action.id == "stop"):
		sayText(ROLE_MAIN, "Never mind.")
		stopLookAt(ROLE_MAIN)
		stopLookAt(ROLE_TARGET)
		stopInteraction()
	if(_action.id == "lock"):
		setState("lockme")
		sayText(ROLE_MAIN, "Lock me up!")
	#if(_actionID == "sex"):
		##TODO: Starting sex should automatically make the doll stop looking
		#stopLookAt(ROLE_MAIN)
		#stopLookAt(ROLE_TARGET)
		#var newSex := SexStartConf.new()
		#newSex.sexType = SexType.OnTheFloor
		#newSex.addRole("dom", getCharID(ROLE_MAIN), SexRole.Dom)
		#newSex.addRole("sub", getCharID(ROLE_TARGET), SexRole.Sub)
		#newSex.pos = getPawn(ROLE_MAIN).global_position
		#newSex.ang = getPawn(ROLE_MAIN).global_rotation
		#GM.sexManager.startSex(newSex)
		#stopInteraction()
	#if(_actionID == "leash"):
		#stopLookAt(ROLE_MAIN)
		#stopLookAt(ROLE_TARGET)
		#GM.leashSystem.connectLeash(
			#LeashPointConnection.createPawnLeashpoint(getPawn(ROLE_MAIN), "leashholder.R"),
			#LeashPointConnection.createPawnLeashpoint(getPawn(ROLE_TARGET), "collar"),
			#LeashSettings.createSimple().setSourcePull(1.5).setTargetPull(1.0),
		#)
		#stopInteraction()
	#if(_actionID == "unleash"):
		#stopLookAt(ROLE_MAIN)
		#stopLookAt(ROLE_TARGET)
		#GM.leashSystem.removeLeash(
			#LeashPointConnection.createPawnLeashpoint(getPawn(ROLE_MAIN), "leashholder.R"),
			#LeashPointConnection.createPawnLeashpoint(getPawn(ROLE_TARGET), "collar"),
		#)
		#stopInteraction()
#
#func getInterruptActions(_role:int, _newPawn:CharacterPawn) -> Array:
	#return [
	#]
#
#func doInterruptAction(_role:int, _newPawn:CharacterPawn, _actionID:String, _args:Array):
	#pass

func onQueueEvent(_eventID:String, _args:Array):
	pass

func think(_role:int, _pawn:CharacterPawn, _ai:PawnAI, _action:AIActionBase):
	if(state == "lockme"):
		if(_action.getSubActionTag() == "ForcePawnSit"):
			return
		var someStocks := GM.world.getNearbyStocks(_pawn.global_position, 100.0)
		if(!someStocks):
			setState("")
			stopInteraction()
			return
		_action.startSubActionUnlessSameTag("ForcePawnSit", [getPawn(ROLE_MAIN), someStocks])
		return
	
	if(_role == ROLE_TARGET):
		if(_action.hasSubAction()):
			return
		_action.startSubActionUnlessSameTag("Follow", [getPawn(ROLE_MAIN).getCharID()])
		
func onSubActionResult(_role:int, _pawn:CharacterPawn, _ai:PawnAI, _action:AIActionBase, _tag:String, _status:int, _result:Array):
	if(_tag == "ForcePawnSit"):
		stopInteraction()
