extends InteractionSocialSimpleBase

func _init() -> void:
	id = "Seduce"
	socialActionName = "Seduce"
	socialActionCategory = CATEGORY_LUSTY
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_LUSTY - 3.0
	
	startLinesTopic = id+"Start"
	startLinesAmount = 1
	startLineFallback = "You look sexy today."
	
	answerAcceptActionName = "Accept"
	answerDenyActionName = "Deny"
	
	answerAcceptReaction = id+"Accept"
	answerAcceptReactionCritical = id+"Accept"
	answerDenyReaction = id+"Deny"
	answerDenyReactionCritical = id+"Deny"
	
func getMemoriesToRegister() -> Dictionary[String, Dictionary]:
	return {
		id: {
			F_NAME: "Seduced",
			F_DESC: "I feel horny.",
			F_STACKMULT: 0.5,
			F_STACKMAX: 3,
			F_DURATION: 600,
			#F_DURATION_EFFECTS: 30,
			
			F_MOOD: MoodValues.new().setHorny(0.7),
		},
	}

func prepareUnlockConditions():
	addUnlockCondition(SocialUnlockOrCondition.new(
		SocialUnlockLustCondition.new(1.0),
		SocialUnlockHasStatusEffectCondition.new(StatusEffect.SocialLusty, false)
	))
	pass

func prepareChanceCalculator():
	var theSICC := SICCSimple.new()
	theSICC.setChance(RSValue.Lust, 0.1, 1.0, 0.95, 2.2)
	theSICC.setChance(RSValue.Affection, 0.0, 0.0, 0.3, 3.0)
	setChanceCalculator(theSICC)

func onSocialInteractionEnd():
	addSocialExhaustion()
	addSocialCooldown()
	if(isCriticalSuccess()):
		addRewardLust(2.0)
		addMemoryTarget(id)
		addStatusEffect(ROLE_TARGET, StatusEffect.SocialHorny, 240.0)
	elif(isCriticalFail()):
		addRewardLust(-0.5)
	elif(isSuccess()):
		addRewardLust(1.0)
		addMemoryTarget(id)
		addStatusEffect(ROLE_TARGET, StatusEffect.SocialHorny, 120.0)
		#addStatusEffect(ROLE_MAIN, StatusEffect.SocialHorny, 120.0)
	elif(isFail()):
		addRewardLust(-0.3)
