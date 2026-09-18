extends InteractionSocialCoupleBase

func _init() -> void:
	id = "Hug"
	socialActionName = "Hug"
	socialActionCategory = CATEGORY_FRIENDLY
	
	askText = "WannaHug"
	coupleAnim = "Hug"
	coupleAnimTime = 4.0
	
	lineSure = "HugSure"
	lineNo = "HugNo"
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_FRIENDLY - 2.0

func prepareChanceCalculator():
	var theSICC := SICCSimple.new()
	theSICC.setChance(SICC.Affection, 0.4, 1.0, 0.9, 2.0)
	setChanceCalculator(theSICC)

func prepareUnlockConditions():
	addUnlockCondition(SocialUnlockAffectionCondition.new(1.0))
	pass

func onSocialInteractionEnd():
	addSocialExhaustion()
	addSocialCooldown(600.0)
	if(isCriticalSuccess()):
		addRewardAffection(2.0)
		addMemoryTarget(FriendlyMemories.Hug)
	elif(isCriticalFail()):
		addRewardAffection(-2.0)
	elif(isSuccess()):
		addRewardAffection(1.0)
		addMemoryTarget(FriendlyMemories.Hug)
	elif(isFail()):
		addRewardAffection(-0.3)
