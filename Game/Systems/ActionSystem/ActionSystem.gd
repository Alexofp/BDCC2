extends Node
class_name ActionSystem

var actions:Array[ActionSystemEntry]
var userToActions:Dictionary[CharacterPawn, Array]
var targetToActions:Dictionary[Node, Array]
var actionByUniqueID:Dictionary[int, ActionSystemEntry]

var lastUniqueID:int = 0

func _ready() -> void:
	GI.actionSystem = self

func deleteAction(_actionEntry:ActionSystemEntry) -> bool:
	if(!actions.has(_actionEntry)):
		return false
	
	var theUser := _actionEntry.user
	var theTarget := _actionEntry.target
	
	if(userToActions.has(theUser)):
		userToActions[theUser].erase(_actionEntry)
		if(userToActions[theUser].is_empty()):
			userToActions.erase(theUser)
	
	if(targetToActions.has(theTarget)):
		targetToActions[theTarget].erase(_actionEntry)
		if(targetToActions[theTarget].is_empty()):
			targetToActions.erase(theTarget)
	
	if(actionByUniqueID.has(_actionEntry.uniqueID)):
		actionByUniqueID.erase(_actionEntry.uniqueID)
	
	actions.erase(_actionEntry)
	return true

func cancelAction(_actionEntry:ActionSystemEntry) -> bool:
	Log.Print("CANCELLED AN ACTION! "+str(_actionEntry))
	return deleteAction(_actionEntry)

func doAction(_actionEntry:ActionSystemEntry) -> bool:
	var theUser := _actionEntry.user
	var theTarget := _actionEntry.target
	var theAction := _actionEntry.action
	var theArgs := _actionEntry.args
	
	if(!deleteAction(_actionEntry)):
		return false
	if(!theAction || !theUser):
		Log.Printerr("SOMETHING WENT WRONG IN THE ACTION SYSTEM. ACTION="+str(theAction)+", USER="+str(theUser))
		return false
	
	var theContext := theUser.pawnActionContext
	theContext.target = theTarget
	theContext.args = theArgs
	
	Log.Print("DOING THE DELAYED ACTION!")
	var theRes := theAction.doDelayedAction(theContext)
	
	theContext.clearContext()
	return theRes

func startAction(_actionEntry:ActionSystemEntry) -> bool:
	#_actionEntry.timePassed = 0.0
	
	#if(_actionEntry.timeFull <= 0.0):
	#	return false
	
	var theUser := _actionEntry.user
	var theTarget := _actionEntry.target
	
	if(!theUser):
		return false
	if(!theTarget):
		return false
	if(!_actionEntry.action):
		return false
	
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
	
	return true
	
func processActions(_delta:float):
	var actionsAm:int = actions.size()
	
	for _i in actionsAm: # Going backwards over actions so you can delete them while iterating over them
		var _indx:int = actionsAm - 1 - _i
		var theAction := actions[_indx]
		var theUser := theAction.user
		var theTarget := theAction.target
		
		# Better way to check if the pawn was deleted?
		if(!theUser || !is_instance_valid(theUser) || !theTarget || !is_instance_valid(theTarget)):
			# Cancel instead?
			deleteAction(theAction)
			continue
		
		# Do the condition checks here
		if(theAction.conditionType != ActionSystemEntry.CONDITION_NONE):
			if(!theUser.isInInteractRangeOf(theTarget)):
				cancelAction(theAction)
				continue
		
		#print(theUser.getActionSystemSpeed()," ", theUser.getActionSystemSpeed().length())
		if(theAction.targetMove == ActionSystemEntry.TARGET_CANMOVE && theAction.userMove == ActionSystemEntry.USER_CANMOVE):
			pass
		else:
			var speedUser := getSpeedOf(theUser)
			var speedTarget := getSpeedOf(theTarget)
			
			if(theAction.targetMove == ActionSystemEntry.TARGET_NO_MOVEMENT && speedTarget.length_squared() >= 1.0):
				cancelAction(theAction)
				continue
			if(theAction.targetMove == ActionSystemEntry.TARGET_NO_RUNNING && speedTarget.length_squared() >= 16.0):
				cancelAction(theAction)
				continue
			if(theAction.userMove == ActionSystemEntry.USER_NO_MOVEMENT && speedUser.length_squared() >= 1.0):
				cancelAction(theAction)
				continue
			if(theAction.userMove == ActionSystemEntry.USER_NO_RUNNING && speedUser.length_squared() >= 16.0):
				cancelAction(theAction)
				continue
			
			#var relativeSpeed:float = (speedTarget - speedUser).length_squared()
			#if(relativeSpeed >= 16.0): # 4.0 squared
			#	cancelAction(theAction)
			#	continue
		
		var thePawnAction := theAction.action
		var theContext := theAction.user.pawnActionContext
		theContext.target = theTarget
		theContext.args = theAction.args
		if(!thePawnAction.canDoDelayedAction(theContext)):
			theContext.clearContext()
			cancelAction(theAction)
			continue
		
		theAction.timePassed += _delta
		if(theAction.timePassed >= theAction.timeFull):
			theContext.clearContext()
			doAction(theAction)
			continue
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

func getAllActionsOfUser(_user:CharacterPawn) -> Array[ActionSystemEntry]:
	if(!userToActions.has(_user)):
		return []
	return userToActions[_user]

func getAllActionsOfTarget(_target:Node) -> Array[ActionSystemEntry]:
	if(!targetToActions.has(_target)):
		return []
	return targetToActions[_target]

func getSpeedOf(_node:Node) -> Vector3:
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
