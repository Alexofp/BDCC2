extends InteractionSocialBase

func _init() -> void:
	id = "OrderFree"
	socialActionName = "You're free"
	#socialActionCategory = CATEGORY_ORDER
	socialFlags = SOCIALFLAG_SHOULD_END_TALKING | SOCIALFLAG_ONLY_IF_TARGET_DOMINATED
	
	registerForInteractionType = [InteractionType.Talking]

func canDoSocialAction(_c:SocialInteractionContext) -> bool:
	#if(!_c.target.submission.isObeyingPawn(_c.main)): # Replaced with social flag
	#	return false
	return true

func start(_roles:Dictionary, _args:Array):
	pushSay(ROLE_MAIN, "OrderYoureFree", ROLE_TARGET)
	pushDelay(2.0)
	pushEvent("stopOrdering")
	pushStopInteraction()
	pass

func onQueueEvent(_eventID:String, _args:Array):
	if(_eventID == "stopOrdering"):
		var theTarget := getPawn(ROLE_TARGET)
		theTarget.submission.stopObeing(getPawn(ROLE_MAIN))
		
