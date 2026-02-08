extends RefCounted
class_name PawnAI

var pawn:CharacterPawn

var bigUpdateTime:float = 1.0

var currentMoveTarget:Vector3
var shouldRunToTarget:bool = false

var aiAction:AIActionBase
var lowestAIAction:AIActionBase

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
	if(pawn.isControlledByAnyPlayer()):
		return
	pawn.goTowardsRaw(_pos, _dt, shouldRun)

func goTowards(_pos:Vector3, shouldRun:bool=false):
	shouldRunToTarget = shouldRun
	
	if(currentMoveTarget == _pos || !pawn):
		return
	
	currentMoveTarget = _pos
	pawn.getNavAgent().target_position = currentMoveTarget

func stopWalking():
	goTowards(getPawn().global_position)

func doJump():
	if(!pawn):
		return
	var theDoll := pawn.getDoll()
	if(!theDoll):
		return
	theDoll.doJump()

func processAI(_dt:float):
	if(!pawn):
		return
	if(pawn.isControlledByAnyPlayer()):
		stopAction()
		return
	
	#var isPC:bool = isControlledByUs()
	
	#if(!isPC):
	if(pawn.isDollSpawned()):
		pawn.getDoll().reset_input()
	if(aiAction):
		aiAction.processActionFinal(_dt)
		checkAction()
	#else:
	#	pass
	
	bigUpdateTime -= _dt
	if(bigUpdateTime <= 0.0):
		bigUpdateTime = 1.0
		processRare()
	
	#if(!isPC):
	var theNavAgent:NavigationAgent3D = pawn.getNavAgent()

	#var current_agent_position: Vector3 = pawn.global_position
	var next_path_position: Vector3 = pawn.getNavAgentNextPathPosAvoidance()#theNavAgent.get_next_path_position()
	if theNavAgent.is_navigation_finished():
		return

	goTowardsRaw(next_path_position, _dt, shouldRunToTarget)
	#velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	#move_and_slide()

func teleportToNextPathPosition() -> bool:
	var theNavAgent:NavigationAgent3D = pawn.getNavAgent()
	if theNavAgent.is_navigation_finished():
		return false
	var next_path_position: Vector3 = theNavAgent.get_next_path_position()
	pawn.teleport(next_path_position)
	return true

func processRare():
	if(!aiAction):
		startAction("BasicAI")
	#if(!pawn.hasInteraction()):
	#	GM.IS.startInteraction("SoloInteraction", {main=pawn})
	
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
	lowestAIAction = aiAction
	aiAction.setAI(self)
	aiAction.start(_args)
	checkAction()

func checkAction():
	if(!aiAction):
		return
	if(!aiAction.hasEnded()):
		return
	stopAction()

func stopAction():
	if(!aiAction):
		return
	var theAction := aiAction
	aiAction = null
	lowestAIAction = null
	stopWalking()
	
	theAction.stopSubAction()
	theAction.onEnd()

func isDoingAction() -> bool:
	return aiAction != null

func isControlledByUs():
	return pawn.isControlledByUs()

func getActionID() -> String:
	if(!aiAction):
		return ""
	return aiAction.id

func isLeashed() -> bool:
	return !GM.leashSystem.getAllLeashesOfTargetNode(pawn).is_empty()

func getDebugText() -> String:
	var resultTexts:Array[String]
	
	var theAction := aiAction
	var preText:String = ""
	while(theAction):
		resultTexts.append(preText+theAction.id+": "+theAction.getDebugText())
		preText += "-"
		theAction = theAction.subAction
	
	return ""+Util.join(resultTexts, "\n")

func isSitting() -> bool:
	return !!GM.sitManager.getSeatOfPawn(getPawn())

func isDoingDelayedActions() -> bool:
	return !GM.actionSystem.getAllActionsOfUser(pawn).is_empty()

func onInteractionChange(_interaction:InteractionBase):
	if(!lowestAIAction || !Network.isServer()):
		return
	lowestAIAction.handleInteractionChangeFinal(_interaction)
