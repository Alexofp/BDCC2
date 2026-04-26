extends RefCounted
class_name ActionSystemTarget

var node:Node
var timerType:int = ActionSystemEntry.TIMER_ONLY
var conditionType:int = ActionSystemEntry.CONDITION_DISTANCE
var targetMove:int = ActionSystemEntry.TARGET_CANMOVE
var didConsent:bool = false

const AI_DECISION_UNDECIDED := 0
const AI_DECISION_ALLOW := 1
const AI_DECISION_DENY := 2 # Deny or resist

var aiDecision:int = AI_DECISION_UNDECIDED

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

func isAutoConsented(_entry:ActionSystemEntry) -> bool:
	if(timerType == ActionSystemEntry.TIMER_CAN_DENY_ALWAYS):
		return false
	if(timerType == ActionSystemEntry.TIMER_CAN_DENY):
		if(node is CharacterPawn):
			if(node.isDefeated()):
				return true
		return false
	#if(timerType == ActionSystemEntry.TIMER_MUST_CONSENT):
		#if(node is CharacterPawn):
			#if(node.submission.isObeyingPawn()):
				#return true
		#return false
	
	return false

func hasAnyConsent(_entry:ActionSystemEntry) -> bool:
	if(didConsent || isAutoConsented(_entry)):
		return true
	return false

func needsConsent(_entry:ActionSystemEntry) -> bool:
	if(timerType == ActionSystemEntry.TIMER_CAN_DENY_ALWAYS):
		return true
	if(timerType == ActionSystemEntry.TIMER_CAN_DENY):
		return true
	if(timerType == ActionSystemEntry.TIMER_MUST_CONSENT):
		return true
	return false

func decideDeny():
	aiDecision = AI_DECISION_DENY

func decideAllow():
	aiDecision = AI_DECISION_ALLOW
