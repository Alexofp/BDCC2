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
	#for otherPawnInteractor in getPawn().pawn_interactor.nearbyPawns:
		#if(otherPawnInteractor.pawn.isControlledByAnyPlayer() || otherPawnInteractor.pawn.isDefeated()):
			#continue
		#getPawn().combatAI.addEnemy(otherPawnInteractor.pawn)
	
	if(getPawn().combatAI.hasEnemies()): # Some check if maybe the sub-action can handle it
		startSubActionUnlessSameTag("Combat")
		return
	
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
