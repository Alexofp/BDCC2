extends InteractionSocialBase

func _init() -> void:
	id = "AskDay"
	socialActionName = "Ask about day"
	socialActionCategory = CATEGORY_FRIENDLY
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_FRIENDLY - 51.0

func canDoSocialAction(_c:SocialInteractionContext) -> bool:
	return true

func prepareChanceCalculator():
	setChanceCalculator(SICCAlways.new())

func start(_roles:Dictionary, _args:Array):
	#startSocialInteraction()
	pushSay(ROLE_MAIN, "AskDay_Start", ROLE_TARGET)
	
	var theTarget := getPawn(ROLE_TARGET)
	var theMemories:MemoryHolder = theTarget.getMemoryHolder()
	var theReactions := theMemories.getAskDayReactions(getPawn(ROLE_MAIN), 3)
	
	if(theReactions.is_empty()):
		pushSay(ROLE_TARGET, "AskDay_Nothing", ROLE_MAIN)
	else:
		for theReaction in theReactions:
			pushSayRaw(ROLE_TARGET, theReaction.line)
			pushDelay(1.0)
		pushSay(ROLE_TARGET, "AskDay_End", ROLE_MAIN)
	
	pushStopInteraction()
