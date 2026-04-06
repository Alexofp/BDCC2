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

func isImpossible() -> bool:
	if(!getTargetPawn()):
		return true
	if(!targetProp):
		return true
	return false

func plan() -> AIPlan:
	#var thePawn := getPawn()
	var theTargetPawn := getTargetPawn()

	if(theTargetPawn.isSittingOn(targetProp)):
		return makePlan("almostDone").add("StopLeashing", [theTargetPawn])
	
	#if(theTargetPawn.isDefeated()):
	#	return makePlan("helpGetUp").add("DoAction", ["DefeatedHelpGetUp", theTargetPawn])
	return makePlan("reachStocks").add("LeashWalkTo", [theTargetPawn, targetProp.global_position])

func onPlanCompleted(_plan:AIPlan):
	if(_plan.id == "almostDone"):
		completeAction()
	if(_plan.id == "reachStocks"):
		var thePawn := getPawn()
		var theTargetPawn := getTargetPawn()
		if(!thePawn.isLeashingPawn(theTargetPawn)):
			return
		var theSlots := targetProp.getAllFreeSitterSlots()
		if(theSlots.is_empty()):
			failAction()
			return
		doInteractEntryDo(InteractEntryDo.create("SitPropLeashed", [RNG.pick(theSlots),"",targetPawn]), targetProp)
