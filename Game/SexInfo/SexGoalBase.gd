extends RefCounted
class_name SexGoalBase

var id:String = ""

var fetishesPerformer:Array[String] = []
var fetishesReceiver:Array[String] = []

var info:SexParticipantInfo
var target:SexParticipantInfo

const GOAL_INPROGRESS := 0
const GOAL_COMPLETED := 1
const GOAL_FAILED := 2
const GOAL_CANCELLED := 3
var status:int = GOAL_INPROGRESS

var resistedAmount:int = 0

#func prepareForSex(_targetID:String, _taskID:String, _args:Array) -> float:
	#if(_taskID == SexTask.Undress && _args.size() > 0 && _args[0] == _targetID):
		#return 0.5
	#if(_taskID == SexTask.Undress && _args.size() > 0 && _args[0] == getInfo().getID()):
		#return 0.5
	#return 0.0

#func getRequiredPossibleTasks() -> Array[String]:
#	return ["cuminside"]

#func getTaskScore(_taskID:String, _args:Array) -> float:
#	return 0.0

func onOneOfSexTasksCompleted(_sexTask:SexTask):
	completeSelf()

func findSexTaskForEvent(_taskID:String, _targetInfo:SexParticipantInfo) -> SexTask:
	var theSexTasks := getSexTasks()
	for theTask in theSexTasks:
		if(theTask.id == _taskID && theTask.actor==getCharID() && theTask.target==_targetInfo.getID()):
			return theTask
	return null

func handleTaskEvent(_taskID:String, _targetInfo:SexParticipantInfo, _event:int) -> bool:
	if(_event == SexEngineActivityBase.EVENT_COMPLETED):
		var theTask := findSexTaskForEvent(_taskID, _targetInfo)
		if(theTask):
			onOneOfSexTasksCompleted(theTask)
			return true
	if(_event == SexEngineActivityBase.EVENT_FAILED):
		var theTask := findSexTaskForEvent(_taskID, _targetInfo)
		if(theTask):
			failSelf()
			return true
	if(_event == SexEngineActivityBase.EVENT_GOT_STUCK):
		var theTask := findSexTaskForEvent(_taskID, _targetInfo)
		if(theTask):
			cancelSelf()
			return true
	if(_event == SexEngineActivityBase.EVENT_GOT_REJECTED):
		var theTask := findSexTaskForEvent(_taskID, _targetInfo)
		if(theTask):
			cancelSelf()
			return true
	return false

func completeSelf():
	if(isFinished()):
		return
	status = GOAL_COMPLETED
	Log.Print("TASK COMPLETED: "+id)
	onGoalFinished()

func cancelSelf():
	if(isFinished()):
		return
	status = GOAL_CANCELLED
	Log.Print("TASK CANCELLED: "+id)
	onGoalFinished()

func failSelf():
	if(isFinished()):
		return
	status = GOAL_FAILED
	Log.Print("TASK FAILED: "+id)
	onGoalFinished()

func onGoalFinished():
	if(info):
		var theSex := info.getSexEngine()
		if(theSex):
			theSex.onParticipantGoalFinished(info, self)

func isPossibleAtAll(_info:SexParticipantInfo, _sexEngine:SexEngine) -> bool:
	return true

func isPossible(_info:SexParticipantInfo, _target:SexParticipantInfo, _sex:SexEngine) -> bool:
	return false

func setupSexGoal(_info:SexParticipantInfo, _target:SexParticipantInfo, _sex:SexEngine, _args:Array) -> bool:
	info = _info
	target = _target
	return true

# Returns [ [target, score, args], [target, score, args], ...]
func getGoalTargets(_info:SexParticipantInfo, _sex:SexEngine) -> Array:
	if(!_info.canDoDomActions()):
		return []
	if(!isPossibleAtAll(_info, _sex)):
		return []
	var hasAnySubs:bool = _sex.hasAnySubs()
	var result:Array = []
	for charID in _sex.getParticipants():
		var theTargetInfo := _sex.getParticipant(charID)
		if(theTargetInfo == _info): # Supports self check here?
			continue
		if(theTargetInfo.canDoDomActions() && hasAnySubs):
			continue
		if(!isPossible(_info, theTargetInfo, _sex)):
			continue
		result.append([theTargetInfo, 1.0, []])
	return result

func getInfo() -> SexParticipantInfo:
	return info

func getSexEngine() -> SexEngine:
	var theInfo := getInfo()
	if(theInfo):
		return theInfo.getSexEngine()
	return null

func isCompleted() -> bool:
	return status == GOAL_COMPLETED

func isFinished() -> bool:
	return status != GOAL_INPROGRESS

func shouldDomWearStraponToFuck() -> bool:
	var theInfo := getInfo()
	assert(theInfo != null)
	var theChar := theInfo.getChar()
	return !theChar.hasReachablePenis() && theChar.canWearStrapon()
	
func shouldCharWearStraponToFuck(_theChar:BaseCharacter) -> bool:
	return !_theChar.hasReachablePenis() && _theChar.canWearStrapon()

func getCharID() -> String:
	return info.getID()

## If one of these get completed, the whole goal is considered completed
func getSexTasks() -> Array[SexTask]:
	return [
	]

func sexTask(_id:String) -> SexTask:
	return SexTask.create(_id, getCharID(), target.getID())

#func sexTaskReceive(_id:String) -> SexTask:
#	return SexTask.create(_id, target.getID(), getCharID())
