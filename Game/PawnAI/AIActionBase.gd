extends RefCounted
class_name AIActionBase

var id:String = ""
var actionTag:String = ""
var planAction:bool = false

var groupBasicAI:bool = false

var ai:PawnAI

var curPlan:AIPlan
var subAction:AIActionBase
var parentAction:AIActionBase

const STATUS_UNKNOWN = 0
const STATUS_COMPLETED = 1
const STATUS_FAILED = 2
const STATUS_IMPOSSIBLE = 3
var completeStatus:int = STATUS_UNKNOWN
var actionResult:Array

# QUEUE_WAIT_UNTIL_DELAYED_ACTIONS_DONE ?
const QUEUE_TIME = 0
const QUEUE_EVENT = 1
var subQueue:Array

# Functions to override
func start(_args:Array):
	pass

func onEnd():
	pass

func processAction(_dt:float):
	pass

func think():
	pass

func isAlreadyCompleted(_args:Array) -> bool:
	return false

func plan() -> AIPlan:
	return null

func onPlanCompleted(_plan:AIPlan):
	pass

func onPlanFail(_plan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	failAction(getActionResult())

func onSubActionResult(_tag:String, _status:int, _result:Array):
	pass

func onSubEvent(_eventID:String, _args:Array):
	pass

func getDebugText() -> String:
	return ""

func getScore(_ai:PawnAI) -> float:
	return -1.0

func getKeepScore() -> float:
	return getScore(ai) + 0.1

func handleInteractionChange(_interaction:InteractionBase) -> bool:
	return false

func needsToHappen() -> bool:
	return false

func onGettingHit(_attackContext:AttackContext) -> bool:
	return false

func shouldBeInCombatMode() -> bool:
	return false

func shouldTryToRecoverIfDefeated() -> bool:
	if(subAction && !subAction.shouldTryToRecoverIfDefeated()):
		return false
	return true

func isImpossible() -> bool:
	return false

# Functions to override END

func startFinal(_args:Array):
	start(_args)
	checkImpossible()

func onGettingHitFinal(_attackContext:AttackContext) -> bool:
	if(onGettingHit(_attackContext)):
		return true
	if(!parentAction):
		return false
	# Go up the chain
	return parentAction.onGettingHitFinal(_attackContext)

func handleInteractionChangeFinal(_interaction:InteractionBase) -> bool:
	if(handleInteractionChange(_interaction)):
		return true
	if(!parentAction):
		return false
	# Go up the chain
	return parentAction.handleInteractionChangeFinal(_interaction)

func handleInteractionStateChange(_interaction:InteractionBase) -> bool:
	return false

func handleInteractionStateChangeFinal(_interaction:InteractionBase) -> bool:
	if(handleInteractionStateChange(_interaction)):
		return true
	if(!parentAction):
		return false
	# Go up the chain
	return parentAction.handleInteractionStateChangeFinal(_interaction)

func processActionFinal(_dt:float):
	if(subAction):
		if(!subAction.hasEnded()):
			subAction.processActionFinal(_dt)
		return
	if(!isSubQueueEmpty()):
		processSubQueue(_dt)
		return
	processAction(_dt)

func processRareFinal():
	checkImpossible()
	checkSubAction()
	
	if(subAction):
		subAction.processRareFinal()
		#return
	if(!isSubQueueEmpty()):
		return
	
	processPlan()
	think()

# Update the basic AI stopAction too if you're changing this
func stopSubAction():
	if(subAction):
		subAction.stopSubAction()
		
		var theSubAction := subAction
		subAction = null
		if(ai && ai.lowestAIAction == theSubAction):
			ai.lowestAIAction = self
		
		theSubAction.onEnd()
		theSubAction.parentAction = null
	else:
		pass

func stopSubActionIfTag(_tag:String) -> bool:
	if(getSubActionTag() == _tag && !_tag.is_empty()):
		stopSubAction()
		return true
	return false

func startSubAction(_id:String, _args:Array = [], _tag:String = "") -> AIActionBase:
	if(_tag.is_empty()):
		_tag = _id
	if(hasSubAction()):
		stopSubAction()
	var theAction:AIActionBase = GlobalRegistry.createAIAction(_id)
	if(!theAction):
		assert(false, "No ai action found: "+str(_id))
		return null
	subAction = theAction
	subAction.parentAction = self
	if(ai && ai.lowestAIAction == self):
		ai.lowestAIAction = subAction
	subAction.actionTag = _tag
	subAction.setAI(getAI())
	subAction.startFinal(_args)
	return subAction

func startSubActionUnlessSameTag(_id:String, _args:Array = [], _tag:String = "") -> bool:
	if(_tag.is_empty()):
		_tag = _id
	if(getSubActionTag() == _tag):
		return false
	startSubAction(_id, _args, _tag)
	return true	

func setAI(_ai:PawnAI):
	ai = _ai

func getAI() -> PawnAI:
	return ai

func getPawn() -> CharacterPawn:
	return ai.getPawn()

func getInteraction() -> InteractionBase:
	return getPawn().getInteraction()

func getPos() -> Vector3:
	var thePawn := getPawn()
	if(!thePawn):
		return Vector3(0.0, 0.0, 0.0)
	return thePawn.global_position

func getPosNoY() -> Vector3:
	var thePawn := getPawn()
	if(!thePawn):
		return Vector3(0.0, 0.0, 0.0)
	var thePos := thePawn.global_position
	thePos.y = 0.0
	return thePos

func isSitting() -> bool:
	return !!GM.sitManager.getSeatOfPawn(getPawn())

func completeAction(_actionResult:Array = []):
	completeStatus = STATUS_COMPLETED
	actionResult = _actionResult

func failAction(_actionResult:Array = []):
	completeStatus = STATUS_FAILED
	actionResult = _actionResult

func impossibleAction(_actionResult:Array = []):
	completeStatus = STATUS_IMPOSSIBLE
	actionResult = _actionResult

func hasEnded() -> bool:
	return completeStatus != STATUS_UNKNOWN

func hasSubAction() -> bool:
	return subAction != null

func checkSubAction():
	if(!subAction || !subAction.hasEnded()):
		return
	var theAction := subAction
	stopSubAction()
	onSubActionResult(theAction.actionTag, theAction.completeStatus, theAction.getActionResult())
	if(curPlan && theAction.planAction):
		if(theAction.completeStatus != STATUS_COMPLETED):
			onPlanFail(curPlan, theAction, theAction.completeStatus)
			curPlan = null
		else:
			if(curPlan.steps.is_empty()):
				onPlanCompleted(curPlan)
				curPlan = null
		if(!curPlan):
			curPlan = planFinal()
	
func getActionResult() -> Array:
	return actionResult

func goTowards(_pos:Vector3, _run:bool = false):
	ai.goTowards(_pos, _run)

func stopWalking():
	ai.stopWalking()

func doJump():
	ai.doJump()

func teleportToNextPathPosition() -> bool:
	return ai.teleportToNextPathPosition()

func getDistSquaredTo(_pos:Vector3) -> float:
	return getPawn().global_position.distance_squared_to(_pos)

func clearSubQueue():
	subQueue.clear()

func pushTimer(_timer:float):
	subQueue.append([QUEUE_TIME, _timer])

func pushEvent(_eventID:String, _args:Array = []):
	subQueue.append([QUEUE_EVENT, _eventID, _args])

func pushReplaceWithTimedEvent(_timer:float, _eventID:String, _args:Array = []):
	clearSubQueue()
	pushTimer(_timer)
	pushEvent(_eventID, _args)

func isSubQueueEmpty() -> bool:
	return subQueue.is_empty()

func processSubQueue(_dt:float):
	while(!subQueue.is_empty()):
		var queueEntry:Array = subQueue[0]
		var entryType:int = queueEntry[0]
		
		if(entryType == QUEUE_TIME):
			queueEntry[1] -= _dt
			if(queueEntry[1] <= 0.0):
				subQueue.pop_front()
				continue
			else:
				break
		elif(entryType == QUEUE_EVENT):
			subQueue.pop_front()
			onSubEvent(queueEntry[1], queueEntry[2])
			continue
		else:
			Log.error("UNKNOWN SUB QUEUE TYPE: "+str(entryType))
			subQueue.pop_front()
		
func getSubActionID() -> String:
	if(!subAction):
		return ""
	return subAction.id

func getSubActionTag() -> String:
	if(!subAction):
		return ""
	return subAction.actionTag

func isLeashed() -> bool:
	return ai.isLeashed()
	
func isDoingDelayedActions() -> bool:
	return ai.isDoingDelayedActions()

func makeSureLeashed(_otherPawn:CharacterPawn) -> bool:
	if(getPawn().isLeashingPawn(_otherPawn)):
		return true
	
	startSubActionUnlessSameTag("LeashPawn", [_otherPawn])
	return false

func goTo(_pos:Vector3, _run:bool = false, _tag:String = "", _dist:float=1.5) -> bool:
	if(getPawn().global_position.distance_squared_to(_pos) <= (_dist*_dist)):
		return true
	
	if(getSubActionID() != "GoTo"):
		startSubAction("GoTo", [_pos], _tag)
	
	if(getAI().getNavAgent().is_navigation_finished()):
		return true
	
	if(!subAction || subAction.id != "GoTo"):
		return false
	subAction.target = _pos
	subAction.run = _run
	subAction.completeDistance = _dist
	return false

func strSmart(_val:Variant) -> String:
	if(_val is float):
		return str(Util.roundF(_val, 2))
	if(_val is Vector3):
		return "("+str(Util.roundF(_val.x, 1))+","+str(Util.roundF(_val.y, 1))+","+str(Util.roundF(_val.z, 1))+")"
	
	return str(_val)

func makePlan(_id:String = "") -> AIPlan:
	var newPlan:AIPlan = AIPlan.new()
	newPlan.id = _id
	return newPlan

func processPlan():
	if(!curPlan && !hasSubAction()):
		curPlan = planFinal()
	
	doNextPlanStep()

func doNextPlanStep():
	if(!curPlan || hasSubAction()):
		return
	
	while(!curPlan.steps.is_empty()):
		var curStepEntry:Array = curPlan.steps.pop_front()
		
		var theActionRef:AIActionBase = GlobalRegistry.getAIActionRef(curStepEntry[0])
		if(!theActionRef):
			continue
		theActionRef.ai = ai
		if(theActionRef.isAlreadyCompleted(curStepEntry[1])):
			theActionRef.ai = null
			continue
		theActionRef.ai = null
		var theAction := startSubAction(curStepEntry[0], curStepEntry[1], curStepEntry[2])
		if(theAction):
			theAction.planAction = true
		break
	
	if(curPlan.steps.is_empty() && !hasSubAction()):
		onPlanCompleted(curPlan)
		curPlan = null

func replan():
	if(subAction && subAction.planAction):
		stopSubAction()
	curPlan = null # new plan will be generated on the next tick

func isDoingPlanEntry(_tag:String) -> bool:
	if(!subAction || !curPlan):
		return false
	if(subAction.planAction && subAction.actionTag == _tag):
		return true
	return false

func doInteractEntryDo(_entry:InteractEntryDo, _target) -> bool:
	var thePawn := getPawn()
	if(!thePawn):
		return false
	
	return thePawn.doInteractEntryDo(_entry, _target)

func checkImpossible() -> bool:
	if(isImpossible()):
		impossibleAction()
		return true
	return false

func planFinal() -> AIPlan:
	if(checkImpossible()):
		return null
	return plan()

func isHandlingCombat() -> bool:
	return false

func isThisActionHandlingCombat() -> bool:
	return ai.getActionThatHandlesCombat() == self
