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
	if(getChildActionID() == "GoTo"):
		var theDistance:float = getDistSquaredTo(getTargetPos())
		if(theDistance <= 3.0):
			startChildAction("Wait")
	
func processRare():
	if(!getTarget()):
		failAction()
		return
	
	var targetPos:Vector3 = getTargetPos()
	var theDistance:float = getDistSquaredTo(targetPos)
	if(theDistance > 3.0):
		#if(getChildActionID() != "GoTo"):
		startChildAction("GoTo", [targetPos])
	else:
		if(getChildActionID() != "Wait"):
			startChildAction("Wait")
	
func getTarget() -> CharacterPawn:
	return GM.pawnRegistry.getPawn(target)
	
func getTargetPos() -> Vector3:
	var thePawn := GM.pawnRegistry.getPawn(target)
	if(!thePawn):
		return Vector3(0.0, 0.0, 0.0)
	return thePawn.global_position
