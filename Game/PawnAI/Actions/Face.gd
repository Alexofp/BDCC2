extends AIActionBase

var target:String
#var followDistance:float = 5.0

func _init() -> void:
	id = "Face" # Look at basically

func start(_args:Array):
	if(_args.is_empty()):
		impossibleAction()
		return
	var theTarget = _args[0]
	if(theTarget is String):
		target = _args[0]
	elif(theTarget is CharacterPawn):
		target = theTarget.getCharID()
	else:
		impossibleAction()
		return

func isImpossible() -> bool:
	if(!getTargetPawn()):
		return true
	return false

func processAction(_dt:float):
	#ai.lookTowardsRaw(getTargetPos())
	pass

func think():
	ai.lookTowardsRaw(getTargetPos())
	
	var theDoll := getPawn().getDoll()
	var theTargetDoll := getTargetPawn().getDoll()
	if(theDoll && theTargetDoll):
		GM.dollHolder.askLookAtDoll(theDoll, theTargetDoll, 5.0)
		#theDoll.lookAtDoll(theTargetDoll)
	
func getTargetPawn() -> CharacterPawn:
	return GM.pawnRegistry.getPawn(target)

func getTargetPos() -> Vector3:
	var thePawn := GM.pawnRegistry.getPawn(target)
	if(!thePawn):
		return Vector3(0.0, 0.0, 0.0)
	return thePawn.global_position
