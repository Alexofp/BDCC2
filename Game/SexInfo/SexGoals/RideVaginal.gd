extends SexGoalBase

func _init() -> void:
	id = SexGoal.RideVaginal
	
	fetishesPerformer = []
	fetishesReceiver = [Fetish.SexVaginal]

func isPossibleAtAll(_info:SexParticipantInfo, _sexEngine:SexEngine) -> bool:
	var theChar := _info.getChar()
	if(!theChar.hasReachableVagina()):
		return false
	return true

func isPossible(_info:SexParticipantInfo, _target:SexParticipantInfo, _sex:SexEngine) -> bool:
	var theTarget := _target.getChar()
	if(!theTarget.hasReachablePenis() && !theTarget.canWearStrapon()):
		return false
	return true

func handleTaskEvent(_taskID:String, _args:Array) -> bool:
	if(_taskID == SexTask.ReceiveCumInsideVaginal && _args.size() > 0 && _args[0] == target):
		completeSelf()
		return true
	return false

func getTasks() -> Array:
	var result:Array = []
	#prepareForSex(result, target)
	#if(shouldDomWearStraponToFuck()):
	if(shouldCharWearStraponToFuck(GM.characterRegistry.getCharacter(target))):
		result.append(task(SexTask.WearStrapon, [target]))
	result.append(task(SexTask.ReceiveCumInsideVaginal, [target]))
	return result
