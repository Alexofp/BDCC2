extends InteractionSocialBase

func _init() -> void:
	id = "OfferSex"
	socialActionName = "Offer sex"
	socialActionCategory = CATEGORY_FRIENDLY
	
	registerForInteractionType = [InteractionType.Talking]

func prepareSocialInteraction():
	addSocial(SocialCheckAffection.new(0.15).addMod(MoodEffects.FriendlyAgreeMod))
	addSocial(SocialCheckExhaustion.new(0.8))
	addSocial(SocialCheckCooldown.new(SocialInteractionKind.Sex))
	
	addSocial(SocialEffectAddExhaustion.new())
	addSocial(SocialEffectAddAffection.new(0.01, -0.005))
	addSocial(SocialEffectAddMemory.new("Compliment"))
	

func canDoSocialAction(_main:CharacterPawn, _target:CharacterPawn) -> bool:
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
	if(_role == ROLE_TARGET && _action.user == getPawn(ROLE_MAIN) && _action.action.id == "SexOffer"):
		return true
	return false

func follow_plan(_role:int, _action:AIActionBase) -> AIPlan:
	return planApproachEachOther(ROLE_MAIN, ROLE_TARGET, _role, _action)
	
#func plan(_role:int, _action:AIActionBase) -> AIPlan:
#	return planFaceEachOther(ROLE_MAIN, ROLE_TARGET, _role, _action)

func onSexEngineResult(_result:SexEngineResult):
	if(state == "follow"):
		setState("afterSex")
		clearPushQueue()
		pushDelay(2.0)
		pushSay(ROLE_TARGET, "OfferSexEnd", ROLE_MAIN)
		pushDelay(2.0)
		pushSocialEnd()
		pushStopInteraction()
