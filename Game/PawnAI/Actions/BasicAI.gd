extends AIActionBase

#const PLANID_INTERACTION := "INTERACTION"

func _init() -> void:
	id = "BasicAI"

func start(_args:Array):
	pass

func processAction(_dt:float):
	pass

func onGettingHit(_attackContext:AttackContext) -> bool:
	if(!getPawn().isDefeated()):
		if(getPawn().combatAI.addEnemy(_attackContext.attacker, CombatPawnAI.ENEMY_GOT_SUDDENLY_ATTACKED)):
			getPawn().ai.goalHandler.addGoal("PunishIfDefeated", [_attackContext.attacker])
			var currentCooldown := GM.main.relationshipSystem.getActionCooldownPawns(_attackContext.target, _attackContext.attacker, SocialCooldown.Attacked)
			var theAffectionMult:float = maxf(currentCooldown + 1.0, 1.0)
			
			var toRemoveAffection:float = -0.5 / theAffectionMult
			
			GM.main.relationshipSystem.addAffection(_attackContext.target.getCharID(), _attackContext.attacker.getCharID(), toRemoveAffection)
			_attackContext.target.showValueChange("Affection", signf(toRemoveAffection), 2.0/theAffectionMult)
			
			GM.main.memorySystem.addMemory(_attackContext.target.getCharID(), "Attacked", _attackContext.attacker.getCharID())
			
			GM.main.relationshipSystem.addActionCooldownPawns(_attackContext.target, _attackContext.attacker, SocialCooldown.Attacked)
			_attackContext.target.addAnnoyance(_attackContext.attacker, 1.0)
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
		return
	
	#if(isLeashed()):
	#	stopSubAction()
	#	return
	
	#var theProp := GI.world.getNearestFreeSitSpot(getPos())
	#if(theProp):
		#startSubActionUnlessSameTag("ForcePawnSit", [GM.pcPawn, theProp])
		#if(true):
			#return

func plan() -> AIPlan:
	#var currentInteraction := getInteraction()
	#if(currentInteraction):
	#	return makePlan(PLANID_INTERACTION).add("Interaction")
	
	if(getPawn().isLeashingAnyone()): # Jank? Might cause problems, not sure how else to solve
		getPawn().stopLeashingAll()
	
	var currentGoal := ai.goalHandler.getCurrentGoal()
	if(currentGoal):
		return currentGoal.getPlan()#makePlan().add("PursueGoal")
	
	#var possible:Dictionary[AIActionBase, float]
	#var allTheBasics := GlobalRegistry.getAIActionGroupBasicAI()
	#for theAction in allTheBasics:
		#var theScore:float = theAction.getScore(ai)
		#if(theScore <= 0.0):
			#continue
		#possible[theAction] = theScore
	#
	#if(possible.is_empty()):
		#return null
	
	#var pickedAction:AIActionBase = RNG.pickWeightedDict(possible)
	#return makePlan("", pickedAction.getScore(ai)).add(pickedAction.id)
	return null

func onPlanCompleted(_plan:AIPlan):
	#if(_plan.id == PLANID_INTERACTION):
	#	return
	ai.goalHandler.onPlanCompleted(_plan)

func onPlanFail(_plan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	#if(_plan.id == PLANID_INTERACTION):
	#	return
	ai.goalHandler.onPlanFail(_plan, _failedAction, _failStatus)

func handleInteractionChange(_interaction:InteractionBase) -> bool:
	#if(curPlan && curPlan.id == PLANID_INTERACTION):
	#	replan()
	return true

func getDebugText() -> String:
	if(ai.goalHandler.currentGoal):
		return "Goal="+str(ai.goalHandler.currentGoal.id)
	return ""
