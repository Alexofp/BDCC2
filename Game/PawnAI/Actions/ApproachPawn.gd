extends AIActionBase

var targetPawn:String = ""

func getTargetPawn() -> CharacterPawn:
	return GM.pawnRegistry.getPawn(targetPawn)

func _init() -> void:
	id = "ApproachPawn"

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
	goTo(getTargetPawn().global_position)

func onSubActionResult(_tag:String, _status:int, _result:Array):
	if(_status == STATUS_COMPLETED):
		completeAction()
	if(_status == STATUS_FAILED):
		failAction()
	if(_status == STATUS_IMPOSSIBLE):
		impossibleAction()
