extends InteractionSocialBase

func _init() -> void:
	id = "AskDay"
	socialActionName = "Ask about day"
	socialActionCategory = CATEGORY_FRIENDLY
	
	registerForInteractionType = [InteractionType.Talking]

func canDoSocialAction(_main:CharacterPawn, _target:CharacterPawn) -> bool:
	return true

func start(_roles:Dictionary, _args:Array):
	#startSocialInteraction()
	say(ROLE_MAIN, "AskDay_Start", ROLE_TARGET)
	pushDelay(2.0)
	
	var theTarget := getPawn(ROLE_TARGET)
	var theMemories:MemoryHolder = theTarget.getMemoryHolder()
	var theReactions := theMemories.getAskDayReactions(getPawn(ROLE_MAIN), 3)
	
	if(theReactions.is_empty()):
		pushSay(ROLE_TARGET, "AskDay_Nothing", ROLE_MAIN)
	else:
		for theReaction in theReactions:
			pushSayRaw(ROLE_TARGET, theReaction.line)
			pushDelay(3.0)
		pushSay(ROLE_TARGET, "AskDay_End", ROLE_MAIN)
	
	pushDelay(2.0)
	pushStopInteraction()

#func _actions(_role:int):
	#if(_role == ROLE_TARGET):
		#var agreeScore := scoreSocialAgree()
		#
		#addAction(action("yes", "Yes", agreeScore))
		#addAction(action("no", "No", 1.0 - agreeScore))

#func _do(_role:int, _action:InteractionAction):
	#if(_action.id == "yes"):
		#socialInteractionStart()
		#say(ROLE_TARGET, "Sure", ROLE_MAIN)
		#pushDelay(3.0)
		#pushSay(ROLE_MAIN, "Talk", ROLE_TARGET)
		#pushDelay(4.0)
		#pushSay(ROLE_TARGET, "Talk", ROLE_MAIN)
		#pushDelay(4.0)
		##pushAddAffection(ROLE_MAIN, ROLE_TARGET, 0.1)
		#pushSocialEnd()
		#pushStopInteraction()
	#if(_action.id == "no"):
		#say(ROLE_TARGET, "No", ROLE_MAIN)
		#pushDelay(2.0)
		##pushAddAffection(ROLE_MAIN, ROLE_TARGET, -0.1)
		#pushSocialDenied()
		#pushStopInteraction()
