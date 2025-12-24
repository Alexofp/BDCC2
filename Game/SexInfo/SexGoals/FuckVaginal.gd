extends SexGoalBase

func _init() -> void:
	id = SexGoal.FuckVaginal
	
	fetishesPerformer = [Fetish.SexVaginal]
	fetishesReceiver = []

func isPossibleAtAll(_info:SexParticipantInfo, _sexEngine:SexEngine) -> bool:
	var theChar := _info.getChar()
	if(!theChar.hasReachablePenis() && !theChar.canWearStrapon()):
		return false
	return true

func isPossible(_info:SexParticipantInfo, _target:SexParticipantInfo, _sex:SexEngine) -> bool:
	var theTarget := _target.getChar()
	if(!theTarget.hasReachableVagina()):
		return false
	return false

#func getTaskScore(_taskID:String, _args:Array) -> float:
	#var theScore:float = 0.0
	#theScore += prepareForSex(target, _taskID, _args)
	#
	#if(_taskID == SexTask.CumInsideVaginal && _args.size() > 0 && _args[0] == target):
		#theScore += 1.0
	#return theScore

func handleTaskEvent(_taskID:String, _args:Array) -> bool:
	if(_taskID == SexTask.CumInsideVaginal && _args.size() > 0 && _args[0] == target):
		completeSelf()
		return true
	return false

func getTasks() -> Array:
	var result:Array = []
	#prepareForSex(result, target)
	if(shouldDomWearStraponToFuck()):
		result.append(task(SexTask.WearStrapon, [getCharID()]))
	result.append(task(SexTask.CumInsideVaginal, [target]))
	return result
