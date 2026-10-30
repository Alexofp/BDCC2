extends AIActionBase

func _init() -> void:
	id = "Despawn"
	groupBasicAI = true

func start(_args:Array):
	pass

func getScore(_ai:PawnAI) -> float:
	return 1.0

func plan() -> AIPlan:
	var thePoint:InmateSpawnPoint = GI.world.getClosestInmateDespawnPoint(getPos())

	return (makePlan()
	.add("GoTo", [thePoint.global_position])
	)

func onPlanCompleted(_plan:AIPlan):
	pushTimer(1.0)
	pushEvent("doEnd")

func onSubEvent(_eventID:String, _args:Array):
	if(_eventID == "doEnd"):
		completeAction()
		GM.pawnRegistry.doPutPawnAway(getPawn())
