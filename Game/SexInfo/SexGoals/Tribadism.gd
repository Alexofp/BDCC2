extends SexGoalBase

func _init() -> void:
	id = SexGoal.Tribadism
	
	fetishesPerformer = [Fetish.Tribadism]
	fetishesReceiver = []

func isPossibleAtAll(_info:SexParticipantInfo, _sexEngine:SexEngine, _stillPossible:bool) -> bool:
	var theChar := _info.getChar()
	if(!theChar.hasReachableVagina()):
		return false
	return true

func isPossible(_info:SexParticipantInfo, _target:SexParticipantInfo, _sex:SexEngine, _stillPossible:bool) -> bool:
	var theTarget := _target.getChar()
	if(!theTarget.hasReachableVagina()):
		return false
	return true

func getSexTasks() -> Array[SexTask]:
	return [
		sexTask(SexTask.CumTribadism),
	]
