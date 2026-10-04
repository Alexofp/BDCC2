extends InteractionSocialSimpleBase

func _init() -> void:
	id = "Flirt"
	socialActionName = "Flirt"
	socialActionCategory = CATEGORY_LUSTY
	socialIATags = {IATag.Lusty: 1.0}
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_LUSTY - 1.0
	
	startLinesTopic = id
	startLinesAmount = 1
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
			F_NAME: "Flirt",
			F_DESC: "I got flirted.",
			F_STACKMULT: 0.5,
			F_STACKMAX: 3,
			F_DURATION: 600,
			#F_DURATION_EFFECTS: 30,
			
			F_MOOD: MoodValues.new().setHorny(0.4),
		},
	}

func prepareChanceCalculator():
	var theSICC := SICCSimple.new()
	theSICC.setChance(RSValue.Affection, 0.0, -0.2, 0.8, 1.5)
	theSICC.setChance(RSValue.Lust, 0.1, 0.0, 1.0, 1.0)
	setChanceCalculator(theSICC)

func prepareUnlockConditions():
	#addUnlockCondition(SocialUnlockAffectionCondition.new(0.1))
	pass

func onSocialInteractionEnd():
	addSocialExhaustion()
	addSocialCooldown()
	if(isCriticalSuccess()):
		addRewardLust(1.0)
		addMemoryTarget(id)
		addStatusEffect(ROLE_TARGET, StatusEffect.SocialLusty, 120.0)
		addStatusEffect(ROLE_TARGET, StatusEffect.SocialHorny, 120.0)
	elif(isCriticalFail()):
		addRewardLust(-0.5)
	elif(isSuccess()):
		addRewardLust(0.4)
		addMemoryTarget(id)
		addStatusEffect(ROLE_TARGET, StatusEffect.SocialLusty, 120.0)
	elif(isFail()):
		addRewardLust(-0.1)
