extends RefCounted
class_name InteractionBase

const ROLE_MAIN = 0
const ROLE_TARGET = 1
const ROLE_EXTRA = 2
const ROLE_EXTRA2 = 3

var id:String = ""

var roleToPawn:Dictionary[int, CharacterPawn]
var pawnToRole:Dictionary[CharacterPawn, int]

var state:String = ""

var rareTimer:float = 1.0

var interactionQueue:Array = []

var wasDeleted:bool = false

enum QueueEntry {
	Delay,
	Say,
	Event,
	State,
	LookAt,
	StopLookAt,
	StopInteraction,
}

func involve(_role:int, _pawn:CharacterPawn):
	if(!_pawn):
		assert(false, "PAWN IS NULL")
		return
	GM.IS.stopAllInteractionsWith(_pawn)
	if(_pawn.hasInteraction()):
		assert(false, "PAWN ALREADY HAS AN INTERACTION "+str(_pawn.id))
		return
	
	roleToPawn[_role] = _pawn
	pawnToRole[_pawn] = _role
	_pawn.setInteraction(self)

func getRequiredRoles(_args:Array) -> Dictionary[int, String]:
	return {
	}

func checkRolesFilled(_requiredRoles:Dictionary[int, String], _roles:Dictionary) -> bool:
	if(_requiredRoles.size() != _roles.size()):
		return false
	for _roleID in _requiredRoles:
		var _roleStr:String = _requiredRoles[_roleID]
		if(!_roles.has(_roleStr)):
			return false
	return true

func startFinal(_roles:Dictionary, _args:Array) -> bool:
	var theRequiredRoles := getRequiredRoles(_args)
	if(!checkRolesFilled(theRequiredRoles, _roles)):
		assert(false, "BAD ROLES!")
		Log.error("INTERACTION "+id+" GOT BAD ROLES! "+str(_roles))
		#stopInteraction() # The interaction system will remove us
		return false
	for roleID in theRequiredRoles:
		var roleStr:String = theRequiredRoles[roleID]
		involve(roleID, _roles[roleStr])
	
	rareTimer = RNG.randfRange(0.5, 1.0)
	start(_roles, _args)
	replan()
	return true

func start(_roles:Dictionary, _args:Array):
	pass

func onEnd():
	pass

func processInteraction(_dt:float):
	rareTimer -= _dt
	if(rareTimer <= 0.0):
		rareTimer = 1.0
		processRare()
	
	processQueue(_dt)

func processRare():
	pass

var tempActions:Array[InteractionAction]
func getActions(_role:int):
	pass

func addAction(_action:InteractionAction):
	tempActions.append(_action)

func doAction(_role:int, _action:InteractionAction):
	#print("MEOW")
	pass

func getInterruptActions(_role:int, _newPawn:CharacterPawn) -> Array:
	return [
		#interuptAction("startTalk", "Hey!", 0.0),
	]

func getInterruptActionsFor(_pawn:CharacterPawn, _newPawn:CharacterPawn) -> Array:
	if(!pawnToRole.has(_pawn)):
		return []
	return getInterruptActions(pawnToRole[_pawn], _newPawn)

func doInterruptAction(_role:int, _newPawn:CharacterPawn, _actionID:String, _args:Array):
	pass

func doInterruptActionFor(_pawn:CharacterPawn, _newPawn:CharacterPawn, _actionEntry:Dictionary):
	if(!pawnToRole.has(_pawn)):
		return
	doInterruptAction(pawnToRole[_pawn], _newPawn, _actionEntry["id"], _actionEntry["args"] if _actionEntry.has("args") else [])

func doActionFor(_pawn:CharacterPawn, _actionEntry:InteractionAction):
	if(!pawnToRole.has(_pawn)):
		return
	doAction(pawnToRole[_pawn], _actionEntry)

func getActionsFor(_pawn:CharacterPawn) -> Array[InteractionAction]:
	if(!pawnToRole.has(_pawn)):
		return []
	tempActions = []
	getActions(pawnToRole[_pawn])
	return tempActions

func getPawn(_role:int) -> CharacterPawn:
	if(!roleToPawn.has(_role)):
		return null
	return roleToPawn[_role]

func getChar(_role:int) -> BaseCharacter:
	if(!roleToPawn.has(_role)):
		return null
	return roleToPawn[_role].getCharacter()

func getCharID(_role:int) -> String:
	if(!roleToPawn.has(_role)):
		return ""
	return roleToPawn[_role].getCharID()

func getRoleOf(_pawn:CharacterPawn) -> int:
	if(!pawnToRole.has(_pawn)):
		return -1
	return pawnToRole[_pawn]

func pushDelay(_delay:float):
	interactionQueue.append([QueueEntry.Delay, _delay])

func pushSay(_role:int, _text:String):
	interactionQueue.append([QueueEntry.Say, _role, _text])

func pushLookAt(_role1:int, _role2:int):
	interactionQueue.append([QueueEntry.LookAt, _role1, _role2])

func pushStopLookAt(_role1:int):
	interactionQueue.append([QueueEntry.StopLookAt, _role1])
	
func pushStopInteraction():
	interactionQueue.append([QueueEntry.StopInteraction])

func pushEvent(_eventID:String, _args:Array = []):
	interactionQueue.append([QueueEntry.Event, _eventID, _args])

func clearPushQueue():
	interactionQueue.clear()

func onQueueEvent(_eventID:String, _args:Array):
	pass

func setState(_newState:String, _doReplan:bool = true):
	state = _newState
	if(_doReplan):
		replan()

func replan():
	for thePawn in pawnToRole:
		thePawn.ai.onInteractionStateChange(self)

func processQueue(_dt:float):
	while(!interactionQueue.is_empty()):
		var theEntry:Array = interactionQueue.front()
		var theType:int = theEntry[0]
		
		match theType:
			QueueEntry.Delay:
				theEntry[1] -= _dt
				if(theEntry[1] <= 0.0):
					interactionQueue.pop_front()
				break
			QueueEntry.Say:
				sayText(theEntry[1], theEntry[2])
				interactionQueue.pop_front()
			QueueEntry.Event:
				onQueueEvent(theEntry[1], theEntry[2])
				interactionQueue.pop_front()
			QueueEntry.State:
				setState(theEntry[1])
				interactionQueue.pop_front()
			QueueEntry.LookAt:
				lookAt(theEntry[1], theEntry[2], theEntry[3] if theEntry.size() > 3 else false)
				interactionQueue.pop_front()
			QueueEntry.StopLookAt:
				stopLookAt(theEntry[1])
				interactionQueue.pop_front()
			QueueEntry.StopInteraction:
				stopInteraction()
				interactionQueue.pop_front()
			_:
				assert(false, "BAD QUEUE ENTRY TYPE")
				interactionQueue.pop_front()
	
func interuptAction(_id:String, _name:String, _score:float) -> Dictionary:
	return {
		id = _id,
		name = _name,
		score = _score,
	}
	
#, _target:int #needed?
#func action(_id:String, _name:String, _score:float) -> Dictionary:
	#return {
		#id = _id,
		#name = _name,
		#score = _score,
		##targetRole = _target,
	#}
func action(_id:String, _name:String, _score:float) -> InteractionAction:
	return InteractionAction.create(_id, _name).setScore(_score)

func stopInteraction():
	if(wasDeleted || !GM.IS):
		return
	GM.IS.removeInteraction(self)

func isCharIDInvolved(_charID:String) -> bool:
	var thePawn := GM.pawnRegistry.getPawn(_charID)
	if(!thePawn):
		return false
	return pawnToRole.has(thePawn)

func isPawnInvolved(_pawn:CharacterPawn) -> bool:
	return pawnToRole.has(_pawn)

func sayText(_role:int, _text:String, talkGesture:bool = true):
	#print(str(_role)+": "+_text)
	var thePawn := getPawn(_role)
	if(thePawn):
		thePawn.sayAdvanced(CharacterPawn.parseSayTextToArray(_text))
		if(talkGesture):
			doTalkGesture(_role)
		#if(talkMouth):
		#	doTalkFaceAnim(_role)
	else:
		Log.error(str(id)+" NOT FOUND ROLE "+str(_role)+" TO SAY TEXT: "+str(_text))

# Not multiplayer-synced
#func doTalkFaceAnim(_role:int, _len:float = 3.0):
	#var thePawn := getPawn(_role)
	#if(thePawn && thePawn.isDollSpawned()):
		#thePawn.getDoll().getDoll().doFaceTalkAnim(_len)

func doGesture(_role:int, _gestureID:String):
	var thePawn := getPawn(_role)
	if(thePawn):
		thePawn.playGesture(_gestureID)

func doTalkGesture(_role:int):
	doGesture(_role, RNG.pick([
		DollGesture.Talking1Hand,
		DollGesture.Talking2Hands,
		DollGesture.HeadGesture,
		DollGesture.HeadGestureShort,
		DollGesture.HeadNod,
		DollGesture.HappyHand,
		DollGesture.LookAway,
	]))

func startAction(_role:int, actionID:String, args:Array = []):
	var thePawn:CharacterPawn = getPawn(_role)
	if(!thePawn):
		return
	var theAI:PawnAI = thePawn.getAI()
	theAI.startAction(actionID, args)

func stopAction(_role:int):
	var thePawn:CharacterPawn = getPawn(_role)
	if(!thePawn):
		return
	var theAI:PawnAI = thePawn.getAI()
	theAI.stopAction()

func startInteraction(_id:String, _roles:Dictionary, _args:Array = []):
	var rolesFinal:Dictionary[String, CharacterPawn] = {}
	for roleID in _roles:
		if(_roles[roleID] is int):
			rolesFinal[roleID] = getPawn(_roles[roleID])
		elif(_roles[roleID] is CharacterPawn):
			rolesFinal[roleID] = _roles[roleID]
		elif(_roles[roleID] is String):
			rolesFinal[roleID] = GM.pawnRegistry.getPawn(_roles[roleID])
	
	GM.IS.startInteraction(_id, rolesFinal, _args)

func getDistanceBetweenSquared(_role1:int, _role2:int) -> float:
	var pawn1:= getPawn(_role1)
	var pawn2:= getPawn(_role2)
	if(!pawn1 || !pawn2):
		return 99999.9
	return pawn1.global_position.distance_squared_to(pawn2.global_position)

func getDistanceBetween(_role1:int, _role2:int) -> float:
	var pawn1:= getPawn(_role1)
	var pawn2:= getPawn(_role2)
	if(!pawn1 || !pawn2):
		return 99999.9
	return pawn1.global_position.distance_to(pawn2.global_position)

func lookAt(_role1:int, _role2:int, lookBack:bool = false, _howLong:float = 5.0):
	var pawn1:= getPawn(_role1)
	var pawn2:= getPawn(_role2)
	if(!pawn1 || !pawn2):
		return
	var doll1:= pawn1.getDoll()
	var doll2:= pawn2.getDoll()
	if(doll1 && doll2):
		GM.dollHolder.askLookAtDoll(doll1, doll2, _howLong)
		if(lookBack):
			GM.dollHolder.askLookAtDoll(doll2, doll1, _howLong)

func stopLookAt(_role1:int):
	var pawn1:= getPawn(_role1)
	if(!pawn1):
		return
	var doll1:= pawn1.getDoll()
	if(doll1 && doll1.getDoll()):
		GM.dollHolder.askLookAtClear(doll1)

func thinkFor(_pawn:CharacterPawn, _action:AIActionBase):
	if(!pawnToRole.has(_pawn)):
		return
	var theRole := pawnToRole[_pawn]
	var theAi := _pawn.ai
	think(theRole, _pawn, theAi, _action)

func think(_role:int, _pawn:CharacterPawn, _ai:PawnAI, _action:AIActionBase):
	pass

func onSubActionResult(_role:int, _pawn:CharacterPawn, _ai:PawnAI, _action:AIActionBase, _tag:String, _status:int, _result:Array):
	pass

func plan(_role:int, _action:AIActionBase) -> AIPlan:
	return null

func onPlanCompleted(_role:int, _action:AIActionBase, _plan:AIPlan):
	pass

func onPlanFail(_role:int, _action:AIActionBase, _plan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	pass

func onGettingHit(_role:int, _attackContext:AttackContext) -> bool:
	#getPawn().combatAI.addEnemy(_attackContext.attacker)
	#startSubActionUnlessSameTag("Combat")
	return false

func isHandlingCombat(_role:int) -> bool:
	return false
