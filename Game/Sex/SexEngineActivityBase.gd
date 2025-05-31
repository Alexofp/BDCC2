extends RefCounted
class_name SexEngineActivityBase

var id:String = "error"
var engineRef:WeakRef

# role = id
var roleToID:Dictionary = {}
var idToRole:Dictionary = {}

func setSexEngine(theEngine:SexEngine):
	engineRef = weakref(theEngine)

func getSexEngine() -> SexEngine:
	if(!engineRef):
		return null
	return engineRef.get_ref()

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, ["dom", "sub"])

func onStart():
	pass

func addActionText(theText:String):
	var sexEngine:SexEngine = getSexEngine()
	if(sexEngine):
		sexEngine.addActionText(theText)

func onDelayedAction(_role:String, _actionID:String, _action:Dictionary):
	pass

func setupRoles(_roles:Dictionary, _need:Array):
	for needRole in _need:
		addRole(needRole, _roles[needRole])

#@rpc("authority", "call_remote", "reliable")
func addRole(theRole:String, charID:String):
	roleToID[theRole] = charID
	idToRole[charID] = theRole
	#if(Network.isServerNotSingleplayer()):
	#	Network.rpcClients(addRole, [theRole, charID])

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

func getActions(_role:String) -> Array:
	return [
		action("test", "TEST ACTION"),
	]

func onDelayedActionStarted(_role:String, _actionID:String, _action:Dictionary):
	pass

func doAction(_role:String, actionID:String, _theAction:Dictionary):
	if(actionID == "test"):
		Log.Print("NYAAAAAAAAAAAAAAAAA")

func getActionsForCharID(_charID:String) -> Array:
	return getActions(idToRole[_charID])

func doActionForCharID(_charID:String, actionID:String, _theAction:Dictionary):
	doAction(getRoleFromID(_charID), actionID, _theAction)

func doOnDelayedActionStartedForCharID(_charID:String, actionID:String, _theAction:Dictionary):
	onDelayedActionStarted(getRoleFromID(_charID), actionID, _theAction)

func action(theId:String, theName:String, actionModifiers:Dictionary = {}):
	return {
		id = theId,
		name = theName,
		args = [],
		mods = actionModifiers,
	}

func getAnimScenePath() -> String:
	return "res://AnimScenes/Scenes/TestSexAnim/test_sex_scene.tscn"

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

func processSex(_dt:float):
	return

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

func saveNetworkData() -> Dictionary:
	return {
		roleToID = roleToID,
		idToRole = idToRole,
	}

func loadNetworkData(_data:Dictionary):
	roleToID = SAVE.loadVar(_data, "roleToID", {})
	idToRole = SAVE.loadVar(_data, "idToRole", {})
