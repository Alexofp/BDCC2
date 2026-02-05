extends RefCounted
class_name InteractionAction

var id:String
var actionName:String = "FILL ME"
var score:float = 0.0
var args:Array

static func create(_id:String, _name:String) -> InteractionAction:
	var theAction := InteractionAction.new()
	theAction.id = _id
	theAction.actionName = _name
	return theAction

func setScore(_score:float) -> InteractionAction:
	score = _score
	return self
