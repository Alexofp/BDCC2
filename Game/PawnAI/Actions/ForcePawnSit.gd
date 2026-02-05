extends AIActionBase

var targetPawn:String = ""
var targetProp:PropHandlerBase

func getTargetPawn() -> CharacterPawn:
	return GM.pawnRegistry.getPawn(targetPawn)

func _init() -> void:
	id = "ForcePawnSit"

func start(_args:Array):
	var theArg0 = _args[0] if _args.size() > 0 else ""
	if(theArg0 is String):
		targetPawn = theArg0
	elif(theArg0 is CharacterPawn):
		targetPawn = theArg0.getCharID()
	
	targetProp = _args[1] if _args.size() > 1 else null
	
	if(!getTargetPawn() || !targetProp):
		impossibleAction()
		return

func think():
	var thePawn := getPawn()
	var theTargetPawn := getTargetPawn()
	if(!theTargetPawn):
		impossibleAction()
		return
	if(theTargetPawn.isSittingOn(targetProp)):
		if(thePawn.isLeashingPawn(theTargetPawn)):
			thePawn.doInteractEntryDo(InteractEntryDo.create("Leash"), theTargetPawn)
			return
		completeAction()
		return
		
	if(!makeSureLeashed(theTargetPawn)):
		return
		
	var theProp := theTargetPawn.getSitPropHandler()
	if(theProp):
		if(!goTo(theProp.global_position)):
			return
		thePawn.doInteractEntryDo(InteractEntryDo.create("SitPropLeashed", [theProp.getSlotOfPawn(theTargetPawn),"",targetPawn]), theProp)
		return
		
	if(!goTo(targetProp.global_position)):
		return
	if(thePawn.isDoingAnyDelayedActions()):
		return
	var theSlots := targetProp.getAllFreeSitterSlots()
	if(theSlots.is_empty()):
		failAction()
		return
	
	#Do delayed action ai action?
	thePawn.doInteractEntryDo(InteractEntryDo.create("SitPropLeashed", [RNG.pick(theSlots),"",targetPawn]), targetProp)
