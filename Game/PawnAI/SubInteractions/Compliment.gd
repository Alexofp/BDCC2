extends InteractionSocialBase

var complimentLines:Array[String]

func _init() -> void:
	id = "Compliment"
	socialActionName = "Compliment"
	socialActionCategory = CATEGORY_FRIENDLY
	
	registerForInteractionType = [InteractionType.Talking]

func prepareSocialInteraction():
	addSocial(SocialCheckAffection.new(0.3).addMod(MoodEffects.FriendlyAgreeMod))
	addSocial(SocialCheckExhaustion.new())
	addSocial(SocialCheckCooldown.new(SocialInteractionKind.Chat))
	
	addSocial(SocialEffectAddExhaustion.new())
	addSocial(SocialEffectAddAffection.new(0.2, -0.1))
	addSocial(SocialEffectAddMemory.new("Compliment"))
	


func canDoSocialAction(_main:CharacterPawn, _target:CharacterPawn) -> bool:
	return true

func start(_roles:Dictionary, _args:Array):
	startSocialInteraction()
	complimentLines = getXSayLines(4, ROLE_MAIN, "Compliment", ROLE_TARGET)
	if(complimentLines.is_empty()):
		complimentLines = ["You look nice today."]
	#sayText(ROLE_MAIN, "*Thinks*")
	#say(ROLE_MAIN, "WannaChat", ROLE_TARGET)
	#pushDelay(2.0)

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
		#socialInteractionStart()
		say(ROLE_TARGET, "ComplimentAccept", ROLE_MAIN)
		pushDelay(3.0)
		pushSocialEnd()
		pushStopInteraction()
	if(_action.id == "no"):
		say(ROLE_TARGET, "ComplimentDeny", ROLE_MAIN)
		pushDelay(2.0)
		#pushAddAffection(ROLE_MAIN, ROLE_TARGET, -0.1)
		pushSocialDenied()
		pushStopInteraction()
