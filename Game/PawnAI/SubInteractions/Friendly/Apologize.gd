extends InteractionSocialSimpleBase

func _init() -> void:
	id = "Apologize"
	socialActionName = "Apologize"
	socialActionCategory = CATEGORY_FRIENDLY
	socialIATags = {IATag.Apologize: 1.0}
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_FRIENDLY - 1.0
	
	startLinesTopic = "ApologizeStart"
	startLinesAmount = 1
	startLineFallback = "I wanna apologize for what happened."
	
	answerAcceptActionName = "Accept"
	answerDenyActionName = "Deny"
	
	answerAcceptReaction = id+"Accept"
	answerAcceptReactionCritical = id+"Accept"
	answerDenyReaction = id+"Deny"
	answerDenyReactionCritical = id+"Deny"
	
func getMemoriesToRegister() -> Dictionary[String, Dictionary]:
	return {
		id: {
			F_NAME: "Received apology",
			F_DESC: "I received an apology.",
			F_STACKMULT: 0.5,
			F_STACKMAX: 3,
			F_DURATION: 600,
			#F_DURATION_EFFECTS: 30,
			
			F_MOOD: MoodValues.new().setAnger(-0.4),
		},
	}

func prepareChanceCalculator():
	var theSICC := SICCSimple.new()
	theSICC.setChance(RSValue.Affection, 0.5, 0.0, 0.5, 0.0)
	setChanceCalculator(theSICC)

func prepareUnlockConditions():
	addUnlockCondition(SocialUnlockApologyCondition.new())
	pass

# An alternative outcomes where the target tries to dominate you (apology accepted only if you submit) could be cool
# Or asks for credits
# Or asks for secks
# Or asks to do a certain task

func onSocialInteractionEnd():
	var theAffection:float = getAffection(ROLE_TARGET, ROLE_MAIN)
	
	addSocialExhaustion()
	addSocialCooldown(600.0)
	if(isCriticalSuccess()):
		addRewardAffection(-theAffection*1.2)
		addMemoryTarget(id)
	elif(isCriticalFail()):
		markInteractionShouldEndTalking()
		addAnnoyanceTarget(1.0)
		addRewardAffection(-1.0)
		getPawn(ROLE_TARGET).combatAI.addEnemy(getPawn(ROLE_MAIN), CombatPawnAI.ENEMY_SOCIAL_INTERACITON)
		getPawn(ROLE_MAIN).combatAI.addEnemy(getPawn(ROLE_TARGET), CombatPawnAI.ENEMY_SOCIAL_INTERACITON)
	elif(isSuccess()):
		addRewardAffection(-theAffection)
		addMemoryTarget(id)
	elif(isFail()):
		markInteractionShouldEndTalking()
		addAnnoyanceTarget(0.5)
		addRewardAffection(-0.1)
