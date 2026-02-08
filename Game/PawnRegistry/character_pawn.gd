extends Node3D
class_name CharacterPawn

const DOLL_DESPAWN_TIME = 1.0
const DOLL_DESPAWN_DISTANCE = 30.0 * 30.0 #Squared

enum SayType {
	Speech,
	Action,
}

@export var id:String = ""
var doll:DollController
#var poseSpot:PoseSpot

@onready var doll_node: SyncNode = %DollNode
#@onready var sit_node: SyncNode = %SitNode

@onready var navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D
@onready var pawn_interactor: PawnInteractor = %PawnInteractor

var ai:PawnAI
var interaction:InteractionBase

signal dollSpawned(doll)
signal dollDespawned(doll)
signal dollSwitched(newdoll, olddoll)

var gridPos:Vector2i

var pawnActionContext:PawnActionContext

const STATE_NORMAL = 0
const STATE_SITTING = 1
const STATE_COMBAT = 2

@onready var stateEmpty: Node = %Empty

@onready var stateNormal: DollControllerState = %Normal
@onready var stateSitting: DollControllerState = %Sitting
@onready var stateCombat: DollControllerState = %Combat
@onready var states:Dictionary[int, DollControllerState] = {
	STATE_NORMAL: stateNormal,
	STATE_SITTING: stateSitting,
	STATE_COMBAT: stateCombat,
}

@export var pawnState:int = STATE_NORMAL
@onready var state:DollControllerState = stateNormal

func _ready() -> void:
	pawnActionContext = PawnActionContext.new()
	pawnActionContext.pawn = self
	pawn_interactor.setPawn(self)
	
	ai = PawnAI.new()
	ai.setPawn(self)
	
	#print(sayArrayToText([
		#[SayType.Speech, "Hello."],
		#[SayType.Speech, "World."],
		#[SayType.Action, "Rubs paws"],
		#[SayType.Action, "Meows"],
		#[SayType.Speech, "Meow meow."],
		#[SayType.Speech, "Meow meow."],
	#]))
	#print(parseMeTextToArray("meows and purrs \"Hello world\" Nya"))
	#print(parseMeTextToArray("meows and purrs\naa\"Hello world\"\nNya"))
	#print(parseSayTextToArray("Hello *nuzzles you* uwu, meow meow *meows a lot*"))

func getCharacter() -> BaseCharacter:
	if(GM.characterRegistry):
		return GM.characterRegistry.getCharacter(id)
	return null

func getCharID() -> String:
	return id

func getDoll() -> DollController:
	return doll

func shouldDollBeSpawned() -> bool:
	#for playerID in Network.players:
		#var info:NetworkPlayerInfo = Network.players[playerID]
		#if(info.charID == id):
			#return true
	if(GM.pawnRegistry.shouldPawnDollBeSpawned(self)):
		return true
	return false

var despawnTimer:float = 0.0
func _process(_delta: float) -> void:
	#if(is_queued_for_deletion()): #HACK fixes a crash when hosting with NORAY, dunno
	#	return
	if(Network.isServer()):
		var shouldBeSpawned:bool = shouldDollBeSpawned()
		if(shouldBeSpawned):
			despawnTimer = 0.0
		else:
			despawnTimer += _delta
		
		if(isDollSpawned()):
			position = doll.position
			rotation = doll.model_root.rotation
			
			if(!shouldBeSpawned && despawnTimer > DOLL_DESPAWN_TIME): # || RNG.chance(1)
				despawnDoll()
		else:
			if(shouldBeSpawned): # && RNG.chance(1)
				spawnDoll()
	
	$MeshInstance3D.visible = !isDollSpawned()
	GM.pawnRegistry.checkPawnSparseGrid(self)
	

func _physics_process(_delta: float) -> void:
	#if(!isControlledByUs()):
	#	if(isDollSpawned()):
	#		getDoll().reset_input()
	updateDelayedActionCache()
	if(Network.isServer()):
		ai.processAI(_delta)
	calcHoverTextProgressBarInfo()
	processPoseSpot()
	
	if(isControlledByAnyPlayer()):
		var theDoll := getDoll()
		navigation_agent_3d.velocity = theDoll.velocity if theDoll else Vector3.ZERO
		#if(navigation_agent_3d.avoidance_enabled):
		#	navigation_agent_3d.avoidance_enabled = false
	else:
		var theDir := (navigation_agent_3d.get_next_path_position() - global_position) if !navigation_agent_3d.is_navigation_finished() else Vector3.ZERO
		var theDirLen:float = theDir.length()
		if(theDirLen > 1.0):
			theDir /= theDirLen
		navigation_agent_3d.velocity = theDir*3.0#getDoll().velocity
		#if(!navigation_agent_3d.avoidance_enabled):
		#	navigation_agent_3d.avoidance_enabled = true
	#DebugDraw.draw_line_3d(global_position, global_position+safeNavAgentVelocity, Color.GREEN)
	
func processPoseSpot():
	var thePoseSpot:PoseSpot = getPoseSpot()
	if(!thePoseSpot):
		return
	var globPos := thePoseSpot.global_position
	var globRot := thePoseSpot.global_rotation
	global_position = globPos
	global_rotation.y = globRot.y
	var theDoll := getDoll()
	if(theDoll):
		theDoll.global_position = globPos
		theDoll.model_root.global_rotation = globRot
		theDoll.velocity = Vector3(0.0, 0.0, 0.0)
	#move_and_slide()

func goTowardsRaw(_pos:Vector3, _delta: float, shouldRun:bool):
	if(!isDollSpawned()):
		if(getState() == STATE_SITTING):
			return
		var dirToGo:Vector3 = (_pos - global_position)
		if(dirToGo.length_squared() < 0.01):
			global_position = _pos
			return
		global_position += dirToGo.limit_length(_delta*(3.0 if !shouldRun else 5.0))
		return
	else:
		var theDoll := getDoll()
		var dirToGo:Vector3 = (_pos - global_position)
		#if(dirToGo.length_squared() < 5.0):
		#	theDoll.doll_controls.move_direction = Vector3(0.0, 0.0, 0.0)
		#	theDoll.doll_controls.move_direction_no_y = Vector3(0.0, 0.0, 0.0)
		#	return
		theDoll.doll_controls.move_direction = dirToGo.normalized()
		theDoll.doll_controls.move_direction_no_y = theDoll.doll_controls.move_direction
		theDoll.doll_controls.move_direction_no_y.y = 0.0
		theDoll.doll_controls.move_direction_no_y = theDoll.doll_controls.move_direction_no_y.normalized()
		theDoll.doll_controls.sprint_isdown = shouldRun

func isDollSpawned() -> bool:
	return !!doll

func spawnDoll():
	if(!Network.isServer()):
		return
	if(doll):
		assert(false, "Doll already spawned")
		return
	var newDoll: = GM.dollHolder.createDollControllerForPawn(self)
	newDoll.tree_exiting.connect(dollOnDelete)
	doll_node.setNode(newDoll)

func despawnDoll():
	if(!doll):
		assert(false, "Doll doesn't exist")
		return
	GM.dollHolder.deleteDoll(doll)
	doll_node.setNode(null)

func dollOnDelete():
	doll_node.setNode(null)

func isControlledByUs() -> bool:
	var myInfo:NetworkPlayerInfo = Network.getMyPlayerInfo()
	if(!myInfo):
		return false
	return myInfo.charID == id

func isControlledByAnyPlayer() -> bool:
	return Network.getPlayerIDWhoControls(id) >= 0

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.Var, position,
		Bins.U8, pawnState,
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	position = _data.readVar()
	pawnState = _data.readU8()
	state = states[pawnState] if states.has(pawnState) else stateEmpty
	_data.endLoad()

func saveData() -> Dictionary:
	return {
		pos = position,
		state = pawnState,
	}

func loadData(_data:Dictionary):
	position = SAVE.loadVar(_data, "pos", position)
	pawnState = SAVE.loadVar(_data, "state", STATE_NORMAL)
	state = states[pawnState] if states.has(pawnState) else stateEmpty

func _on_doll_node_on_node_changed(newNode: Variant) -> void:
	var tempDoll = doll
	doll = newNode
	
	if(doll):
		Log.Print("Doll spawned for "+getCharID())
		doll.updatePoseSpot()
		dollSpawned.emit(doll)
	elif(tempDoll && !doll):
		Log.Print("Doll despawned for "+getCharID())
		dollDespawned.emit(tempDoll)
	if(doll != tempDoll):
		dollSwitched.emit(doll, tempDoll)

#func _on_sit_node_on_node_changed(newNode: Variant) -> void:
	#poseSpot = newNode
	# # Notify doll
	#var theDoll:=getDoll()
	#if(theDoll):
		#theDoll.updatePoseSpot()
#
#func setPoseSpot(newPoseSpot:PoseSpot):
	#if(Network.isClient()):
		#assert(false, "Client trying to set pose spot. Only server should do it")
		#return
	#sit_node.setNode(newPoseSpot)

func getPoseSpot() -> PoseSpot:
	return GM.sitManager.getSeatOfPawn(self)

func _exit_tree() -> void:
	GM.sitManager.handleDeletionOfPawn(self)
	if(Network.isServer()):
		if(doll):
			despawnDoll()

func canSit() -> bool:
	return !GM.sitManager.isSitting(self)

## Called by sit manager
func onSeatChange(_newSpot:PoseSpot):
	var theDoll := getDoll()
	if(theDoll):
		theDoll.onSeatChange(_newSpot)
	
	if(Network.isServer()):
		if(!_newSpot):
			if(getState() == STATE_SITTING):
				setState(STATE_NORMAL)
		else:
			setState(STATE_SITTING)

func getNavAgent() -> NavigationAgent3D:
	return navigation_agent_3d

var safeNavAgentVelocity:Vector3
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	safeNavAgentVelocity = safe_velocity

func getNavAgentNextPathPosAvoidance() -> Vector3:
	if(!navigation_agent_3d.avoidance_enabled):
		return navigation_agent_3d.get_next_path_position()
	else:
		return global_position + safeNavAgentVelocity*10.0

func getSaveNavAgentVelocity() -> Vector3:
	return safeNavAgentVelocity

func getAI() -> PawnAI:
	return ai

func hasInteraction() -> bool:
	return interaction != null

func getInteraction() -> InteractionBase:
	return interaction

func setInteraction(_int:InteractionBase):
	var oldInteraction := interaction
	interaction = _int
	
	if(oldInteraction != interaction && ai):
		ai.onInteractionChange(interaction)

static func sayArrayToText(theStuff:Array) -> String:
	var result:String = ""
	for stuffEntry in theStuff:
		var entryType:int = stuffEntry[0]
		
		if(!result.is_empty()):
			result += " "
		
		if(entryType == SayType.Speech):
			result += stuffEntry[1]
		if(entryType == SayType.Action):
			result += "*"+stuffEntry[1]+"*"
			
	return result

static func sayArrayToMeText(theStuff:Array) -> String:
	var result:String = ""
	for stuffEntry in theStuff:
		var entryType:int = stuffEntry[0]
		
		if(!result.is_empty()):
			result += " "
		
		if(entryType == SayType.Speech):
			result += "\""+stuffEntry[1]+"\""
		if(entryType == SayType.Action):
			result += stuffEntry[1]
			
	return result

static func sayArrayToChatTextSmart(charName:String, theStuff:Array) -> String:
	if(theStuff.is_empty()):
		return ""
	var firstType:Array = theStuff.front()
	if(firstType[0] == SayType.Speech):
		return charName+": "+sayArrayToText(theStuff)
	elif(firstType[0] == SayType.Action):
		return charName+" "+sayArrayToMeText(theStuff)
	else:
		return "error?"

static func parseMeTextToArray(_theText:String) -> Array:
	var result:Array = []
	
	var curText:String = ""
	var curToken:int = SayType.Action
	
	for theLetter in _theText:
		if(theLetter == "\""):
			if(curText != ""):
				result.append([curToken, curText.strip_edges()])
				curText = ""
			if(curToken == SayType.Action):
				curToken = SayType.Speech
			else:
				curToken = SayType.Action
		else:
			curText += theLetter
	
	if(curText != ""):
		result.append([curToken, curText.strip_edges()])
		curText = ""
	
	return result

static func parseSayTextToArray(_theText:String) -> Array:
	var result:Array = []
	
	var curText:String = ""
	var curToken:int = SayType.Speech
	
	for theLetter in _theText:
		if(theLetter == "*"):
			if(curText != ""):
				result.append([curToken, curText.strip_edges()])
				curText = ""
			if(curToken == SayType.Action):
				curToken = SayType.Speech
			else:
				curToken = SayType.Action
		else:
			curText += theLetter
	
	if(curText != ""):
		result.append([curToken, curText.strip_edges()])
		curText = ""
	
	return result

static func getStuffTalkLen(stuff:Array) -> float:
	var result:float = 0.0
	for stuffEntry in stuff:
		#TODO: Make this depend on amount of speech
		if(stuffEntry[0] == SayType.Speech):
			result = 3.0
	return result

func sayAdvanced(stuff:Array):
	GM.pawnRegistry.sayAdvanced(self, stuff)

func sayAdvancedLocal(stuff:Array):
	# Spread this to nearby dolls to hear?
	#var theText:String = sayArrayToText(stuff)
	
	#if(isDollSpawned()):
		#var theDoll := getDoll()
		
		# Hover text maybe should happen in hear
		# But if the pc isn't controlling a doll, we do it here
		#theDoll.addHoverText(theText)
	
	if(isDollSpawned()):
		var theSpeechTime:float = getStuffTalkLen(stuff)
		if(theSpeechTime > 0.0):
			getDoll().getDoll().doFaceTalkAnim(theSpeechTime)
	
	var nearbyPawns := GM.pawnRegistry.getPawnsNear(global_position, 20.0)
	for theOtherPawn in nearbyPawns:
		#if(theOtherPawn == self):
		#	continue
		theOtherPawn.hearAdvanced(self, stuff)
		#theOtherPawn.addHoverText("I HEAR!")

func hearAdvanced(otherPawn:CharacterPawn, stuff:Array):
	if(isControlledByUs()):
		sendToChatLocal(sayArrayToChatTextSmart(otherPawn.getCharacter().getName(), stuff))
		var theText:String = sayArrayToText(stuff)
		otherPawn.addHoverText(theText)
		
func sendToChatLocal(rawText:String):
	if(isControlledByUs()):
		GameChat.addChat(rawText)

func addHoverText(_text:String):
	if(isDollSpawned()):
		var theDoll := getDoll()
		theDoll.addHoverText(_text)

func playGesture(_gestureID:String):
	if(isDollSpawned()):
		var theDoll := getDoll()
		GM.dollHolder.playGesture(theDoll, _gestureID)

func isFullbodyGesturesBlocked() -> bool:
	var theChar := getCharacter()
	if(!theChar):
		return false
	return theChar.isFullbodyGesturesBlocked()

func isPartialGesturesBlocked() -> bool:
	var theChar := getCharacter()
	if(!theChar):
		return false
	return theChar.isPartialGesturesBlocked()

func teleport(_globalPos:Vector3, _resetSpeed:bool = true):
	global_position = _globalPos
	var theDoll := getDoll()
	if(theDoll):
		theDoll.global_position = _globalPos
		if(_resetSpeed):
			theDoll.velocity = Vector3.ZERO

func isSittingOn(_node:Node3D) -> bool:
	var theSeat := GM.sitManager.getSeatOfPawn(self)
	if(!theSeat):
		return false
	return theSeat.getHandler() == _node

func isSittingSomewhere() -> bool:
	var theSeat := GM.sitManager.getSeatOfPawn(self)
	if(!theSeat):
		return false
	return !!theSeat.getHandler()

func getSitPropHandler() -> PropHandlerBase:
	var theSeat := GM.sitManager.getSeatOfPawn(self)
	if(!theSeat):
		return null
	var theProp := theSeat.getHandler()
	if(!theProp || !(theProp is PropHandlerBase)):
		return null
	return theProp

func getState() -> int:
	return pawnState

func setState(_state:int):
	pawnState = _state
	state = states[_state] if states.has(_state) else stateEmpty
	
	var theDoll := getDoll()
	if(pawnState == STATE_SITTING && theDoll):
		theDoll.velocity = Vector3.ZERO
	
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(setState_RPC.bind(_state))

@rpc("authority", "call_remote", "reliable")
func setState_RPC(_state:int):
	setState(_state)









# LEASH STUFF
const LEASH_TYPE_PAWN = 0

@onready var backup_leash_point: LeashPoint = %BackupLeashPoint

var dollLeashPoints:Dictionary[String, DollLeashPoint] = {}
var leashConnections:Array = []

func registerLeashPoint(_dollLeashPoint:DollLeashPoint):
	var theID:String = _dollLeashPoint.leashPointID
	if(dollLeashPoints.has(theID)):
		#TODO: PROBABLY REMOVE THIS ERROR?
		Log.Printerr("A LEASH POINT WITH ID '"+str(theID)+"' WAS ALREADY REGISTERED IN PAWN "+str(getCharID()))
		var curLeashPoint:DollLeashPoint = dollLeashPoints[theID]
		if(curLeashPoint.leashPointPriority >= _dollLeashPoint.leashPointPriority):
			return
		pass
	
	dollLeashPoints[theID] = _dollLeashPoint
	#print(str(self)+" REGISTERED LEASH POINT "+str(_dollLeashPoint))
	pass

func unregisterLeashPoint(_dollLeashPoint:DollLeashPoint):
	#print(str(self)+" UN-REGISTERED LEASH POINT "+str(_dollLeashPoint))
	var theID:String = _dollLeashPoint.leashPointID
	if(dollLeashPoints.has(theID) && dollLeashPoints[theID] == _dollLeashPoint):
		dollLeashPoints.erase(theID)
	pass
	
func getLeashPoint(_id:String) -> LeashPoint:
	if(!dollLeashPoints.has(_id)):
		if(doll):
			return doll.getBackupDollLeashPoint()
		return backup_leash_point
	return dollLeashPoints[_id]

func getDollLeashPointName(_id:String) -> String:
	if(!dollLeashPoints.has(_id)):
		return _id
	return dollLeashPoints[_id].leashPointName

func isLeashingPawn(_otherPawn:CharacterPawn) -> bool:
	var allLeashes := GM.leashSystem.getAllLeashesOfSourceNode(self)
	for leash in allLeashes:
		if(leash.p2con.isSpecificPawn(_otherPawn)):
			return true
	return false

# LEASH STUFF END

# INTERACTOR STUFF BEGINS
func getPawnInteractor() -> PawnInteractor:
	return pawn_interactor

func getQuickActionsSelf() -> Array[InteractEntryDo]:
	var result:Array[InteractEntryDo] = []
	
	if(true):
		var currentDelayedActions := GM.actionSystem.getAllActionsOfUser(self)
		for entry in currentDelayedActions:
			if(entry.cancelType != ActionSystemEntry.CANCEL_ALLOW):
				continue
			result.append(InteractEntryDo.create("ActionCancel", [entry.uniqueID]))
	
	if(true):
		var currentDelayedActions := GM.actionSystem.getAllActionsOfTargetAll(self)
		for entry in currentDelayedActions:
			var theTarget := entry.getTargetSpecific(self)
			if(theTarget.timerType == ActionSystemEntry.TIMER_MUST_CONSENT):
				result.append(InteractEntryDo.create("ActionAllow", [entry.uniqueID]))
				result.append(InteractEntryDo.create("ActionDeny", [entry.uniqueID]))
			elif(theTarget.timerType == ActionSystemEntry.TIMER_CAN_DENY):
				result.append(InteractEntryDo.create("ActionResist", [entry.uniqueID]))
	
	if(interaction):
		var theInteractActions := interaction.getActionsFor(self)
		
		var _i:int = 0
		for theAction in theInteractActions:
			result.append(InteractEntryDo.create("InteractionAction", [
				theAction.actionName, _i, theAction.id,
			]))
			_i += 1
	
	#var theContext := pawnActionContext
	#theContext.clearContext()
	for pawnAction in GlobalRegistry.pawnQuickActionsAlwaysSelf:
		#if(!pawnAction.canDoAction(theContext)):
		#	continue
		result.append(InteractEntryDo.create(pawnAction.id))
	
	var theContext := pawnActionContext
	theContext.target = self
	
	var resAm:int = result.size()
	for _i in resAm:
		var _indx:int = resAm - _i - 1
		var theEntry := result[_indx]
		theContext.args = theEntry.args
		
		if(!theEntry.action.canStartAction(theContext)):
			result.remove_at(_indx)
	theContext.clearContext()
	
	return result

# self is target in this case
func getQuickActions(_actor:CharacterPawn) -> Array[InteractEntryDo]:
	var result:Array[InteractEntryDo] = []
	
	#var theContext := _actor.pawnActionContext
	#theContext.clearContext()
	#theContext.target = self
	for pawnAction in GlobalRegistry.pawnQuickActionsAlwaysOtherPawn:
		#if(!pawnAction.canDoAction(theContext)):
		#	continue
		result.append(InteractEntryDo.create(pawnAction.id))
	#theContext.target = null
	
	var theContext := _actor.pawnActionContext
	theContext.target = self
	
	var resAm:int = result.size()
	for _i in resAm:
		var _indx:int = resAm - _i - 1
		var theEntry := result[_indx]
		theContext.args = theEntry.args
		
		if(!theEntry.action.canStartAction(theContext)):
			result.remove_at(_indx)
	theContext.clearContext()
	
	return result

func getInteractEntriesSelf() -> Array[InteractEntryBase]:
	var result:Array[InteractEntryBase] = []
	
	result.append(InteractEntryText.create("You are "+str(getCharacter().getFullName())))
	
	#var theContext := pawnActionContext
	#theContext.clearContext()
	for pawnAction in GlobalRegistry.pawnActionsAlwaysSelf:
		#if(!pawnAction.canDoAction(theContext)):
		#	continue
		result.append(InteractEntryDo.create(pawnAction.id))
	
	return result

# self is target in this case
func getInteractEntries(_actor:CharacterPawn) -> Array[InteractEntryBase]:
	var result:Array[InteractEntryBase] = []
	
	#var theContext := _actor.pawnActionContext
	#theContext.clearContext()
	#theContext.target = self
	for pawnAction in GlobalRegistry.pawnActionsAlwaysOtherPawn:
		#if(!pawnAction.canDoAction(theContext)):
		#	continue
		result.append(InteractEntryDo.create(pawnAction.id))
	#theContext.target = null
	
	#result.append(InteractEntryDo.create(
		#"Leash", "leash"
	#))
	var theChar := getCharacter()
	for leashpointID in theChar.getAllLeashingPoints():
		result.append(InteractEntryDo.create("LeashSpecific", [leashpointID]))
	
	return result

func askDoInteractEntryDo(_entry:InteractEntryDo, _target):
	doInteractEntryDo(_entry, _target)

func doInteractEntryDoByIndex(_indx:int, _target, _actionID:String):
	var theEntry:InteractEntryDo = pawn_interactor.findInteractEntryDo(_indx, _target, _actionID)
	if(!theEntry):
		Log.Printerr("Interact entry not found: Indx="+str(_indx)+", Action id="+_actionID)
		return
	
	doInteractEntryDo(theEntry, _target)
	pass

func doInteractEntryDo(_entry:InteractEntryDo, _target) -> bool:
	#Only support self actions for now
	#if(_entry.user != self):
		#_entry.user.askDoInteractEntryDo(_entry)
		#return
	var theAction:PawnActionBase = _entry.action
	
	if(!theAction):
		return false
	
	updateDelayedActionCache()
	
	pawnActionContext.args = _entry.args
	pawnActionContext.target = _target#_entry.target
	
	if(!theAction.canStartAction(pawnActionContext)):
		pawnActionContext.args = []
		pawnActionContext.target = null
		return false
	#Log.Print("DOING AN ACTION!!!")
	var theRes := theAction.doAction(pawnActionContext)
	pawnActionContext.clearContext()
	return theRes

func isInInteractRangeOf(_node:Node) -> bool:
	if(!_node):
		return false
	if(_node == self):
		return true
	
	if(_node is CharacterPawn):
		var otherPawnInteractor:PawnInteractor = _node.pawn_interactor
		if(pawn_interactor.nearbyPawns.has(otherPawnInteractor)):
			return true
	
	if(_node is Node3D):
		for interactable in pawn_interactor.interactables:
			if(interactable.target == _node):
				return true
	
	return false

func getActionSystemSpeed() -> Vector3:
	var theDoll := getDoll()
	if(!theDoll):
		return Vector3(0.0, 0.0, 0.0)
	var theResult := theDoll.velocity
	theResult.y = 0.0
	return theResult

var isDoingAnyDelayedActionCached:bool = false
var isTargetOfAnyDelayedActionsCached:bool = false

func updateDelayedActionCache():
	isDoingAnyDelayedActionCached = !GM.actionSystem.getAllActionsOfUser(self).is_empty()
	isTargetOfAnyDelayedActionsCached = !GM.actionSystem.getAllActionsOfTarget(self).is_empty()

func isDoingAnyDelayedActions() -> bool:
	return isDoingAnyDelayedActionCached

func isTargetOfAnyDelayedActions() -> bool:
	return isTargetOfAnyDelayedActionsCached

var progressBarsValuesCached:Array[float]
var progressBarsTextsCached:Array[String]

@export var progressBarsData:PackedByteArray: set = onSyncProgressData

func onSyncProgressData(_data:PackedByteArray):
	progressBarsData = _data
	
	var newProgressBarsValues:Array[float]
	var newProgressBarsTexts:Array[String]
	
	var theData := Bins.readUncompressed(_data)
	theData.loadStart()
	var theAm:int = theData.readU16()
	for _i in theAm:
		var theValue := theData.readFloat()
		var theText := theData.readStrShort()
		newProgressBarsValues.append(theValue)
		newProgressBarsTexts.append(theText)
	theData.endLoad()

	progressBarsValuesCached = newProgressBarsValues
	progressBarsTextsCached = newProgressBarsTexts

func calcHoverTextProgressBarInfo():
	if(!Network.isServer()):
		return
	var newProgressBarsValues:Array[float]
	var newProgressBarsTexts:Array[String]
	
	var theActions := GM.actionSystem.getAllActionsOfUser(self)
	for theAction in theActions:
		var theValue := theAction.getProgressValue()
		var theText := theAction.getActionText()
		
		newProgressBarsValues.append(theValue)
		newProgressBarsTexts.append(theText)
	
	progressBarsValuesCached = newProgressBarsValues
	progressBarsTextsCached = newProgressBarsTexts
	
	if(Network.isServerNotSingleplayer()):
		var theData:Array = [
			Bins.U16, progressBarsValuesCached.size(),
		]
		for _i in progressBarsValuesCached.size():
			theData.append_array([
				Bins.Float, progressBarsValuesCached[_i],
				Bins.StrShort, progressBarsTextsCached[_i],
			])
		var theBins:Bins = Bins.saveStartEnd(theData)
		progressBarsData = theBins.getBytes()

func getLeashedPawns() -> Array[CharacterPawn]:
	var result:Array[CharacterPawn]
	
	var allLeashes := GM.leashSystem.getAllLeashesOfSourceNode(self)
	for theLeash in allLeashes:
		if(theLeash.isTargetAPawn()):
			result.append(theLeash.getTargetPawn())

	return result

# INTERACTOR STUFF ENDS
