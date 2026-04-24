extends Node3D
class_name SexEngine

@onready var tweaker: Node3D = %Tweaker
@onready var free_camera: PriorityCamera = %FreeCamera
@onready var fixed_camera_pivot: Node3D = %FixedCameraPivot
@onready var spring_arm: SpringArm3D = %SpringArm
@onready var fixed_camera: PriorityCamera = %FixedCamera

@onready var anim_scene_player: AnimScenePlayer = %AnimScenePlayer

const STATE_NORMAL = 0 # We can do actions?
const STATE_BUSY = 1 # We're waiting for a delayed action
const STATE_CONSENT = 2 # We're waiting for someone to agree

@export var state:int = STATE_NORMAL
@export var transitionTimer:float = 0.0
@export var transitionTimerFull:float = 0.0
@export var gripLevel:float = 0.5

const ACTION_SEX_ACTION = 1
const ACTION_CONSENT = 2
const ACTION_DENY_CONSENT = 3
const ACTION_CANCEL = 4
const ACTION_CONSENT_ALWAYS = 5
const ACTION_RESIST = 6
const ACTION_FORCE = 7
const ACTION_TARGET = 8
const ACTION_END_SEX = 9

var actionsCache:Dictionary[String, Array] = {} # Dictionary[String, Array[SexEngineAction]]
@export var actionsNetworked:Dictionary = {}

@onready var resistMinigame: ResistMinigameNode = %ResistMinigameNode
@onready var hover_text: Label3D = %HoverText
@onready var hover_text_poser: Node3D = %HoverTextPoser

# char id = sex info
var participants:Dictionary[String, SexParticipantInfo] = {}

# Replace with nodepaths?
var props:Dictionary[String, Node3D]

var sexActivity:SexMainActivity
var sexType:SexTypeBase
var sideActivities:Array[SexSideActivity] = []

const MODE_NORMAL = 0
const MODE_FORCED = 1

var sexMode:int = MODE_NORMAL

const CAMERA_LOCKED = 0
const CAMERA_FREE = 1
const CAMERA_FPS = 2
var cameraMode:int = CAMERA_LOCKED

signal onAnimSceneSwitched
signal onParticipantUpdate(charID)
signal onSexChange(_change:SexEngineChange)

var actionTexts:Array = []
@export var actionText:String = ""
@export var cachedHoverText:String = ""
var hoverTextLocalTargetPos:Vector3 = Vector3()

var cooldowns:Dictionary[String, float] = {}
var tempItemUIDs:Array[int] = []
var itemBelong:Dictionary[int, String] = {} # item uid = char id
var savedCharPositions:Dictionary[String, Vector3]
var timeSinceAnyActions:float = 0.0
var lostGrip:bool = false

var eventQueue:Array[SexEngineQueueEntry] = []

var dialogue:SexDialogueHandler

const ENGINE_STATE_SEX := 0
const ENGINE_STATE_END_PC_WAIT := 1 # Waiting for any player participant to press 'Continue'
const ENGINE_STATE_ENDING := 2 # The timer before the sex actually gets ended and deleted
var sexEngineState:int = ENGINE_STATE_SEX
var sexResult:SexEngineResult
var endOfSexTimer:float = 0.0
const END_OF_SEX_TIME := 2.0
var wasDeleted:bool = false
@export var sexResultText:String

# event queue stuff
const QUEUE_DELAY = 0
const QUEUE_EVENT = 1
const QUEUE_AUTOACTION = 2
const QUEUE_ACTIONTEXT = 3
const QUEUE_DELAY_CANCANCEL = 4
const QUEUE_CANCEL_STOPPER = 5
const QUEUE_CANCEL_CATCHER = 6
const QUEUE_SET_STATE = 7
const QUEUE_CONSENT_CHECK = 8
const QUEUE_START_MAIN_ACTIVITY = 9
const QUEUE_START_SIDE_ACTIVITY = 10
const QUEUE_RESIST_MINIGAME = 11
const QUEUE_EXPOSE = 12
const QUEUE_COMMENT_ON_ACTION = 13

const JUST_SKIP_QUEUE_TYPES = [
	QUEUE_CANCEL_STOPPER,
	QUEUE_CANCEL_CATCHER,
]

var autoEquipAfterEndItems:Dictionary[String, Array] = {} #charID = [slot, unique item id]

func pushToQueue(_obj, _entry:SexEngineQueueEntry):
	eventQueue.append(_entry.setObj(_obj))

func isQueueBusy() -> bool:
	return !eventQueue.is_empty()

func processEventQueue(_dt:float):
	if(eventQueue.is_empty()):
		return
	
	while(!eventQueue.is_empty()):
		var queueEntry:SexEngineQueueEntry = eventQueue[0]
		var _entryObj := queueEntry.obj
		
		if((queueEntry is SexEngineQueueEntry.Delay) || (queueEntry is SexEngineQueueEntry.DelayCanCancel)):
			queueEntry.elapsedTime += _dt
			if(queueEntry.elapsedTime >= queueEntry.time):
				eventQueue.pop_front()
				continue
			else:
				break
		elif(queueEntry is SexEngineQueueEntry.Event):
			eventQueue.pop_front()
			_entryObj.doEventFinal(queueEntry.state, queueEntry.event)
		elif(queueEntry is SexEngineQueueEntry.AutoAction):
			eventQueue.pop_front()
			_entryObj.doActionFinalCustomState(queueEntry.state, queueEntry.role, queueEntry.actionID, queueEntry.args)
		elif(queueEntry is SexEngineQueueEntry.ActionText):
			eventQueue.pop_front()
			_entryObj.addActionText(queueEntry.text)
		elif(queueEntry is SexEngineQueueEntry.CommentOnAction):
			eventQueue.pop_front()
			var theStarterInfo := getParticipant(queueEntry.starterID)
			var theTargetInfo := getParticipant(queueEntry.targetID)
			if(theStarterInfo && theTargetInfo):
				theStarterInfo.ai.addCommentTopic(queueEntry.targetID, queueEntry.line)
		elif(queueEntry is SexEngineQueueEntry.SetState):
			eventQueue.pop_front()
			_entryObj.setState(queueEntry.state)
		elif(queueEntry is SexEngineQueueEntry.ConsentCheck):
			if(hasEveryoneConsent(_entryObj, queueEntry.needToConsent)):
				eventQueue.pop_front()
				#addActionTextRaw("Consent gotten!")
				continue
			
			if(queueEntry.resisted):
				resistMinigame.updateMinigame(_dt)
				break
			var theMaxTimer:float = queueEntry.delay if !isForced() else queueEntry.delayForced
			
			queueEntry.delayElapsed += _dt
			if(queueEntry.delayElapsed >= theMaxTimer):
				if(hasEveryoneConsentEndCheck(_entryObj, queueEntry.needToConsent)):
					eventQueue.pop_front()
					#addActionTextRaw("Consent gotten!")
					continue
				else:
					eventQueue.pop_front()
					addActionTextRaw("Couldn't get consent!")
					cancelQueue()
					
					var theInfo := getInfo(queueEntry.starterID)
					if(theInfo):
						theInfo.ai.onConsentIgnore(queueEntry)
					
					continue
			else:
				break
		elif(queueEntry is SexEngineQueueEntry.StartActivity):
			eventQueue.pop_front()
			if(queueEntry.isMain):
				startMainActivity(queueEntry.activityID, queueEntry.roles, queueEntry.args)
			else:
				startSideActivity(queueEntry.activityID, queueEntry.roles, queueEntry.args)
		elif(queueEntry is SexEngineQueueEntry.ResistMinigameStart):
			if(!queueEntry.started):
				startResistMinigame(1.0, 2.0)
				queueEntry.started = true
			resistMinigame.updateMinigame(_dt)
			break
		elif(queueEntry is SexEngineQueueEntry.Expose):
			doExposeFetish(queueEntry.giverID, queueEntry.receiverID, queueEntry.fetishID, queueEntry.intensity)
			eventQueue.pop_front()
		elif(queueEntry.justSkip):
			eventQueue.pop_front()
		else:
			assert(false, "Unknown queue element type: "+str(queueEntry.type))
	
	if(eventQueue.is_empty()):
		notifyThingHappened()
	
func calcTransitionTimer():
	transitionTimer = 0.0
	transitionTimerFull = 0.0
	if(sexEngineState == ENGINE_STATE_ENDING):
		transitionTimer = endOfSexTimer
		transitionTimerFull = END_OF_SEX_TIME
		return
	
	if(eventQueue.is_empty()):
		return
	for queueBigEntry:SexEngineQueueEntry in eventQueue:
		var _entryObj := queueBigEntry.obj
		#var queueType:int = queueBigEntry.type
		
		if(queueBigEntry is SexEngineQueueEntry.Delay):
			transitionTimer += maxf(queueBigEntry.elapsedTime, 0.0)
			transitionTimerFull += maxf(queueBigEntry.time, 0.0)
			return
		if(queueBigEntry is SexEngineQueueEntry.DelayCanCancel):
			transitionTimer += maxf(queueBigEntry.elapsedTime, 0.0)
			transitionTimerFull += maxf(queueBigEntry.time, 0.0)
			return
		if(queueBigEntry is SexEngineQueueEntry.ConsentCheck):
			if(queueBigEntry.resisted):
				return
			transitionTimer += maxf(queueBigEntry.delayElapsed, 0.0)
			var theMaxTimer:float = queueBigEntry.delay if !isForced() else queueBigEntry.delayForced
			transitionTimerFull += maxf(theMaxTimer, 0.0)
			return
		
# event queue stuff end


func start(sexTypeID:String, roles:Dictionary, args:Dictionary = {}):
	if(args.has("sexMode")):
		sexMode = args["sexMode"]
	
	dialogue = SexDialogueHandler.new()
	dialogue.setSex(self)
	
	var theSexType:SexTypeBase = GlobalRegistry.createSexActivity(sexTypeID)
	theSexType.setSexEngine(self)
	sexType = theSexType
	sexType.start(roles, args)
	
	GI.networkedNodes.notifySpawned(self)
	sexType.onStartFinal()

	for charID in participants:
		participants[charID].onSexStart()
	process_timer.start(0.1)

func addParticipant(theID:String, theRole:int) -> SexParticipantInfo:
	var newInfo:SexParticipantInfo = SexParticipantInfo.new()
	newInfo.id = theID
	newInfo.role = theRole
	newInfo.setSexEngine(self)
	
	addParticipantInfo(newInfo)
	return newInfo

func addParticipantInfo(_info:SexParticipantInfo):
	var thePawn := GM.pawnRegistry.getPawn(_info.id)
	if(!thePawn):
		Log.error("SexEngine.addParticipantInfo() can't find pawn! ID="+str(_info.id))
		return
	if(thePawn.getDoll()):
		GM.main.doll_holder.askLookAtClear(thePawn.getDoll())
	
	savedCharPositions[_info.id] = thePawn.global_position
	participants[_info.id] = _info
	onParticipantUpdate.emit(_info.id)
	onSexChange.emit(SexEngineChange.makeParticipantUpdate(_info.id))

func getParticipant(theID:String) -> SexParticipantInfo:
	if(!participants.has(theID)):
		return null
	return participants[theID]

func getParticipants() -> Dictionary[String, SexParticipantInfo]:
	return participants

func getInfo(theID:String) -> SexParticipantInfo:
	if(!participants.has(theID)):
		return null
	return participants[theID]

func addProp(propID:String, theNode:Node3D):
	props[propID] = theNode

func getProp(_propID:String) -> Node3D:
	if(!props.has(_propID)):
		return null
	return props[_propID]

func _process(_delta: float) -> void:
	processCamera(_delta)
	hover_text_poser.position = hover_text_poser.position*0.9 + hoverTextLocalTargetPos*0.1
	
#func _physics_process(_delta: float) -> void:
	#if(Network.isServer()):
		#if(sexType):
			#sexType.doProcessFinal(_delta)
		#if(sexActivity):
			#sexActivity.doProcessFinal(_delta)

func updateActions():
	# action cache update
	var newNetworkActions:Dictionary = {}
	actionsCache.clear()
	for charID in participants:
		actionsCache[charID] = calculateActions(charID)
		newNetworkActions[charID] = calculateNetworkActions(actionsCache[charID])
	actionsNetworked = newNetworkActions

func checkPawnsExist() -> bool:
	for charID in participants:
		if(!GM.pawnRegistry.hasPawn(charID)):
			Log.Printerr("Pawn doesn't exist: "+str(charID)+". Stopping sex.")
			removeSex()
			return false
	return true

func doProcessAlways(_delta: float) -> void:
	var theIsServer:bool = Network.isServer()
	if(theIsServer):
		processEventQueue(_delta)
		calcTransitionTimer()
		processCooldowns(_delta)

func doProcessAlwaysAfter(_delta:float) -> void:
	var theIsServer:bool = Network.isServer()
	# Sync all participant data
	if(Network.isServerNotSingleplayer()):
		for charID in participants:
			var theInfo := participants[charID]
			if(theInfo.ai):
				var aiSyncState := theInfo.ai.syncState
				if(aiSyncState.getDirtyTime() > 0.5):
					var theDelta := aiSyncState.getDelta()
					Network.rpcClients(syncInfoAIState_RPC.bind(charID, theDelta))
					aiSyncState.resetDelta()

	if(theIsServer):
		# action cache update
		updateActions()
		
		# action text update
		var textsAmount:int = actionTexts.size()
		for _i in range(textsAmount):
			var theEntry:Array = actionTexts[textsAmount - _i - 1]
			theEntry[1] -= _delta
			if(theEntry[1] <= 0.0):
				actionTexts.remove_at(textsAmount - _i - 1)
			
		actionText = calculateActionText()
		cachedHoverText = actionText#calculateHoverText()
	
	if(isResistMinigameRunning()):
		for charID in participants:
			var theInfo := participants[charID]
			if(!theInfo):
				continue
			var theID := theInfo.getID()
			var thePawn := GM.pawnRegistry.getPawn(theID)
			if(!thePawn):
				continue
			var theDoll := thePawn.getDoll()
			if(!theDoll):
				continue
			theDoll.doStruggleAnimFor(0.5)
	
	hover_text.text = parseText(cachedHoverText)
	hoverTextLocalTargetPos = to_local(anim_scene_player.getAverageBodyPos())

func doProcessSexState(_delta:float) -> void:
	var theIsServer:bool = Network.isServer()
	timeSinceAnyActions += _delta
	
	if(sexType):
		sexType.doProcessFinal(_delta)
	if(sexActivity):
		sexActivity.doProcessFinal(_delta)
	
	if(theIsServer):
		if(resistMinigame.isDisabled() && !hasNoGripRecoverCooldown()):
			gripLevel += 0.03 * _delta
			if(gripLevel >= 1.0):
				gripLevel = 1.0
		
		for charID in participants:
			var theInfo := participants[charID]
			theInfo.processInfo(_delta)
	
	if(theIsServer):
		checkGripLevel()

func doProcessWaitingForPCState(_delta:float) -> void:
	if(!isAnyParticipantControlledByPlayer()):
		sexEngineState = ENGINE_STATE_ENDING

func doProcessSexEnding(_delta:float) -> void:
	endOfSexTimer += _delta
	if(endOfSexTimer >= END_OF_SEX_TIME):
		removeSex()

func doProcess(_delta: float) -> void:
	var theIsServer:bool = Network.isServer()
	if(theIsServer):
		if(!checkPawnsExist()):
			return
	doProcessAlways(_delta)
	if(wasDeleted):
		return

	if(sexEngineState == ENGINE_STATE_SEX):
		doProcessSexState(_delta)
	elif(sexEngineState == ENGINE_STATE_END_PC_WAIT):
		doProcessWaitingForPCState(_delta)
	elif(sexEngineState == ENGINE_STATE_ENDING):
		doProcessSexEnding(_delta)
	
	if(wasDeleted):
		return
	doProcessAlwaysAfter(_delta)
	
func getSexEngineState() -> int:
	return sexEngineState

@rpc("authority", "call_remote", "reliable")
func syncInfoAIState_RPC(_charID:String, _delta:PackedByteArray):
	var theInfo := getInfo(_charID)
	if(!theInfo):
		return
	if(theInfo.ai):
		theInfo.ai.syncState.applyDelta(_delta)

const NET_FLAG_DISABLED := 1
const NET_FLAG_EXTRA := 2

func calculateNetworkActions(theActions:Array[SexEngineAction]) -> Array:
	var result:Array = []
	
	var _i:int = 0
	for actionEntry:SexEngineAction in theActions:
		var theFlags:int = 0
		if(actionEntry.disabled):
			theFlags |= NET_FLAG_DISABLED
		if(actionEntry.extraButton):
			theFlags |= NET_FLAG_EXTRA
		
		result.append([
			#       0           1                2                        3
			actionEntry.name, theFlags, actionEntry.getCategory(), actionEntry.type,
		])
		#result.append({
			#i = _i,
			#name = actionEntry.name,
			#f = theFlags,
			#cat = actionEntry.getCategory(),
			#t = actionEntry.type,
		#})
		_i += 1
	
	return result

func getExpressionState(charID:String) -> int:
	if(sexActivity):
		return sexActivity.getExpressionStateForCharID(charID)
	if(sexType):
		return sexType.getExpressionStateForCharID(charID)
	
	return DollExpressionState.IgnoreChange

func calculateActions(charID:String) -> Array[SexEngineAction]:
	if(!participants.has(charID)):
		return []
	var _info := getParticipant(charID)
	var isSexEngineBusy:bool = isBusy()
	var _charCanDoDomActions:bool = canDoDomActions(charID)
	
	var result:Array[SexEngineAction] = []
	var curOverridePrio:int = 0
	
	if(sexEngineState == ENGINE_STATE_END_PC_WAIT):
		result.clear()
		var theAction := SexEngineAction.createGeneric(ACTION_END_SEX, "Continue")
		result.append(theAction)
		return result
	if(sexEngineState == ENGINE_STATE_ENDING):
		return []
	
	if(!eventQueue.is_empty()):
		result.append_array(SexEngineAction.createFromQueueEntry(self, eventQueue[0], charID))
	
	if(_info.shouldShowSetTargetButton()): # only player? only if there are > 2 targets
		var curTargetID:String = _info.targetID
		var theCharacter := GM.main.characterRegistry.getCharacter(curTargetID)
		var theTargetName:String = theCharacter.getName() if theCharacter else "Unknown?"
		if(curTargetID == _info.getID()):
			theTargetName = "You"
		var theAction := SexEngineAction.createGeneric(ACTION_TARGET, "Target: "+theTargetName, null)
		theAction.extraButton = true
		theAction.priority = -995.5
		result.append(theAction)
	
	if(!isSexEngineBusy):
		var toProcess:Array[SexEngineActivityBase] = [sexType, sexActivity]
		toProcess.append_array(sideActivities)
		for theSexActivity in toProcess:
			if(!theSexActivity):
				continue
			var theActions := theSexActivity.getActionsForCharID(charID)
			for actionEntry in theActions:
				var theOverridePrio:int = actionEntry.overridePriority
				if(theOverridePrio > curOverridePrio):
					curOverridePrio = theOverridePrio
					result.clear()
				
				if(theOverridePrio < curOverridePrio):
					continue
				result.append(SexEngineAction.createFromSexAction(actionEntry, theSexActivity))
	
	# Can't do it, no target. Dialogue needs a target
	#if(!_info.ai.getCommentTopics(_target.getID()).is_empty()):
	#	addAction(action("Comment").setAllowBusy(true).setScore(1.25).setRoles({ROLE_USER:_info, ROLE_TARGET:_target}).setCooldown("talk", 10.0).start(id, {ROLE_USER:_info, ROLE_TARGET:_target}, {action="comment"}))
	
	result.sort_custom(sortSexEngineActions)
	return result

# Higher priority actions go first
func sortSexEngineActions(a:SexEngineAction, b:SexEngineAction):
	if a.priority > b.priority:
		return true
	return false

# Subs consent if no answer if forced
func hasConsentIfNoAnswer(_charID:String) -> bool:
	if(!isForced()):
		return false
	var theInfo := getInfo(_charID)
	if(!theInfo):
		return false
	return !theInfo.canDoDomActions()

func hasAutoConsent(_charID:String) -> bool:
	var theInfo := getInfo(_charID)
	if(!theInfo):
		return false
	return theInfo.isAutoConsent()

func shouldConsent(_charID:String) -> bool:
	if(hasAutoConsent(_charID)):
		return false
	if(!eventQueue.is_empty()):
		var queueEntry:SexEngineQueueEntry = eventQueue[0]
		var _entryObj := queueEntry.obj
		
		if(queueEntry is SexEngineQueueEntry.ConsentCheck):
			if(queueEntry.needToConsent.has(_charID) && !queueEntry.needToConsent.get(_charID, false)):
				return true
	return false
	
func hasEveryoneConsent(_activity, _needConsent:Dictionary[String, bool]) -> bool:
	for _charID in _needConsent:
		if(!participants.has(_charID)): # Char went away
			continue
		if(_needConsent[_charID]): # We've gotten consent from this char id
			continue
		if(shouldConsent(_charID)):
			return false
	return true
	
func hasEveryoneConsentEndCheck(_activity, _needConsent:Dictionary[String, bool]) -> bool:
	for _charID in _needConsent:
		if(!participants.has(_charID)): # Char went away
			continue
		if(_needConsent[_charID]): # We've gotten consent from this char id
			continue
		if(hasConsentIfNoAnswer(_charID)):
			continue
		if(shouldConsent(_charID)):
			return false
	return true

#func shouldKeepAction(charID:String, actionEntry:Dictionary, SexMainActivity:SexEngineActivityBase) -> bool:
	#var theMods:Dictionary = actionEntry["mods"] if actionEntry.has("mods") else {}
	#
	#if(theMods.has(SexActionMod.ROLES)):
		#if(isConsensual()):
			#pass
		#elif(!(SexMainActivity.getRoleFromID(charID) in theMods[SexActionMod.ROLES])):
			#return false
	#
	#return true

func getActions(charID:String) -> Array:
	if(!actionsNetworked.has(charID)):
		return []
	return actionsNetworked[charID]

func askSelectAction(charID:String, _i:int, networkedAction:Array):
	if(Network.isServer()):
		doActionNetworked(charID, _i, networkedAction)
	else:
		doActionNetworked.rpc_id(1, charID, _i, networkedAction)

@rpc("any_peer", "call_remote", "reliable")
func doActionNetworked(charID:String, _i:int, networkedAction:Array):
	if(!actionsCache.has(charID)):
		Log.Printerr("SexEngine: No key found in actions cache for "+str(charID))
		return
	if(networkedAction.size() < 4):
		Log.Printerr("SexEngine: Network action too small. Corrupt network action?")
		return
	#if(!networkedAction.has("i")):
	#	Log.Printerr("SexEngine: No action index found. Corrupt network action?")
	#	return
	#var _i:int = networkedAction["i"]
	var theActions:Array[SexEngineAction] = actionsCache[charID]
	if(theActions.is_empty()):
		return
	if(_i < 0 || _i >= theActions.size()):
		return
	
	var theNType:int = networkedAction[3] if networkedAction[3] is int else -1
	var theNName:String = networkedAction[0] if networkedAction[0] is String else "ERROR?"
	
	var action:SexEngineAction = theActions[_i]
	if(action.type != theNType): # Sanity check
		Log.Printerr("SexEngine: bad action type. Corrupt/Old network action?")
		return
	if(action.name != theNName): # Sanity check
		Log.Printerr("SexEngine: bad action name. Corrupt/Old network action?")
		return
	doAction(charID, action)

func doAction(charID:String, action:SexEngineAction):
	doActionInternal(charID, action)

func doActionInternal(charID:String, action:SexEngineAction):
	if(action.disabled):
		return
	#actionsCache.clear()
	#actionsNetworked.clear()
	timeSinceAnyActions = 0.0
	
	# all id checks go here
	
	var actionID:int = action.type
	if(actionID == ACTION_SEX_ACTION):
		var theAction:SexAction = action.sexAction
		var theActivity:SexEngineActivityBase = action.activity
		if(!theActivity):
			Log.Printerr("Tried to do a sex action that isn't attached to a sex activity! action="+str(action.type))
			return
		theActivity.doSexActionForCharID(charID, theAction)
		notifyThingHappened()
	elif(actionID == ACTION_CANCEL):
		cancelQueue(charID)
		addActionText("{user.You} {user.youVerb decide} to cancel the action!", {user=charID})
		notifyThingHappened()
	elif(actionID == ACTION_CONSENT):
		if(eventQueue.is_empty()):
			return
		var queueEntry:SexEngineQueueEntry = eventQueue[0]
		if(queueEntry is SexEngineQueueEntry.ConsentCheck):
			queueEntry.needToConsent[charID] = true
			addActionText("{user.You} {user.youVerb consent}!", {user=charID})
	elif(actionID == ACTION_DENY_CONSENT):
		if(eventQueue.is_empty()):
			return
		var queueEntry:SexEngineQueueEntry = eventQueue[0]
		if(queueEntry is SexEngineQueueEntry.ConsentCheck):
			cancelQueue(charID)
			addActionText("{user.You} didn't consent!", {user=charID})
			if(queueEntry.obj is SexEngineActivityBase):
				var theActivity:SexEngineActivityBase = queueEntry.obj
				theActivity.onConsentDeniedBy(charID, queueEntry)
			notifyThingHappened()
	elif(actionID == ACTION_FORCE):
		if(canDoDomActions(charID)):
			setSexMode(MODE_FORCED)
			if(eventQueue.is_empty()):
				return
			var queueEntry:SexEngineQueueEntry = eventQueue[0]
			if(queueEntry is SexEngineQueueEntry.ConsentCheck):
				queueEntry.delayElapsed = 0.0
			notifyThingHappenedNeedsReaction()
	elif(actionID == ACTION_RESIST):
		if(eventQueue.is_empty()):
			return
		var queueEntry:SexEngineQueueEntry = eventQueue[0]
		if(queueEntry is SexEngineQueueEntry.ConsentCheck):
			#cancelQueue(charID)
			queueEntry.resisted = true
			addActionText("{user.You} {user.youVerb resist}!", {user=charID})
			
			startResistMinigame(1.0, 2.0)
			notifyThingHappenedNeedsReaction()
		
	elif(actionID == ACTION_CONSENT_ALWAYS):
		var theInfo := getInfo(charID)
		if(theInfo):
			theInfo.autoConsent = true
			theInfo.syncUserOptions()
		#askSetParticipantAutoConsent(charID, true)
			#theInfo.autoConsent = true
			#theInfo.syncMe()
	elif(actionID == ACTION_TARGET):
		var theInfo := getInfo(charID)
		if(theInfo):
			theInfo.switchToNextTarget()
	elif(actionID == ACTION_END_SEX):
		if(sexEngineState == ENGINE_STATE_END_PC_WAIT):
			sexEngineState = ENGINE_STATE_ENDING
	
	processEventQueue(0.0) # To potentially clear out the queue
	updateActions()

func startResistMinigame(_domSpeedMult:float, _subSpeedMult:float):
	var _doms:Array[String] = []
	var _subs:Array[String] = []
	
	for theCharID in participants:
		#var theInfo:SexParticipantInfo = participants[theCharID]
		if(canDoDomActions(theCharID)):
			_doms.append(theCharID)
		else:
			_subs.append(theCharID)
	resistMinigame.setTeams("Doms" if _doms.size() != 1 else "Dom", _doms, "Subs" if _subs.size() != 1 else "Sub", _subs)
	resistMinigame.startMinigame(_domSpeedMult, _subSpeedMult)
	

func cancelQueue(_charID:String = ""):
	while(!eventQueue.is_empty()):
		var queueEntry:SexEngineQueueEntry = eventQueue[0]
		eventQueue.pop_front()
		var _entryObj := queueEntry.obj
		if(queueEntry is SexEngineQueueEntry.CancelStopper):
			break
		#elif(queueType == QUEUE_CANCEL_CATCHER):
			#_entryObj.doActionFinalCustomState(queueEntry[1], _entryObj.getRoleFromID(charID), queueEntry[2], queueEntry[3])
			#
			#break
		elif(queueEntry is SexEngineQueueEntry.CancelCatcher):
			_entryObj.doEventFinal(queueEntry.state, queueEntry.event)
			break

func startMainActivity(activityID:String, _roles:Dictionary, _args:Dictionary = {}) -> SexMainActivity:
	if(sexActivity):
		stopMainActivity()
	var theActivity:SexMainActivity = GlobalRegistry.createSexActivity(activityID)
	if(!theActivity):
		return null
	theActivity.setSexEngine(self)
	sexActivity = theActivity
	sexActivity.start(_roles, _args)
	#TODO: some syncing here?
	sexActivity.onStartFinal()
	return sexActivity
	
func stopMainActivity():
	if(!sexActivity):
		return
	var savedActivityID:String = sexActivity.id
	sexActivity = null
	sexType.onMainActivityEnded(savedActivityID)

func getSexActivity() -> SexMainActivity:
	return sexActivity

func hasMainActivity() -> bool:
	if(sexActivity):
		return true
	return false

func startSideActivity(activityID:String, _roles:Dictionary, _args:Dictionary = {}) -> SexSideActivity:
	var theActivity:SexSideActivity = GlobalRegistry.createSexActivity(activityID)
	if(!theActivity):
		return null
	theActivity.setSexEngine(self)
	sideActivities.append(theActivity)
	theActivity.start(_roles, _args)
	#TODO: some syncing here?
	theActivity.onStartFinal()
	return theActivity

func stopActivity(theActivity:SexEngineActivityBase):
	if(!theActivity):
		return
	theActivity.wasDeleted = true
	if(theActivity == sexActivity):
		stopMainActivity()
		return
	if(!sideActivities.has(theActivity)):
		return
	#var savedActivityID:String = sexActivity.id
	#sexActivity = null
	#sexType.onMainActivityEnded(savedActivityID)
	sideActivities.erase(theActivity) #onSideActivityEnded?

func getSexType() -> SexTypeBase:
	return sexType

func getSexTypeID() -> String:
	return sexType.id if sexType else ""

func isBusy() -> bool:
	return isQueueBusy()

func getProgressBarValue() -> float:
	if(transitionTimerFull > 0.0):
		return transitionTimer/transitionTimerFull
	return -1.0

func getFreeCameraMode() -> int:
	return cameraMode

func setCameraMode(newCameraMode:int):
	if(newCameraMode == CAMERA_FREE && cameraMode == CAMERA_LOCKED):
		free_camera.global_position = fixed_camera.global_position
		free_camera.global_rotation = fixed_camera.global_rotation
		free_camera.fov = fixed_camera.fov
	cameraMode = newCameraMode

func isLocalPCInvolved() -> bool:
	var ourNetworkInfo:NetworkPlayerInfo = Network.getMyPlayerInfo()
	if(!ourNetworkInfo):
		return false
	if(participants.has(ourNetworkInfo.charID)):
		return true
	return false

func processCamera(_dt:float):
	var isPCInvolved:bool = isLocalPCInvolved()
	
	free_camera.cameraActive = (cameraMode == CAMERA_FREE) && isPCInvolved
	fixed_camera.cameraActive = (cameraMode == CAMERA_LOCKED) && isPCInvolved
	
	if(isPCInvolved && fixed_camera.cameraActive && GM.pcDoll):
		fixed_camera_pivot.global_position = GM.pcDoll.getGlobalChestBonePosition()#CameraPivot.global_position

func playAnim(theAnimID:String, theStateID:String, thePawns:Dictionary, theAnimArgs:Dictionary):
	anim_scene_player.playAnim(theAnimID, theStateID, thePawns, theAnimArgs, props)

func playOneShot(oneShotID:String):
	anim_scene_player.playOneShot(oneShotID)

func isPawnInvolved(thePawn:CharacterPawn) -> bool:
	if(!thePawn):
		return false
	if(participants.has(thePawn.getCharID())):
		return true
	return false

func isCharIDInvolved(charID:String) -> bool:
	if(participants.has(charID)):
		return true
	return false

func _enter_tree() -> void:
	GM.sexManager.addSexInternal(self)

func _exit_tree() -> void:
	GM.sexManager.removeSexInternal(self)
	if(dialogue):
		dialogue.setSex(null)
		dialogue = null

func onSexEngineResult(_result:SexEngineResult):
	var checkedInteractions:Dictionary[InteractionBase, bool]
	
	for charID in _result.participants:
		var thePawn := GM.main.pawn_registry.getPawn(charID)
		if(!thePawn):
			continue
		var theInteraction := thePawn.getInteraction()
		if(theInteraction && !checkedInteractions.has(theInteraction)):
			checkedInteractions[theInteraction] = true
			theInteraction.pushSexEngineResult(_result)

func generateSexEngineResult() -> SexEngineResult:
	var theResult := SexEngineResult.new()
	theResult.fillFromSexEngine(self)
	return theResult

func isAnyParticipantControlledByPlayer() -> bool:
	for charID in participants:
		var theInfo := participants[charID]
		if(theInfo.isPlayer() && !theInfo.ai.shouldProcessAI()):
			return true
	return false

func stopSex():
	if(sexEngineState != ENGINE_STATE_SEX):
		return
	
	addActionTextRaw("The sex has ended.")
	if(isAnyParticipantControlledByPlayer()):
		sexEngineState = ENGINE_STATE_END_PC_WAIT
	else:
		sexEngineState = ENGINE_STATE_ENDING
	sexResult = generateSexEngineResult()
	sexResultText = sexResult.generateText(self)

func removeSex():
	if(wasDeleted):
		return
	wasDeleted = true
	GM.sexManager.removeSexInternal(self)
	queue_free()
	if(Network.isServer()):
		deleteAllTemporaryItems()
		doAutoEquipAfterEnd()
		
		for charID in savedCharPositions:
			var thePos:Vector3 = savedCharPositions[charID]
			var thePawn:CharacterPawn = GM.pawnRegistry.getPawn(charID)
			if(thePawn):
				thePawn.global_position = thePos
				var theDoll := thePawn.getDoll()
				if(theDoll):
					theDoll.global_position = thePos
		
		if(sexType):
			sexType.onSexEnd()
		
		if(sexResult):
			onSexEngineResult(sexResult)
		else:
			onSexEngineResult(generateSexEngineResult())

func _on_anim_scene_player_on_scene_switched() -> void:
	onAnimSceneSwitched.emit()
	onSexChange.emit(SexEngineChange.makeSceneChange())

@onready var process_timer: Timer = %ProcessTimer
func _on_process_timer_timeout() -> void:
	doProcess(process_timer.wait_time)
	dialogue.process(process_timer.wait_time)

func getRolePawn(_role:String) -> CharacterPawn:
	if(!sexType):
		return null
	return sexType.getRolePawn(_role)

func getRoleID(_role:String) -> String:
	if(!sexType):
		return ""
	return sexType.getRoleID(_role)

func _on_anim_scene_player_on_anim_play(_animID: String, _state: String) -> void:
	pass # Replace with function body.

func getSexHideTagsFor(_charID:String) -> Array:
	var result:Array = []
	result.append_array(anim_scene_player.getSexHideTagsFor(_charID))
	return result

func onParticipantGoalFinished(_info:SexParticipantInfo, _goal:SexGoalBase):
	for charID in participants: # Announce it to every participant
		var theInfo := participants[charID]
		theInfo.onParticipantGoalFinished(_info, _goal)

#TODO: Somehow fix ability to scroll while other menus are opened
func processCameraControl(_delta:float, _controllingCamera:bool):
	if(UIHandler.isMenuInputBlocked()):
		return
	#if(UIHandler.hasAnyUIVisible() || UIHandler.isMenuInputBlocked()):
	#	return
	
	if(cameraMode == CAMERA_FREE):
		const speed := 2.0
		var vel := Vector3.ZERO
		if(Input.is_action_pressed("move_forward") || (_controllingCamera && Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT))):
			vel += Vector3.FORWARD * speed
		if(Input.is_action_pressed("move_back")):
			vel += Vector3.BACK * speed
		if(Input.is_action_pressed("move_left")):
			vel += Vector3.LEFT * speed
		if(Input.is_action_pressed("move_right")):
			vel += Vector3.RIGHT * speed
		if(Input.is_action_pressed("move_jump")):
			vel += Vector3.UP * speed
		if(Input.is_action_pressed("move_sprint")):
			vel *= 5.0
		if(Input.is_action_just_pressed("camera_zoomin")):
			free_camera.fov = clamp((free_camera.fov*0.9), 1.0, 150.0)
		if(Input.is_action_just_pressed("camera_zoomout")):
			free_camera.fov = clamp((free_camera.fov*1.1), 1.0, 150.0)
		
		free_camera.translate_object_local(vel * _delta)
	if(cameraMode == CAMERA_LOCKED):
		var isShiftPressMult:float = 3.0 if Input.is_action_pressed("move_sprint") else 1.0
		if(Input.is_action_pressed("move_forward")):
			rotateCamera(fixed_camera_pivot, 0.0, 60.0*_delta*isShiftPressMult)
		if(Input.is_action_pressed("move_back")):
			rotateCamera(fixed_camera_pivot, 0.0, -60.0*_delta*isShiftPressMult)
		if(Input.is_action_pressed("move_left")):
			rotateCamera(fixed_camera_pivot, 60.0*_delta*isShiftPressMult, 0.0)
		if(Input.is_action_pressed("move_right")):
			rotateCamera(fixed_camera_pivot, -60.0*_delta*isShiftPressMult, 0.0)
		if(Input.is_action_just_pressed("camera_zoomin")):
			spring_arm.spring_length -= 0.1
		if(Input.is_action_just_pressed("camera_zoomout")):
			spring_arm.spring_length += 0.1

func processCameraMouseMotion(mouseD:Vector2):
	if(cameraMode == CAMERA_FREE):
		const sensivity = 0.05
		rotateCamera(free_camera, mouseD.x * sensivity, mouseD.y * sensivity)
	if(cameraMode == CAMERA_LOCKED):
		const sensivity = 0.05
		rotateCamera(fixed_camera_pivot, mouseD.x * sensivity, mouseD.y * sensivity)

func rotateCamera(theCamera:Node3D, roty:float, rotx:float):
	var rot := theCamera.rotation_degrees
	rot.x = clamp(rot.x - rotx, -90.0, 90)
	rot.y -= roty
	theCamera.rotation_degrees = rot

func addActionText(theText:String, replacers:Dictionary[String, String]):
	addActionTextRaw(GM.textParser.applyObjReplacers(theText, replacers))

func addActionTextRaw(theText:String):
	if(Network.isServer()):
		actionTexts.append([
			theText, 5.0,
		])
		if(actionTexts.size() > 5):
			actionTexts.pop_front()

func getActionText() -> String:
	return actionText

func sendSexActivityEvent(_eventID:String, _args:Array = []):
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(sendSexActivityEvent_RPC.bind(_eventID, _args))

@rpc("authority", "call_remote", "reliable")
func sendSexActivityEvent_RPC(_eventID:String, _args:Array = []):
	if(sexActivity):
		sexActivity.onEvent(_eventID, _args)
	else:
		Log.Printerr("We received a '"+str(_eventID)+"' sex activity event but no sex activity is currently running.")

func sendSexTypeEvent(_eventID:String, _args:Array = []):
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(sendSexTypeEvent_RPC.bind(_eventID, _args))

@rpc("authority", "call_remote", "reliable")
func sendSexTypeEvent_RPC(_eventID:String, _args:Array = []):
	if(sexType):
		sexType.onEvent(_eventID, _args)
	else:
		Log.Printerr("We received a '"+str(_eventID)+"' sex type event but no sex type is currently running.")

func askSetParticipantUserPickedOptions(_charID:String, _options:Dictionary):
	if(Network.isClient()):
		askSetParticipantUserPickedOptions_SERVERRPC.rpc_id(1, _charID, _options)
	else:
		askSetParticipantUserPickedOptions_SERVERRPC(_charID, _options)

@rpc("any_peer", "call_remote", "reliable")
func askSetParticipantUserPickedOptions_SERVERRPC(_charID:String, _options:Dictionary):
	if(!participants.has(_charID)):
		return
	participants[_charID].applyUserPickedOptions(_options)
	onParticipantUpdate.emit(_charID)
	onSexChange.emit(SexEngineChange.makeParticipantUpdate(_charID))
	syncParticipant(_charID)

func askSetParticipantAutoConsent(_charID:String, _newAutoConsent:bool):
	if(Network.isClient()):
		askSetParticipantAutoConsent_SERVERRPC.rpc_id(1, _charID, _newAutoConsent)
	else:
		askSetParticipantAutoConsent_SERVERRPC(_charID, _newAutoConsent)

@rpc("any_peer", "call_remote", "reliable")
func askSetParticipantAutoConsent_SERVERRPC(_charID:String, _newAutoConsent:bool):
	if(!participants.has(_charID)):
		return
	participants[_charID].autoConsent = _newAutoConsent
	onParticipantUpdate.emit(_charID)
	onSexChange.emit(SexEngineChange.makeParticipantUpdate(_charID))
	syncParticipant(_charID)

func syncParticipant(_charID:String):
	if(!Network.isServerNotSingleplayer()):
		return
	if(!participants.has(_charID)):
		Network.rpcClients(syncParticipant_RPC.bind(_charID, {}))
	else:
		Network.rpcClients(syncParticipant_RPC.bind(_charID, participants[_charID].saveData()))

@rpc("authority", "call_remote", "reliable")
func syncParticipant_RPC(_charID:String, _data:Dictionary):
	if(_data.is_empty()):
		# Participant removed
		participants.erase(_charID)
		return
	if(!participants.has(_charID)):
		# New participant
		var newParticipant:SexParticipantInfo = SexParticipantInfo.new()
		newParticipant.id = _charID
		newParticipant.setSexEngine(self)
		participants[_charID] = newParticipant
		newParticipant.loadData(_data)
		return
	# Updated participant
	participants[_charID].loadData(_data) #TODO: Change to load/saveNetworkData
	onParticipantUpdate.emit(_charID)
	onSexChange.emit(SexEngineChange.makeParticipantUpdate(_charID))

func isConsensual() -> bool:
	return sexMode != MODE_FORCED

func isForced() -> bool:
	return sexMode == MODE_FORCED

func isRPMode() -> bool:
	return false

func _on_anim_scene_player_on_anim_event(theAnimID:String, theState:String, eventID: Variant, args: Variant) -> void:
	if(sexType):
		sexType.onAnimEvent(theAnimID, theState, eventID, args)
	if(sexActivity):
		sexActivity.onAnimEvent(theAnimID, theState, eventID, args)

func isSub(_charID:String) -> bool:
	var theInfo := getInfo(_charID)
	if(!theInfo):
		return false
	return theInfo.isSub()
	
func isDom(_charID:String) -> bool:
	var theInfo := getInfo(_charID)
	if(!theInfo):
		return false
	return theInfo.isDom()

func hasAnyDoms() -> bool:
	for charID in participants:
		var theInfo:SexParticipantInfo = participants[charID]
		if(theInfo.isDom()):
			return true
	return false

func hasAnySubs() -> bool:
	if(!hasAnyDoms()): # no doms = all subs are doms
		return false
	for charID in participants:
		var theInfo:SexParticipantInfo = participants[charID]
		if(theInfo.isSub()):
			return true
	return false

func canDoDomActions(_charID:String) -> bool:
	if(isRPMode()):
		return true
	if(isDom(_charID)):
		return true
	if(!hasAnyDoms()): # no doms = all subs are also doms
		return true
	return false

func addAutoEquipAfterEnd(_charID:String, _slot:int, _itemUID:int):
	if(!autoEquipAfterEndItems.has(_charID)):
		autoEquipAfterEndItems[_charID] = [[_slot, _itemUID]]
	else:
		autoEquipAfterEndItems[_charID].append([_slot, _itemUID])

func doAutoEquipAfterEnd():
	for theCharID in autoEquipAfterEndItems:
		var theChar:BaseCharacter = GM.characterRegistry.getCharacter(theCharID)
		if(!theChar):
			continue
		#TODO: if can't re-equip items because of restraints, you shouldn't!
		var theInv:Inventory = theChar.getInventory()
		var theItemsAndSlots:Array = autoEquipAfterEndItems[theCharID]
		for theItemEntry in theItemsAndSlots:
			var theSlot:int = theItemEntry[0]
			var theItemUID:int = theItemEntry[1]
			
			var theItem:ItemBase = theInv.findItemByUniqueID(theItemUID)
			if(!theItem || theItem.isEquipped() || theInv.hasSlotEquipped(theSlot)):
				continue
			theInv.equipItem(theItem, theSlot)
			theItem.onAutoEquipAfterSex()

func parseText(_text:String, _replacers:Dictionary[String, String] = {}) -> String:
	return GM.textParser.parseString(_text, getSimpleGameTextParserText, _replacers).text

func getSimpleGameTextParserText(_id:String, _command:String, _arg:String) -> SGTPResult:
	var theResult:SGTPResult = null
	if(!theResult):
		if(participants.has(_id)):
			theResult = GM.characterRegistry.getSimpleGameTextParserText(_id, _command, _arg)
	
	return theResult

func setSexMode(_mode:int):
	if(_mode == sexMode):
		return
	sexMode = _mode
	if(sexMode == MODE_FORCED):
		addCooldown("subResist", 5.0)
	onSexChange.emit(SexEngineChange.makeModeChange(sexMode))
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(setSexMode_RPC.bind(_mode))

@rpc("authority", "call_remote", "reliable")
func setSexMode_RPC(_mode:int):
	setSexMode(_mode)

func askSetSexMode(_mode:int):
	if(Network.isClient()):
		askSetSexMode_SERVERRPC.rpc_id(1, _mode)
	else:
		askSetSexMode_SERVERRPC(_mode)

@rpc("any_peer", "call_remote", "reliable")
func askSetSexMode_SERVERRPC(_mode:int):
	var theInfo := Network.getSenderPlayerInfo()
	if(!theInfo):
		return
	var theID:String = theInfo.getCharID()
	if(theID.is_empty() || !isCharIDInvolved(theID) || !canDoDomActions(theID)):
		return
	setSexMode(_mode)

func isResistMinigameRunning() -> bool:
	return !resistMinigame.isDisabled()

# Runs on server
func _on_resist_minigame_node_on_result(_result: ResistMinigameResult) -> void:
	resistMinigame.syncMinigame()

	if(eventQueue.is_empty()):
		return
	
	var didDomsWin:bool = _result.didDomsWin()
	
	var queueEntry:SexEngineQueueEntry = eventQueue[0]
	if(queueEntry is SexEngineQueueEntry.ConsentCheck):
		#queueEntry[5] = false
		
		if(!didDomsWin):
			cancelQueue()
			addActionTextRaw("The sub"+("s" if getSubAmount() != 1 else "")+" managed to resist the action! The dom"+("s" if getDomAmount() != 1 else "")+" have lost grip.")
			var theSubs:Array[SexParticipantInfo] = []
			for theCharID in queueEntry.needToConsent:
				var theInfo := getParticipant(theCharID)
				if(!theInfo || theInfo.canDoDomActions()):
					continue
				theSubs.append(theInfo)
			#var theStarterInfo:SexParticipantInfo = getParticipant(queueEntry.starterID)
			#var theDomsArray:Array[SexParticipantInfo] = [theStarterInfo] if theStarterInfo else []
			#doSubResist(theSubs, theDomsArray)
			doSubResist()
			#addGrip(-0.4)
			#if(theStarterInfo && !theSubs.is_empty()):
			#	theStarterInfo.ai.addCommentTopic(theSubs[0].getID(), SexComment.SubResisted)
		else:
			eventQueue.pop_front()
			addActionTextRaw("The dom"+("s" if getDomAmount() != 1 else "")+" managed to force the action!")
			addGrip(0.2)
			addCooldown("subResist", 10.0)
			#queueEntry[5] = false
		
		#Log.Print("LET'S GOOO!")
	elif(queueEntry is SexEngineQueueEntry.ResistMinigameStart):
		queueEntry.obj.handleResistMinigame(queueEntry.state, _result)
		eventQueue.pop_front()
	
func getSubAmount() -> int:
	var result:int = 0
	for charID in participants:
		if(isSub(charID)):
			result += 1
	return result

func getDomAmount() -> int:
	var result:int = 0
	for charID in participants:
		if(isDom(charID)):
			result += 1
	return result

func getGripLevel() -> float:
	return gripLevel

func addGrip(_grip:float):
	gripLevel += _grip
	if(gripLevel >= 1.0):
		gripLevel = 1.0
	if(sexActivity && gripLevel < 0.1): # Can't escape unless we escape the current sex activity
		gripLevel = 0.1

func doSubResist():
	addGrip(-0.4)
	addCooldown("noGripRecover", 10.0)
	addCooldown("subResist", 10.0)
	
	for theSideActivity in sideActivities:
		theSideActivity.onResist()
	
	if(sexActivity):
		sexActivity.onResist()
	else:
		sexType.onResist()
	
	for charID in participants:
		var theInfo := participants[charID]
		theInfo.ai.onSubsResisted()

func checkGripLevel():
	if(gripLevel <= 0.0):
		lostGrip = true
		stopSex()

func setCooldown(_cooldownID:String, _time:float):
	cooldowns[_cooldownID] = _time

func addCooldown(_cooldownID:String, _time:float, _max:bool = true):
	if(_max):
		cooldowns[_cooldownID] = maxf(_time, getCooldown(_cooldownID))
	else:
		cooldowns[_cooldownID] = _time + getCooldown(_cooldownID)

func processCooldowns(_dt:float):
	for cooldownID in cooldowns.keys():
		cooldowns[cooldownID] -= _dt
		if(cooldowns[cooldownID] <= 0.0):
			cooldowns.erase(cooldownID)

func hasCooldown(_cooldownID:String) -> bool:
	if(cooldowns.has(_cooldownID)):
		return cooldowns[_cooldownID] > 0.0
	return false

func getCooldown(_cooldownID:String) -> float:
	if(cooldowns.has(_cooldownID)):
		return cooldowns[_cooldownID]
	return 0.0

func hasResistCooldown() -> bool:
	return hasCooldown("subResist")

func hasNoGripRecoverCooldown() -> bool:
	return hasCooldown("noGripRecover")

# Makes AI react better
func notifyThingHappened():
	for charID in participants:
		participants[charID].notifyThingHappened()

# Makes AI react faster
func notifyThingHappenedNeedsReaction():
	for charID in participants:
		participants[charID].notifyThingHappenedNeedsReaction()

func doExposeFetish(_performerID:String, _receiverID:String, _fetishID:String, _intensity:float = 1.0):
	var _infoPerf:SexParticipantInfo = getInfo(_performerID)
	var _infoReceiver:SexParticipantInfo = getInfo(_receiverID)
	if(!_infoPerf && !_infoReceiver):
		return
	#Log.Print("EXPOSING: "+_performerID+" "+_receiverID+" FETISH="+_fetishID+" INTENSITY: "+str(_intensity))
	if(_infoPerf == _infoReceiver):
		_infoPerf.exposeToFetish(_fetishID, _intensity, true, true)
	else:
		if(_infoPerf):
			_infoPerf.exposeToFetish(_fetishID, _intensity, true, false)
		if(_infoReceiver):
			_infoReceiver.exposeToFetish(_fetishID, _intensity, false, true)

func calculateEngineText(_eventQueue:bool = true, _actions:bool = true) -> String:
	var result:Array[String] = []
	
	var _isForced:bool = isForced()
	
	if(_actions):
		for textEntry in actionTexts:
			result.append(textEntry[0])
	
	if(_eventQueue && !eventQueue.is_empty()):
		var queueEntry:SexEngineQueueEntry = eventQueue[0]
		var _entryObj := queueEntry.obj
		
		if(queueEntry is SexEngineQueueEntry.ConsentCheck):
			var theTexts:Array = queueEntry.hoverTexts
			if(theTexts.size() >= 2):
				var consentActionText:String = theTexts[0] if !_isForced else theTexts[1]
				
				result.append(GM.textParser.applyObjReplacers(consentActionText, queueEntry.roles))
	
	return Util.join(result, "\n")

func calculateActionText() -> String:
	#return parseText(calculateEngineText())
	return calculateEngineText()

# Ran on server, gets synced to the clients?
# Alternative = sync the whole sex engine and run this function localy (can localize then)
func calculateHoverText() -> String:
	#return parseText(calculateEngineText())
	return calculateEngineText()

func markItemBelongsTo(_item:ItemBase, _charID:String):
	if(!_item):
		return
	itemBelong[_item.uniqueID] = _charID

func doesItemBelongTo(_item:ItemBase, _charID:String) -> bool:
	if(!_item):
		return false
	return itemBelong.has(_item.uniqueID) && itemBelong[_item.uniqueID] == _charID

func markItemAsTemporary(_item:ItemBase):
	if(!_item):
		return
	tempItemUIDs.append(_item.uniqueID)

func isItemTemporary(_item:ItemBase):
	if(!_item):
		return false
	return tempItemUIDs.has(_item.uniqueID)

func shouldItemBeDeletedOnUnequipOrSexEnd(_item:ItemBase) -> bool:
	if(tempItemUIDs.has(_item.uniqueID)):
		return true
	for charID in participants:
		var theInfo:SexParticipantInfo = participants[charID]
		if(theInfo.freeStraponUniqueID == _item.uniqueID):
			return true
	return false

func deleteAllTemporaryItemsFor(charID:String):
	if(!participants.has(charID)):
		return
	var theInfo:SexParticipantInfo = participants[charID]
	var theChar:BaseCharacter = theInfo.getChar()
	if(!theChar):
		return
	var theInv:Inventory = theChar.getInventory()
	for itemUID in tempItemUIDs:
		var theItem:ItemBase = theInv.findItemByUniqueID(itemUID)
		if(theItem):
			theItem.removeSelf()
	
func deleteAllTemporaryItems():
	for charID in participants:
		deleteAllTemporaryItemsFor(charID)

func askSetRotation(_rot:float):
	if(Network.isClient()):
		askSetRotation_SERVERRPC.rpc_id(1, _rot)
	else:
		askSetRotation_SERVERRPC(_rot)

#MULTIPLAYER: add server checks to make sure client is in this sex engine
@rpc("any_peer", "call_remote", "reliable")
func askSetRotation_SERVERRPC(_rot:float):
	if(sexType && !sexType.canTweakPosition()):
		return
	setRotationRaw(_rot)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(setRotation_RPC.bind(_rot))

@rpc("authority", "call_remote", "reliable")
func setRotation_RPC(_rot:float):
	setRotationRaw(_rot)

func setRotationRaw(_rot:float):
	tweaker.rotation_degrees.y = _rot

func setRotation(_rot:float):
	if(sexType && !sexType.canTweakPosition()):
		return
	tweaker.rotation_degrees.y = _rot

func askSetPos(_pos:Vector3):
	if(Network.isClient()):
		askSetPos_SERVERRPC.rpc_id(1, _pos)
	else:
		askSetPos_SERVERRPC(_pos)

#MULTIPLAYER: add server checks to make sure client is in this sex engine
@rpc("any_peer", "call_remote", "reliable")
func askSetPos_SERVERRPC(_pos:Vector3):
	if(sexType && !sexType.canTweakPosition()):
		return
	setPosRaw(_pos)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(setPos_RPC.bind(_pos))

@rpc("authority", "call_remote", "reliable")
func setPos_RPC(_pos:Vector3):
	setPosRaw(_pos)

func setPosRaw(_pos:Vector3):
	tweaker.position = _pos

func setPos(_pos:Vector3):
	if(sexType && !sexType.canTweakPosition()):
		return
	tweaker.position = _pos

func isSexTaskPossibleToSatisfy(_sexTask:SexTask) -> bool:
	for sexActivityID in GlobalRegistry.getSexActivities():
		var theSexActivityRef:SexEngineActivityBase = GlobalRegistry.getSexActivityRef(sexActivityID)
		if(!theSexActivityRef.isActivitySupported(self)):
			continue
		if(theSexActivityRef.canDoSexTask(self, _sexTask)):
			return true
	return false

func getAllActivities() -> Array[SexEngineActivityBase]:
	var result:Array[SexEngineActivityBase] = []
	if(sexType):
		result.append(sexType)
	if(sexActivity):
		result.append(sexActivity)
	result.append_array(sideActivities)
	return result

func getAllSexTags(_charID:String, _targetID:String) -> int:
	var result:int = 0
	if(sexType):
		result |= sexType.getTagsFor(_charID, _targetID)
	if(sexActivity):
		result |= sexActivity.getTagsFor(_charID, _targetID)
	for theActivity in sideActivities:
		result |= theActivity.getTagsFor(_charID, _targetID)
	return result

func hasInfoSexTag(_charID:String, _targetID:String, _tag:int) -> bool:
	return getAllSexTags(_charID, _targetID) & _tag

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.Var, saveData(),
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	loadData(_data.readVar())
	_data.endLoad()

#TODO: Finish this
func saveData() -> Dictionary:
	var sexActivityData = null
	if(sexActivity):
		sexActivityData = {
			id = sexActivity.id,
			data = sexActivity.saveData(),
		}
	var participantsData:Dictionary = {}
	for charID in participants:
		participantsData[charID] = participants[charID].saveData()
	
	#TODO: FORGOT TO SAVE SIDE SEX ACTIVITIES
	
	return {
		participants = participantsData,
		sexType = {
			id = sexType.id,
			data = sexType.saveData(),
		},
		sexActivity = sexActivityData,
		animPlayer = anim_scene_player.saveData(),
		sexMode = sexMode,
		rotY = tweaker.rotation.y,
		posx = tweaker.position.x,
		posy = tweaker.position.y,
		posz = tweaker.position.z,
	}

func loadData(_data:Dictionary):
	sexMode = SAVE.loadVar(_data, "sexMode", MODE_NORMAL)
	
	participants.clear()
	var participantsData:Dictionary = SAVE.loadVar(_data, "participants", {})
	for charID in participantsData:
		syncParticipant_RPC(charID, participantsData[charID])
	
	var sexTypeData:Dictionary = SAVE.loadVar(_data, "sexType", {})
	sexType = GlobalRegistry.createSexActivity(SAVE.loadVar(sexTypeData, "id", ""))
	sexType.setSexEngine(self)
	sexType.loadData(SAVE.loadVar(sexTypeData, "data", {}))
	
	var activityData = SAVE.loadVar(_data, "sexActivity", null)
	if(activityData == null):
		sexActivity = null
	elif(activityData is Dictionary):
		sexActivity = GlobalRegistry.createSexActivity(SAVE.loadVar(activityData, "id", ""))
		sexActivity.setSexEngine(self)
		sexActivity.loadData(SAVE.loadVar(activityData, "data", {}))
	
	anim_scene_player.loadData(SAVE.loadVar(_data, "animPlayer", {}))
	tweaker.rotation.y = SAVE.loadVar(_data, "rotY", 0.0)
	var thePos:Vector3
	thePos.x = SAVE.loadVar(_data, "posx", 0.0)
	thePos.y = SAVE.loadVar(_data, "posy", 0.0)
	thePos.z = SAVE.loadVar(_data, "posz", 0.0)
	tweaker.position = thePos
