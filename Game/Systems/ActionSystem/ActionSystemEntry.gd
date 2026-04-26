extends RefCounted
class_name ActionSystemEntry

const TIMER_ONLY = 0
const TIMER_MUST_CONSENT = 1
const TIMER_CAN_DENY = 2
const TIMER_CAN_DENY_ALWAYS = 3 # Can deny even if defeated

const CONDITION_NONE = 0
const CONDITION_DISTANCE = 1

const USER_CANMOVE = 0
const USER_NO_RUNNING = 1
const USER_NO_MOVEMENT = 2

const TARGET_CANMOVE = 0
const TARGET_NO_RUNNING = 1
const TARGET_NO_MOVEMENT = 2

const CANCEL_DISALLOW = 0
const CANCEL_ALLOW = 1

var uniqueID:int = -1

var userMove:int = USER_CANMOVE
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
	
	if(target.timerType == TIMER_MUST_CONSENT):
		return 1.0 - theVal
	for extra in extraTargets:
		if(extra.timerType == TIMER_MUST_CONSENT):
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

func deleteMe():
	GM.actionSystem.deleteAction(self)

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
	
	if(_target.aiDecision == ActionSystemTarget.AI_DECISION_ALLOW):
		if(_target.timerType == TIMER_MUST_CONSENT):
			thePawn.doInteractEntryDo(
				InteractEntryDo.create("ActionAllow", [uniqueID]), thePawn,
			)
		else:
			pass # Just let it happen
	elif(_target.aiDecision == ActionSystemTarget.AI_DECISION_DENY):
		if(_target.timerType == TIMER_MUST_CONSENT):
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
	if((timePassed > 1.6 && RNG.chance(20)) || _f > 0.8):
		return true
	return false

func doAIDecisions():
	var theF:float = (timePassed / timeFull) if timeFull > 0.0 else 1.0
	
	if(shouldDoAIDecision(target, theF)):
		doAIDecisionForTarget(target)
	for extraTarget in extraTargets:
		if(shouldDoAIDecision(extraTarget, theF)):
			doAIDecisionForTarget(extraTarget)
	
