extends RefCounted
class_name AIPlan

var id:String
var steps:Array

func add(_stepID:String, _args:Array = [], _tag:String = "") -> AIPlan:
	steps.append([
		_stepID, _args, _tag,
	])
	return self
