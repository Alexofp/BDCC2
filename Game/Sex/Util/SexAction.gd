extends RefCounted
class_name SexAction

const ACTION_ACTION = 0
const ACTION_DELAY = 1
const ACTION_DELAY_CANCANCEL = 2
const ACTION_CONSENT_CHECK = 3

#var id:String = ""
var actionName:String = ""
#var args:Array = []
var score:float = 0.0
var category:Array[String] = []
var payload:Array = []

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

func consent(_delay:float) -> SexAction:
	payload.append([ACTION_CONSENT_CHECK, _delay])
	return self

func setScore(_score:float) -> SexAction:
	score = _score
	return self

func setCat(_category:Array[String]) -> SexAction:
	category = _category
	return self
