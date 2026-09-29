extends InteractionSocialCoupleBase

func _init() -> void:
	id = "ScritchChin"
	socialActionName = "Scritch chin"
	socialActionCategory = CATEGORY_DOM
	
	askText = id+"Start"
	coupleAnim = "ScritchChin"
	coupleAnimTime = 4.0
	
	lineSure = id+"Sure"
	lineNo = id+"No"
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_DOMINATION - 3.0

func getMemoriesToRegister() -> Dictionary[String, Dictionary]:
	return {
		id: {
			F_NAME: "Scritched chin",
			F_DESC: "Getting your chin scritched feels good.",
			F_STACKMULT: 0.5,
			F_STACKMAX: 3,
			F_DURATION: 600,
			#F_DURATION_EFFECTS: 30,
			
			F_MOOD: MoodValues.new().setDominance(-0.5),
		},
	}

func prepareChanceCalculator():
	var theSICC := SICCSimple.new()
	theSICC.setChance(RSValue.PowerBalance, 0.2, 0.0, 0.9, 1.2)
	theSICC.setChance(RSValue.Affection, 0.0, 0.5, 0.6, 3.0)
	theSICC.setChance(RSValue.Lust, 0.0, 1.0, 0.5, 3.0)
	setChanceCalculator(theSICC)

func prepareUnlockConditions():
	addUnlockCondition(SocialUnlockPBAboveCondition.new(-0.1))
	#addUnlockCondition(SocialUnlockAffectionCondition.new(0.1))
	pass

func onSocialInteractionEnd():
	addSocialExhaustion()
	addSocialCooldown(600.0)
	if(isCriticalSuccess()):
		addRewardAffection(0.5)
		addRewardPowerBalance(1.0)
		addMemoryTarget(id)
		# Subby status effect?
	elif(isCriticalFail()):
		markInteractionShouldEndTalking()
		addAnnoyanceTarget(0.5)
		addRewardAffection(-2.0)
	elif(isSuccess()):
		addRewardAffection(0.2)
		addRewardPowerBalance(0.4)
		addMemoryTarget(id)
	elif(isFail()):
		addRewardAffection(-0.2)
