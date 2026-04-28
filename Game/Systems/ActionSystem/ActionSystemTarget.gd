extends RefCounted
class_name ActionSystemTarget

var node:Node
var timerType:int = ActionSystemEntry.TIMER_ONLY
var conditionType:int = ActionSystemEntry.CONDITION_DISTANCE
var targetMove:int = ActionSystemEntry.MOVE_CANMOVE
var didConsent:bool = false

const AI_DECISION_UNDECIDED := 0
const AI_DECISION_ALLOW := 1
const AI_DECISION_DENY := 2 # Deny or resist

var aiDecision:int = AI_DECISION_UNDECIDED

func shouldCancelAction(theAction:ActionSystemEntry) -> bool:
	var theUser := theAction.user
	var theTarget := node
	
	if(conditionType == ActionSystemEntry.CONDITION_DISTANCE):
		if(!theUser.isInInteractRangeOf(theTarget)):
			return true
	
	if(!ActionSystem.checkSpeedCondition(theTarget, targetMove)):
		return true

	return false

func markDidConsent():
	didConsent = true

func isAutoConsented(_entry:ActionSystemEntry) -> bool:
	if(timerType == ActionSystemEntry.TIMER_CAN_DENY_ALWAYS || timerType == ActionSystemEntry.TIMER_MUST_CONSENT_ALWAYS):
		return false

	if(timerType == ActionSystemEntry.TIMER_MUST_CONSENT || timerType == ActionSystemEntry.TIMER_CAN_DENY):
		if(node is CharacterPawn):
			if(node.submission.isObeyingPawn(_entry.user)):
				return true
		return false
	
	return false

func hasAnyConsent(_entry:ActionSystemEntry) -> bool:
	if(!(node is CharacterPawn)): # Objects just auto-consent
		return true
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
	if(timerType == ActionSystemEntry.TIMER_MUST_CONSENT_ALWAYS):
		return true
	if(timerType == ActionSystemEntry.TIMER_ONLY):
		return false
	return false

func hasConsentIfTimerEnds() -> bool:
	if(timerType == ActionSystemEntry.TIMER_CAN_DENY_ALWAYS):
		return true
	if(timerType == ActionSystemEntry.TIMER_CAN_DENY):
		return true
	if(timerType == ActionSystemEntry.TIMER_MUST_CONSENT):
		return false
	if(timerType == ActionSystemEntry.TIMER_MUST_CONSENT_ALWAYS):
		return false
	if(timerType == ActionSystemEntry.TIMER_ONLY):
		return true
	return false

func decideDeny():
	aiDecision = AI_DECISION_DENY

func decideAllow():
	aiDecision = AI_DECISION_ALLOW
