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
	interactionPriority = PRIO_FRIENDLY - 4.1

func prepareUnlockConditions():
	addUnlockCondition(SocialUnlockAffectionCondition.new(2.0))
	pass

func prepareChanceCalculator():
	var theSICC := SICCSimple.new()
	theSICC.setChance(SICC.Affection, 0.3, 2.0, 0.9, 3.0)
	theSICC.setChance(SICC.Lust, 0.0, 0.0, 0.5, 3.0)
	theSICC.setChance(SICC.PowerBalance, 0.0, 0.0, 0.5, 2.0)
	setChanceCalculator(theSICC)

func onSocialInteractionEnd():
	addSocialExhaustion()
	addSocialCooldown(1000.0)
	if(isCriticalSuccess()):
		addRewardAffection(5.0)
		addMemoryTarget(FriendlyMemories.Embraced)
	elif(isCriticalFail()):
		addRewardAffection(-3.0)
	elif(isSuccess()):
		addRewardAffection(2.0)
		addMemoryTarget(FriendlyMemories.Embraced)
	elif(isFail()):
		addRewardAffection(-1.0)
