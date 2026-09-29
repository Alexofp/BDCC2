extends InteractionSocialSimpleBase

func _init() -> void:
	id = "Worship"
	socialActionName = "Worship"
	socialActionCategory = CATEGORY_SUB
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_SUBMISSION - 1.0
	
	startLinesTopic = id+"Start"
	startLinesAmount = 4
	startLineFallback = "You are awesome."
	
	answerAcceptActionName = "Accept"
	answerDenyActionName = "Deny"
	
	answerAcceptReaction = id+"Accept"
	answerAcceptReactionCritical = id+"Accept"
	answerDenyReaction = id+"Deny"
	answerDenyReactionCritical = id+"Deny"
	
func getMemoriesToRegister() -> Dictionary[String, Dictionary]:
	return {
		id: {
			F_NAME: "Worshipped",
			F_DESC: "I got praised.",
			F_STACKMULT: 0.5,
			F_STACKMAX: 3,
			F_DURATION: 600,
			#F_DURATION_EFFECTS: 30,
			
			F_MOOD: MoodValues.new().setDominance(0.4),
		},
	}

func prepareChanceCalculator():
	var theSICC := SICCSimple.new()
	theSICC.setChance(RSValue.Lust, 0.0, 0.0, 0.5, 1.5)
	theSICC.setChance(RSValue.PowerBalanceSub, 0.3, -0.2, 0.95, 1.5)
	setChanceCalculator(theSICC)

func prepareUnlockConditions():
	addUnlockCondition(SocialUnlockPBBelowCondition.new(0.05))
	#addUnlockCondition(SocialUnlockAffectionCondition.new(0.1))
	pass

func onSocialInteractionEnd():
	addSocialExhaustion()
	addSocialCooldown(600.0)
	if(isCriticalSuccess()):
		addRewardAffection(1.0)
		addRewardPowerBalance(-1.0)
		addMemoryTarget(id)
	elif(isCriticalFail()):
		markInteractionShouldEndTalking()
		addAnnoyanceTarget(0.3)
		addRewardAffection(-0.5)
	elif(isSuccess()):
		addRewardAffection(0.1)
		addRewardPowerBalance(-0.4)
		addMemoryTarget(id)
	elif(isFail()):
		addRewardAffection(-0.1)
