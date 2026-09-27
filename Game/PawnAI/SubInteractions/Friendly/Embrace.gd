extends InteractionSocialCoupleBase

func _init() -> void:
	id = "Embrace"
	socialActionName = "Embrace"
	socialActionCategory = CATEGORY_FRIENDLY
	
	askText = "WannaEmbrace"
	coupleAnim = "Embrace"
	coupleAnimTime = 6.0
	
	lineSure = "HugSure"
	lineNo = "HugNo"
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_FRIENDLY - 6.1

func getMemoriesToRegister() -> Dictionary[String, Dictionary]:
	return {
		id: {
			F_NAME: "Embraced",
			F_DESC: "Getting hugged feels good.",
			F_STACKMULT: 0.5,
			F_STACKMAX: 3,
			F_DURATION: 600,
			#F_DURATION_EFFECTS: 30,
			
			F_MOOD: MoodValues.new().setMood(0.6),
		},
	}

func prepareUnlockConditions():
	addUnlockCondition(SocialUnlockAffectionCondition.new(2.0))
	pass

func prepareChanceCalculator():
	var theSICC := SICCSimple.new()
	theSICC.setChance(RSValue.Affection, 0.3, 2.0, 0.9, 3.0)
	theSICC.setChance(RSValue.Lust, 0.0, 0.0, 0.5, 3.0)
	theSICC.setChance(RSValue.PowerBalance, 0.0, 0.0, 0.5, 2.0)
	setChanceCalculator(theSICC)

func onSocialInteractionEnd():
	addSocialExhaustion()
	addSocialCooldown(1000.0)
	if(isCriticalSuccess()):
		addRewardAffection(5.0)
		addMemoryTarget(id)
	elif(isCriticalFail()):
		addRewardAffection(-3.0)
	elif(isSuccess()):
		addRewardAffection(2.0)
		addMemoryTarget(id)
	elif(isFail()):
		addRewardAffection(-1.0)
