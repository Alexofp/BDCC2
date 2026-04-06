extends AIActionBase

var target:Node
#var targetPawn:String = ""
var actionID:String = ""
var actionArgs:Array
var waitingForAction:bool = false

#func getTargetPawn() -> CharacterPawn:
#	return GM.pawnRegistry.getPawn(targetPawn)

func _init() -> void:
	id = "DoAction"

#return makePlan().add("DoAction", ["DefeatedHelpGetUp", getPawn(pawnIDToHelp), []])

func isAlreadyCompleted(_args:Array) -> bool:
	return false

func start(_args:Array):
	actionID = _args[0]
	actionArgs = _args[2] if _args.size() > 2 else []
	
	var theArg0 = _args[1]
	if(theArg0 is String):
		#targetPawn = theArg0
		target = GM.main.pawn_registry.getPawn(theArg0)
	elif(theArg0 is CharacterPawn):
		target = theArg0
		#targetPawn = theArg0.getCharID()
	elif(theArg0 is Node):
		target = theArg0
	
func isImpossible() -> bool:
	#if(!getTargetPawn()):
	#	return true
	if(!target):
		return true
	return false

func think():
	var thePawn := getPawn()
	#var theTargetPawn := getTargetPawn()
	var theTargetPawn := target
	
	if(waitingForAction):
		if(!isDoingDelayedActions()):
			completeAction() # Some way to detect if the delayed action failed
		return
	
	if(!goTo(theTargetPawn.global_position)):
		return
	if(hasSubAction() || isDoingDelayedActions()):
		return
	
	if(!thePawn.doInteractEntryDo(InteractEntryDo.create(actionID, actionArgs), theTargetPawn)):
		onInteractEntryFail()
	
	if(isDoingDelayedActions()):
		waitingForAction = true
		return
	completeAction()

func onInteractEntryFail():
	failAction()
