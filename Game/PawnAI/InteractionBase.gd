extends RefCounted
class_name InteractionBase

const ROLE_MAIN = 0
const ROLE_TARGET = 1
const ROLE_EXTRA = 2
const ROLE_EXTRA2 = 3

const CATEGORY_FRIENDLY:Array[String] = ["Friendly"]
const CATEGORY_ORDER:Array[String] = ["Order"]

var id:String = ""
var registerForInteractionType:Array[int]

var roleToPawn:Dictionary[int, CharacterPawn]
var pawnToRole:Dictionary[CharacterPawn, int]

var state:String = "": set = setState, get = getState
var stateRaw:String = ""
var elapsedTime:float = 0.0 # Time since last setState() call
var timeoutTime:float = 0.0 # Time since last action

var rareTimer:float = 0.0
var wasDeleted:bool = false

var subInteraction:InteractionBase
var parentInteraction:InteractionBase
var interactionTag:String = ""

var interactionQueue:Array = []

enum QueueEntry {
	Delay,
	Say,
	SayRaw,
	Event,
	SetState,
	LookAt,
	StopLookAt,
	StopInteraction,
	AddAffection,
	AddSocialEvent,
	SocialInteractionEnd,
	SocialInteractionDeny,
	SocialInteractionShowSuccess,
}

func involve(_role:int, _pawn:CharacterPawn):
	if(!_pawn):
		assert(false, "PAWN IS NULL")
		return
	var isSubInteraction:bool = (parentInteraction != null)
	
	if(isSubInteraction):
		roleToPawn[_role] = _pawn
		pawnToRole[_pawn] = _role
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
	
	rareTimer = RNG.randfRange(0.0, 0.5)
	start(_roles, _args)
	replan()
	return true

func start(_roles:Dictionary, _args:Array):
	pass

func onEnd():
	pass

func startSubInteraction(_tag:String, _interactionID:String, _roles:Dictionary[String, CharacterPawn], _args:Array = []) -> InteractionBase:
	stopSubInteraction()
	var theInteraction:InteractionBase = GlobalRegistry.createInteraction(_interactionID)
	if(!theInteraction):
		return null
	theInteraction.parentInteraction = self
	subInteraction = theInteraction
	subInteraction.interactionTag = _tag
	#interactions.append(theInteraction)
	if(!theInteraction.startFinal(_roles, _args)):
		#interactions.erase(theInteraction)
		theInteraction.parentInteraction = null
		subInteraction = null
		return null
	replan()
	return theInteraction

func processInteraction(_dt:float):
	if(subInteraction):
		subInteraction.processInteraction(_dt)
		
		rareTimer += _dt
		if(rareTimer >= 1.0):
			var theDeltaTime:float = rareTimer
			rareTimer = 0.0
			processRareAlways(theDeltaTime)
		return
	
	rareTimer += _dt
	if(rareTimer >= 1.0):
		var theDeltaTime:float = rareTimer
		rareTimer = 0.0
		var theFuncName:String = getStateFunc("processRare")
		if(has_method(theFuncName)):
			call(theFuncName, theDeltaTime)
		else:
			processRare(theDeltaTime)
		processRareAlways(theDeltaTime)
	
	elapsedTime += _dt
	if(!subInteraction && interactionQueue.is_empty()):
		timeoutTime += _dt
	
	processQueue(_dt)

func processRare(_dt:float):
	pass

func processRareAlways(_dt:float):
	pass

var tempActions:Array[InteractionAction]
func getActions(_role:int):
	pass

func addAction(_action:InteractionAction):
	_action.interaction = self
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
	if(subInteraction && _actionEntry.interaction == subInteraction):
		subInteraction.doActionFor(_pawn, _actionEntry)
		return
	if(_actionEntry.interaction != self):
		return
	
	if(!pawnToRole.has(_pawn)):
		return
	timeoutTime = 0.0
	var theFuncName := getStateFunc("do")
	if(has_method(theFuncName)):
		call(theFuncName, pawnToRole[_pawn], _actionEntry)
	else:
		doAction(pawnToRole[_pawn], _actionEntry)
	
	_pawn.ai.goalHandler.handleInteractionAction(self, _actionEntry)

func getStateFunc(_name:String) -> String:
	return stateRaw+"_"+_name

func getActionsFor(_pawn:CharacterPawn) -> Array[InteractionAction]:
	if(subInteraction):
		return subInteraction.getActionsFor(_pawn)
	
	if(!interactionQueue.is_empty()):
		return []
	
	if(!pawnToRole.has(_pawn)):
		return []
	tempActions = []
	var theFuncName := getStateFunc("actions")
	if(has_method(theFuncName)):
		call(theFuncName, pawnToRole[_pawn])
	else:
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

func pushSayRaw(_role:int, _text:String):
	interactionQueue.append([QueueEntry.SayRaw, _role, _text])

func pushSay(_role:int, _text:String, _roleTarget:int = -1, _args:Dictionary[String, Variant] = {}):
	interactionQueue.append([QueueEntry.Say, _role, _text, _roleTarget, _args])

func pushLookAt(_role1:int, _role2:int):
	interactionQueue.append([QueueEntry.LookAt, _role1, _role2])

func pushStopLookAt(_role1:int):
	interactionQueue.append([QueueEntry.StopLookAt, _role1])
	
func pushStopInteraction():
	interactionQueue.append([QueueEntry.StopInteraction])
	
func pushAddAffection(_role1:int, _role2:int, _amount:float):
	interactionQueue.append([QueueEntry.AddAffection, _role1, _role2, _amount])
	
#func pushAddSocialEvent(_roleStarter:int, _roleTarget:int, _event:String, _outcome:int, _affection):
	#interactionQueue.append([QueueEntry.AddAffection, _role1, _role2, _amount])

func pushEvent(_eventID:String, _args:Array = []):
	interactionQueue.append([QueueEntry.Event, _eventID, _args])

func pushSetState(_state:String):
	interactionQueue.append([QueueEntry.SetState, _state])

func pushSocialEnd():
	interactionQueue.append([QueueEntry.SocialInteractionEnd])

func pushSocialDenied():
	interactionQueue.append([QueueEntry.SocialInteractionDeny])

# Just shows text above the target's head
func pushSocialShowSuccess():
	interactionQueue.append([QueueEntry.SocialInteractionShowSuccess])

func clearPushQueue():
	interactionQueue.clear()

func onQueueEvent(_eventID:String, _args:Array):
	pass

func getState() -> String:
	return stateRaw

func setState(_newState:String): #, _doReplan:bool = true
	elapsedTime = 0.0
	timeoutTime = 0.0
	state = _newState
	stateRaw = _newState
	#if(_doReplan):
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
			QueueEntry.SayRaw:
				sayText(theEntry[1], theEntry[2])
				interactionQueue.pop_front()
			QueueEntry.Say:
				say(theEntry[1], theEntry[2], theEntry[3], theEntry[4])
				interactionQueue.pop_front()
			QueueEntry.Event:
				onQueueEvent(theEntry[1], theEntry[2])
				interactionQueue.pop_front()
			QueueEntry.SetState:
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
			QueueEntry.AddAffection:
				addAffection(theEntry[1], theEntry[2], theEntry[3])
				interactionQueue.pop_front()
			QueueEntry.SocialInteractionEnd:
				socialInteractionEnd()
				interactionQueue.pop_front()
			QueueEntry.SocialInteractionDeny:
				socialInteractionDeny()
				interactionQueue.pop_front()
			QueueEntry.SocialInteractionShowSuccess:
				showInteractionSuccess()
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
func action(_id:String, _name:String, _score:float = 0.0) -> InteractionAction:
	return InteractionAction.create(_id, _name).setScore(_score)

func stopInteraction():
	if(wasDeleted || !GM.IS):
		return
	if(parentInteraction):
		parentInteraction.stopSubInteraction()
		return
	GM.IS.removeInteraction(self)

func stopSubInteraction():
	if(!subInteraction):
		return
	var theInteraction := subInteraction
	subInteraction = null
	theInteraction.onEnd()
	onSubInteractionEnd(theInteraction)
	theInteraction.parentInteraction = null
	theInteraction.wasDeleted = true
	replan()

func onSubInteractionEnd(_interaction:InteractionBase):
	pass

func isCharIDInvolved(_charID:String) -> bool:
	var thePawn := GM.pawnRegistry.getPawn(_charID)
	if(!thePawn):
		return false
	return pawnToRole.has(thePawn)

func isPawnInvolved(_pawn:CharacterPawn) -> bool:
	return pawnToRole.has(_pawn)

func getXSayLines(_amount:int, _roleSay:int, _reaction:String, _roleTarget:int = -1, _args:Dictionary[String, Variant] = {}) -> Array[String]:
	var thePawn := getPawn(_roleSay)
	if(!thePawn):
		return []
	var theContext := ReactionSystem.ReactionContext.new()
	theContext.main = thePawn.getCharacter()
	theContext.target = getPawn(_roleTarget).getCharacter() if _roleTarget >= 0 else null
	theContext.args = _args
	var theReactions := GM.main.reactionSystem.generateXReactions(_reaction, theContext, _amount)
	if(theReactions.is_empty()):
		return []
	var theLines:Array[String]
	for theReaction in theReactions:
		theLines.append(theReaction.line)
	return theLines
	
func say(_roleSay:int, _reaction:String, _roleTarget:int = -1, _args:Dictionary[String, Variant] = {}):
	var thePawn := getPawn(_roleSay)
	if(!thePawn):
		return
	var theContext := ReactionSystem.ReactionContext.new()
	theContext.main = thePawn.getCharacter()
	theContext.target = getPawn(_roleTarget).getCharacter() if _roleTarget >= 0 else null
	theContext.args = _args
	var theReaction := GM.main.reactionSystem.generateReaction(_reaction, theContext)
	if(!theReaction):
		Log.Printerr("# WRITE ME: "+_reaction+" #")
		sayText(_roleSay, "#WRITE_ME: "+_reaction+"#", true)
		return
	sayText(_roleSay, theReaction.line, true)

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

func planFor(_pawn:CharacterPawn, _action:AIActionBase) -> AIPlan:
	if(subInteraction):
		return subInteraction.planFor(_pawn, _action)
	
	if(!pawnToRole.has(_pawn)):
		return null
	var theFuncName := getStateFunc("plan")
	if(has_method(theFuncName)):
		return call(theFuncName, pawnToRole[_pawn], _action)
	else:
		return plan(pawnToRole[_pawn], _action)

func plan(_role:int, _action:AIActionBase) -> AIPlan:
	return null

func onPlanCompletedFor(_pawn:CharacterPawn, _action:AIActionBase, _plan:AIPlan):
	if(subInteraction):
		return subInteraction.onPlanCompletedFor(_pawn, _action, _plan)

	if(!pawnToRole.has(_pawn)):
		return
	var theFuncName := getStateFunc("planDone")
	if(has_method(theFuncName)):
		call(theFuncName, pawnToRole[_pawn], _action, _plan)
	else:
		onPlanCompleted(pawnToRole[_pawn], _action, _plan)

func onPlanCompleted(_role:int, _action:AIActionBase, _plan:AIPlan):
	pass

func onPlanFailFor(_pawn:CharacterPawn, _action:AIActionBase, _plan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	if(subInteraction):
		return subInteraction.onPlanFailFor(_pawn, _action, _plan, _failedAction, _failStatus)

	if(!pawnToRole.has(_pawn)):
		return
	var theFuncName := getStateFunc("planFail")
	if(has_method(theFuncName)):
		call(theFuncName, pawnToRole[_pawn], _action, _plan, _failedAction, _failStatus)
	else:
		onPlanFail(pawnToRole[_pawn], _action, _plan, _failedAction, _failStatus)

func onPlanFail(_role:int, _action:AIActionBase, _plan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	pass

func isAnyoneInCombat() -> bool:
	for thePawn in pawnToRole:
		if(thePawn.isInCombat()):
			return true
	return false

func onGettingHitFor(_pawn:CharacterPawn, _attackContext:AttackContext) -> bool:
	if(subInteraction):
		if(subInteraction.onGettingHitFor(_pawn, _attackContext)):
			return true
	
	if(!pawnToRole.has(_pawn)):
		return false
	return onGettingHit(pawnToRole[_pawn], _attackContext)

func onGettingHit(_role:int, _attackContext:AttackContext) -> bool:
	#getPawn().combatAI.addEnemy(_attackContext.attacker)
	#startSubActionUnlessSameTag("Combat")
	return false

func isHandlingCombatFor(_pawn:CharacterPawn) -> bool:
	if(subInteraction):
		if(subInteraction.isHandlingCombatFor(_pawn)):
			return true
	
	if(!pawnToRole.has(_pawn)):
		return false
	return isHandlingCombat(pawnToRole[_pawn])

func isHandlingCombat(_role:int) -> bool:
	return false

func checkClose2(_role1:int, _role2:int, _dist:float = 5.0) -> bool:
	var thePawn1 := getPawn(_role1)
	var thePawn2 := getPawn(_role2)
	if(!thePawn1 || !thePawn2):
		return false
	if(thePawn1.global_position.distance_squared_to(thePawn2.global_position) <= _dist):
		return true
	return false

func checkTooFar(_dist:float = 7.0) -> bool:
	var allRoles:Array = roleToPawn.keys()
	if(allRoles.size() <= 1):
		return false
	var theDistSquared:float = _dist * _dist
	var theMainRole:int = allRoles.pop_front()
	var theMainPawn := getPawn(theMainRole)
	for _otherRole in allRoles:
		var theOtherPawn := getPawn(_otherRole)
		if(theMainPawn.global_position.distance_squared_to(theOtherPawn.global_position) > theDistSquared):
			return true
	return false

func checkTooFarAutoStop(_dist:float = 7.0) -> bool:
	if(checkTooFar(_dist)):
		stopInteraction()
		return true
	return false

func planFaceEachOther(_role1:int, _role2:int, _role:int, _action:AIActionBase) -> AIPlan:
	if(_role == _role1):
		return _action.makePlan().add("Face", [getPawn(_role2)])
	if(_role == _role2):
		return _action.makePlan().add("Face", [getPawn(_role1)])
	return null

func planApproachEachOther(_role1:int, _role2:int, _role:int, _action:AIActionBase) -> AIPlan:
	if(_role == _role1):
		return _action.makePlan().add("ApproachPawn", [getPawn(_role2)])
	if(_role == _role2):
		return _action.makePlan().add("ApproachPawn", [getPawn(_role1)])
	return null

func isInteractionQueueEmpty() -> bool:
	return interactionQueue.is_empty()

## How much time has passed since the start of the interaction or the last setState() call
func getElapsedTime() -> float:
	return elapsedTime

func addAffection(_role1:int, _role2:int, _am:float):
	var pawn1 := getPawn(_role1)
	var pawn2 := getPawn(_role2)
	if(!pawn1 || !pawn2):
		return
	
	GM.main.relationshipSystem.addAffection(pawn1.getCharID(), pawn2.getCharID(), _am)
	
	if(_am > 0.0):
		pawn1.addSmallText("Affection+", Color.GREEN)
		pawn2.addSmallText("Affection+", Color.GREEN)
	elif(_am < 0.0):
		pawn1.addSmallText("Affection-", Color.RED)
		pawn2.addSmallText("Affection-", Color.RED)

func canDoSocialActionFinal(_main:CharacterPawn, _target:CharacterPawn) -> bool:
	return false

func canDoSocialAction(_main:CharacterPawn, _target:CharacterPawn) -> bool:
	return false

func getSocialActions(_main:CharacterPawn, _target:CharacterPawn) -> Array[InteractionAction]:
	return []

func socialInteractionEnd():
	pass

func socialInteractionDeny():
	pass

func showInteractionSuccess():
	pass

func shouldAllowDelayedActionFor(_pawn:CharacterPawn, _action:ActionSystemEntry) -> bool:
	if(subInteraction):
		return subInteraction.shouldAllowDelayedActionFor(_pawn, _action)
	
	if(!pawnToRole.has(_pawn)):
		return false
	return shouldAllowDelayedAction(pawnToRole[_pawn], _action)

func shouldAllowDelayedAction(_role:int, _action:ActionSystemEntry) -> bool:
	return false

func onSexEngineResult(_result:SexEngineResult):
	pass

func pushSexEngineResult(_result:SexEngineResult):
	if(subInteraction):
		subInteraction.onSexEngineResult(_result)
		return
	
	onSexEngineResult(_result)
