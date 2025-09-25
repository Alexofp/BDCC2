extends RefCounted
class_name SexEvent

var id:String = ""
var args:Array = []

static func make(_id:String, _args:Array = []) -> SexEvent:
	var newEvent:SexEvent = SexEvent.new()
	newEvent.id = _id
	newEvent.args = _args
	return newEvent
