extends SexGoalBase

func _init() -> void:
	id = SexGoal.FuckAnal
	
	fetishesPerformer = [Fetish.SexAnal]
	fetishesReceiver = []

func isPossibleAtAll(_info:SexParticipantInfo, _sexEngine:SexEngine) -> bool:
	var theChar := _info.getChar()
	if(!theChar.hasReachablePenis() && !theChar.canWearStrapon()):
		return false
	return true

func isPossible(_info:SexParticipantInfo, _target:SexParticipantInfo, _sex:SexEngine) -> bool:
	var theTarget := _target.getChar()
	if(!theTarget.hasReachableAnus()):
		return false
	return true

func getSexTasks() -> Array[SexTask]:
	return [
		sexTask(SexTask.CumInsideAnal),
	]
