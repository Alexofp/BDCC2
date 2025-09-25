extends RefCounted
class_name SexEngineActivityBase

var id:String = "error"
var engineRef:WeakRef

# role = id
var roleToID:Dictionary = {}
var idToRole:Dictionary = {}

var state:String = ""

func setSexEngine(theEngine:SexEngine):
	engineRef = weakref(theEngine)

func getSexEngine() -> SexEngine:
	if(!engineRef):
		return null
	return engineRef.get_ref()

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, ["dom", "sub"])

func onStartFinal():
	onStart()
	doRun()

func onStart():
	pass

func getStateFuncPrefixRaw(_state:String) -> String:
	if(_state.is_empty()):
		return "start"
	else:
		return _state

func getStateFuncPrefix() -> String:
	return getStateFuncPrefixRaw(state)

func setState(_newState:String):
	if(_newState == state):
		return
	state = _newState
	doRun()

func doRun():
	var funcName:String = getStateFuncPrefix()+"_run"
	if(has_method(funcName)):
		call(funcName)

func addActionText(theText:String):
	var sexEngine:SexEngine = getSexEngine()
	if(sexEngine):
		sexEngine.addActionText(theText)

func setupRoles(_roles:Dictionary, _need:Array):
	for needRole in _need:
		addRole(needRole, _roles[needRole])

#@rpc("authority", "call_remote", "reliable")
func addRole(theRole:String, charID:String):
	roleToID[theRole] = charID
	idToRole[charID] = theRole
	#if(Network.isServerNotSingleplayer()):
	#	Network.rpcClients(addRole.bind(theRole, charID))

func getAllRoles() -> Array[String]:
	return roleToID.keys()

func getRoleID(theRole:String) -> String:
	if(!roleToID.has(theRole)):
		return ""
	return roleToID[theRole]

func getRoleFromID(theCharID:String) -> String:
	if(!idToRole.has(theCharID)):
		return ""
	return idToRole[theCharID]

func getRolePawn(theRole:String) -> CharacterPawn:
	if(!roleToID.has(theRole)):
		return null
	return GM.pawnRegistry.getPawn(roleToID[theRole])

func getRoleChar(_theRole:String) -> BaseCharacter:
	return GM.characterRegistry.getCharacter(getRoleID(_theRole))

func addArousal(_theRole:String, _howMuch:float):
	var theChar:=getRoleChar(_theRole)
	if(!theChar):
		return
	theChar.addArousal(_howMuch)

func setArousal(_theRole:String, _howMuch:float):
	var theChar:=getRoleChar(_theRole)
	if(!theChar):
		return
	theChar.setArousal(_howMuch)

var tempActions:Array[SexAction] = []

func addAction(_name:String, _score:float, _actionID:String, _args:Array = []):
	var newAction:SexAction = SexAction.new()
	newAction.id = _actionID
	newAction.actionName = _name
	newAction.score = _score
	newAction.args = _args
	
	tempActions.append(newAction)

func getActionsFinal(_role:String) -> Array[SexAction]:
	tempActions = []
	
	var theFuncName:String = getStateFuncPrefix()+"_actions"
	if(has_method(theFuncName)):
		call(theFuncName, _role)
	
	getActions(_role)
	var result := tempActions
	tempActions = []
	return result

func getActions(_role:String):
	pass

func doEvent(_event:SexEvent):
	pass

func doEventFinal(_state:String, _event:SexEvent):
	var theFuncName:String = getStateFuncPrefixRaw(_state)+"_event"
	if(has_method(theFuncName)):
		call(theFuncName, _event)
		return
	doEvent(_event)

func doActionFinal(_role:String, _action:SexAction):
	var theFuncName:String = getStateFuncPrefix()+"_do"
	if(has_method(theFuncName)):
		if(call(theFuncName, _role, _action)):
			return
	doAction(_role, _action)

func doActionFinalCustomState(_state:String, _role:String, _action:SexAction):
	var theFuncName:String = getStateFuncPrefixRaw(_state)+"_do"
	if(has_method(theFuncName)):
		call(theFuncName, _role, _action)
		return
	doAction(_role, _action)

func doAction(_role:String, _action:SexAction):
	pass
	
func getActionsForCharID(_charID:String) -> Array[SexAction]:
	return getActionsFinal(idToRole[_charID])

func doActionForCharID(_charID:String, _action:SexAction):
	doActionFinal(getRoleFromID(_charID), _action)

func endActivity():
	var sexEngine:SexEngine = getSexEngine()
	if(sexEngine.getSexActivity() == self):
		sexEngine.stopMainActivity()

# playAnim(AnimScene.TestSex, "sex", {top="dom", bottom="sub"})
func playAnim(theAnimID:String, theStateID:String, theAnimSeats:Dictionary):
	var thePawns:Dictionary = {}
	for animSeat in theAnimSeats:
		if(theAnimSeats[animSeat] is String):
			thePawns[animSeat] = {pawn=GM.pawnRegistry.getPawn(getRoleID(theAnimSeats[animSeat]))}
		else:
			var animSeatInfo:Dictionary = theAnimSeats[animSeat]
			thePawns[animSeat] = {pawn=GM.pawnRegistry.getPawn(getRoleID(animSeatInfo["id"]))}
			if(animSeatInfo.has("guidePenisVag")):
				thePawns[animSeat]["guidePenisVag"] = animSeatInfo["guidePenisVag"]
			if(animSeatInfo.has("guidePenisAnus")):
				thePawns[animSeat]["guidePenisAnus"] = animSeatInfo["guidePenisAnus"]
			
	getSexEngine().playAnim(theAnimID, theStateID, thePawns)

func playOneShot(oneShotID:String):
	getSexEngine().playOneShot(oneShotID)

func doProcessFinal(_dt:float):
	var theFunc := getStateFuncPrefix()+"_process"
	if(has_method(theFunc)):
		call(theFunc, _dt)
	doProcess(_dt)

func doProcess(_dt:float):
	pass

## Sends event that every connected player receives and executes.
## If _sendToSelf is true (default), The event is also received locally
func sendEvent(_eventID:String, _args:Array = [], _sendToSelf:bool = true):
	assert(false, "Trying to call sendEvent from the base class")

func onEvent(_eventID:String, _args:Array):
	pass

func eventArg(_args:Array, _indx:int, _default = null):
	if(_indx < 0 || _indx >= _args.size()):
		return _default
	return _args[_indx]

func isSub(_role:String) -> bool:
	return false
	
func isDom(_role:String) -> bool:
	return false
	
func isSwitch(_role:String) -> bool:
	return isSub(_role) && isDom(_role)
	
func isSubCharID(_charID:String) -> bool:
	if(!idToRole.has(_charID)):
		return false
	return isSub(idToRole[_charID])

func isDomCharID(_charID:String) -> bool:
	if(!idToRole.has(_charID)):
		return false
	return isDom(idToRole[_charID])

func isSwitchCharID(_charID:String) -> bool:
	if(!idToRole.has(_charID)):
		return false
	return isSwitch(idToRole[_charID])

func getExpressionState(_role:String) -> int:
	return DollExpressionState.Normal

func getExpressionStateForCharID(_charID:String) -> int:
	if(!idToRole.has(_charID)):
		return DollExpressionState.IgnoreChange
	return getExpressionState(idToRole[_charID])

func isConsensual() -> bool:
	return getSexEngine().isConsensual()

func onAnimEvent(_animID:String, _animState:String, _eventID:String, _args:Variant):
	pass

func addAutomoan(_theRole:String, _howMuch:float, _maxValue:float):
	var theChar:=getRoleChar(_theRole)
	if(!theChar):
		return
	theChar.getCharState().addAutoMoanCappedMax(_howMuch, _maxValue)

func processVaginalSex(_dt:float, topRole:String, bottomRole:String, mult:float = 1.0):
	addArousal(topRole, _dt*mult*0.05*randf_range(0.9, 1.1))
	addArousal(bottomRole, _dt*mult*0.05*randf_range(0.9, 1.1))

func processAnalSex(_dt:float, topRole:String, bottomRole:String, mult:float = 1.0):
	addArousal(topRole, _dt*mult*0.1)
	addArousal(bottomRole, _dt*mult*0.1)

func doOrgasm(_role:String, _causerRole:String = "", _orgasmType:int = SexOrgasmType.Generic, _orgasmCause:int = SexOrgasmCause.Generic, _intensity:int = SexOrgasmIntensity.Normal):
	setArousal(_role, 0.0)

func pushCancelStopper():
	getSexEngine().pushToQueue(self, getSexEngine().createCancelStopper())

func pushCancelCatcher(_actionID:String, _args:Array=[]):
	getSexEngine().pushToQueue(self, getSexEngine().createCancelCatcher(state, _actionID, _args))

func pushCancelCatcherEvent(_event:SexEvent):
	getSexEngine().pushToQueue(self, getSexEngine().createCancelCatcherEvent(state, _event))

func pushDelay(_delay:float):
	getSexEngine().pushToQueue(self, getSexEngine().createQueueDelay(_delay))

func pushDelayCanCancel(_delay:float, _role:String):
	getSexEngine().pushToQueue(self, getSexEngine().createQueueDelayCanCancel(_delay, _role))

func pushSetState(_state:String):
	getSexEngine().pushToQueue(self, getSexEngine().createSetState(_state))

func pushEvent(_event:SexEvent):
	getSexEngine().pushToQueue(self, getSexEngine().createQueueEvent(state, _event))

func pushAutoAction(_role:String, _actionID:String, _args:Array = []):
	getSexEngine().pushToQueue(self, getSexEngine().createAutoAction(state, _role, _actionID, _args))

func pushActionText(_text:String):
	getSexEngine().pushToQueue(self, getSexEngine().createActionText(_text))

func isReadyToCum(_role:String) -> bool:
	var theChar := getRoleChar(_role)
	if(!theChar):
		return false
	return theChar.getArousal() >= 1.0

func isQueueFree() -> bool:
	return !getSexEngine().isBusy()

func isQueueBusy() -> bool:
	return getSexEngine().isBusy()

func isBusy() -> bool:
	return getSexEngine().isBusy()

func saveNetworkData() -> Dictionary:
	return {
		roleToID = roleToID,
		idToRole = idToRole,
	}

func loadNetworkData(_data:Dictionary):
	roleToID = SAVE.loadVar(_data, "roleToID", {})
	idToRole = SAVE.loadVar(_data, "idToRole", {})
