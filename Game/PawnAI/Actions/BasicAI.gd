extends AIActionBase

func _init() -> void:
	id = "BasicAI"

func start(_args:Array):
	pass

func processAction(_dt:float):
	pass

func think():
	if(isLeashed()):
		stopSubAction()
		return
	
	if(hasSubAction()):
		return
	
	var possible:Dictionary[AIActionBase, float]
	var allTheBasics := GlobalRegistry.getAIActionGroupBasicAI()
	for theAction in allTheBasics:
		var theScore:float = theAction.getScore(ai)
		if(theScore <= 0.0):
			continue
		possible[theAction] = theScore
	
	if(possible.is_empty()):
		return
	startSubActionUnlessSameTag(RNG.pickWeightedDict(possible).id)
