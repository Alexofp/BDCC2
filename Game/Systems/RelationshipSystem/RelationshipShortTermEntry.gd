extends RefCounted
class_name RelationshipShortTermEntry

var char1:String
var char2:String

var annoyed:float = 0.0
var actionCooldowns:Dictionary[String, float]

func canBeRemoved() -> bool:
	if(annoyed > 0.0):
		return false
	return true
	
const ANNOY_DECAY_RATE := 0.1
const ACTION_COOLDOWN_DECAY_RATE := 0.01
	
func updateCheckShouldRemove(_dt:float) -> bool:
	if(annoyed > 0.0):
		annoyed -= _dt*ANNOY_DECAY_RATE # Should depend on personality?
	
	if(!actionCooldowns.is_empty()):
		for theAction in actionCooldowns.keys():
			actionCooldowns[theAction] -= _dt * ACTION_COOLDOWN_DECAY_RATE
			if(actionCooldowns[theAction] <= 0.0):
				actionCooldowns.erase(theAction)
		return false
	
	if(annoyed > 0.0):
		return false
	return true
