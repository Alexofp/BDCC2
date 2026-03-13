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

func isHandlingCombat() -> bool:
	return true

func think():
	#for otherPawnInteractor in getPawn().pawn_interactor.nearbyPawns:
		#if(otherPawnInteractor.pawn.isControlledByAnyPlayer() || otherPawnInteractor.pawn.isDefeated()):
			#continue
		#getPawn().combatAI.addEnemy(otherPawnInteractor.pawn)
	
	if(isThisActionHandlingCombat()):
		if(getPawn().combatAI.hasEnemies()):
			startSubActionUnlessSameTag("Combat")
			return
	
	var theInteraction := getInteraction()
	if(theInteraction):
		startSubActionUnlessSameTag("Interaction")
		return
	
	if(isLeashed()):
		stopSubAction()
		return
	
	#var theProp := GI.world.getNearestFreeSitSpot(getPos())
	#if(theProp):
		#startSubActionUnlessSameTag("ForcePawnSit", [GM.pcPawn, theProp])
		#if(true):
			#return

func plan() -> AIPlan:
	var possible:Dictionary[AIActionBase, float]
	var allTheBasics := GlobalRegistry.getAIActionGroupBasicAI()
	for theAction in allTheBasics:
		var theScore:float = theAction.getScore(ai)
		if(theScore <= 0.0):
			continue
		possible[theAction] = theScore
	
	if(getPawn().isLeashingAnyone()): # Jank? Might cause problems, not sure how else to solve
		getPawn().stopLeashingAll()
	
	if(possible.is_empty()):
		return null
	
	return makePlan().add(RNG.pickWeightedDict(possible).id)

func onPlanFail(_plan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	return

func onPlanCompleted(_plan:AIPlan):
	pass

func handleInteractionChange(_interaction:InteractionBase) -> bool:
	if(_interaction):
		startSubAction("Interaction") # Will restart if new interaction
	else:
		stopSubActionIfTag("Interaction")
	
	return true
