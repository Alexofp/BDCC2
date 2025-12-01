extends RefCounted
class_name SexAction

const ACTION_ACTION = 0
const ACTION_DELAY = 1
const ACTION_DELAY_CANCANCEL = 2
const ACTION_CONSENT_CHECK = 3
const ACTION_START = 4
const ACTION_EXPOSE = 5

#var id:String = ""
var actionName:String = ""
#var args:Array = []
var score:float = 0.0
var category:Array[String] = []
var payload:Array = []
var cooldownID:String = ""
var cooldownTime:float = 0.0
var disabled:bool = false
var overridePriority:int = 0

static func make(_name:String) -> SexAction:
	var theAction:SexAction = SexAction.new()
	theAction.actionName = _name
	return theAction

func do(_id:String, _args:Array = []) -> SexAction:
	payload.append([ACTION_ACTION, _id, _args])
	return self

func delay(_delay:float) -> SexAction:
	payload.append([ACTION_DELAY, _delay])
	return self

func delayCancel(_delay:float) -> SexAction:
	payload.append([ACTION_DELAY_CANCANCEL, _delay])
	return self

func consent(_consenters:Array = [], _conTexts:Array=[], _scoringStrategy:int = SexEngineActivityBase.CONSENT_RESISTANCE, _strategyArgs:Array = []) -> SexAction:
	payload.append([ACTION_CONSENT_CHECK, 5.0, 3.0, _scoringStrategy, _strategyArgs, _consenters, _conTexts])
	return self

func start(_roles:Dictionary, _args:Dictionary = {}) -> SexAction:
	payload.append([ACTION_START, _roles, _args])
	return self

func setScore(_score:float) -> SexAction:
	score = _score
	return self

func setCat(_category:Array[String]) -> SexAction:
	category = _category
	return self

func setCooldown(_cooldownID:String, _cooldownTime:float = 0.0) -> SexAction:
	cooldownID = _cooldownID
	cooldownTime = _cooldownTime
	return self

func setDisabled(_dis:bool) -> SexAction:
	disabled = _dis
	return self

func setEnabled(_dis:bool) -> SexAction:
	disabled = !_dis
	return self

func expose(_giver:Variant, _receiver:Variant, _fetishID:String, _intensity:float = 1.0) -> SexAction:
	payload.append([ACTION_EXPOSE, _giver, _receiver, _fetishID, _intensity])
	return self

func setOverridePriority(_overridePriority:int) -> SexAction:
	overridePriority = _overridePriority
	return self
