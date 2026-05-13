extends InteractionSocialBase

func _init() -> void:
	id = "OfferSex"
	socialActionName = "Offer sex"
	socialActionCategory = CATEGORY_FRIENDLY
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_FRIENDLY - 5.0

func prepareUnlockConditions():
	addUnlockCondition(SocialUnlockAffectionCondition.new(0.6))

func prepareSocialInteraction():
	setSocialRequiredScore(0.15)
	addSocial(SocialScoreAffection.new())
	addSocial(SocialScoreLust.new())
	
	addSocial(SocialCheckExhaustion.new())
	addSocial(SocialCheckCooldown.new(SocialCooldown.Sex))
	
	addSocial(SocialEffectAddExhaustion.new())
	addSocial(SocialEffectAddAffection.new(0.5, -0.3))
	addSocial(SocialEffectAddMemory.new(FriendlyMemories.GoodSex))
	

func canDoSocialAction(_c:SocialInteractionContext) -> bool:
	return true

func start(_roles:Dictionary, _args:Array):
	startSocialInteraction()
	say(ROLE_MAIN, "OfferSex", ROLE_TARGET)
	pushDelay(2.0)

func _actions(_role:int):
	if(_role == ROLE_TARGET):
		var agreeScore := scoreSocialAgree()
		
		addAction(action("yes", "Accept", agreeScore))
		addAction(action("no", "Deny", 1.0 - agreeScore))

func _do(_role:int, _action:InteractionAction):
	if(_action.id == "yes"):
		socialInteractionStart()
		say(ROLE_TARGET, "Sure", ROLE_MAIN)
		pushDelay(3.0)
		pushSetState("follow")
		#pushStopInteraction()
	if(_action.id == "no"):
		say(ROLE_TARGET, "No", ROLE_MAIN)
		pushDelay(2.0)
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
		say(ROLE_MAIN, "OfferSexCancel", ROLE_TARGET)
		pushDelay(2.0)
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
		socialInteraction.status = SocialInteractionHandler.STATUS_DENY
		socialInteraction.success = remap(theSatisfaction, 0.5, 0.0, 0.0, 1.0)
	else:
		socialInteraction.status = SocialInteractionHandler.STATUS_AGREE
		socialInteraction.success = remap(theSatisfaction, 0.5, 1.0, 0.0, 1.0)
	setState("afterSex")
	clearPushQueue()
	pushDelay(2.0)
	pushSay(ROLE_TARGET, "OfferSexEnd", ROLE_MAIN)
	pushDelay(2.0)
	pushSocialEnd()
	pushStopInteraction()
