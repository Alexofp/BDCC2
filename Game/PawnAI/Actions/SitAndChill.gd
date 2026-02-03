extends AIActionBase

var propToSitAt:PropHandlerBase

func _init() -> void:
	id = "SitAndChill"
	groupBasicAI = true

func getScore(_ai:PawnAI) -> float:
	if(_ai.isSitting()):
		return 0.0
	return 1.0

func start(_args:Array):
	pass

func think():
	if(hasSubAction()):
		return
	var theProp := GI.world.getNearestFreeSitSpot(getPos())
	if(!theProp):
		failAction()
		return
	
	propToSitAt = theProp
	startSubAction("GoTo", [theProp.global_position], "go")

func onSubActionResult(_tag:String, _status:int, _result:Array):
	if(_tag == "go"):
		if(_status == STATUS_COMPLETED):
			if(!propToSitAt || !is_instance_valid(propToSitAt)):
				failAction()
				return
			var allFreeSpots := propToSitAt.getAllFreeSitterSlots()
			if(allFreeSpots.is_empty()):
				failAction()
				return
			
			var _doAct := getPawn().doInteractEntryDo(InteractEntryDo.create(
				"SitProp", [RNG.pick(allFreeSpots)],
			), propToSitAt)
			
			pushReplaceWithTimedEvent(5.0, "chill")
			return _doAct
		else:
			failAction()
			
		#startSubAction("Wait", [1.0])
		#pushTimer(1.0)

func onSubEvent(_eventID:String, _args:Array):
	if(_eventID == "chill"):
		completeAction()
