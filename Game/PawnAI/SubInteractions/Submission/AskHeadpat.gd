extends InteractionSocialCoupleBase

func _init() -> void:
	id = "AskHeadpat"
	socialActionName = "Ask for headpats"
	socialActionCategory = CATEGORY_SUB
	socialIATags = {IATag.Submission: 1.0}
	
	askText = id+"Start"
	coupleAnim = "Headpat"
	coupleAnimTime = 4.0
	coupleAnimReverse = true
	
	lineSure = id+"Sure"
	lineNo = id+"No"
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_SUBMISSION - 4.0

func getMemoriesToRegister() -> Dictionary[String, Dictionary]:
	return {
		#id: {
		#	F_NAME: "Headpatted",
		#	F_DESC: "Getting your head patted feels good.",
		#	F_STACKMULT: 0.5,
		#	F_STACKMAX: 3,
		#	F_DURATION: 600,
		#	#F_DURATION_EFFECTS: 30,
		#	
		#	F_MOOD: MoodValues.new().setDominance(-1.0),
		#},
	}

func prepareChanceCalculator():
	var theSICC := SICCSimple.new()
	theSICC.setChance(RSValue.PowerBalanceSub, 0.2, 1.0, 0.9, 2.2)
	theSICC.setChance(RSValue.Affection, 0.0, 0.5, 0.6, 3.0)
	theSICC.setChance(RSValue.Lust, 0.0, 1.0, 0.5, 3.0)
	setChanceCalculator(theSICC)

func prepareUnlockConditions():
	addUnlockCondition(SocialUnlockPBBelowCondition.new(-1.0))
	pass

func onSocialInteractionEnd():
	addSocialExhaustion()
	addSocialCooldown(600.0)
	if(isCriticalSuccess()):
		addRewardAffection(0.5)
		addRewardPowerBalance(-2.5)
		#addMemoryTarget(id)
		addMemoryStarter("Headpat")
		# Subby status effect?
	elif(isCriticalFail()):
		markInteractionShouldEndTalking()
		addAnnoyanceTarget(0.5)
		addRewardAffection(-2.0)
	elif(isSuccess()):
		addRewardAffection(0.3)
		addRewardPowerBalance(-1.0)
		#addMemoryTarget(id)
		addMemoryStarter("Headpat")
	elif(isFail()):
		addRewardAffection(-0.3)
