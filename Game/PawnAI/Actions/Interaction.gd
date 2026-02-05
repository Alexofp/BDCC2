extends AIActionBase

func _init() -> void:
	id = "Interaction"

func start(_args:Array):
	pass

func onEnd():
	pass

func processAction(_dt:float):
	pass

func think():
	var theInteraction := getInteraction()
	if(!theInteraction):
		completeAction()
		return
	var thePawn := getPawn()
	theInteraction.thinkFor(thePawn, self)
	
	# Action selection
	var theActions := theInteraction.getActionsFor(thePawn)
	var fullScore:float = 0.0
	var theWeightMap:Dictionary[InteractionAction, float]
	for theAction in theActions:
		if(theAction.score <= 0.0):
			continue
		fullScore += theAction.score
		theWeightMap[theAction] = theAction.score
	
	if(theWeightMap.is_empty() || !RNG.chance(fullScore * 100.0)):
		return
	var theActionToDo:InteractionAction = RNG.pickWeightedDict(theWeightMap)
	if(!theActionToDo):
		return
	theInteraction.doActionFor(thePawn, theActionToDo)

func onSubActionResult(_tag:String, _status:int, _result:Array):
	var theInteraction := getInteraction()
	if(!theInteraction):
		return
	var theRole:int = theInteraction.getRoleOf(getPawn())
	if(theRole < 0):
		return
	theInteraction.onSubActionResult(theRole, getPawn(), ai, self, _tag, _status, _result)

func onSubEvent(_eventID:String, _args:Array):
	pass
