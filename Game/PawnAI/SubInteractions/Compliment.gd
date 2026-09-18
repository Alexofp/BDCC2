extends InteractionSocialBase

var complimentLines:Array[String]

func _init() -> void:
	id = "Compliment"
	socialActionName = "Compliment"
	socialActionCategory = CATEGORY_FRIENDLY
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_FRIENDLY - 1.0

func prepareChanceCalculator():
	var theSICC := SICCSimple.new()
	theSICC.setChance(SICC.Affection, 0.3, -0.2, 0.9, 1.5)
	theSICC.setChance(SICC.Lust, 0.0, 0.0, 0.5, 1.0)
	#theSICC.critFailChance = 1.0
	#theSICC.critWinChance = 1.0
	setChanceCalculator(theSICC)

func prepareUnlockConditions():
	#addUnlockCondition(SocialUnlockAffectionCondition.new(0.1))
	pass

func onSocialInteractionEnd():
	addSocialExhaustion()
	addSocialCooldown(600.0)
	if(isCriticalSuccess()):
		addRewardAffection(1.0)
		addMemoryTarget(FriendlyMemories.Compliment)
	elif(isCriticalFail()):
		addRewardAffection(-0.5)
	elif(isSuccess()):
		addRewardAffection(0.4)
		addMemoryTarget(FriendlyMemories.Compliment)
	elif(isFail()):
		addRewardAffection(-0.1)

func canDoSocialAction(_c:SocialInteractionContext) -> bool:
	return true

func start(_roles:Dictionary, _args:Array):
	startSocialInteraction()
	complimentLines = getXSayLines(4, ROLE_MAIN, "Compliment", ROLE_TARGET)
	if(complimentLines.is_empty()):
		complimentLines = ["You look nice today."]

func _actions(_role:int):
	if(_role == ROLE_MAIN):
		for theLine in complimentLines:
			addAction(action("say", theLine).setArgs([theLine]).setScore(1.0))

func _do(_role:int, _action:InteractionAction):
	if(_action.id == "say"):
		socialInteractionStart()
		sayText(ROLE_MAIN, _action.args[0])
		pushDelay(2.0)
		pushSetState("answer")

func answer_actions(_role:int):
	if(_role == ROLE_TARGET):
		var agreeScore := scoreSocialAgree()
		
		addAction(action("yes", "Accept", agreeScore))
		addAction(action("no", "Deny", 1.0 - agreeScore))

func answer_do(_role:int, _action:InteractionAction):
	if(_action.id == "yes"):
		socialInteractionAgree()
		if(isCritical()):
			pushDelay(1.0)
		pushSay(ROLE_TARGET, "ComplimentAccept", ROLE_MAIN)
		pushDelay(2.0)
		pushSocialEnd()
		pushStopInteraction()
	if(_action.id == "no"):
		socialInteractionDeny()
		if(isCritical()):
			pushDelay(1.0)
		pushSay(ROLE_TARGET, "ComplimentDeny", ROLE_MAIN)
		pushDelay(2.0)
		#pushAddAffection(ROLE_MAIN, ROLE_TARGET, -0.1)
		pushSocialEnd()
		pushStopInteraction()
