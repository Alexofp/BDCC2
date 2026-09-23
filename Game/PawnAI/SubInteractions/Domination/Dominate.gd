extends InteractionSocialSimpleBase

func _init() -> void:
	id = "Dominate"
	socialActionName = "Dominate"
	socialActionCategory = CATEGORY_DOM
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_FRIENDLY - 1.0
	
	startLinesTopic = "Dominate"
	startLineFallback = "You gonna do what I tell you to do."
	
	answerAcceptActionName = "Submit"
	answerDenyActionName = "Deny"
	
	answerAcceptReaction = "DominateAccept"
	answerAcceptReactionCritical = "DominateAccept"
	answerDenyReaction = "DominateDeny"
	answerDenyReactionCritical = "DominateDenyCrit"
	
func getMemoriesToRegister() -> Dictionary[String, Dictionary]:
	return {
	}

func prepareChanceCalculator():
	var theSICC := SICCSimple.new().withCritChances(0.5, 0.0)
	theSICC.setChance(SICC.PowerBalance, 0.03, 0.0, 1.0, 2.0)
	setChanceCalculator(theSICC)

func prepareUnlockConditions():
	addUnlockCondition(SocialUnlockPBAboveCondition.new(-0.05))
	pass

func onSocialInteractionEnd():
	addSocialExhaustion()
	addSocialCooldown(600.0)
	if(isCriticalFail()):
		markInteractionShouldEndTalking()
		addAnnoyanceTarget(1.0)
		getPawn(ROLE_TARGET).combatAI.addEnemy(getPawn(ROLE_MAIN), CombatPawnAI.ENEMY_SOCIAL_INTERACITON)
		getPawn(ROLE_MAIN).combatAI.addEnemy(getPawn(ROLE_TARGET), CombatPawnAI.ENEMY_SOCIAL_INTERACITON)
		say(ROLE_TARGET, "InsultResponseFight", ROLE_MAIN, {}, false)
		pushDelay(1.0)
		pushSocialDenied()
		pushStopInteraction()
	elif(isSuccess()):
		addRewardPowerBalance(0.1)
		getPawn(ROLE_TARGET).submission.tryMakeObeyPawn(getPawn(ROLE_MAIN))
	elif(isFail()):
		addAnnoyanceTarget(0.6)
		addRewardAffection(-0.2)

	if((isCriticalSuccess() || isSuccess()) && !isPlayer(ROLE_MAIN)):
		#markInteractionShouldEndTalking()
		#stopInteraction()
		startInteraction("Defeated", {
			main = getPawn(ROLE_MAIN),
			target = getPawn(ROLE_TARGET),
		})
