extends RefCounted
class_name ReactionEntry

enum ArgType {
	NOTHING,
	PAWN,
	BOOL,
	INT,
	FLOAT,
	STRING,
}

class Argument:
	var type:int = ArgType.NOTHING
	var default:Variant = null

var id:String
var args:Dictionary[String, Argument]
var fallback:Array[String]
var fallbackID:String = ""

static func getDefaultValueForArgType(_type:int) -> Variant:
	if(_type == ArgType.BOOL):
		return false
	if(_type == ArgType.INT):
		return 0
	if(_type == ArgType.FLOAT):
		return 0.0
	if(_type == ArgType.STRING):
		return ""
	return null
