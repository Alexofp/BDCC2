extends RefCounted
class_name SexGoalBase

var id:String = ""

var fetishesPerformer:Array[String] = []
var fetishesReceiver:Array[String] = []

var target:String = ""
var infoRef:WeakRef

var completed:bool = false

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

func handleTaskEvent(_taskID:String, _args:Array) -> bool:
	return false

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

func tryGenerateGoals(_info:SexParticipantInfo, _sex:SexEngine) -> Array[Dictionary]:
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
	return infoRef.get_ref() if infoRef else null

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
	return getInfo().getID()
