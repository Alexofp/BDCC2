extends AIActionBase

var lineToLeanAt:AILeanLine
var linePos:Vector3

func _init() -> void:
	id = "LeanAndChill"
	groupBasicAI = true

func getScore(_ai:PawnAI) -> float:
	if(_ai.isSitting()):
		return 0.0
	return 1.0

func start(_args:Array):
	pass

func checkNearbyFail() -> bool:
	if(!lineToLeanAt):
		return false
	if(!GM.world.getNearbyActiveLeaners(linePos, 4.0).is_empty()):
		failAction()
		return true
	return false

func think():
	if(hasSubAction()):
		if(getSubActionTag() == "go"):
			checkNearbyFail()
		return
	var theLine := GI.world.getCloseLeanLine(getPos())
	if(!theLine):
		failAction()
		return
	
	lineToLeanAt = theLine
	linePos = lineToLeanAt.getRandomSpot()
	startSubAction("GoTo", [linePos], "go")

func onSubActionResult(_tag:String, _status:int, _result:Array):
	if(_tag == "go"):
		if(_status == STATUS_COMPLETED):
			if(!lineToLeanAt || !is_instance_valid(lineToLeanAt)):
				failAction()
				return
			if(checkNearbyFail()):
				return
			
			var theTransform := lineToLeanAt.global_transform#GM.main.wall_checker.getLeanTransform()
			theTransform.origin = linePos
			
			var theHandler:PackedScene = load("res://AnimScenes/Scenes/SoloSex/AgainstWallAnimHandler.tscn")
			if(!theHandler):
				return
			var newWallHandler:Node3D = theHandler.instantiate()
			GM.netNodes.add_child(newWallHandler, true)
			newWallHandler.global_transform = theTransform
			GM.netNodes.notifySpawned(newWallHandler)
			
			newWallHandler.setSitter("dom", getPawn())
			
			pushReplaceWithTimedEvent(5.0, "chill")
			return
		else:
			failAction()
			
		#startSubAction("Wait", [1.0])
		#pushTimer(1.0)

func onSubEvent(_eventID:String, _args:Array):
	if(_eventID == "chill"):
		completeAction()
