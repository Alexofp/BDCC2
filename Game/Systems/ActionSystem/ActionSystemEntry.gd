extends RefCounted
class_name ActionSystemEntry

const TIMER_ONLY = 0
const TIMER_MUST_CONSENT = 1
const TIMER_CAN_DENY = 2

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

var timerType:int = TIMER_ONLY
var conditionType:int = CONDITION_DISTANCE
var userMove:int = USER_CANMOVE
var targetMove:int = TARGET_CANMOVE
var cancelType:int = CANCEL_ALLOW

var timeFull:float = 1.0
var timePassed:float = 0.0

var user:CharacterPawn
var target:Node

var action:PawnActionBase
var args:Array

var actionText:String = ""

static func create(_text:String, _user:CharacterPawn, _target:Node, _timer:float, _action:PawnActionBase, _args:Array = []) -> ActionSystemEntry:
	var newEntry := ActionSystemEntry.new()
	
	#newEntry.actionText = _text
	newEntry.user = _user
	newEntry.target = _target
	newEntry.timeFull = _timer
	newEntry.action = _action
	newEntry.args = _args
	
	newEntry.setActionText(_text)
	
	return newEntry

func getProgressValue() -> float:
	if(timeFull <= 0.0):
		return 1.0
	var theVal:float = clamp(timePassed / timeFull, 0.0, 1.0)
	if(timerType == TIMER_MUST_CONSENT):
		return 1.0 - theVal
	return theVal

func setActionText(_text:String, _doParse:bool = true):
	if(!_doParse):
		actionText = _text
		return
	var theReplacers:Dictionary[String, String]
	if(user):
		theReplacers["user"] = user.getCharID()
	if(target && (target is CharacterPawn)):
		theReplacers["target"] = target.getCharID()
	
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
	timerType = _type
	return self

func setConditionType(_type:int) -> ActionSystemEntry:
	conditionType = _type
	return self

func setUserMove(_type:int) -> ActionSystemEntry:
	userMove = _type
	return self

func setTargetMove(_type:int) -> ActionSystemEntry:
	targetMove = _type
	return self

func setCancelType(_type:int) -> ActionSystemEntry:
	cancelType = _type
	return self
