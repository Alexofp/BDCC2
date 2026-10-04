extends RefCounted
class_name RelationshipShortTermEntry

var char1:String
var char2:String

var annoyed:float = 0.0

func canBeRemoved() -> bool:
	if(annoyed > 0.0):
		return false
	return true
	
func updateCheckShouldRemove(_dt:float) -> bool:
	if(annoyed > 0.0):
		annoyed -= _dt*GM.GB.socialAnnoyanceFadeRate # Should depend on personality?
	
	if(annoyed > 0.0):
		return false
	return true
