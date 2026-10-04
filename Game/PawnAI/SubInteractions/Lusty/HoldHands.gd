extends InteractionSocialCoupleBase

func _init() -> void:
	id = "HoldHands"
	socialActionName = "Hold hands"
	socialActionCategory = CATEGORY_LUSTY
	socialIATags = {IATag.Lusty: 1.0}
	
	askText = id+"Start"
	coupleAnim = "HoldHands"
	coupleAnimTime = 4.0
	
	lineSure = id+"Sure"
	lineNo = id+"No"
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_LUSTY - 3.0

func getMemoriesToRegister() -> Dictionary[String, Dictionary]:
	return {
		id: {
			F_NAME: "Held hands",
			F_DESC: "Holding hands feels good.",
			F_STACKMULT: 0.5,
			F_STACKMAX: 3,
			F_DURATION: 600,
			#F_DURATION_EFFECTS: 30,
			
			F_MOOD: MoodValues.new().setHorny(0.6),
		},
	}

func prepareChanceCalculator():
	var theSICC := SICCSimple.new()
	theSICC.setChance(RSValue.Lust, 0.4, 1.0, 0.95, 3.0)
	theSICC.setChance(RSValue.Affection, 0.0, 0.5, 0.5, 3.0)
	setChanceCalculator(theSICC)

func prepareUnlockConditions():
	addUnlockCondition(SocialUnlockLustCondition.new(1.0))
	pass

func onSocialInteractionEnd():
	addSocialExhaustion()
	addSocialCooldown(600.0)
	if(isCriticalSuccess()):
		addRewardAffection(0.5)
		addRewardLust(1.5)
		addMemoryTarget(id)
		addStatusEffect(ROLE_TARGET, StatusEffect.SocialHorny, 240.0)
	elif(isCriticalFail()):
		addRewardLust(-2.0)
	elif(isSuccess()):
		addRewardAffection(0.3)
		addRewardLust(0.8)
		addMemoryTarget(id)
	elif(isFail()):
		addRewardLust(-0.3)
