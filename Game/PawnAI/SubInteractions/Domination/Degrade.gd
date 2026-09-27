extends InteractionSocialSimpleBase

func _init() -> void:
	id = "Degrade"
	socialActionName = "Degrade"
	socialActionCategory = CATEGORY_DOM
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_DOMINATION - 1.9
	
	startLinesTopic = id+"Start"
	startLinesAmount = 4
	startLineFallback = "You are a slut."
	
	answerAcceptActionName = "Accept"
	answerDenyActionName = "Deny"
	
	answerAcceptReaction = id+"Accept"
	answerAcceptReactionCritical = id+"Accept"
	answerDenyReaction = id+"Deny"
	answerDenyReactionCritical = id+"Deny"
	
func getMemoriesToRegister() -> Dictionary[String, Dictionary]:
	return {
		id: {
			F_NAME: "Degraded",
			F_DESC: "I got degraded.",
			F_STACKMULT: 0.5,
			F_STACKMAX: 3,
			F_DURATION: 600,
			#F_DURATION_EFFECTS: 30,
			
			F_MOOD: MoodValues.new().setDominance(-0.4),
		},
	}

func prepareChanceCalculator():
	var theSICC := SICCSimple.new()
	theSICC.setChance(RSValue.Affection, 0.0, -0.2, 0.4, 1.5)
	theSICC.setChance(RSValue.Lust, 0.0, 0.2, 0.9, 2.5)
	theSICC.setChance(RSValue.PowerBalance, 0.0, 0.0, 0.9, 2.5)
	setChanceCalculator(theSICC)

func prepareUnlockConditions():
	addUnlockCondition(SocialUnlockPBAboveCondition.new(-0.05))
	#addUnlockCondition(SocialUnlockAffectionCondition.new(0.1))
	pass

func onSocialInteractionEnd():
	addSocialExhaustion()
	addSocialCooldown(600.0)
	if(isCriticalSuccess()):
		addRewardAffection(1.0)
		addRewardPowerBalance(1.0)
		addMemoryTarget(id)
	elif(isCriticalFail()):
		markInteractionShouldEndTalking()
		addAnnoyanceTarget(1.0)
		getPawn(ROLE_TARGET).combatAI.addEnemy(getPawn(ROLE_MAIN), CombatPawnAI.ENEMY_SOCIAL_INTERACITON)
		getPawn(ROLE_MAIN).combatAI.addEnemy(getPawn(ROLE_TARGET), CombatPawnAI.ENEMY_SOCIAL_INTERACITON)
		addRewardAffection(-0.5)
	elif(isSuccess()):
		addRewardAffection(0.1)
		addRewardPowerBalance(0.4)
		addMemoryTarget(id)
	elif(isFail()):
		markInteractionShouldEndTalking()
		addAnnoyanceTarget(0.3)
		addRewardAffection(-0.1)
