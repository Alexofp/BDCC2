extends AIActionBase

var targetPawn:String
var targetLoc:Vector3

func getTargetPawn() -> CharacterPawn:
	return GM.pawnRegistry.getPawn(targetPawn)

func _init() -> void:
	id = "LeashWalkTo"

func isAlreadyCompleted(_args:Array) -> bool:
	return false

func start(_args:Array):
	var theArg0 = _args[0]
	if(theArg0 is String):
		targetPawn = theArg0
	elif(theArg0 is CharacterPawn):
		targetPawn = theArg0.getCharID()
	targetLoc = _args[1]

func isImpossible() -> bool:
	if(!getTargetPawn()):
		return true
	return false

func plan() -> AIPlan:
	var theTargetPawn := getTargetPawn()
	if(theTargetPawn.isSittingSomewhere()):
		return (makePlan("makeGetUp")
		.add("LeashPawn", [targetPawn])
		)
	
	return (makePlan()
	.add("LeashPawn", [targetPawn])
	.add("DoActionIfCan", ["DefeatedHelpGetUp", targetPawn])
	.add("GoTo", [targetLoc], "leashedGo")
	)

func onPlanCompleted(_plan:AIPlan):
	var thePawn := getPawn()
	var theTargetPawn := getTargetPawn()
	
	if(_plan.id == "makeGetUp"):
		var theProp := theTargetPawn.getSitPropHandler()
		if(!theProp):
			return
		doInteractEntryDo(InteractEntryDo.create("SitPropLeashed", [theProp.getSlotOfPawn(theTargetPawn),"",targetPawn]), theProp)
		return
	
	if(thePawn.isLeashingPawn(theTargetPawn)):
		completeAction()

func think():
	var thePawn := getPawn()
	var theTargetPawn := getTargetPawn()
	
	if(isDoingPlanEntry("leashedGo")):
		if(!thePawn.isLeashingPawn(theTargetPawn) || theTargetPawn.isSittingSomewhere()):
			replan()
			return
