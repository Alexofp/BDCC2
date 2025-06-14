extends RefCounted
class_name PawnAI

var pawn:CharacterPawn

var bigUpdateTime:float = 1.0

var currentMoveTarget:Vector3
var shouldRunToTarget:bool = false

var aiAction:AIActionBase

func setPawn(_thePawn:CharacterPawn):
	pawn = _thePawn

func getPawn() -> CharacterPawn:
	return pawn

func getDoll() -> DollController:
	if(!pawn):
		return null
	return pawn.getDoll()
	
func getNavAgent() -> NavigationAgent3D:
	if(!pawn):
		return null
	return pawn.getNavAgent()

func hasDoll() -> bool:
	return getDoll() != null

func goTowardsRaw(_pos:Vector3, _dt:float, shouldRun:bool=false):
	pawn.goTowardsRaw(_pos, _dt, shouldRun)

func goTowards(_pos:Vector3, shouldRun:bool=false):
	shouldRunToTarget = shouldRun
	
	if(currentMoveTarget == _pos || !pawn):
		return
	
	currentMoveTarget = _pos
	pawn.getNavAgent().target_position = currentMoveTarget

func stopWalking():
	goTowards(getPawn().global_position)

func processAI(_dt:float):
	if(aiAction):
		aiAction.processActionFinal(_dt)
		checkAction()
	
	bigUpdateTime -= _dt
	if(bigUpdateTime <= 0.0):
		bigUpdateTime = 1.0
		processRare()
	
	var theNavAgent:NavigationAgent3D = pawn.getNavAgent()

	#var current_agent_position: Vector3 = pawn.global_position
	var next_path_position: Vector3 = theNavAgent.get_next_path_position()
	if theNavAgent.is_navigation_finished():
		return

	goTowardsRaw(next_path_position, _dt, shouldRunToTarget)
	#velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	#move_and_slide()



func processRare():
	if(!pawn.hasInteraction()):
		GM.IS.startInteraction("SoloInteraction", {main=pawn})
	
	if(aiAction):
		aiAction.processRareFinal()
		checkAction()
	
	#var theTarget:DollController = GM.pcDoll
	#if(!theTarget):
		#return
	#
	#if(!aiAction):
		#startAction("GoTo", [theTarget.global_position])
		
	#var targetPos:Vector3 = theTarget.global_position
	#goTowards(targetPos, (pawn.global_position.distance_squared_to(currentMoveTarget) > 20.0))
	
#func gatherAllPossibleActions


func startAction(_id:String, _args:Array = []):
	var theAction:AIActionBase = GlobalRegistry.createAIAction(_id)
	if(!theAction):
		assert(false, "No ai action found: "+str(_id))
		return
	aiAction = theAction
	aiAction.setAI(self)
	aiAction.start(_args)
	checkAction()

func checkAction():
	if(!aiAction):
		return
	if(!aiAction.hasEnded()):
		return
	aiAction = null

func isDoingAction() -> bool:
	return aiAction != null
