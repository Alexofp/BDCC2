extends RefCounted
class_name RelationshipShortTermEntry

var char1:String
var char2:String

var annoyed:float

func canBeRemoved() -> bool:
	if(annoyed > 0.0):
		return false
	return true
	
