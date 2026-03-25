extends RefCounted
class_name PawnAI

var pawn:CharacterPawn

var bigUpdateTime:float = 0.0
var nextBigUpdateAt:float = 1.0

var currentMoveTarget:Vector3
var shouldRunToTarget:bool = false

var aiAction:AIActionBase
var lowestAIAction:AIActionBase

var goalHandler:AIGoalHandler = AIGoalHandler.new()

func _init() -> void:
	pass

func setPawn(_thePawn:CharacterPawn):
	pawn = _thePawn
	goalHandler.setAI(self)

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
	
	if(currentMoveTarget.distance_squared_to(_pos) < 0.1 || !pawn):
		return
	
	currentMoveTarget = _pos
	pawn.getNavAgent().target_position = currentMoveTarget

func lookTowardsRaw(_pos:Vector3):
	if(pawn.isControlledByAnyPlayer()):
		return
	if(pawn.state.isControllingLookDir()):
		return
	var theDoll := pawn.getDoll()
	if(theDoll):
		theDoll.targetLookDir = _pos - theDoll.global_position

func stopWalking():
	goTowards(getPawn().global_position)
	#pawn.getNavAgent().target_position = getPawn().global_position
	#pawn.getNavAgent().set_velocity_forced(Vector3.ZERO)

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
	
	bigUpdateTime += _dt
	if(bigUpdateTime >= nextBigUpdateAt):
		nextBigUpdateAt = 1.0
		processRare(bigUpdateTime)
		bigUpdateTime = 0.0
	
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

func processRare(_dt:float):
	if(!aiAction):
		startAction("BasicAI")
	if(pawn.isDefeated() && aiAction && aiAction.shouldTryToRecoverIfDefeated()):
		pawn.combatAI.recoverIfDefeated()
	
	if(aiAction):
		aiAction.processRareFinal()
		checkAction()
	
	checkCombatMode()
	goalHandler.processRare(_dt)
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
	aiAction.startFinal(_args)
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

func onInteractionStateChange(_interaction:InteractionBase):
	if(!lowestAIAction || !Network.isServer()):
		return
	lowestAIAction.handleInteractionStateChangeFinal(_interaction)

func onGettingHit(_attack:AttackContext):
	if(!lowestAIAction || !Network.isServer()):
		return
	lowestAIAction.onGettingHitFinal(_attack)

func checkCombatMode():
	if(!lowestAIAction):
		getPawn().exitCombatMode()
		return
	if(lowestAIAction.shouldBeInCombatMode()):
		getPawn().enterCombatMode()
	else:
		getPawn().exitCombatMode()

func isPlayer() -> bool:
	return pawn.isControlledByAnyPlayer()

func reactDelayedAction(_action:ActionSystemEntry):
	if(isPlayer()):
		return
	var theTarget := _action.getTargetSpecific(pawn)
	if(!theTarget):
		return
	
	Log.Print("DECISION!!!")
	theTarget.decideDeny()
	
	pawn.addAnnoyance(_action.user, 0.7)
	if(pawn.getAnnoyance(_action.user) >= 1.0):
		pawn.combatAI.addEnemy(_action.user)
	else:
		GM.main.interactionSystem.startInteraction("Annoyed", {
			main = pawn,
			target = _action.user,
		})

func getActionThatHandlesCombat() -> AIActionBase:
	if(!lowestAIAction):
		return null
	var theAction := lowestAIAction
	while(theAction):
		if(theAction.isHandlingCombat()):
			return theAction
		theAction = theAction.parentAction
	return null

func onCurrentAIGoalSwitch():
	#var _newGoal := goalHandler.getCurrentGoal()
	
	if(aiAction):
		aiAction.replan()
