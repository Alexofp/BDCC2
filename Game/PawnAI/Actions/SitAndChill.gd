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

func plan() -> AIPlan:
	var theProp := GI.world.getNearestFreeSitSpot(getPos())
	if(!theProp):
		failAction()
		return null
		
	propToSitAt = theProp
	return (makePlan()
	.add("GoTo", [theProp.global_position])
	)

func onPlanCompleted(_plan:AIPlan):
	doSitStuff()

func doSitStuff():
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

func onSubEvent(_eventID:String, _args:Array):
	if(_eventID == "chill"):
		completeAction()
