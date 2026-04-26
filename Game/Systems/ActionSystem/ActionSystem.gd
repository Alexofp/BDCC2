extends Node
class_name ActionSystem

var actions:Array[ActionSystemEntry]
var userToActions:Dictionary[CharacterPawn, Array]
var targetToActions:Dictionary[Node, Array]
var extraTargetToActions:Dictionary[Node, Array]
var actionByUniqueID:Dictionary[int, ActionSystemEntry]

var lastUniqueID:int = 0

func _ready() -> void:
	GI.actionSystem = self

func internal_deleteListofActionsSafe(theActions:Array[ActionSystemEntry]):
	var actAm:int = theActions.size()
	for _i in actAm:
		var _indx:int = actAm - 1 - _i
		deleteAction(theActions[_indx])

func deleteAllActionsRelatedTo(_node:Node):
	if(_node is CharacterPawn):
		var thePawn:CharacterPawn = _node
		if(userToActions.has(_node)):
			internal_deleteListofActionsSafe(userToActions[thePawn])
			userToActions.erase(_node)
	if(targetToActions.has(_node)):
		internal_deleteListofActionsSafe(targetToActions[_node])
		targetToActions.erase(_node)
	if(extraTargetToActions.has(_node)):
		internal_deleteListofActionsSafe(extraTargetToActions[_node])
		extraTargetToActions.erase(_node)

func deleteAction(_actionEntry:ActionSystemEntry) -> bool:
	if(!actions.has(_actionEntry)):
		return false
	
	var theUser := _actionEntry.user
	var theTarget := _actionEntry.target.node if _actionEntry.target else null
	
	if(userToActions.has(theUser)):
		userToActions[theUser].erase(_actionEntry)
		if(userToActions[theUser].is_empty()):
			userToActions.erase(theUser)
	
	if(targetToActions.has(theTarget)):
		targetToActions[theTarget].erase(_actionEntry)
		if(targetToActions[theTarget].is_empty()):
			targetToActions.erase(theTarget)
	
	for extra in _actionEntry.extraTargets:
		var theExtraTarget:Node = extra.node
		if(!extraTargetToActions.has(theExtraTarget)):
			continue
		extraTargetToActions[theExtraTarget].erase(_actionEntry)
		if(extraTargetToActions[theExtraTarget].is_empty()):
			extraTargetToActions.erase(theExtraTarget)
	
	if(actionByUniqueID.has(_actionEntry.uniqueID)):
		actionByUniqueID.erase(_actionEntry.uniqueID)
	
	actions.erase(_actionEntry)
	return true

func cancelAction(_actionEntry:ActionSystemEntry) -> bool:
	#Log.Print("CANCELLED AN ACTION! "+str(_actionEntry))
	return deleteAction(_actionEntry)

func allowAction(theEntry:ActionSystemEntry, _target:Node) -> bool:
	var theTarget := theEntry.getTargetSpecific(_target)
	if(!theTarget):
		return false
	
	if(theTarget.timerType != ActionSystemEntry.TIMER_MUST_CONSENT):
		return false
	theTarget.markDidConsent()
	
	if(!theEntry.didEveryoneConsent()):
		return false
	return doAction(theEntry)

func denyAction(theEntry:ActionSystemEntry, _target:Node) -> bool:
	var theTarget := theEntry.getTargetSpecific(_target)
	if(!theTarget):
		return false
	
	if(!theTarget.needsConsent(theEntry)):
		return false
	return cancelAction(theEntry)

func resistAction(theEntry:ActionSystemEntry, _target:Node) -> bool:
	return denyAction(theEntry, _target)

func doAction(_actionEntry:ActionSystemEntry) -> bool:
	var theUser := _actionEntry.user
	var theTarget := _actionEntry.target.node
	var theAction := _actionEntry.action
	var theArgs := _actionEntry.args
	var theExtraTargets := _actionEntry.extraTargets
	var theExtraTargetsNodes:Array[Node]
	
	if(!deleteAction(_actionEntry)):
		return false
		
	for extra in theExtraTargets:
		if(!extra.node || !is_instance_valid(extra.node)):
			Log.Printerr("SOMETHING WENT WRONG IN THE ACTION SYSTEM. ONE OF THE EXTRA TARGETS DOESN'T EXIST ANYMORE. ACTION="+str(theAction)+", USER="+str(theUser))
			return false
		theExtraTargetsNodes.append(extra.node)
		
	if(!theAction || !theUser):
		Log.Printerr("SOMETHING WENT WRONG IN THE ACTION SYSTEM. ACTION="+str(theAction)+", USER="+str(theUser))
		return false
	
	var theContext := theUser.pawnActionContext
	theContext.target = theTarget
	theContext.args = theArgs
	theContext.extraTargets = theExtraTargetsNodes

	#Log.Print("DOING THE DELAYED ACTION!")
	var theRes := theAction.doDelayedAction(theContext)
	
	theContext.clearContext()
	return theRes

func startAction(_actionEntry:ActionSystemEntry) -> bool:
	#_actionEntry.timePassed = 0.0
	
	#if(_actionEntry.timeFull <= 0.0):
	#	return false
	
	var theUser := _actionEntry.user
	var theTarget := _actionEntry.target.node if _actionEntry.target else null
	
	if(!theUser):
		return false
	if(!theTarget):
		return false
	if(!_actionEntry.action):
		return false
	for extraTarget in _actionEntry.extraTargets:
		if(!extraTarget.node):
			return false
	
	theUser.tree_exiting.connect(_actionEntry.deleteMe)
	if(theUser != theTarget): # To avoid connecting the signal twice if target = user
		theTarget.tree_exiting.connect(_actionEntry.deleteMe)
		
	for extraTarget in _actionEntry.extraTargets:
		extraTarget.node.tree_exiting.connect(_actionEntry.deleteMe)
	
	lastUniqueID += 1
	_actionEntry.uniqueID = lastUniqueID
	
	actions.append(_actionEntry)
	actionByUniqueID[_actionEntry.uniqueID] = _actionEntry
	
	if(!userToActions.has(theUser)):
		var newAr:Array[ActionSystemEntry] = [_actionEntry]
		userToActions[theUser] = newAr
	else:
		userToActions[theUser].append(_actionEntry)
	if(!targetToActions.has(theTarget)):
		var newAr:Array[ActionSystemEntry] = [_actionEntry]
		targetToActions[theTarget] = newAr
	else:
		targetToActions[theTarget].append(_actionEntry)
	
	for extraTargetEntry in _actionEntry.extraTargets:
		var extraTarget:Node = extraTargetEntry.node
		if(!extraTargetToActions.has(extraTarget)):
			var newAr:Array[ActionSystemEntry] = [_actionEntry]
			extraTargetToActions[extraTarget] = newAr
		else:
			extraTargetToActions[extraTarget].append(_actionEntry)
	
	#if(_actionEntry.target.node is CharacterPawn):
		#_actionEntry.target.node.ai.reactDelayedAction(_actionEntry)
	#for extraTarget in _actionEntry.extraTargets:
		#if(extraTarget.node is CharacterPawn):
			#extraTarget.node.ai.reactDelayedAction(_actionEntry)
	
	return true
	
func processActions(_delta:float):
	var actionsAm:int = actions.size()
	
	#TODO: CHECK EXTRAS
	for _i in actionsAm: # Going backwards over actions so you can delete them while iterating over them
		var _indx:int = actionsAm - 1 - _i
		var theAction := actions[_indx]
		var theUser := theAction.user
		var theTarget := theAction.target.node
		
		# Better way to check if the pawn was deleted?
		if(!theUser || !is_instance_valid(theUser)):
			# Cancel instead?
			deleteAction(theAction)
			continue
		
		if(theAction.userMove != ActionSystemEntry.USER_CANMOVE):
			var speedUser := getSpeedOf(theUser)
			if(theAction.userMove == ActionSystemEntry.USER_NO_MOVEMENT && speedUser.length_squared() >= 1.0):
				cancelAction(theAction)
				continue
			if(theAction.userMove == ActionSystemEntry.USER_NO_RUNNING && speedUser.length_squared() >= 16.0):
				cancelAction(theAction)
				continue
		
		if(theAction.target.shouldCancelAction(theAction)):
			cancelAction(theAction)
			continue
		
		var didCancel:bool = false
		for extraTarget in theAction.extraTargets:
			if(extraTarget.shouldCancelAction(theAction)):
				cancelAction(theAction)
				didCancel = true
				break
		if(didCancel):
			continue
		
		var thePawnAction := theAction.action
		var theContext := theAction.user.pawnActionContext
		theContext.target = theTarget
		theContext.args = theAction.args
		if(!thePawnAction.canDoDelayedAction(theContext)):
			theContext.clearContext()
			cancelAction(theAction)
			continue
		
		var timePassMult:float = 1.0
		if(theAction.needsConsent() && theAction.didEveryoneConsent()):
			#theContext.clearContext()
			#doAction(theAction)
			#continue
			timePassMult *= theAction.consentTimeMult
		
		theAction.timePassed += _delta * timePassMult
		if(theAction.timePassed >= theAction.timeFull):
			theContext.clearContext()
			
			var shouldDoTheAction:bool = true
			if(theAction.target.timerType == ActionSystemEntry.TIMER_MUST_CONSENT):
				shouldDoTheAction = false
			for extraTarget in theAction.extraTargets:
				if(extraTarget.timerType == ActionSystemEntry.TIMER_MUST_CONSENT):
					shouldDoTheAction = false
					break
			
			if(shouldDoTheAction):
				doAction(theAction)
			else:
				cancelAction(theAction)
			continue
		else:
			theAction.doAIDecisions()
		theContext.clearContext()

func cancelAllActionsOfUser(_user:CharacterPawn):
	if(!userToActions.has(_user)):
		return
	var theActionsToCancel := userToActions[_user]
	var theAm:int = theActionsToCancel.size()
	
	for _i in theAm:
		var _indx:int = theAm - _i - 1
		cancelAction(theActionsToCancel[_indx])

func cancelAllActionsOfTarget(_target:Node):
	if(!targetToActions.has(_target)):
		return
	var theActionsToCancel := targetToActions[_target]
	var theAm:int = theActionsToCancel.size()
	
	for _i in theAm:
		var _indx:int = theAm - _i - 1
		cancelAction(theActionsToCancel[_indx])

func cancelAllActionsOfExtraTarget(_target:Node):
	if(!extraTargetToActions.has(_target)):
		return
	var theActionsToCancel := extraTargetToActions[_target]
	var theAm:int = theActionsToCancel.size()
	
	for _i in theAm:
		var _indx:int = theAm - _i - 1
		cancelAction(theActionsToCancel[_indx])

func cancelAllActionsOfTargetAll(_target:Node):
	cancelAllActionsOfTarget(_target)
	cancelAllActionsOfExtraTarget(_target)

func getAllActionsOfUser(_user:CharacterPawn) -> Array[ActionSystemEntry]:
	if(!userToActions.has(_user)):
		return []
	return userToActions[_user]

func isUserDoingSomething(_user:CharacterPawn) -> bool:
	if(!userToActions.has(_user)):
		return false
	return !userToActions[_user].is_empty()

func getAllActionsOfTarget(_target:Node) -> Array[ActionSystemEntry]:
	if(!targetToActions.has(_target)):
		return []
	return targetToActions[_target]

func getAllActionsOfExtraTarget(_target:Node) -> Array[ActionSystemEntry]:
	if(!extraTargetToActions.has(_target)):
		return []
	return extraTargetToActions[_target]

func getAllActionsOfTargetAll(_target:Node) -> Array[ActionSystemEntry]:
	var _l1 := getAllActionsOfTarget(_target)
	var _l2 := getAllActionsOfExtraTarget(_target)
	if(_l1.is_empty()):
		return _l2
	if(_l2.is_empty()):
		return _l1
	return _l1 + _l2

static func getSpeedOf(_node:Node) -> Vector3:
	if(!_node):
		return Vector3(0.0, 0.0, 0.0)
	if(_node is CharacterPawn):
		return _node.getActionSystemSpeed()
	elif(_node is RigidBody3D):
		return _node.linear_velocity
	elif(_node is CharacterBody3D):
		return _node.velocity
	return Vector3(0.0, 0.0, 0.0)

func findActionEntryByUniqueID(_uid:int) -> ActionSystemEntry:
	if(!actionByUniqueID.has(_uid)):
		return null
	return actionByUniqueID[_uid]

func _process(_delta: float) -> void:
	processActions(_delta)

func onPawnHit(_pawn:CharacterPawn, _attackContext:AttackContext):
	var allTheActions := getAllActionsOfUser(_pawn)
	
	var actAm:int = allTheActions.size()
	for _i in actAm:
		var _indx:int = actAm - _i - 1
		var theAction := allTheActions[_indx]
		
		if(theAction.cancelIfHit):
			cancelAction(theAction)
		
