extends Node3D
class_name SexEngine

@onready var free_camera: PriorityCamera = %FreeCamera
@onready var fixed_camera_pivot: Node3D = %FixedCameraPivot
@onready var spring_arm: SpringArm3D = %SpringArm
@onready var fixed_camera: PriorityCamera = %FixedCamera

@onready var anim_scene_player: AnimScenePlayer = %AnimScenePlayer

const ROLE_DOM = 0
const ROLE_SUB = 1
const ROLE_SWITCH = 2

const STATE_NORMAL = 0 # We can do actions?
const STATE_BUSY = 1 # We're waiting for a delayed action
const STATE_CONSENT = 2 # We're waiting for someone to agree

@export var state:int = STATE_NORMAL
@export var transitionTimer:float = 0.0
@export var transitionTimerFull:float = 1.0
@export var transitionText:String = ""
var consentedChars:Dictionary = {}
var delayedAction:Dictionary = {}

const ACTION_SEXTYPE = 0
const ACTION_SEXACTIVITY = 1
const ACTION_CONSENT = 2
const ACTION_DENY_CONSENT = 3

var actionsCache:Dictionary = {}
@export var actionsNetworked:Dictionary = {}

# char id = sex info
var participants:Dictionary = {}

var sexActivity:SexActivityBase
var sexType:SexTypeBase

var consensual:bool = false

const CAMERA_LOCKED = 0
const CAMERA_FREE = 1
const CAMERA_FPS = 2
var cameraMode:int = CAMERA_LOCKED

signal onAnimSceneSwitched
signal onParticipantUpdate(charID)

var actionTexts:Array = []
@export var actionText:String = ""

func start(sexTypeID:String, roles:Dictionary, args:Dictionary = {}):
	if(args.has("consensual")):
		consensual = args["consensual"]
	
	var theSexType:SexTypeBase = GlobalRegistry.createSexType(sexTypeID)
	theSexType.setSexEngine(self)
	sexType = theSexType
	sexType.start(roles, args)
	
	GameInteractor.networkedNodes.notifySpawned(self)
	sexType.onStart()

func addParticipant(theID:String, theRole:int) -> SexParticipantInfo:
	var newInfo:SexParticipantInfo = SexParticipantInfo.new()
	newInfo.id = theID
	newInfo.role = theRole
	newInfo.setSexEngine(self)
	
	participants[theID] = newInfo
	onParticipantUpdate.emit(theID)
	return newInfo

func getParticipant(theID:String) -> SexParticipantInfo:
	if(!participants.has(theID)):
		return null
	return participants[theID]

func _process(_delta: float) -> void:
	processCamera(_delta)
	
	if(Network.isServer()):
		if(sexType):
			sexType.processSex(_delta)
		if(sexActivity):
			sexActivity.processSex(_delta)

func doProcess(_delta: float) -> void:
	if(Network.isServer()):
		for charID in participants:
			if(!GM.pawnRegistry.hasPawn(charID)):
				Log.Printerr("Pawn doesn't exist: "+str(charID)+". Stopping sex.")
				stopSex()
				return
			
			#var thePawn:CharacterPawn = GM.pawnRegistry.getPawn(charID)
			#var theDoll:DollController = thePawn.getDoll()
			#if(theDoll):
				#theDoll.setExpressionState(getExpressionState(charID))
	
	sexType.doProcess(_delta)
	if(sexActivity):
		sexActivity.doProcess(_delta)
	
	if(state == STATE_BUSY):
		transitionTimer -= _delta
		if(transitionTimer <= 0.0 && Network.isServer()):
			# We can do stuff
			state = STATE_NORMAL
			
			onDelayedAction(delayedAction)
	if(state == STATE_CONSENT):
		if(didEveryoneConsent()):
			state = STATE_NORMAL
			onDelayedAction(delayedAction)
		else:
			transitionTimer -= _delta
			if(transitionTimer <= 0.0 && Network.isServer()):
				# Cancel
				state = STATE_NORMAL
			
	
	if(Network.isServer()):
		# action cache update
		var newNetworkActions:Dictionary = {}
		actionsCache.clear()
		for charID in participants:
			actionsCache[charID] = calculateActions(charID)
			newNetworkActions[charID] = calculateNetworkActions(actionsCache[charID])
		actionsNetworked = newNetworkActions
		
		# action text update
		var textsAmount:int = actionTexts.size()
		for _i in range(textsAmount):
			var theEntry:Array = actionTexts[textsAmount - _i - 1]
			theEntry[1] -= _delta
			if(theEntry[1] <= 0.0):
				actionTexts.remove_at(textsAmount - _i - 1)
			
		actionText = calculateActionText()

func calculateNetworkActions(theActions:Array) -> Array:
	var result:Array = []
	
	var _i:int = 0
	for actionEntry in theActions:
		result.append({i=_i,name=actionEntry["name"]})
		_i += 1
	
	return result

func getExpressionState(charID:String) -> int:
	if(sexActivity):
		return sexActivity.getExpressionStateForCharID(charID)
	if(sexType):
		return sexType.getExpressionStateForCharID(charID)
	
	return DollExpressionState.IgnoreChange

func calculateActions(charID:String) -> Array:
	if(!participants.has(charID)):
		return []
	var isSexEngineBusy:bool = isBusy()
	
	var result:Array = []
	
	if(doesCharIDNeedsToConsent(charID)):
		result.append({
			id = ACTION_CONSENT,
			name = "Agree",
		})
		result.append({
			id = ACTION_DENY_CONSENT,
			name = "Deny",
		})
	
	if(!isSexEngineBusy && sexType):
		var theActions:Array = sexType.getActionsForCharID(charID)
		
		for actionEntry in theActions:
			if(!shouldKeepAction(charID, actionEntry, sexType)):
				continue
			
			result.append({
				id = ACTION_SEXTYPE,
				name = actionEntry["name"],
				action = actionEntry,
				mods = actionEntry["mods"] if actionEntry.has("mods") else {},
			})
	if(!isSexEngineBusy && sexActivity):
		var theActions:Array = sexActivity.getActionsForCharID(charID)
		
		for actionEntry in theActions:
			if(!shouldKeepAction(charID, actionEntry, sexActivity)):
				continue
			
			result.append({
				id = ACTION_SEXACTIVITY,
				name = actionEntry["name"],
				action = actionEntry,
				mods = actionEntry["mods"] if actionEntry.has("mods") else {},
			})
	
	return result

func shouldKeepAction(charID:String, actionEntry:Dictionary, sexActivityBase:SexEngineActivityBase) -> bool:
	var theMods:Dictionary = actionEntry["mods"] if actionEntry.has("mods") else {}
	
	if(theMods.has(SexActionMod.ROLES)):
		if(isConsensual()):
			pass
		elif(!(sexActivityBase.getRoleFromID(charID) in theMods[SexActionMod.ROLES])):
			return false
	
	return true

func getActions(charID:String) -> Array:
	if(!actionsNetworked.has(charID)):
		return []
	return actionsNetworked[charID]

func askSelectAction(charID:String, networkedAction:Dictionary):
	if(Network.isServer()):
		doActionNetworked(charID, networkedAction)
	else:
		doActionNetworked.rpc_id(1, charID, networkedAction)

@rpc("any_peer", "call_remote", "reliable")
func doActionNetworked(charID:String, networkedAction:Dictionary):
	if(!actionsCache.has(charID)):
		Log.Printerr("SexEngine: No key found in actions cache for "+str(charID))
		return
	if(!networkedAction.has("i")):
		Log.Printerr("SexEngine: No action index found. Corrupt network action?")
		return
	var _i:int = networkedAction["i"]
	var theActions:Array = actionsCache[charID]
	if(theActions.is_empty()):
		return
	if(_i >= theActions.size()):
		return
		
	var action:Dictionary = theActions[_i]
	doAction(charID, action)

func doAction(charID:String, action:Dictionary):
	var theMods:Dictionary = action["mods"] if action.has("mods") else {}
	
	
	
	var requiresConsent:bool = theMods[SexActionMod.CONSENT_ALL] if theMods.has(SexActionMod.CONSENT_ALL) else false
	if(requiresConsent):
		transitionText = theMods[SexActionMod.CONSENT_TEXT] if theMods.has(SexActionMod.CONSENT_TEXT) else ""
		theMods[SexActionMod.CONSENT_ALL] = false
		doConsentAction(charID, action)
		return
	
	var delay:float = theMods[SexActionMod.DELAY] if theMods.has(SexActionMod.DELAY) else 0.0
	if(delay > 0.0):
		transitionText = theMods[SexActionMod.ACTION_TEXT] if theMods.has(SexActionMod.ACTION_TEXT) else ""
		theMods[SexActionMod.DELAY] = 0.0
		doDelayedAction(delay, charID, action)
		return
	
	doActionInternal(charID, action)

## Just does the action. Doesn't do any modification checks (like delay)
func doActionInternal(charID:String, action:Dictionary):
	# all id checks go here
	
	var actionID:int = action["id"]
	if(actionID == ACTION_SEXTYPE):
		var theAction:Dictionary = action["action"]
		sexType.doActionForCharID(charID, theAction["id"], theAction)
	if(actionID == ACTION_SEXACTIVITY):
		var theAction:Dictionary = action["action"]
		sexActivity.doActionForCharID(charID, theAction["id"], theAction)
	if(actionID == ACTION_CONSENT):
		consentedChars[charID] = true
		addActionText("Someone agrees!")
	if(actionID == ACTION_DENY_CONSENT):
		addActionText("Someone denies the offer!")
		cancelDelayedAction()

func cancelDelayedAction():
	transitionTimer = 0.0
	state = STATE_NORMAL
	consentedChars.clear()
	transitionText = ""

func onDelayedAction(_info:Dictionary):
	#Log.Print("DELAYED ACTION: "+str(_info))
	doAction(_info["charID"], _info["action"])
	
	#if(_info["id"] == ACTION_SEXTYPE):
		#sexType.onDelayedAction(_info["role"], _info["actionID"], _info["action"])
	#if(_info["id"] == ACTION_SEXACTIVITY):
		#sexActivity.onDelayedAction(_info["role"], _info["actionID"], _info["action"])
	#

func didEveryoneConsent() -> bool:
	for charID in participants:
		if(!consentedChars.has(charID) || !consentedChars[charID]):
			return false
	return true

func doesCharIDNeedsToConsent(charID:String) -> bool:
	if(state != STATE_CONSENT):
		return false
	if(consentedChars.has(charID) && consentedChars[charID]):
		return false
	return true

func doConsentAction(charID:String, _action:Dictionary):
	if(state != STATE_NORMAL):
		assert(false, "BAD STATE")
		return
	state = STATE_CONSENT
	transitionTimerFull = 10.0
	transitionTimer = transitionTimerFull
	
	consentedChars = {
		charID: true,
	}
	for participantCharID in participants:
		var participant:SexParticipantInfo = participants[participantCharID]
		if(participant.willConsentToAnything()):
			consentedChars[participantCharID] = true
	delayedAction = {
		charID = charID,
		action = _action,
	}
	
func doDelayedAction(_timer:float, charID:String, _action:Dictionary):
	if(state != STATE_NORMAL):
		assert(false, "BAD STATE")
		return
	state = STATE_BUSY
	transitionTimerFull = _timer
	transitionTimer = transitionTimerFull
	
	delayedAction = {
		charID = charID,
		action = _action,
	}
	
	if(_action["id"] in [ACTION_SEXTYPE, ACTION_SEXACTIVITY]):
		var theAction:Dictionary = _action["action"]
		if(_action["id"] == ACTION_SEXTYPE):
			sexType.doOnDelayedActionStartedForCharID(charID, theAction["id"], theAction)
		if(_action["id"] == ACTION_SEXACTIVITY):
			sexActivity.doOnDelayedActionStartedForCharID(charID, theAction["id"], theAction)

func startMainActivity(activityID:String, _roles:Dictionary, _args:Dictionary = {}) -> SexActivityBase:
	if(sexActivity):
		stopMainActivity()
	var theActivity:SexActivityBase = GlobalRegistry.createSexActivity(activityID)
	if(!theActivity):
		return null
	theActivity.setSexEngine(self)
	sexActivity = theActivity
	sexActivity.start(_roles, _args)
	# TODO some syncing here?
	sexActivity.onStart()
	return sexActivity
	
func stopMainActivity():
	if(!sexActivity):
		return
	var savedActivityID:String = sexActivity.id
	sexActivity = null
	sexType.onMainActivityEnded(savedActivityID)

func getSexActivity() -> SexActivityBase:
	return sexActivity

func getSexType() -> SexTypeBase:
	return sexType

func isBusy() -> bool:
	return state != STATE_NORMAL

func getProgressBarValue() -> float:
	if(state == STATE_BUSY || state == STATE_CONSENT):
		if(transitionTimerFull == 0.0):
			return 0.5
		return (1.0 - transitionTimer/transitionTimerFull)
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

func playAnim(theAnimID:String, theStateID:String, thePawns:Dictionary):
	anim_scene_player.playAnim(theAnimID, theStateID, thePawns)

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

func stopSex():
	GM.sexManager.removeSexInternal(self)
	queue_free()

func _on_anim_scene_player_on_scene_switched() -> void:
	onAnimSceneSwitched.emit()

@onready var process_timer: Timer = %ProcessTimer
func _on_process_timer_timeout() -> void:
	doProcess(process_timer.wait_time)

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

func processCameraControl(_delta:float, _controllingCamera:bool):
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

func addActionText(theText:String):
	if(Network.isServer()):
		actionTexts.append([
			theText, 5.0,
		])
		if(actionTexts.size() > 5):
			actionTexts.pop_front()

func calculateActionText() -> String:
	var result:String = ""
	for textEntry in actionTexts:
		if(result != ""):
			result += "\n"
		result += textEntry[0]
	if(transitionText != "" && (state in [STATE_BUSY, STATE_CONSENT])):
		if(result != ""):
			result += "\n"
		result += "[b]"+transitionText+"[/b]"
	return result

func getActionText() -> String:
	return actionText

func sendSexActivityEvent(_eventID:String, _args:Array = []):
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(sendSexActivityEvent_RPC, [_eventID, _args])

@rpc("authority", "call_remote", "reliable")
func sendSexActivityEvent_RPC(_eventID:String, _args:Array = []):
	if(sexActivity):
		sexActivity.onEvent(_eventID, _args)
	else:
		Log.Printerr("We received a '"+str(_eventID)+"' sex activity event but no sex activity is currently running.")

func sendSexTypeEvent(_eventID:String, _args:Array = []):
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(sendSexTypeEvent_RPC, [_eventID, _args])

@rpc("authority", "call_remote", "reliable")
func sendSexTypeEvent_RPC(_eventID:String, _args:Array = []):
	if(sexType):
		sexType.onEvent(_eventID, _args)
	else:
		Log.Printerr("We received a '"+str(_eventID)+"' sex type event but no sex type is currently running.")

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
	syncParticipant(_charID)

func syncParticipant(_charID:String):
	if(!Network.isServerNotSingleplayer()):
		return
	if(!participants.has(_charID)):
		Network.rpcClients(syncParticipant_RPC, [_charID, {}])
	else:
		Network.rpcClients(syncParticipant_RPC, [_charID, participants[_charID].saveNetworkData()])

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
		newParticipant.loadNetworkData(_data)
		return
	# Updated participant
	participants[_charID].loadNetworkData(_data)
	onParticipantUpdate.emit(_charID)

func isConsensual() -> bool:
	return consensual

func isRPMode() -> bool:
	return false

func _on_anim_scene_player_on_anim_event(theAnimID:String, theState:String, eventID: Variant, args: Variant) -> void:
	if(sexType):
		sexType.onAnimEvent(theAnimID, theState, eventID, args)
	if(sexActivity):
		sexActivity.onAnimEvent(theAnimID, theState, eventID, args)

func saveNetworkData() -> Dictionary:
	var sexActivityData = null
	if(sexActivity):
		sexActivityData = {
			id = sexActivity.id,
			data = sexActivity.saveNetworkData(),
		}
	var participantsData:Dictionary = {}
	for charID in participants:
		participantsData[charID] = participants[charID].saveNetworkData()
	
	return {
		participants = participantsData,
		sexType = {
			id = sexType.id,
			data = sexType.saveNetworkData(),
		},
		sexActivity = sexActivityData,
		animPlayer = anim_scene_player.saveNetworkData(),
	}

func loadNetworkData(_data:Dictionary):
	participants.clear()
	var participantsData:Dictionary = SAVE.loadVar(_data, "participants", {})
	for charID in participantsData:
		syncParticipant_RPC(charID, participantsData[charID])
	
	var sexTypeData:Dictionary = SAVE.loadVar(_data, "sexType", {})
	sexType = GlobalRegistry.createSexType(SAVE.loadVar(sexTypeData, "id", ""))
	sexType.setSexEngine(self)
	sexType.loadNetworkData(SAVE.loadVar(sexTypeData, "data", {}))
	
	var activityData = SAVE.loadVar(_data, "sexActivity", null)
	if(activityData == null):
		sexActivity = null
	elif(activityData is Dictionary):
		sexActivity = GlobalRegistry.createSexActivity(SAVE.loadVar(activityData, "id", ""))
		sexActivity.setSexEngine(self)
		sexActivity.loadNetworkData(SAVE.loadVar(activityData, "data", {}))
	
	anim_scene_player.loadNetworkData(SAVE.loadVar(_data, "animPlayer", {}))
