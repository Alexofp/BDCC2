extends RefCounted
class_name InteractionAction

var id:String
var actionName:String = "FILL ME"
var score:float = 0.0
var args:Array
var disabled:bool = false
var category:Array[String]
var fallbackScore:float = 0.0 # Fallback actions will be chosen if no other actions have score
var interaction:InteractionBase

static func create(_id:String, _name:String) -> InteractionAction:
	var theAction := InteractionAction.new()
	theAction.id = _id
	theAction.actionName = _name
	return theAction

func setCategory(_cat:Array[String]) -> InteractionAction:
	category = _cat
	return self

func setScore(_score:float) -> InteractionAction:
	score = _score
	return self

func setFallback(_score:float = 0.2) -> InteractionAction:
	fallbackScore = _score
	return self

func setDisabled(_dis:bool) -> InteractionAction:
	disabled = _dis
	return self
