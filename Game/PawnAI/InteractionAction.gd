extends RefCounted
class_name InteractionAction

var id:String
var actionName:String = "FILL ME"
var score:float = 0.0
var args:Array
var disabled:bool = false
var category:Array[String]
var fallbackScore:float = 0.0 # Fallback actions will be chosen if no other actions have score
var timeoutTime:float = 0.0 # Timeout actions are chosen after this amount of seconds passes with nobody picking any action
var timeoutScore:float = 1.0 # Score of the timeout action
var timeoutOnly:bool = false # Only show this action after timeoutShow seconds have passed
var timeoutShow:float = 0.0
var chance:float = 1.0 # Only used for ai
var aiTags:Dictionary[int, float] = {} # Only used for ai
var interaction:InteractionBase
var canDoBitfield:int = PawnActionBase.CAN_COLLAPSED | PawnActionBase.CAN_DEFEATED

static func create(_id:String, _name:String) -> InteractionAction:
	var theAction := InteractionAction.new()
	theAction.id = _id
	theAction.actionName = _name
	return theAction

func setCanDoBitfield(_bits:int) -> InteractionAction:
	canDoBitfield = _bits
	return self

func allowDuringCoupleAnim() -> InteractionAction:
	canDoBitfield |= PawnActionBase.CAN_COUPLE_ANIM
	return self

func setAll(_category:Array[String], _score:float, _chance:float, _aiTags:Dictionary[int, float]) -> InteractionAction:
	category = _category
	score = _score
	chance = _chance
	aiTags = _aiTags
	return self

func setAITags(_tags:Dictionary[int, float]) -> InteractionAction:
	aiTags = _tags
	return self

func setChance(_c:float) -> InteractionAction:
	chance = _c
	return self

func setArgs(_args:Array) -> InteractionAction:
	args = _args
	return self

func setCategory(_cat:Array[String]) -> InteractionAction:
	category = _cat
	return self

func setScore(_score:float) -> InteractionAction:
	score = _score
	return self

func setFallback(_score:float = 0.2) -> InteractionAction:
	fallbackScore = _score
	return self

func setOnTimeout(_time:float, _score:float = 1.0) -> InteractionAction:
	timeoutTime = _time
	timeoutScore = _score
	return self

func setDisabled(_dis:bool) -> InteractionAction:
	disabled = _dis
	return self

func setShowAfter(_time:float) -> InteractionAction:
	timeoutOnly = (_time > 0.0)
	timeoutShow = _time
	return self

func shouldShowAction(_interaction:InteractionBase, _pawn:CharacterPawn) -> bool:
	if(timeoutOnly && interaction && interaction.timeoutTime < timeoutShow):
		return false
	return true
