extends InteractionSocialSimpleBase

func _init() -> void:
	id = "Submit"
	socialActionName = "Submit"
	socialActionCategory = CATEGORY_SUB
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_SUBMISSION - 3.0
	
	startLinesTopic = "SubmitAsk"
	startLineFallback = "I wanna submit to you."
	
	answerAcceptActionName = "Dominate"
	answerDenyActionName = "Deny"
	
	answerAcceptReaction = "SubmitAccept"
	answerAcceptReactionCritical = "SubmitAccept"
	answerDenyReaction = "SubmitDeny"
	answerDenyReactionCritical = "SubmitDenyCrit"
	
func getMemoriesToRegister() -> Dictionary[String, Dictionary]:
	return {
	}

func prepareChanceCalculator():
	var theSICC := SICCSimple.new().withCritChances(0.2, 0.0)
	theSICC.setChance(RSValue.PowerBalanceSub, 0.5, 0.0, 1.0, 1.0)
	setChanceCalculator(theSICC)

func prepareUnlockConditions():
	addUnlockCondition(SocialUnlockPBBelowCondition.new(0.05))
	pass

func onSocialInteractionEnd():
	addSocialExhaustion()
	addSocialCooldown(600.0)
	if(isCriticalFail()):
		markInteractionShouldEndTalking()
		addAnnoyanceTarget(1.0)
		getPawn(ROLE_TARGET).combatAI.addEnemy(getPawn(ROLE_MAIN), CombatPawnAI.ENEMY_SOCIAL_INTERACITON)
		getPawn(ROLE_MAIN).combatAI.addEnemy(getPawn(ROLE_TARGET), CombatPawnAI.ENEMY_SOCIAL_INTERACITON)
		say(ROLE_TARGET, "InsultResponseFight", ROLE_MAIN, {}, TalkGesture.None)
		pushDelay(1.0)
		pushSocialDenied()
		pushStopInteraction()
	elif(isSuccess()):
		addRewardPowerBalance(-0.1)
		getPawn(ROLE_MAIN).submission.tryMakeObeyPawn(getPawn(ROLE_TARGET))
	elif(isFail()):
		addAnnoyanceTarget(0.6)
		addRewardAffection(-0.2)

	if((isCriticalSuccess() || isSuccess()) && !isPlayer(ROLE_TARGET)):
		#markInteractionShouldEndTalking()
		#stopInteraction()
		startInteraction("Defeated", {
			main = getPawn(ROLE_TARGET),
			target = getPawn(ROLE_MAIN),
		})
