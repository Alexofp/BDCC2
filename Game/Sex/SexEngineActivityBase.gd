extends RefCounted
class_name SexEngineActivityBase

const ACTIVITY_SEXTYPE = 0
const ACTIVITY_MAIN = 1
const ACTIVITY_SIDE = 2

const S_PENIS = 0
const S_VAGINA = 1
const S_ANUS = 2
const S_MOUTH = 3
const S_HANDS = 4
const S_FEET = 5

const I_TEASE = 0
const I_NORMAL = 1
const I_HIGH = 2

const CONSENT_RESISTANCE = 0
const CONSENT_FETISH = 1

const OVERRIDE_PRIORITY_ORGASM = 10

const CATEGORY_SEX:Array[String] = ["Sex"]

var id:String = "error"
var engineRef:WeakRef

# role = id
var roleToID:Dictionary[String, String] = {}
var idToRole:Dictionary[String, String] = {}

var state:String = ""

func getActivityType() -> int:
	return ACTIVITY_SEXTYPE

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

func onSexEnd():
	pass

func getStartActionsFinal(_sexEngine:SexEngine, _info:SexParticipantInfo, _target:SexParticipantInfo) -> Array[SexAction]:
	tempActions = []
	getStartActions(_sexEngine, _info, _target)
	return tempActions

func getStartActions(_sexEngine:SexEngine, _info:SexParticipantInfo, _target:SexParticipantInfo):
	if(_sexEngine.hasMainActivity() || _info == _target):
		return
	#addAction(action("TEST TEST!").delay(0.3).start({dom=_info, sub=_target}))
	#addAction(action("AAAA!").delay(3.0))
	pass

#func addStartAction():
#	pass
func doStartSexAction(_sexEngine:SexEngine, _info:SexParticipantInfo, _target:SexParticipantInfo, _action:SexAction):
	if(!_action.cooldownID.is_empty() && _action.cooldownTime > 0.0):
		_sexEngine.addCooldown(_action.cooldownID, _action.cooldownTime)
	
	for payloadEntry in _action.payload:
		var entryType:int = payloadEntry[0]
		
		#if(entryType == SexAction.ACTION_ACTION):
		#	pushAutoAction(_role, payloadEntry[1], payloadEntry[2])
		if(entryType == SexAction.ACTION_DELAY):
			_sexEngine.pushToQueue(id, _sexEngine.createQueueDelay(payloadEntry[1]))
		elif(entryType == SexAction.ACTION_START):
			var _roles:Dictionary = payloadEntry[1].duplicate()
			for theRole in _roles:
				if(_roles[theRole] is SexParticipantInfo):
					_roles[theRole] = _roles[theRole].getID()
			var _args:Dictionary = payloadEntry[2]
			_sexEngine.pushToQueue(id, [SexEngine.QUEUE_START_MAIN_ACTIVITY if getActivityType() == ACTIVITY_MAIN else SexEngine.QUEUE_START_SIDE_ACTIVITY, id, _roles, _args])
		elif(entryType == SexAction.ACTION_EXPOSE):
			var _giverInfo:SexParticipantInfo = payloadEntry[1]
			var _receiverInfo:SexParticipantInfo = payloadEntry[2]
			var _fetishID:String = payloadEntry[3]
			var _intensity:float = payloadEntry[4]
			_sexEngine.pushToQueue(id, _sexEngine.createExpose(_giverInfo.getID(), _receiverInfo.getID(), _fetishID, _intensity))
		elif(entryType == SexAction.ACTION_CONSENT_CHECK):
			var whoNeedToConsent:Array = payloadEntry[5]
			if(whoNeedToConsent.is_empty()):
				whoNeedToConsent = _sexEngine.getParticipants().keys()
			
			var gaveConsent:Dictionary[String, bool] = {}
			for theParticipant in whoNeedToConsent:
				if(theParticipant is SexParticipantInfo):
					gaveConsent[theParticipant.getID()] = false
				elif(theParticipant is String):
					gaveConsent[theParticipant] = false
			gaveConsent[_info.getID()] = true
			
			_sexEngine.pushToQueue(id, _sexEngine.createConsentCheck(payloadEntry[1], payloadEntry[2], gaveConsent, payloadEntry[3], payloadEntry[4], payloadEntry[6]))
			
		#elif(entryType == SexAction.ACTION_DELAY_CANCANCEL):
		#	pushDelayCanCancel(payloadEntry[1], _role)
		#elif(entryType == SexAction.ACTION_CONSENT_CHECK):
		#	pushConsentCheck(payloadEntry[1], [getRoleID(_role)])
		else:
			assert(false, "Payload entry type "+str(entryType)+" is not implemented for doStartSexAction()")

func conTexts(_askText:String, _forceText:String = "", _involved:Dictionary[String, Variant] = {}):
	if(_forceText.is_empty()):
		_forceText = _askText
	return [_askText, _forceText, _involved]

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

func getState() -> String:
	return state

func run():
	pass

func doRun():
	var funcName:String = getStateFuncPrefix()+"_run"
	if(has_method(funcName)):
		call(funcName)
	else:
		run()

func addActionText(theText:String):
	var sexEngine:SexEngine = getSexEngine()
	if(sexEngine):
		sexEngine.addActionTextRaw(applyObjReplacers(theText))

func setupRoles(_roles:Dictionary, _need:Array):
	for needRole in _need:
		addRole(needRole, _roles[needRole])

func swapRoles(_role1:String, _role2:String):
	if(!roleToID.has(_role1) || !roleToID.has(_role2)):
		Log.Printerr("TRYING TO SWAP ROLES THAT DON'T EXIST: "+_role1+", "+_role2)
		return
	var charID1:String = roleToID[_role1]
	var charID2:String = roleToID[_role2]
	
	#Use addRole() instead?
	roleToID[_role2] = charID1
	idToRole[charID1] = _role2
	roleToID[_role1] = charID2
	idToRole[charID2] = _role1
	
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

func getRoleInfo(_role:String) -> SexParticipantInfo:
	var theEngine := getSexEngine()
	if(!theEngine):
		return null
	return theEngine.getInfo(getRoleID(_role))

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

func getArousal(_theRole:String) -> float:
	var theChar:=getRoleChar(_theRole)
	if(!theChar):
		return 0.0
	return theChar.getArousal()

var tempActions:Array[SexAction] = []

func addAction(_action:SexAction):
	tempActions.append(_action)

func addActionEasy(_name:String, _score:float, _actionID:String, _args:Array = [], _category:Array[String] = []):
	var newAction:SexAction = SexAction.make(_name)
	newAction.setScore(_score)
	newAction.setCat(_category)
	newAction.do(_actionID, _args)
	
	addAction(newAction)

func getAllPossiblePoses() -> Array[SexPoseBase]:
	var result:Array[SexPoseBase] = []
	var theEngine := getSexEngine()
	
	var allPoses := GlobalRegistry.getSexPosesForActivityID(id)
	for thePose in allPoses:
		if(!thePose.canBeUsedFinal(theEngine, self)):
			continue
		result.append(thePose)
	
	return result

func getAllPossiblePosesCanPickRandomly() -> Array[SexPoseBase]:
	var result:Array[SexPoseBase] = []
	var theEngine := getSexEngine()
	
	var allPoses := GlobalRegistry.getSexPosesForActivityID(id)
	for thePose in allPoses:
		if(!thePose.canPickRandomly):
			continue
		if(!thePose.canBeUsedFinal(theEngine, self)):
			continue
		result.append(thePose)
	
	return result

func pickRandomPose() -> String:
	var allPoses := getAllPossiblePosesCanPickRandomly()
	if(allPoses.is_empty()):
		return ""
	return RNG.pick(allPoses).id

func hasAnyPosesToPick() -> bool:
	var allPoses := getAllPossiblePosesCanPickRandomly()
	if(allPoses.is_empty()):
		return false
	return true

func addPosePickActions(_poseActionID:String, _addIfOne:bool = false):
	var allPoses := getAllPossiblePoses()
	
	if(!_addIfOne && allPoses.size() <= 1):
		return
	
	var theCat:Array[String] = ["Pose"]
	for thePose in allPoses:
		addAction(action(thePose.getVisibleName()).setCat(theCat).do(_poseActionID, [thePose.id]))

func setPoseFromPickAction(_pose:String, _args:Array) -> String:
	var newPose:String = _args[0]
	#if(newPose == _pose):
	#	return _pose
	if(!GlobalRegistry.getSexPose(newPose)):
		return _pose
	
	return newPose

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

func doActionFinal(_role:String, _id:String, _args:Array):
	var theFuncName:String = getStateFuncPrefix()+"_do"
	if(has_method(theFuncName)):
		if(call(theFuncName, _role, _id, _args)):
			return
	doAction(_role, _id, _args)

func doActionFinalCustomState(_state:String, _role:String, _id:String, _args:Array):
	var theFuncName:String = getStateFuncPrefixRaw(_state)+"_do"
	if(has_method(theFuncName)):
		if(call(theFuncName, _role, _id, _args)):
			return
	doAction(_role, _id, _args)

func doAction(_role:String, _id:String, _args:Array):
	pass
	
func getActionsForCharID(_charID:String) -> Array[SexAction]:
	return getActionsFinal(idToRole[_charID])

func doActionForCharID(_charID:String, _id:String, _args:Array):
	doActionFinal(getRoleFromID(_charID), _id, _args)

func addCooldown(_cooldownID:String, _time:float):
	getSexEngine().addCooldown(_cooldownID, _time)

#func doActionStuff(_action:SexAction):
	#if(!_action.cooldownID.is_empty() && _action.cooldownTime > 0.0):
		#addCooldown(_action.cooldownID, _action.cooldownTime)

func doSexActionFinal(_role:String, _action:SexAction):
	if(!_action.cooldownID.is_empty() && _action.cooldownTime > 0.0):
		addCooldown(_action.cooldownID, _action.cooldownTime)
	
	for payloadEntry in _action.payload:
		var entryType:int = payloadEntry[0]
		
		if(entryType == SexAction.ACTION_ACTION):
			pushAutoAction(_role, payloadEntry[1], payloadEntry[2])
		elif(entryType == SexAction.ACTION_DELAY):
			pushDelay(payloadEntry[1])
		elif(entryType == SexAction.ACTION_DELAY_CANCANCEL):
			pushDelayCanCancel(payloadEntry[1], _role)
		elif(entryType == SexAction.ACTION_CONSENT_CHECK):
			var theRolesToConsent:Array = payloadEntry[5]
			if(theRolesToConsent.is_empty()):
				theRolesToConsent = roleToID.keys()
			theRolesToConsent.erase(_role) # Remove the role that called it
			var finalAr:Array[String] = []
			finalAr.append_array(theRolesToConsent)
			pushConsentCheck(payloadEntry[1], payloadEntry[2], finalAr, payloadEntry[3], payloadEntry[4], payloadEntry[6])
		elif(entryType == SexAction.ACTION_EXPOSE):
			pushExpose(payloadEntry[1], payloadEntry[2], payloadEntry[3], payloadEntry[4])
		else:
			assert(false, "Payload entry type "+str(entryType)+" is not implemented for doSexActionFinal()")

func doSexActionForCharID(_charID:String, _action:SexAction):
	doSexActionFinal(getRoleFromID(_charID), _action)

func endActivity():
	var sexEngine:SexEngine = getSexEngine()
	if(sexEngine):
		sexEngine.stopActivity(self)

func playPoseOrAnim(thePoseID:String, theAnimID:String, theStateID:String, theAnimSeats:Dictionary, theAnimArgs:Dictionary = {}):
	if(!playPose(thePoseID, theStateID, theAnimSeats, theAnimArgs)):
		playAnim(theAnimID, theStateID, theAnimSeats, theAnimArgs)

func playPose(thePoseID:String, theStateID:String, theAnimSeats:Dictionary, theAnimArgs:Dictionary = {}) -> bool:
	if(thePoseID.is_empty()):
		return false
	var thePose:= GlobalRegistry.getSexPose(thePoseID)
	if(!thePose):
		Log.Printerr("(Sex Engine Activity) SEX POSE NOT FOUND TO PLAY: "+str(thePoseID))
		return false
	var newAnim:String = thePose.getAnim()
	var newState:String = thePose.getState(theStateID)
	var newSeats := thePose.getRoles(theAnimSeats)
	playAnim(newAnim, newState, newSeats, theAnimArgs)
	return true
	
# playAnim(AnimScene.TestSex, "sex", {top="dom", bottom="sub"})
func playAnim(theAnimID:String, theStateID:String, theAnimSeats:Dictionary, theAnimArgs:Dictionary = {}):
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
			
	getSexEngine().playAnim(theAnimID, theStateID, thePawns, theAnimArgs)

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
	return getSexEngine().isSub(getRoleID(_role))
	
func isDom(_role:String) -> bool:
	return getSexEngine().isDom(getRoleID(_role))

func canDoDomActions(_role:String) -> bool:
	return getSexEngine().canDoDomActions(getRoleID(_role))

func isForced() -> bool:
	return getSexEngine().isForced()

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

func processSex(holeZone:int, topRole:String, bottomRole:String, mult:float = 1.0):
	if(holeZone == ZoneCover.Vagina):
		processVaginalSex(topRole, bottomRole, mult)
	elif(holeZone == ZoneCover.Anus):
		processAnalSex(topRole, bottomRole, mult)
	else:
		Log.Printerr("processSex() Bad zone to do sex: "+str(holeZone))

func processVaginalSex(topRole:String, bottomRole:String, mult:float = 1.0):
	stimulate(topRole, S_PENIS, bottomRole, S_VAGINA, I_NORMAL, Fetish.SexVaginal, 0.05*mult)

func processAnalSex(topRole:String, bottomRole:String, mult:float = 1.0):
	stimulate(topRole, S_PENIS, bottomRole, S_ANUS, I_NORMAL, Fetish.SexAnal, 0.05*mult)

#func processAnalSex(_dt:float, topRole:String, bottomRole:String, mult:float = 1.0):
	#addArousal(topRole, _dt*mult*0.1)
	#addArousal(bottomRole, _dt*mult*0.1)

func doOrgasm(_role:String, _causerRole:String = "", _orgasmType:int = SexOrgasmType.Generic, _orgasmCause:int = SexOrgasmCause.Generic, _intensity:int = SexOrgasmIntensity.Normal):
	setArousal(_role, 0.0)

func pushCancelStopper():
	getSexEngine().pushToQueue(self, getSexEngine().createCancelStopper())

func pushCancelCatcher(_event:SexEvent):
	getSexEngine().pushToQueue(self, getSexEngine().createCancelCatcher(state, _event))

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

func pushConsentCheck(_delay:float, _delayForced:float, _toConsent:Array[String], _consentStrategy:int, _consentArgs:Array, _hoverTexts:Array):
	var newConsentID:Dictionary[String, bool] = {}
	for theRole in _toConsent:
		var theID:String = getRoleID(theRole)
		if(!theID.is_empty()):
			newConsentID[theID] = false
	getSexEngine().pushToQueue(self, getSexEngine().createConsentCheck(_delay, _delayForced, newConsentID, _consentStrategy, _consentArgs, _hoverTexts))

func pushResistMinigame():
	getSexEngine().pushToQueue(self, getSexEngine().createResistMinigame(state))

func pushExpose(_rolePerfomer:String, _roleReceiver:String, _fetishID:String, _intensity:float = 1.0):
	getSexEngine().pushToQueue(self, getSexEngine().createExpose(getRoleID(_rolePerfomer), getRoleID(_roleReceiver), _fetishID, _intensity))

func exposeFetish(_rolePerfomer:String, _roleReceiver:String, _fetishID:String, _intensity:float = 1.0):
	getSexEngine().doExposeFetish(getRoleID(_rolePerfomer), getRoleID(_roleReceiver), _fetishID, _intensity)

func pleasureModFromZone(_role:String, _zone:int) -> float:
	if(_zone == S_PENIS || _zone == S_VAGINA || _zone == S_ANUS):
		return 1.0
	return 0.0

func stimulate(_rolePerformer:String, _perfZone:int, _roleReceiver:String, _recZone:int, _intensity:int, _fetishID:String, _arousalBase:float):
	var perfPleasure:float = pleasureModFromZone(_rolePerformer, _perfZone)
	if(perfPleasure != 0.0):
		addArousal(_rolePerformer, perfPleasure*_arousalBase*randf_range(0.9, 1.1))
	
	var recPleasure:float = pleasureModFromZone(_roleReceiver, _recZone)
	if(recPleasure != 0.0):
		addArousal(_roleReceiver, recPleasure*_arousalBase*randf_range(0.9, 1.1))
	
	exposeFetish(_rolePerformer, _roleReceiver, _fetishID, _arousalBase*2.0)

func handleResistMinigame(_state:String, _result:ResistMinigameResult):
	var theFuncName:String = getStateFuncPrefixRaw(_state)+"_resistMinigame"
	if(has_method(theFuncName)):
		call(theFuncName, _result)
		return
	#doEvent(_event)

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

func action(_name:String) -> SexAction:
	return SexAction.make(_name)

func hasEveryoneConsent(_roleList:Array[String]) -> bool:
	for theRole in roleToID:
		if(!_roleList.has(theRole)):
			return false
	return true

func getContext() -> Dictionary:
	return {}

func addAutoEquipAfterEnd(_role:String, _slot:int, _itemUID:int):
	var theCharID:String = getRoleID(_role)
	if(theCharID.is_empty()):
		return
	getSexEngine().addAutoEquipAfterEnd(theCharID, _slot, _itemUID)

func applyObjReplacers(_text:String) -> String:
	return GM.textParser.applyObjReplacers(_text, getObjReplacers())

func getObjReplacers() -> Dictionary[String, String]:
	return roleToID

func parseText(_text:String) -> String:
	return GM.textParser.parseString(_text, getSimpleGameTextParserText).text

func getSimpleGameTextParserText(_id:String, _command:String, _arg:String) -> SGTPResult:
	var theResult:SGTPResult = null
	if(!theResult):
		if(roleToID.has(_id)):
			theResult = GM.characterRegistry.getSimpleGameTextParserText(roleToID[_id], _command, _arg)
	
	return theResult

func calcConsentScore(_strategy:int, _args:Array, _info:SexParticipantInfo, _isForced:bool) -> float:
	var ai:SexParticipantAI = _info.ai
	if(_strategy == CONSENT_RESISTANCE):
		if(_info.canDoDomActions()):
			return 1.0
		return 1.0 - ai.getSmoothResistScore()
	
	Log.Printerr("BAD CONSENT STRATEGY: "+str(_strategy))
	return 1.0

func calcNoConsentScore(_strategy:int, _args:Array, _info:SexParticipantInfo, _isForced:bool) -> float:
	return 1.0 - calcConsentScore(_strategy, _args, _info, _isForced)

func canSatisfyTask(_info:SexParticipantInfo, _taskID:String, _args:Array) -> bool:
	return false

func taskScore(_role:String, _taskID:String, _args:Array=[]) -> float:
	var theInfo := getRoleInfo(_role)
	if(!theInfo):
		return 0.0
	return theInfo.taskScore(_taskID, _args)

func getSubTasks(_info:SexParticipantInfo, _taskID:String, _args:Array) -> Array:
	return []

func task(_taskID:String, _taskArgs:Array, _score:float = 1.0) -> Array:
	return [_taskID, _taskArgs, _score]

func scoreStop(_role:String) -> float:
	#var theInfo := getRoleInfo(_role)
	#if(!theInfo):
	#	return 0.0
	var theEngine := getSexEngine()
	if(!theEngine):
		return 0.0
	for charID in idToRole:
		var theInfo := theEngine.getInfo(charID)
		if(!theInfo):
			continue
		if(!theInfo.ai.shouldProcessAI() || !theInfo.canDoDomActions()):
			continue
		var theTasksByID := theInfo.ai.tasksByID
		for theTaskID in theTasksByID:
			for taskEntry in theTasksByID[theTaskID]:
				if(canSatisfyTask(theInfo, taskEntry[0], taskEntry[1])):
					return 0.0
	return 1.0

func completeTask(_role:String, _taskID:String, _taskArray:Array):
	var theInfo := getRoleInfo(_role)
	if(!theInfo):
		return
	theInfo.sendTaskEvent(_taskID, _taskArray)

func isReadyToPenetrate(_role:String) -> bool:
	var theChar := getRoleChar(_role)
	if(!theChar):
		return false
	if(!theChar.hasReachablePenisOrStrapon()):
		return false
	if(theChar.isZoneCovered(ZoneCover.Penis)):
		return false
	return true

func isZoneReadyToBePenetrated(_role:String, _zone:int) -> bool:
	var theChar := getRoleChar(_role)
	if(!theChar):
		return false
	if(theChar.isZoneCovered(_zone)):
		return false
	
	if(_zone == ZoneCover.Mouth):
		return true
	if(_zone == ZoneCover.Vagina):
		return theChar.hasReachableVagina()
	if(_zone == ZoneCover.Anus):
		return theChar.hasReachableAnus()
	return false

func doText(_role:String, _text:String):
	#getSexEngine().doText(self, _role, _text)
	addActionText(_text)

func getPoseText(_poseID:String, _poseName:String, _args:Dictionary, _defaultStr:String) -> String:
	var thePose := GlobalRegistry.getSexPose(_poseID)
	
	var theStr:String = _defaultStr
	if(thePose):
		theStr = thePose.getPoseText(_poseName)
		if(theStr.is_empty()):
			theStr = _defaultStr
	
	return theStr.format(_args, "%%_%%")

func doPoseText(_role:String, _poseID:String, _poseName:String, _args:Dictionary, _defaultStr:String):
	doText(_role, getPoseText(_poseID, _poseName, _args, _defaultStr))

func isActivitySupported(_sexEngine:SexEngine) -> bool:
	return true

#func onDoText(_role:String, _text:String):
	#var finalText := parseText(_text)
	#var theCharID:String = getRoleID(_role)
	#var thePawn := GM.pawnRegistry.getPawn(theCharID)
	#if(!thePawn):
		#return
	#thePawn.addHoverText(finalText)

func zoneLewdName(_role:String, _zone:int) -> String:
	if(_zone == ZoneCover.Vagina):
		return "pussy"
	if(_zone == ZoneCover.Anus):
		return "anus"
	if(_zone == ZoneCover.Penis):
		return "cock"
	return "ERROR"

func doHitAnimationRandom(_role:String, _strength:float):
	var thePawn := getRolePawn(_role)
	if(!thePawn):
		return
	var theDoll := thePawn.getDoll()
	if(!theDoll):
		return
	GM.dollHolder.applyHitRandom(theDoll, _strength)

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.Var, saveData(),
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	loadData(_data.readVar())
	_data.endLoad()

func saveData() -> Dictionary:
	return {
		roleToID = roleToID,
		idToRole = idToRole,
	}

func loadData(_data:Dictionary):
	roleToID = SAVE.loadVar(_data, "roleToID", {})
	idToRole = SAVE.loadVar(_data, "idToRole", {})
