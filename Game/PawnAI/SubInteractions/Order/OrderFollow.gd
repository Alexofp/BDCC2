extends InteractionSocialBase

const OrderToDialogueLine:Dictionary[int, String] = {
	ObeyTask.Follow: "OrderFollow",
	ObeyTask.Stand: "OrderStayStill",
	ObeyTask.Look: "OrderLookAtMe",
}

func _init() -> void:
	id = "OrderFollow"
	socialActionName = "Follow"
	socialActionCategory = CATEGORY_ORDER
	socialFlags = SOCIALFLAG_SHOULD_END_TALKING | SOCIALFLAG_ONLY_IF_TARGET_DOMINATED
	
	registerForInteractionType = [InteractionType.Talking]

func canDoSocialAction(_c:SocialInteractionContext) -> bool:
	#if(!_c.target.submission.isObeyingPawn(_c.main)): # Replaced with social flag
	#	return false
	return true

func getSocialActions(_c:SocialInteractionContext) -> Array[InteractionAction]:
	if(!canDoSocialActionFinal(_c)):
		return []
	# Needs a function that calculates which intro should have the biggest score
	var result:Array[InteractionAction] = []
	var theObeyTask:int = _c.target.submission.obeyTask
	if(theObeyTask != ObeyTask.Follow):
		result.append(action(id, "Follow").setArgs([ObeyTask.Follow]).setCategory(socialActionCategory).setScore(1.0))
	if(theObeyTask != ObeyTask.Look):
		result.append(action(id, "Look at me").setArgs([ObeyTask.Look]).setCategory(socialActionCategory).setScore(1.0))
	if(theObeyTask != ObeyTask.Stand):
		result.append(action(id, "Stand still").setArgs([ObeyTask.Stand]).setCategory(socialActionCategory).setScore(1.0))
	return result

func start(_roles:Dictionary, _args:Array):
	refreshDominance(ROLE_TARGET, ROLE_MAIN)
	pushSay(ROLE_MAIN, OrderToDialogueLine.get(_args[0], "OrderUnknownOrder"), ROLE_TARGET)
	pushDelay(2.0)
	pushEvent("doOrder", _args)
	pushStopInteraction()
	pass

func onQueueEvent(_eventID:String, _args:Array):
	if(_eventID == "doOrder"):
		var theTarget := getPawn(ROLE_TARGET)
		theTarget.submission.obeyTask = _args[0]
		if(theTarget.submission.obeyTask == ObeyTask.Stand):
			stopLookAt(ROLE_TARGET)
		
