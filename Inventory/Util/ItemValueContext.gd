extends RefCounted
class_name ItemValueContext

const Gift:int = 0

var target:BaseCharacter
var gifter:BaseCharacter
var type:int = Gift

static func make(_target:BaseCharacter, _gifter:BaseCharacter = null, _type:int = Gift) -> ItemValueContext:
	var theContext := ItemValueContext.new()
	theContext.target = _target
	theContext.gifter = _gifter
	theContext.type = _type
	return theContext
