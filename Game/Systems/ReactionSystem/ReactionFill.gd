extends RefCounted
class_name ReactionFill

var id:String = "" # if not provided, gonna get an auto generated one based on index
var reactionID:String # Which reaction does this fill belong to
var priority:int = 0
var score:float = 1.0 # Multiplied by the amount of lines
var condition:ReactionExpression # Some kind of expression tree
var lines:Array[String]

# Smart random that avoids repetitions?
func getRandomLine() -> String:
	if(lines.is_empty()):
		return ""
	return RNG.pick(lines)
