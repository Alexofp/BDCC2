extends AIActionBase

func _init() -> void:
	id = "BasicAI"

func start(_args:Array):
	pass

func processAction(_dt:float):
	pass

func onGettingHit(_attackContext:AttackContext) -> bool:
	getPawn().combatAI.addEnemy(_attackContext.attacker)
	startSubActionUnlessSameTag("Combat")
	return true

func think():
	var theInteraction := getInteraction()
	if(theInteraction):
		startSubActionUnlessSameTag("Interaction")
		return
	
	if(isLeashed()):
		stopSubAction()
		return
	
	if(hasSubAction()):
		return
	
	#var theProp := GI.world.getNearestFreeSitSpot(getPos())
	#if(theProp):
		#startSubActionUnlessSameTag("ForcePawnSit", [GM.pcPawn, theProp])
		#if(true):
			#return
	
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

func handleInteractionChange(_interaction:InteractionBase) -> bool:
	if(_interaction):
		startSubAction("Interaction") # Will restart if new interaction
	else:
		stopSubActionIfTag("Interaction")
	
	return true
