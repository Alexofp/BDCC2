extends AIActionBase

var target:String
var followDistance:float = 5.0

func _init() -> void:
	id = "Follow"

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
	if(_args.size() > 1):
		followDistance = _args[1]

func processAction(_dt:float):
	if(!getTarget()):
		failAction()
		return
	if(getSubActionID() == "GoTo"):
		var theDistance:float = getDistSquaredTo(getTargetPos())
		if(theDistance <= followDistance):
			stopSubAction()
			#stopWalking()
			#startSubAction("Wait")
	
func think():
	if(!getTarget()):
		failAction()
		return
	
	var targetPos:Vector3 = getTargetPos()
	var theDistance:float = getDistSquaredTo(targetPos)
	if(theDistance > followDistance):
		#if(getSubActionID() != "GoTo"):
		#startSubActionUnlessSameTag("GoTo", [targetPos])
		goTo(targetPos, true, "", 3.0)
	else:
		stopSubAction()
		#if(getSubActionID() != "Wait"):
		#	startSubAction("Wait")
	
func getTarget() -> CharacterPawn:
	return GM.pawnRegistry.getPawn(target)
	
func getTargetPos() -> Vector3:
	var thePawn := GM.pawnRegistry.getPawn(target)
	if(!thePawn):
		return Vector3(0.0, 0.0, 0.0)
	return thePawn.global_position
