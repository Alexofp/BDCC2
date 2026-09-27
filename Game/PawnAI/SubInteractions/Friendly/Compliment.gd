extends InteractionSocialSimpleBase

func _init() -> void:
	id = "Compliment"
	socialActionName = "Compliment"
	socialActionCategory = CATEGORY_FRIENDLY
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_FRIENDLY - 1.0
	
	startLinesTopic = id+"Start"
	startLinesAmount = 4
	startLineFallback = "You look nice today."
	
	answerAcceptActionName = "Accept"
	answerDenyActionName = "Deny"
	
	answerAcceptReaction = id+"Accept"
	answerAcceptReactionCritical = id+"Accept"
	answerDenyReaction = id+"Deny"
	answerDenyReactionCritical = id+"Deny"
	
func getMemoriesToRegister() -> Dictionary[String, Dictionary]:
	return {
		id: {
			F_NAME: "Compliment",
			F_DESC: "I got complimented.",
			F_STACKMULT: 0.5,
			F_STACKMAX: 3,
			F_DURATION: 600,
			#F_DURATION_EFFECTS: 30,
			
			F_MOOD: MoodValues.new().setMood(0.4),
		},
	}

func prepareChanceCalculator():
	var theSICC := SICCSimple.new()
	theSICC.setChance(RSValue.Affection, 0.3, -0.2, 0.9, 1.5)
	theSICC.setChance(RSValue.Lust, 0.0, 0.0, 0.5, 1.0)
	setChanceCalculator(theSICC)

func prepareUnlockConditions():
	addUnlockCondition(SocialUnlockAffectionCondition.new(-0.1))
	pass

func onSocialInteractionEnd():
	addSocialExhaustion()
	addSocialCooldown(600.0)
	if(isCriticalSuccess()):
		addRewardAffection(1.0)
		addMemoryTarget(id)
	elif(isCriticalFail()):
		addRewardAffection(-0.5)
	elif(isSuccess()):
		addRewardAffection(0.4)
		addMemoryTarget(id)
	elif(isFail()):
		addRewardAffection(-0.1)
