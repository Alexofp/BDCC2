extends InteractionSocialCoupleBase

func _init() -> void:
	id = "Kiss"
	socialActionName = "Kiss"
	socialActionCategory = CATEGORY_LUSTY
	
	askText = "WannaKiss"
	coupleAnim = "Kiss"
	coupleAnimTime = 4.0
	
	lineSure = "KissSure"
	lineNo = "KissNo"
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_LUSTY - 2.0

func getMemoriesToRegister() -> Dictionary[String, Dictionary]:
	return {
		id: {
			F_NAME: "Kiss",
			F_DESC: "Getting kissed feels good.",
			F_STACKMULT: 0.5,
			F_STACKMAX: 3,
			F_DURATION: 600,
			#F_DURATION_EFFECTS: 30,
			
			F_MOOD: MoodValues.new().setHorny(0.6),
		},
	}

func prepareChanceCalculator():
	var theSICC := SICCSimple.new()
	theSICC.setChance(RSValue.Lust, 0.4, 1.0, 0.9, 2.0)
	setChanceCalculator(theSICC)

func prepareUnlockConditions():
	addUnlockCondition(SocialUnlockLustCondition.new(1.0))
	pass

func onSocialInteractionEnd():
	addSocialExhaustion()
	addSocialCooldown(600.0)
	if(isCriticalSuccess()):
		addRewardLust(2.0)
		addMemoryTarget(id)
	elif(isCriticalFail()):
		addRewardLust(-2.0)
	elif(isSuccess()):
		addRewardLust(1.0)
		addMemoryTarget(id)
	elif(isFail()):
		addRewardLust(-0.3)
