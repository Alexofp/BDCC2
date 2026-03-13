extends AIActionBase

var targetPawn:String = ""

func getTargetPawn() -> CharacterPawn:
	return GM.pawnRegistry.getPawn(targetPawn)

func _init() -> void:
	id = "StopLeashing"

func isAlreadyCompleted(_args:Array) -> bool:
	var theTargetPawn:CharacterPawn
	var theArg0 = _args[0] if _args.size() > 0 else ""
	if(theArg0 is String):
		theTargetPawn = GM.pawnRegistry.getPawn(theArg0)
	elif(theArg0 is CharacterPawn):
		theTargetPawn = theArg0
	
	if(!getPawn().isLeashingPawn(theTargetPawn)):
		return true
	return false

func start(_args:Array):
	var theArg0 = _args[0] if _args.size() > 0 else ""
	if(theArg0 is String):
		targetPawn = theArg0
	elif(theArg0 is CharacterPawn):
		targetPawn = theArg0.getCharID()

func isImpossible() -> bool:
	if(!getTargetPawn()):
		return true
	return false

func think():
	var thePawn := getPawn()
	var theTargetPawn := getTargetPawn()

	if(!thePawn.isLeashingPawn(theTargetPawn)):
		completeAction()
		return
	
	if(!goTo(theTargetPawn.global_position)):
		return
	if(hasSubAction() || isDoingDelayedActions()):
		return
	
	thePawn.doInteractEntryDo(InteractEntryDo.create("Leash"), theTargetPawn)
	
