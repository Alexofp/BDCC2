extends RefCounted
class_name AIActionBase

var id:String = ""
var actionTag:String = ""

var ai:PawnAI

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

func onSubActionResult(_tag:String, _status:int, _result:Array):
	pass

func onSubEvent(_eventID:String, _args:Array):
	pass

func getDebugText() -> String:
	return ""

# Functions to override END


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
	checkSubAction()
	
	if(subAction):
		subAction.processRareFinal()
		#return
	if(!isSubQueueEmpty()):
		return
	think()

func stopSubAction():
	if(subAction):
		subAction.stopSubAction()
		subAction.onEnd()
		if(ai.lowestAIAction == subAction.parentAction):
			ai.lowestAIAction = self
		subAction.parentAction = null
	subAction = null

func startSubAction(_id:String, _args:Array = [], _tag:String = ""):
	if(_tag.is_empty()):
		_tag = _id
	if(hasSubAction()):
		stopSubAction()
	var theAction:AIActionBase = GlobalRegistry.createAIAction(_id)
	if(!theAction):
		assert(false, "No ai action found: "+str(_id))
		return
	subAction = theAction
	subAction.parentAction = self
	if(ai.lowestAIAction == self):
		ai.lowestAIAction = subAction
	subAction.actionTag = _tag
	subAction.setAI(getAI())
	subAction.start(_args)

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
	if(!ai):
		return null
	return ai.getPawn()

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
	
	
