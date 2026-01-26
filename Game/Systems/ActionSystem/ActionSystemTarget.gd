extends RefCounted
class_name ActionSystemTarget

var node:Node
var timerType:int = ActionSystemEntry.TIMER_ONLY
var conditionType:int = ActionSystemEntry.CONDITION_DISTANCE
var targetMove:int = ActionSystemEntry.TARGET_CANMOVE
var didConsent:bool = false

func shouldCancelAction(theAction:ActionSystemEntry) -> bool:
	var theUser := theAction.user
	var theTarget := node
	
	if(!theTarget || !is_instance_valid(theTarget)):
		return true
	
	if(conditionType != ActionSystemEntry.CONDITION_NONE):
		if(!theUser.isInInteractRangeOf(theTarget)):
			return true
	
	if(targetMove != ActionSystemEntry.TARGET_CANMOVE):
		var speedTarget := ActionSystem.getSpeedOf(theTarget)
	
		if(targetMove == ActionSystemEntry.TARGET_NO_MOVEMENT && speedTarget.length_squared() >= 1.0):
			return true
		if(targetMove == ActionSystemEntry.TARGET_NO_RUNNING && speedTarget.length_squared() >= 16.0):
			return true

	return false

func markDidConsent():
	didConsent = true
