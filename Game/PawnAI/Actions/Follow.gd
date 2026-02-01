extends AIActionBase

var target:String

func _init() -> void:
	id = "Follow"

func start(_args:Array):
	if(_args.is_empty()):
		failAction()
		return
	target = _args[0]

func processAction(_dt:float):
	if(!getTarget()):
		failAction()
		return
	if(getSubActionID() == "GoTo"):
		var theDistance:float = getDistSquaredTo(getTargetPos())
		if(theDistance <= 3.0):
			startSubAction("Wait")
	
func think():
	if(!getTarget()):
		failAction()
		return
	
	var targetPos:Vector3 = getTargetPos()
	var theDistance:float = getDistSquaredTo(targetPos)
	if(theDistance > 3.0):
		#if(getSubActionID() != "GoTo"):
		startSubAction("GoTo", [targetPos])
	else:
		if(getSubActionID() != "Wait"):
			startSubAction("Wait")
	
func getTarget() -> CharacterPawn:
	return GM.pawnRegistry.getPawn(target)
	
func getTargetPos() -> Vector3:
	var thePawn := GM.pawnRegistry.getPawn(target)
	if(!thePawn):
		return Vector3(0.0, 0.0, 0.0)
	return thePawn.global_position
