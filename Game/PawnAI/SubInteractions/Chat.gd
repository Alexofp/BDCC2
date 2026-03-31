extends InteractionSocialBase

func _init() -> void:
	id = "Chat"
	socialActionName = "Chat"
	socialActionCategory = CATEGORY_FRIENDLY
	
	registerForInteractionType = [InteractionType.Talking]

func prepareSocialInteraction():
	var theSocial := makeSocialInteraction("GenericFriendly")
	if(!theSocial):
		return
	theSocial.affectionGain = 0.005
	theSocial.affectionLossDeny = 0.0025
	theSocial.setKind(SocialInteractionKind.Chat)
	theSocial.memorySuccess = "Chat"
	theSocial.memorySuccessAbove = 0.3

func canDoSocialAction(_main:CharacterPawn, _target:CharacterPawn) -> bool:
	return true

func start(_roles:Dictionary, _args:Array):
	startSocialInteraction()
	say(ROLE_MAIN, "WannaChat", ROLE_TARGET)
	pushDelay(2.0)

func _actions(_role:int):
	if(_role == ROLE_TARGET):
		var agreeScore := scoreSocialAgree()
		
		addAction(action("yes", "Yes", agreeScore))
		addAction(action("no", "No", 1.0 - agreeScore))

func _do(_role:int, _action:InteractionAction):
	if(_action.id == "yes"):
		socialInteractionStart()
		say(ROLE_TARGET, "Sure", ROLE_MAIN)
		pushDelay(3.0)
		pushSay(ROLE_MAIN, "Talk", ROLE_TARGET)
		pushDelay(4.0)
		pushSay(ROLE_TARGET, "Talk", ROLE_MAIN)
		pushDelay(4.0)
		#pushAddAffection(ROLE_MAIN, ROLE_TARGET, 0.1)
		pushSocialEnd()
		pushStopInteraction()
	if(_action.id == "no"):
		say(ROLE_TARGET, "No", ROLE_MAIN)
		pushDelay(2.0)
		#pushAddAffection(ROLE_MAIN, ROLE_TARGET, -0.1)
		pushSocialDenied()
		pushStopInteraction()
