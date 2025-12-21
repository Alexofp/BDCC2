extends SexGoalBase

func _init() -> void:
	id = SexGoal.Tribadism
	
	fetishesPerformer = [Fetish.Tribadism]
	fetishesReceiver = []

func isPossibleAtAll(_info:SexParticipantInfo, _sexEngine:SexEngine) -> bool:
	var theChar := _info.getChar()
	if(!theChar.hasReachableVagina()):
		return false
	return true

func isPossible(_info:SexParticipantInfo, _target:SexParticipantInfo, _sex:SexEngine) -> bool:
	var theTarget := _target.getChar()
	if(!theTarget.hasReachableVagina()):
		return false
	return false

func handleTaskEvent(_taskID:String, _args:Array) -> bool:
	if(_taskID == SexTask.CumTribadism && _args.size() > 0 && _args[0] == target):
		completeSelf()
		return true
	return false

func getTasks() -> Array:
	var result:Array = []
	#prepareForSex(result, target)
	#if(shouldDomWearStraponToFuck()):
	#	result.append(task(SexTask.WearStrapon, [getCharID()]))
	result.append(task(SexTask.CumTribadism, [target]))
	return result
