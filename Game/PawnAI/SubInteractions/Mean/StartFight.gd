extends InteractionSocialBase

func _init() -> void:
	id = "StartFight"
	socialActionName = "Start a fight"
	socialActionCategory = CATEGORY_MEAN
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_MEAN - 5.0

func prepareChanceCalculator():
	setChanceCalculator(SICCAlways.new())

func prepareUnlockConditions():
	#addUnlockCondition(SocialUnlockAffectionCondition.new(0.1))
	pass

func onSocialInteractionEnd():
	pass

func canDoSocialAction(_c:SocialInteractionContext) -> bool:
	return _c.main.canStartFight(_c.target)

func start(_roles:Dictionary, _args:Array):
	addSocialCooldown()
	markInteractionShouldEndTalking()
	startSocialInteraction()
	pushSay(ROLE_MAIN, "StartFightStart", ROLE_TARGET, {}, TalkGesture.Angry)

	# Automatic ai surrender chance here?
	pushEvent("startFight")
	pushStopInteraction()

func onQueueEvent(_eventID:String, _args:Array):
	if(_eventID == "startFight"):
		var theTarget:CharacterPawn = getPawn(ROLE_TARGET)
		var theMain:CharacterPawn = getPawn(ROLE_MAIN)
		#if(theTarget.addEnemy(theMain, CombatPawnAI.ENEMY_GOT_SUDDENLY_ATTACKED)):
		if(theMain.addEnemy(theTarget, CombatPawnAI.ENEMY_DECIDED_TO_ATTACK) || theTarget.addEnemy(theMain, CombatPawnAI.ENEMY_DECIDED_TO_ATTACK)):
			theMain.ai.goalHandler.addGoal("PunishIfDefeated", [theTarget])
			theTarget.onGettingAttackedEnemyAdded(theMain)
