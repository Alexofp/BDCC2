extends RefCounted
class_name SexGoalBase

var id:String = ""

var fetishesPerformer:Array[String] = []
var fetishesReceiver:Array[String] = []

var target:String = ""
var infoRef:WeakRef

var completed:bool = false

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
	
	var result:Array = []
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

func markCompleted():
	completed = true

func isCompleted() -> bool:
	return completed
