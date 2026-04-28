extends RefCounted
class_name ActionSystemEntry

const TIMER_ONLY = 0 # Action always happens when the timer ends
const TIMER_MUST_CONSENT = 1 # Action happens if the target allows it. Or if the target is dominated by the user
const TIMER_MUST_CONSENT_ALWAYS = 2 # Action happens ONLY if the target explicitly allows it. No exceptions
const TIMER_CAN_DENY = 3 # Action will happen unless the target resists it. Can't resist if the target is dominated by the user
const TIMER_CAN_DENY_ALWAYS = 4 # Can deny even if dominated by the user

const CONDITION_NONE = 0
const CONDITION_DISTANCE = 1

const MOVE_CANMOVE = 0
const MOVE_NO_RUNNING = 1
const MOVE_NO_MOVEMENT = 2

const CANCEL_DISALLOW = 0
const CANCEL_ALLOW = 1

var uniqueID:int = -1

var userMove:int = MOVE_CANMOVE
var cancelType:int = CANCEL_ALLOW
var cancelIfHit:bool = true # Cancel the action if user got hit by someone

var timeFull:float = 1.0
var timePassed:float = 0.0
var consentTimeMult:float = 2.0

var user:CharacterPawn
var target:ActionSystemTarget
var extraTargets:Array[ActionSystemTarget]

var action:PawnActionBase
var args:Array

var actionText:String = ""

static func create(_text:String, _user:CharacterPawn, _target:Node, _timer:float, _action:PawnActionBase, _args:Array = []) -> ActionSystemEntry:
	var newEntry := ActionSystemEntry.new()
	
	var mainTarget := ActionSystemTarget.new()
	mainTarget.node = _target
	
	#newEntry.actionText = _text
	newEntry.user = _user
	newEntry.target = mainTarget
	newEntry.timeFull = _timer
	newEntry.action = _action
	newEntry.args = _args
	
	newEntry.setActionText(_text)
	
	return newEntry

func addExtraTarget(_extraTarget:ActionSystemTarget) -> ActionSystemEntry:
	extraTargets.append(_extraTarget)
	return self

func getTargetSpecific(_node:Node) -> ActionSystemTarget:
	if(target.node == _node):
		return target
	for extra in extraTargets:
		if(extra.node == _node):
			return extra
	return null

func isTarget(_node:Node) -> bool:
	return getTargetSpecific(_node) != null

func needsConsent() -> bool:
	if(target.needsConsent(self)):
		return true
	for extraTarget in extraTargets:
		if(extraTarget.needsConsent(self)):
			return true
	return false
	
func didEveryoneConsent() -> bool:
	if(!target.hasAnyConsent(self)):
		return false
	for extraTarget in extraTargets:
		if(!extraTarget.hasAnyConsent(self)):
			return false
	return true

func getProgressValue() -> float:
	if(timeFull <= 0.0):
		return 1.0
	var theVal:float = clamp(timePassed / timeFull, 0.0, 1.0)
	
	if(target.timerType == TIMER_MUST_CONSENT || target.timerType == TIMER_MUST_CONSENT_ALWAYS):
		return 1.0 - theVal
	for extra in extraTargets:
		if(extra.timerType == TIMER_MUST_CONSENT || extra.timerType == TIMER_MUST_CONSENT_ALWAYS):
			return 1.0 - theVal
	return theVal

func setActionText(_text:String, _doParse:bool = true):
	if(!_doParse):
		actionText = _text
		return
	var theReplacers:Dictionary[String, String]
	if(user):
		theReplacers["user"] = user.getCharID()
	if(target && (target.node is CharacterPawn)):
		theReplacers["target"] = target.node.getCharID()
	var _i:int = 0
	for extra in extraTargets:
		if(extra.node is CharacterPawn):
			theReplacers["extra"+str(_i)] = extra.node.getCharID()
		_i += 1
	
	actionText = GM.textParser.applyObjReplacers(_text, theReplacers)
	#actionText = GM.textParser.parseString(actionText, getSimpleGameTextParserText).text

#func getSimpleGameTextParserText(_id:String, _command:String, _arg:String) -> SGTPResult:
	#var theResult:SGTPResult = null
	#if(!theResult):
		#theResult = GM.characterRegistry.getSimpleGameTextParserText(_id, _command, _arg)
	#
	#return theResult

func getActionText() -> String:
	return actionText

func setTimerType(_type:int) -> ActionSystemEntry:
	target.timerType = _type
	return self

func setConditionType(_type:int) -> ActionSystemEntry:
	target.conditionType = _type
	return self

func setUserMove(_type:int) -> ActionSystemEntry:
	userMove = _type
	return self

func setTargetMove(_type:int) -> ActionSystemEntry:
	target.targetMove = _type
	return self

func setCancelType(_type:int) -> ActionSystemEntry:
	cancelType = _type
	return self

func setCancelOnUserGettingHit(_h:bool) -> ActionSystemEntry:
	cancelIfHit = _h
	return self

func doAIDecisionForTarget(_target:ActionSystemTarget):
	if(!(_target.node is CharacterPawn)):
		return
	var thePawn:CharacterPawn = _target.node
	if(thePawn.isControlledByAnyPlayer()):
		return
	
	thePawn.ai.reactDelayedAction(self)
	
	if(_target.hasAnyConsent(self)):
		return
	
	if(_target.aiDecision == ActionSystemTarget.AI_DECISION_ALLOW):
		if(_target.timerType == TIMER_MUST_CONSENT || _target.timerType == TIMER_MUST_CONSENT_ALWAYS):
			thePawn.doInteractEntryDo(
				InteractEntryDo.create("ActionAllow", [uniqueID]), thePawn,
			)
		else:
			pass # Just let it happen
	elif(_target.aiDecision == ActionSystemTarget.AI_DECISION_DENY):
		if(_target.timerType == TIMER_MUST_CONSENT || target.timerType == TIMER_MUST_CONSENT_ALWAYS):
			thePawn.doInteractEntryDo(
				InteractEntryDo.create("ActionDeny", [uniqueID]), thePawn,
			)
		else:
			thePawn.doInteractEntryDo(
				InteractEntryDo.create("ActionResist", [uniqueID]), thePawn,
			)

func shouldDoAIDecision(_target:ActionSystemTarget, _f:float) -> bool:
	if(_target.aiDecision != ActionSystemTarget.AI_DECISION_UNDECIDED):
		return false
	if(!_target.needsConsent(self)):
		return false
	if((timePassed > 0.6 && RNG.chance(20)) || _f > 0.8):
		return true
	return false

func doAIDecisions():
	var theF:float = (timePassed / timeFull) if timeFull > 0.0 else 1.0
	
	if(shouldDoAIDecision(target, theF)):
		doAIDecisionForTarget(target)
	for extraTarget in extraTargets:
		if(shouldDoAIDecision(extraTarget, theF)):
			doAIDecisionForTarget(extraTarget)

func deleteMe():
	GM.main.action_system.deleteAction(self)

func cancelMe():
	GM.main.action_system.cancelAction(self)

func doMe():
	GM.main.action_system.doAction(self)

func processAction(_delta:float):
	var theUser := user
	var theTarget := target.node
	
	if(!ActionSystem.checkSpeedCondition(theUser, userMove)):
		cancelMe()
		return
	if(target.shouldCancelAction(self)):
		cancelMe()
		return
	for extraTarget in extraTargets:
		if(extraTarget.shouldCancelAction(self)):
			cancelMe()
			return

	var theContext := user.pawnActionContext
	theContext.target = theTarget
	theContext.args = args
	if(!action.canDoDelayedAction(theContext)):
		theContext.clearContext()
		cancelMe()
		return
	theContext.clearContext()

	#var timePassMult:float = 1.0
	var _hasConsent:bool = false
	if(needsConsent() && didEveryoneConsent()):
		#timePassMult *= consentTimeMult
		_hasConsent = true

	if(checkShouldDoItself(_delta, _hasConsent)):
		return
	
	doAIDecisions()

## Gets called when the timer ends, decides what to do.
func doActionOnTimerEnd() -> bool:
	if(!target.hasConsentIfTimerEnds() && !target.hasAnyConsent(self)):
		cancelMe()
		return true
	for extraTarget in extraTargets:
		if(!extraTarget.hasConsentIfTimerEnds() && !extraTarget.hasAnyConsent(self)):
			cancelMe()
			return true
	doMe()
	return true

## Gets called every frame.
## Checks if we got all the consent and completes the action then
func checkShouldDoItself(_dt:float, _hasConsent:bool) -> bool:
	if(_hasConsent && timeFull > 1.0): # makes it take <1 second
		_dt *= timeFull
		
	timePassed += _dt
	if(timePassed >= timeFull):
		doActionOnTimerEnd()
		return true
	return false

func getActionEntriesForUserPawn(_pawn:CharacterPawn) -> Array[InteractEntryDo]:
	var result:Array[InteractEntryDo] = []
	if(cancelType == ActionSystemEntry.CANCEL_ALLOW):
		result.append(InteractEntryDo.create("ActionCancel", [uniqueID]))
	return result

func onUserActionEntry(_pawn:CharacterPawn, _id:String):
	if(_pawn != user):
		return
	if(_id == "ActionCancel"):
		cancelMe()

func getActionEntriesForTargetPawn(_pawn:CharacterPawn) -> Array[InteractEntryDo]:
	var theTarget := getTargetSpecific(_pawn)
	if(!theTarget || theTarget.hasAnyConsent(self)):
		return []
	var result:Array[InteractEntryDo] = []
	if(theTarget.timerType == ActionSystemEntry.TIMER_MUST_CONSENT || theTarget.timerType == ActionSystemEntry.TIMER_MUST_CONSENT_ALWAYS):
		result.append(InteractEntryDo.create("ActionAllow", [uniqueID]))
		result.append(InteractEntryDo.create("ActionDeny", [uniqueID]))
	elif(theTarget.timerType == ActionSystemEntry.TIMER_CAN_DENY || theTarget.timerType == ActionSystemEntry.TIMER_CAN_DENY_ALWAYS):
		result.append(InteractEntryDo.create("ActionResist", [uniqueID]))
	return result

func onTargetActionEntry(_node:Node, _id:String):
	var theTarget := getTargetSpecific(_node)
	if(!theTarget):
		return
	
	if(_id == "ActionDeny"):
		if(!theTarget.needsConsent(self)):
			return
		cancelMe()
	if(_id == "ActionResist"):
		if(!theTarget.needsConsent(self)):
			return
		cancelMe()
	if(_id == "ActionAllow"):
		theTarget.markDidConsent()
		#if(!didEveryoneConsent()):
		#	return
		#doMe()
