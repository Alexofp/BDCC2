extends AIActionBase

func _init() -> void:
	id = "Wander"
	groupBasicAI = true

func start(_args:Array):
	pass

func getScore(_ai:PawnAI) -> float:
	return 1.0

func plan() -> AIPlan:
	var theWanderArea := GI.world.getRandomWanderArea(getPos())
	if(!theWanderArea):
		return null

	return (makePlan()
	.add("GoTo", [theWanderArea.getRandomSpot()])
	)

func onPlanCompleted(_plan:AIPlan):
	pushTimer(1.0)
	pushEvent("doEnd")

func onSubEvent(_eventID:String, _args:Array):
	if(_eventID == "doEnd"):
		completeAction()
