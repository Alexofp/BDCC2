extends InteractionSocialBase

func _init() -> void:
	id = "OfferSex"
	socialActionName = "Offer sex"
	socialActionCategory = CATEGORY_LUSTY
	socialIATags = {IATag.OfferSex: 1.0}
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_LUSTY - 3.0

func prepareUnlockConditions():
	#addUnlockCondition(SocialUnlockAffectionCondition.new(0.0))
	pass

func prepareChanceCalculator():
	var theSICC := SICCSimple.new().withCritChances(0.3, 0.0)
	theSICC.setChance(RSValue.Lust, 0.04, 0.5, 1.0, 3.0)
	theSICC.setChance(RSValue.PowerBalance, 0.0, 1.0, 1.0, 3.0)
	setChanceCalculator(theSICC)

func onSocialInteractionEnd():
	if(isSuccess()):
		addRewardLust(0.5)
		addMemoryTarget(FriendlyMemories.GoodSex)
	if(isFail()):
		addRewardAffection(-0.3)
		#addSocialCooldown()
	if(isCriticalFail()):
		addAnnoyanceTarget(1.0)
		addSocialCooldown()
		markInteractionShouldEndTalking()

func canDoSocialAction(_c:SocialInteractionContext) -> bool:
	return true

func start(_roles:Dictionary, _args:Array):
	startSocialInteraction()
	pushSay(ROLE_MAIN, "OfferSex", ROLE_TARGET)

func _actions(_role:int):
	if(_role == ROLE_TARGET):
		var agreeScore := scoreSocialAgree()
		
		addAction(action("yes", "Accept", agreeScore))
		addAction(action("no", "Deny", 1.0 - agreeScore))

func _do(_role:int, _action:InteractionAction):
	if(_action.id == "yes"):
		socialInteractionStart()
		socialInteractionAgree()
		pushSay(ROLE_TARGET, "Sure", ROLE_MAIN)
		pushSetState("follow")
		#pushStopInteraction()
	if(_action.id == "no"):
		socialInteractionStart()
		socialInteractionDeny()
		pushSay(ROLE_TARGET, "OfferSexDeny" if !isCriticalFail() else "OfferSexDenyCrit", ROLE_MAIN)
		#pushAddAffection(ROLE_MAIN, ROLE_TARGET, -0.1)
		pushSocialDenied()
		pushStopInteraction()

func follow_actions(_role:int):
	if(_role == ROLE_MAIN):
		if(getPawn(ROLE_MAIN).isDoingSomething()):
			return
		if(getPawn(ROLE_MAIN).isDoingSex()):
			return
		#var agreeScore := scoreSocialAgree()
		
		if(getPawn(ROLE_MAIN).canDoInteractEntryDo(InteractEntryDo.create("SexOffer"), getPawn(ROLE_TARGET))):
			addAction(action("start", "Do it here", 1.0))
		addAction(action("cancel", "Never mind", 0.0))

func follow_do(_role:int, _action:InteractionAction):
	if(_action.id == "start"):
		getPawn(ROLE_MAIN).doInteractEntryDo(InteractEntryDo.create("SexOffer"), getPawn(ROLE_TARGET))
		#socialInteractionStart()
		#say(ROLE_TARGET, "ComplimentAccept", ROLE_MAIN)
		#pushDelay(3.0)
		#pushSocialEnd()
		#pushStopInteraction()
		
	if(_action.id == "cancel"):
		pushSay(ROLE_MAIN, "OfferSexCancel", ROLE_TARGET)
		#pushAddAffection(ROLE_MAIN, ROLE_TARGET, -0.1)
		pushSocialDenied()
		pushStopInteraction()

func shouldAllowDelayedAction(_role:int, _action:ActionSystemEntry) -> bool:
	#if(socialInteraction.status != SocialInteractionHandler.STATUS_AGREE):
		#return false
	if(state != "follow"):
		return false
	if(_role == ROLE_TARGET && _action.user == getPawn(ROLE_MAIN) && _action.action.id == "SexOffer"):
		return true
	return false

func follow_plan(_role:int, _action:AIActionBase) -> AIPlan:
	return planApproachEachOther(ROLE_MAIN, ROLE_TARGET, _role, _action)
	
#func plan(_role:int, _action:AIActionBase) -> AIPlan:
#	return planFaceEachOther(ROLE_MAIN, ROLE_TARGET, _role, _action)

func onSexEngineResult(_result:SexEngineResult):
	if(state != "follow"):
		return
	var theSatisfaction:float = _result.getSatisfactionCharID(getCharID(ROLE_TARGET))
	
	if(theSatisfaction < 0.5):
		markAsFail(false, remap(theSatisfaction, 0.5, 0.0, 0.0, 1.0))
	else:
		markAsSuccess(false, remap(theSatisfaction, 0.5, 1.0, 0.0, 1.0))
	setState("afterSex")
	clearPushQueue()
	pushDelay(2.0)
	pushSay(ROLE_TARGET, "OfferSexEnd", ROLE_MAIN)
	pushSocialEnd()
	pushStopInteraction()
