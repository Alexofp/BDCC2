extends InteractionSocialSimpleBase

func _init() -> void:
	id = "FriendlyFight"
	socialActionName = "Friendly Fight"
	socialActionCategory = CATEGORY_FRIENDLY
	
	#socialFlags = SOCIALFLAG_SHOULD_END_TALKING | SOCIALFLAG_SUPPORTS_COMBAT
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_FRIENDLY - 7.0

	startLinesTopic = "FriendlyFightAsk"
	startLineFallback = "Wanna do a friendly fight?"
	
	answerAcceptActionName = "Do a friendly fight"
	answerDenyActionName = "Deny"
	
	answerAcceptReaction = id+"Accept"
	answerAcceptReactionCritical = id+"Accept"
	answerDenyReaction = id+"Deny"
	answerDenyReactionCritical = id+"Deny"

func canDoSocialAction(_c:SocialInteractionContext) -> bool:
	return _c.main.combatAI.canAddEnemy(_c.target) || _c.main.isControlledByAnyPlayer()

func prepareChanceCalculator():
	setChanceCalculator(SICCAlways.new())

func prepareUnlockConditions():
	addUnlockCondition(SocialUnlockAffectionCondition.new(2.0))
	pass

#func start(_roles:Dictionary, _args:Array):
#	lookAt(ROLE_MAIN, ROLE_TARGET)
#	sayText(ROLE_MAIN, "Let's FIGHT!")
#	getPawn(ROLE_MAIN).combatAI.addEnemy(getPawn(ROLE_TARGET), CombatPawnAI.ENEMY_FRIENDLY_FIGHT)
#	getPawn(ROLE_TARGET).combatAI.addEnemy(getPawn(ROLE_MAIN), CombatPawnAI.ENEMY_FRIENDLY_FIGHT)

func onSocialInteractionEnd():
	addSocialExhaustion()
	addSocialCooldown(600.0)
	if(isCriticalSuccess()):
		addRewardAffection(1.0)
		#addMemoryTarget(id)
	elif(isCriticalFail()):
		addRewardAffection(-0.5)
	elif(isSuccess()):
		addRewardAffection(0.4)
		#addMemoryTarget(id)
	elif(isFail()):
		addRewardAffection(-0.1)

func answer_do(_role:int, _action:InteractionAction):
	if(_action.id == "base_yes"):
		pickedOption = _action.id
		socialInteractionAgree()
		if(isCritical()):
			pushDelay(1.0)
		pushSay(ROLE_TARGET, answerAcceptReaction if !isCritical() else answerAcceptReactionCritical, ROLE_MAIN)
		pushSetState("fight")
		getPawn(ROLE_MAIN).combatAI.addEnemy(getPawn(ROLE_TARGET), CombatPawnAI.ENEMY_FRIENDLY_FIGHT)
		getPawn(ROLE_TARGET).combatAI.addEnemy(getPawn(ROLE_MAIN), CombatPawnAI.ENEMY_FRIENDLY_FIGHT)
		socialFlags = SOCIALFLAG_SHOULD_END_TALKING | SOCIALFLAG_SUPPORTS_COMBAT
	else:
		super.answer_do(_role, _action)
	
func onFriendlyFightEnd():
	var theTarget := getPawn(ROLE_TARGET)
	var theMain := getPawn(ROLE_MAIN)
	
	if(theTarget && theMain):
		theMain.combatAI.removeEnemy(theTarget)
		theTarget.combatAI.removeEnemy(theMain)
		
		theMain.ai.goalHandler.addGoal("HelpGetUp", [theTarget.getCharID()])
		theTarget.ai.goalHandler.addGoal("HelpGetUp", [theMain.getCharID()])
	pushSocialEnd()
	pushStopInteraction()

func processRare(_dt:float):
	if(getState() != "fight"):
		super.processRare(_dt)
		return
	
	if(getDistanceBetween(ROLE_MAIN, ROLE_TARGET) > 10.0):
		stopInteraction()
	elif(getPawn(ROLE_MAIN).isDefeated() || getPawn(ROLE_TARGET).isDefeated()):
		if(getPawn(ROLE_MAIN).isDefeated()):
			sayText(ROLE_TARGET, "I won!")
		elif(getPawn(ROLE_TARGET).isDefeated()):
			sayText(ROLE_MAIN, "I won!")
		onFriendlyFightEnd()
	else:
		getPawn(ROLE_MAIN).combatAI.addEnemy(getPawn(ROLE_TARGET), CombatPawnAI.ENEMY_FRIENDLY_FIGHT)
		getPawn(ROLE_TARGET).combatAI.addEnemy(getPawn(ROLE_MAIN), CombatPawnAI.ENEMY_FRIENDLY_FIGHT)

func plan(_role:int, _action:AIActionBase) -> AIPlan:
	if(getState() == "fight"):
		return _action.makePlan().add("Combat")
	return super.plan(_role, _action)

func onGettingHit(_role:int, _attackContext:AttackContext) -> bool:
	if(!isDoingAFriendlyFight()):
		return super.onGettingHit(_role, _attackContext)
	
	if(_attackContext.attacker != getPawn(ROLE_MAIN) && _attackContext.attacker != getPawn(ROLE_TARGET)):
		stopInteraction()
		return false
	#getPawn().combatAI.addEnemy(_attackContext.attacker)
	#startSubActionUnlessSameTag("Combat")
	return true

func isHandlingCombat(_role:int) -> bool:
	if(!isDoingAFriendlyFight()):
		return super.isHandlingCombat(_role)
	return true

func isDoingAFriendlyFight() -> bool:
	return pickedOption == "base_yes" || getState() == "fight"
