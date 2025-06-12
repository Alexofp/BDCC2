extends RefCounted
class_name PawnAI

var pawn:CharacterPawn

var bigUpdateTime:float = 1.0

var currentMoveTarget:Vector3
var shouldRunToTarget:bool = false

func setPawn(_thePawn:CharacterPawn):
	pawn = _thePawn

func getPawn() -> CharacterPawn:
	return pawn

func getDoll() -> DollController:
	if(!pawn):
		return null
	return pawn.getDoll()

func hasDoll() -> bool:
	return getDoll() != null

func goTowardsRaw(_pos:Vector3, _dt:float, shouldRun:bool=false):
	pawn.goTowardsRaw(_pos, _dt, shouldRun)

func processAI(_dt:float):
	bigUpdateTime -= _dt
	if(bigUpdateTime <= 0.0):
		bigUpdateTime = 1.0
		processRare()
	
	var theNavAgent:NavigationAgent3D = pawn.getNavAgent()
	if theNavAgent.is_navigation_finished():
		return
	#var current_agent_position: Vector3 = pawn.global_position
	var next_path_position: Vector3 = theNavAgent.get_next_path_position()

	goTowardsRaw(next_path_position, _dt, shouldRunToTarget)
	#velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	#move_and_slide()



func processRare():
	var theTarget:DollController = GM.pcDoll
	if(!theTarget):
		return
	
	var thePawn:CharacterPawn = getPawn()
	if(!thePawn):
		return
	var targetPos:Vector3 = theTarget.global_position
	thePawn.getNavAgent().target_position = targetPos
	currentMoveTarget = targetPos
	
	shouldRunToTarget = (pawn.global_position.distance_squared_to(currentMoveTarget) > 20.0)
