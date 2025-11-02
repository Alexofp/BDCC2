extends SexGoalBase

func _init() -> void:
	id = SexGoal.FuckAnal
	
	fetishesPerformer = [Fetish.SexAnal]
	fetishesReceiver = []

func isPossibleAtAll(_info:SexParticipantInfo, _sexEngine:SexEngine) -> bool:
	if(true):
		return true #TODO: REMOVE ME
	var theChar := _info.getChar()
	if(!theChar.hasReachablePenis()):
		return false
	return true

func isPossible(_info:SexParticipantInfo, _target:SexParticipantInfo, _sex:SexEngine) -> bool:
	if(true):
		return true #TODO: REMOVE ME
	var theTarget := _target.getChar()
	if(!theTarget.hasReachableVagina()):
		return false
	return false

func handleTaskEvent(_taskID:String, _args:Array) -> bool:
	if(_taskID == SexTask.CumInsideAnal && _args.size() > 0 && _args[0] == target):
		completeSelf()
		return true
	return false

func getTasks() -> Array:
	var result:Array = []
	#prepareForSex(result, target)
	result.append(task(SexTask.CumInsideAnal, [target]))
	return result
