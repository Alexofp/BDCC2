extends RefCounted
class_name SexGoalBase

var id:String = ""

var fetishesPerformer:Array[String] = []
var fetishesReceiver:Array[String] = []

var info:SexParticipantInfo
var target:SexParticipantInfo

var completed:bool = false

#TODO: DELETE
func task(_taskID:String, _taskArgs:Array, _score:float = 1.0) -> Array:
	return [_taskID, _taskArgs, _score]

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

func handleTaskEvent(_taskID:String, _targetInfo:SexParticipantInfo, _event:int) -> bool:
	if(_event == SexEngineActivityBase.EVENT_COMPLETED):
		var theSexTasks := getSexTasks()
		for theTask in theSexTasks:
			if(theTask.id == _taskID && theTask.actor==getCharID() && theTask.target==_targetInfo.getID()):
				onOneOfSexTasksCompleted(theTask)
				return true
	return false

#TODO: DELETE
func getTasks() -> Array:
	return []

func completeSelf():
	if(completed):
		return
	completed = true
	Log.Print("TASK COMPLETED: "+id)

func isPossibleAtAll(_info:SexParticipantInfo, _sexEngine:SexEngine) -> bool:
	return true

func isPossible(_info:SexParticipantInfo, _target:SexParticipantInfo, _sex:SexEngine) -> bool:
	return false

func generateGoalData(_info:SexParticipantInfo, _target:SexParticipantInfo, _sex:SexEngine) -> Array:
	return [_target.getID()]

func setupGoal(_goalData:Array) -> bool:
	target = _goalData[0] if _goalData.size() > 0 else ""
	return true

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

func getGenerateGoalScoreFinal(_info:SexParticipantInfo, _target:SexParticipantInfo, _sex:SexEngine, _args:Array) -> float:
	return 1.0

#TODO: DELETE
func tryGenerateGoalsOLD(_info:SexParticipantInfo, _sex:SexEngine) -> Array[Dictionary]:
	if(!_info.canDoDomActions()):
		return []
	if(!isPossibleAtAll(_info, _sex)):
		return []
	
	var hasAnySubs:bool = _sex.hasAnySubs()
	
	var result:Array[Dictionary] = []
	for charID in _sex.getParticipants():
		var theTargetInfo := _sex.getParticipant(charID)
		
		if(theTargetInfo == _info):
			continue
		if(theTargetInfo.canDoDomActions() && hasAnySubs):
			continue
		if(!isPossible(_info, theTargetInfo, _sex)):
			continue
		
		result.append({
			score = 1.0,
			args = generateGoalData(_info, theTargetInfo, _sex),
		})
	
	return result

func getInfo() -> SexParticipantInfo:
	return info

func getSexEngine() -> SexEngine:
	var theInfo := getInfo()
	if(theInfo):
		return theInfo.getSexEngine()
	return null

func isCompleted() -> bool:
	return completed

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

func sexTaskReceive(_id:String) -> SexTask:
	return SexTask.create(_id, target.getID(), getCharID())
