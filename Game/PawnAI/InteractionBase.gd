extends RefCounted
class_name InteractionBase

const ROLE_MAIN = 0
const ROLE_TARGET = 1
const ROLE_EXTRA = 2
const ROLE_EXTRA2 = 3

var id:String = ""

var roleToID:Dictionary[int, String] = {}
var idToRole:Dictionary[String, int] = {}

var state:String = ""

var rareTimer:float = 1.0

var interactionQueue:Array = []

var wasDeleted:bool = false

enum QueueEntry {
	Delay,
	Say,
	Event,
	State,
}

func involve(_role:int, _pawn:CharacterPawn):
	if(!_pawn):
		assert(false, "PAWN IS NULL")
		return
	GM.IS.stopAllInteractionsWith(_pawn.id)
	if(_pawn.hasInteraction()):
		assert(false, "PAWN ALREADY HAS AN INTERACTION "+str(_pawn.id))
		return
	
	roleToID[_role] = _pawn.id
	idToRole[_pawn.id] = _role
	_pawn.setInteraction(self)

func startFinal(_roles:Dictionary, _args:Array):
	rareTimer = RNG.randfRange(0.5, 1.0)
	start(_roles, _args)

func start(_roles:Dictionary, _args:Array):
	pass

func processInteraction(_dt:float):
	rareTimer -= _dt
	if(rareTimer <= 0.0):
		rareTimer = 1.0
		processRare()
	
	processQueue(_dt)

func processRare():
	pass

func getActions(_role:int) -> Array:
	return [
		#action("meow", "Meow!", 1.0),
	]

func doAction(_role:int, _actionID:String, _args:Array):
	#print("MEOW")
	pass

func getInterruptActions(_role:int, _newCharID:String) -> Array:
	return [
		#interuptAction("startTalk", "Hey!", 0.0),
	]

func getInterruptActionsFor(_charID:String, _newCharID:String) -> Array:
	if(!idToRole.has(_charID)):
		return []
	return getInterruptActions(idToRole[_charID], _newCharID)

func doInterruptAction(_role:int, _newCharID:String, _actionID:String, _args:Array):
	pass

func doInterruptActionFor(_charID:String, _newCharID:String, _actionEntry:Dictionary):
	if(!idToRole.has(_charID)):
		return
	doInterruptAction(idToRole[_charID], _newCharID, _actionEntry["id"], _actionEntry["args"] if _actionEntry.has("args") else [])

func doActionFor(_charID:String, _actionEntry:Dictionary):
	if(!idToRole.has(_charID)):
		return
	doAction(idToRole[_charID], _actionEntry["id"], _actionEntry["args"] if _actionEntry.has("args") else [])

func getActionsFor(_charID:String) -> Array:
	if(!idToRole.has(_charID)):
		return []
	return getActions(idToRole[_charID])

func getPawn(_role:int) -> CharacterPawn:
	if(!roleToID.has(_role)):
		return null
	return GM.pawnRegistry.getPawn(roleToID[_role])

func getChar(_role:int) -> BaseCharacter:
	if(!roleToID.has(_role)):
		return null
	return GM.characterRegistry.getCharacter(roleToID[_role])

func getCharID(_role:int) -> String:
	if(!roleToID.has(_role)):
		return ""
	return roleToID[_role]

func pushDelay(_delay:float):
	interactionQueue.append([QueueEntry.Delay, _delay])

func pushSay(_role:int, _text:String):
	interactionQueue.append([QueueEntry.Say, _role, _text])

func pushEvent(_eventID:String, _args:Array = []):
	interactionQueue.append([QueueEntry.Event, _eventID, _args])

func clearPushQueue():
	interactionQueue.clear()

func onQueueEvent(_eventID:String, _args:Array):
	pass

func setState(_newState:String):
	state = _newState

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
func action(_id:String, _name:String, _score:float) -> Dictionary:
	return {
		id = _id,
		name = _name,
		score = _score,
		#targetRole = _target,
	}

func stopInteraction():
	if(wasDeleted || !GM.IS):
		return
	GM.IS.removeInteraction(self)

func isCharIDInvolved(_charID:String):
	return idToRole.has(_charID)

func sayText(_role:int, _text:String):
	print(str(_role)+": "+_text)

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
