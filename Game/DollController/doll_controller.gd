extends CharacterBody3D
class_name DollController
# https://github.com/Jamsers/Godot-Human-For-Scale

const LOOK_SENSITIVITY = 0.0025
const LOOK_SENSITIVITY_TOUCH = 0.05
const LOOK_LIMIT_UPPER = 1.55
const LOOK_LIMIT_LOWER = -1.55
const ANIM_MOVE_SPEED = 1.2
const ANIM_RUN_SPEED = 3.5
const MOVE_MULT = 1.4
const RUN_MULT = 1.25
const NOCLIP_MULT = 4
const ROTATE_SPEED = 12.0
const JUMP_FORCE = 15.0
const GRAVITY_FORCE = 50.0
const COLLIDE_FORCE = 0.05
const DIRECTIONAL_FORCE_DIV = 30.0
const TOGGLE_COOLDOWN = 0.5

var move_direction:Vector3 = Vector3.ZERO
var move_direction_no_y:Vector3 = Vector3.ZERO
var camera_rotation:Quaternion = Quaternion.IDENTITY
var camera_rotation_no_y:Quaternion = Quaternion.IDENTITY
var targetLookDir:Vector3 = Vector3.ZERO
@export var noclip_on:bool = false
var mousecapture_on:bool = true
var rigidbody_collisions:Array = []
var input_velocity:Vector3 = Vector3.ZERO

@export var syncPosition:Vector3 = Vector3.ZERO
@export var syncRotation:Vector3 = Vector3.ZERO

@export var isRunning:bool = false
var yankWalkDir:Vector3 = Vector3.ZERO
var knockbackVelocity:Vector3

var isOnFloorVisually:bool = false
var isOnFloorVisuallyFrames:int = 0
var gotOntoFloorThisFrame:bool = false

@onready var doll_controls: DollControls = %DollControls
#var mouse_movement = Vector2.ZERO
#@export var sprint_isdown:bool = false
#var jump_isdown = false
#var noclip_isdown = false
#@export var input_dir:Vector2 = Vector2.ZERO
#@export var camera_dir:Vector2 = Vector2.ZERO
@onready var backup_leash_point: DollLeashPoint = %BackupLeashPoint
@onready var SpringArm: SpringArm3D = %SpringArm
@onready var CameraPivot: Node3D = %CameraPivot
@onready var doll: Doll = %Doll
@onready var model_root: Node3D = %ModelRoot
@onready var camera: PriorityCamera = %Camera
@onready var typing_status_reset_timer: Timer = %TypingStatusResetTimer

#const STATE_NORMAL = "normal"
#const STATE_SITTING = "sitting"

var typingStatus:int = GI.TYPING_NONE
#@export var state:String = STATE_NORMAL
var uniqueID:int = -1
#@onready var sit_node: SynchronizedTargetNode = %SitNode

var pawn:CharacterPawn

@export var expressionState:int = DollExpressionState.Normal

var hoverTexts:Array = []

signal onGesturePlay(gestureID, playFullBody, playPartial)

func getNetworkPlayerID() -> int:
	return Network.getPlayerIDWhoControls(pawn.id)

func processCharacterID():
	var theChar := pawn.getCharacter()
	if(!theChar):
		return
	if(theChar != getDoll().getChar()):
		getDoll().setCharacter(theChar)

func canSit() -> bool:
	return pawn.state.canSit()

#func playSitAnim():
#	doll.animSit()

func setPoseSpot(newSpot:PoseSpot):
	var thePawn := getPawn()
	if(Network.isServer() && thePawn):
		thePawn.setPoseSpot(newSpot)
	#if(Network.isServer()):
	#	sit_node.setNode(newSpot)
	#if(newSpot == null):
		#var currentSpot:PoseSpot = getPoseSpot()
		#poseSpotRef = null
		#if(currentSpot):
			#currentSpot.unSit()
			#model_root.global_rotation = Vector3(0.0, 0.0, 0.0)
		#return
	#poseSpotRef = weakref(newSpot)

func getPoseSpot() -> PoseSpot:
	var thePawn := getPawn()
	if(!thePawn):
		#assert(false, "WTF")
		return null
	return thePawn.getPoseSpot()



#func getBodySkeleton():
#	return getDoll().getBodySkeleton()
func setState(newState:int):
	pawn.setState(newState)

func getState() -> int:
	return pawn.pawnState

func getDoll() -> Doll:
	return doll
	
func playDollAnim(_dollAnim:String, _howFast:float = 1.0):
	#getDoll().playAnim(dollAnim, howFast)
	pass

func _enter_tree() -> void:
	UIHandler.addMouseCapturer(self)

func _exit_tree() -> void:
	UIHandler.removeMouseCapturer(self)

func shouldCaptureMouse() -> bool:
	if(Input.is_physical_key_pressed(KEY_ALT)):
		return false
	if mousecapture_on && !UIHandler.hasAnyUIVisible() && isControlledByUs():
		return true
	return false

func _ready():
	basis = Basis.IDENTITY
	SpringArm.add_excluded_object(self.get_rid())

	processFocus()
	if(getPawn()):
		updatePoseSpot()

func reset_input():
	doll_controls.resetInput()
	
	#jump_isdown = false
	#noclip_isdown = false
	#if(isRemote()):
		#return
	#sprint_isdown = false
	#input_dir = Vector2.ZERO
	#camera_dir = Vector2.ZERO

func process_input_human():
	if(isRemote() || !isControlledByPlayer()):
		return
	#doll_controls.processInput()
	#input_dir = Vector2.ZERO
	#input_dir.x = Input.get_axis("move_left", "move_right")
	#input_dir.y = Input.get_axis("move_forward", "move_back")
	#camera_dir = Vector2.ZERO
	#camera_dir.x = Input.get_axis("camera_left", "camera_right")
	#camera_dir.y = Input.get_axis("camera_up", "camera_down")
	#jump_isdown = Input.is_action_pressed("move_jump")
	#sprint_isdown = Input.is_action_pressed("move_sprint")
	#
	#noclip_isdown = Input.is_action_just_pressed("debug_noclip")

func syncVec3(ourVec3:Vector3, remoteVec3:Vector3, howSmooth:float = 0.9, autoSnapDist:float=0.02, tooBigSnapDist:float=3.0) -> Vector3:
	var result: Vector3 = ourVec3*howSmooth + remoteVec3*(1.0 - howSmooth)

	var globalDiff:float = ourVec3.distance_squared_to(remoteVec3)
	if(globalDiff < autoSnapDist*autoSnapDist || globalDiff > tooBigSnapDist*tooBigSnapDist):
		result = remoteVec3

	return result
	
func syncRot3(ourVec3:Vector3, remoteVec3:Vector3, howSmooth:float = 0.8, autoSnapDist:float=0.02) -> Vector3:
	var result: Vector3 = Vector3.ZERO
	result.x = lerp_angle(ourVec3.x, remoteVec3.x, 1.0 - howSmooth)
	result.y = lerp_angle(ourVec3.y, remoteVec3.y, 1.0 - howSmooth)
	result.z = lerp_angle(ourVec3.z, remoteVec3.z, 1.0 - howSmooth)

	var globalDiff:float = ourVec3.distance_squared_to(remoteVec3)
	if(globalDiff < autoSnapDist*autoSnapDist):
		result = remoteVec3
	
	return result

func getWalkSpeedMult() -> float:
	var theChar:= getCharacter()
	if(!theChar):
		return 1.0
	return theChar.getWalkSpeed()

func canSprint() -> bool:
	var theChar:= getCharacter()
	if(!theChar):
		return true
	return theChar.canSprint()

func getJumpHeight() -> float:
	var theChar:= getCharacter()
	if(!theChar):
		return 1.0
	return theChar.getJumpHeight()

func processChar(_delta:float):
	var theChar:= getCharacter()
	if(!theChar):
		return
	#TODO: Make this work using signals rather than constant pulling?
	doll.setIdleAnim(theChar.getIdleAnim())
	doll.setWalkAnim(theChar.getWalkAnim())
	doll.updatePose() # Could technically be removed, this is called in updateFromCharacter
	#doll.setIdleAnim(theChar.getIdleAnim())

func addKnockback(_vel:Vector3):
	knockbackVelocity += _vel

func _process(delta:float):
	#processFocus()
	processChar(delta)
	
	var hasAuthority:bool = !isRemote()
	var theIsControlledByUs:bool = isControlledByUs()#isControlledByPlayer()
	
	#DEBUG: debug stuff
	#if(theIsControlledByUs && OS.is_debug_build() && Input.is_action_just_pressed("debug_4")):
	#	ShaderNodeChecker.checkNode(self)
	#if(theIsControlledByUs && OS.is_debug_build() && Input.is_action_just_pressed("debug_3")):
		#print(GM.main.checkCanLean(global_position, model_root.global_rotation))
	if(theIsControlledByUs && OS.is_debug_build() && Input.is_action_just_pressed("debug_3")):
		GlobalRegistry.reloadCombatMoves()
	if(theIsControlledByUs && OS.is_debug_build() && Input.is_action_just_pressed("debug_2")):
		#getDoll().applyHitSpecific(4.0, Vector3(1.0, 0.0, 0.0))
		#addKnockback(Vector3(11.0, 10.0, 0.0))
		getPawn().sendFlying(Vector3(10.0, 0.0, 0.0), 10.0)
		#getPawn().doStagger()
		#print(GM.main.checkCanLean(global_position, model_root.global_rotation))
	#if(theIsControlledByUs):
	#	print(GI.world.getNearbyWanderAreas(global_position, 5.0))
	#end of debug stuff
	
	#if(theIsControlledByUs && hasAuthority):
		#reset_input()
	#if(theIsControlledByUs):
	#	doll_controls.processInput()
	
	processCharacterID()

	pawn.state.processTick(self, delta)
	process_noclip(delta)
	
	var theSpeed := pawn.state.getRotationToTargetSpeed(self)
	if(theSpeed > 0.0 && targetLookDir.length_squared() > 0.1):
		rotateTowardsDirection(delta*theSpeed, targetLookDir)
		#targetLookDir = Vector3.ZERO
	
	if(!hasAuthority):
		position = syncVec3(position, syncPosition)
		model_root.rotation = syncRot3(model_root.rotation, syncRotation)
	
	if(hasAuthority):
		syncPosition = position
		syncRotation = model_root.rotation
		
		processExpressionState(delta)
	doll.setExpressionState(expressionState)

func rotateTowardsDirection(_dt:float, _dir:Vector3):
	if(Network.isClient()):
		return
	_dir.y = 0.0
	_dir = _dir.normalized()
	if _dir.length_squared() > 0.1 && !isRemote():
		model_root.basis = model_root.basis.slerp(Basis.looking_at(-_dir), ROTATE_SPEED * _dt)

func processExpressionState(_delta:float):
	var currentSex:SexEngine = GM.sexManager.getSexEngineOfCharID(pawn.id)
	if(currentSex):
		setExpressionState(currentSex.getExpressionState(pawn.id))
	else:
		setExpressionState(DollExpressionState.Normal)

func setYankDir(_dir:Vector3):
	yankWalkDir = _dir
		
func doJump():
	pawn.state.doJump(self)

func _physics_process(_delta:float):
	#var hasAuthority:bool = !isRemote()
	var theIsControlledByUs:bool = isControlledByUs()
	#if(theIsControlledByUs):
	processCameraBlindness()

	if(theIsControlledByUs):
		doll_controls.resetInput()
		doll_controls.processInput()
	#if(Input.is_action_pressed("move_jump")):
	#	print("JUMP")
	
	pawn.state.processPhysics(self, _delta)

	var hasAuthority:bool = !isRemote()
	if(hasAuthority):
		if(doll_controls.noclip_isdown):
			noclip_on = !noclip_on

	var isOnTheFloor := is_on_floor()
	gotOntoFloorThisFrame = false
	if(isOnTheFloor):
		if(!isOnFloorVisually):
			isOnFloorVisually = true
			gotOntoFloorThisFrame = true
		isOnFloorVisuallyFrames = 2
	elif(isOnFloorVisually):
		isOnFloorVisuallyFrames -= 1
		if(isOnFloorVisuallyFrames <= 0):
			isOnFloorVisually = false

	input_velocity = velocity
	move_and_slide()
	
	rigidbody_collisions = []
	
	for index in get_slide_collision_count():
		var collision = get_slide_collision(index)
		if collision.get_collider() is RigidBody3D:
			rigidbody_collisions.append(collision)
	
	var central_multiplier = input_velocity.length() * COLLIDE_FORCE * 3.0
	var directional_multiplier = input_velocity.length() * (COLLIDE_FORCE/DIRECTIONAL_FORCE_DIV) * 3.0
	
	for collision in rigidbody_collisions:
		var direction = -collision.get_normal()
		var location = collision.get_position()
		collision.get_collider().apply_central_impulse(direction * central_multiplier)
		collision.get_collider().apply_impulse(direction * directional_multiplier, location)
	
	processHoverText(_delta)


func canScrollUp() -> bool:
	if(!GM.main || !GM.main.interact_ui):
		return true
	var interact_ui := GM.main.interact_ui
	if(!interact_ui.canScrollUp() || interact_ui.didScrollThisFrame()):
		return false
	return true

func canScrollDown() -> bool:
	if(!GM.main || !GM.main.interact_ui):
		return true
	var interact_ui := GM.main.interact_ui
	if(!interact_ui.canScrollDown() || interact_ui.didScrollThisFrame()):
		return false
	return true

func processCameraBlindness():
	if(!isControlledByUs()):
		doll.blindness_quad_effect.visible = false
		return
	var theCharacter := getCharacter()
	if(theCharacter && theCharacter.isBlind()):
		doll.blindness_quad_effect.visible = true
	else:
		doll.blindness_quad_effect.visible = false
	#print(getCurrentGlobalAnimKey())
	
# Gonna be used for anim tweaking
func getCurrentGlobalAnimKey() -> String:
	if(getState() == CharacterPawn.STATE_NORMAL):
		var theDoll := getDoll()
		if(!theDoll):
			return ""
		return theDoll.getCurrentLocomotionAnim()
	if(getState() == CharacterPawn.STATE_SITTING):
		var _theSeat := GM.sitManager.getSeatOfDoll(self)
		if(_theSeat):
			return _theSeat.dollAnimKey
	return ""

func getCurrentLocomotionAnim() -> String:
	if(getState() != CharacterPawn.STATE_NORMAL):
		return ""
	var theDoll := getDoll()
	if(!theDoll):
		return ""
	return theDoll.getCurrentLocomotionAnim()

func processDollPoseCamera() -> bool:
	var theAnimID := getCurrentLocomotionAnim()
	if(theAnimID.is_empty() || !GlobalRegistry.hasDollAnim(theAnimID)):
		return false
	var theAnim:DollAnimBase = GlobalRegistry.getDollAnim(theAnimID)
	if(!theAnim.hasCustomCamera(theAnimID)):
		return false
	var theCameraOffset:Vector2 = theAnim.processCamera(theAnimID, SpringArm.spring_length)
	SpringArm.position.x = theCameraOffset.x
	CameraPivot.position.y = theCameraOffset.y
	return true

func getGlobalChestBonePosition() -> Vector3:
	return getBodySkeleton().getChestBoneAttachment().global_position

func isRemote() -> bool:
	return Network.isMultiplayer() && !is_multiplayer_authority()

func process_noclip(_delta):
	$CollisionShape.disabled = noclip_on || (getState() == CharacterPawn.STATE_SITTING)

func _unhandled_input(_event):
	if(UIHandler.hasAnyUIVisible()):
		return
	#
	#if _event is InputEventMouseMotion:
		#mouse_movement -= _event.relative


func isControlledByPlayer() -> bool:
	return GM.pcDoll == self

func isControlledByAnyPlayer() -> bool:
	return Network.getPlayerIDWhoControls(pawn.id) >= 0

func onGainControl():
	pass

func onLoseControl():
	pass

func updatePoseSpot():
	var theSpot := getPoseSpot()
	
	if(!theSpot):
		doll.setAnimationPartFlags({})
		doll.setAnimPlayerEnabled(true)
		#if(getState() != STATE_NORMAL):
		getBodySkeleton().resetBones()
		getDoll().alignPenisToVagina(null)
		if(getState() != CharacterPawn.STATE_NORMAL):
			# This prevents 2 dolls from occupying the same spot
			# Glitchy stuff happens otherwise
			position.x += RNG.randfRange(-0.1, 0.1)
			position.z += RNG.randfRange(-0.1, 0.1)
		
		# Bad code?
		var theChar:BaseCharacter = getCharacter()
		if(theChar):
			theChar.triggerUpdatePartFilter()
	else:
		doll.setAnimPlayerEnabled(false)
		#if(getState() != STATE_SITTING):
		
#
#func _on_sit_node_on_node_changed(newSpot: Variant) -> void:
	#if(newSpot == null):
		#var currentSpot:PoseSpot = getPoseSpot()
		#poseSpotRef = null
		#if(currentSpot):
			#currentSpot.unSit()
			#model_root.global_rotation = Vector3(0.0, 0.0, 0.0)
		#return
	#poseSpotRef = weakref(newSpot)
	#Log.Print(str(newSpot))

func getBodySkeleton() -> BodySkeleton:
	return doll.getBodySkeleton()

func isControlledByUs() -> bool:
	return Network.getPlayerIDWhoControls(pawn.id) == Network.getMultiplayerID()

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.StrShort, pawn.id,
		Bins.I32, uniqueID,
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	pawn = GM.pawnRegistry.getPawn(_data.readStrShort())
	uniqueID = _data.readI32()
	_data.endLoad()
	name = str(uniqueID)
	
	updateControlsMultiplayerAuthority()
	updatePoseSpot()

func saveData() -> Dictionary:
	return {
		charID = pawn.id,
		UID = uniqueID,
	}

func loadData(_data:Dictionary):
	pawn = GM.pawnRegistry.getPawn(SAVE.loadVar(_data, "charID", ""))
	uniqueID = SAVE.loadVar(_data, "UID", uniqueID)
	name = str(uniqueID)
	
	updateControlsMultiplayerAuthority()
	updatePoseSpot()

func updateControlsMultiplayerAuthority():
	if(Network.isMultiplayer()):
		var NID:int = getNetworkPlayerID()
		if(NID < 0):
			NID = 1
		doll_controls.set_multiplayer_authority(NID)
		#doll_controls.set_multiplayer_authority(networkPlayerID)
		#Log.Print("doll_controls.set_multiplayer_authority "+str(NID))

var isBeingControlledCached:bool = false
var cachedNID:int = -1
func processFocus():
	var theNID:int = getNetworkPlayerID()
	var doWeHaveControl := isControlledByUs()
	
	if(doWeHaveControl != isBeingControlledCached):
		if(doWeHaveControl):
			onGainControl()
		else:
			onLoseControl()
		
		isBeingControlledCached = doWeHaveControl
	
	if(theNID != cachedNID):
		updateControlsMultiplayerAuthority()
		cachedNID = theNID

func getPawn() -> CharacterPawn:
	return pawn

func getCharacter() -> BaseCharacter:
	return pawn.getCharacter()

func onSeatChange(_newSpot:PoseSpot):
	updatePoseSpot()

func setExpressionState(newExpr:int):
	if(newExpr == DollExpressionState.IgnoreChange):
		return
	expressionState = newExpr

# Disabled. Enable 'Monitoring' on the OtherDollsArea to make this work
var nearbyDolls:Array[DollController] = []
func _on_other_dolls_area_body_entered(body: Node3D) -> void:
	if(body is DollController):
		if(body == self):
			return
		nearbyDolls.append(body)
		body.tree_exiting.connect(_on_other_dolls_area_body_exited.bind(body))

func _on_other_dolls_area_body_exited(body: Node3D) -> void:
	if(body is DollController):
		nearbyDolls.erase(body)
		body.tree_exiting.disconnect(_on_other_dolls_area_body_exited.bind(body))

func getNearbyDolls() -> Array[DollController]:
	return nearbyDolls

func addHoverText(_text:String):
	hoverTexts.append([_text, 5.0])

func sayHoverText(_text:String):
	var hover_text := doll.getHoverText()
	hover_text.addText(_text)

func clearSayLocal():
	var hover_text := doll.getHoverText()
	hover_text.clearTexts()

func interruptSay(_text:String = "- ugh.."):
	doll.getHoverText().tryInterruptText(_text)

func addSmallText(_text:String, _color:Color = Color.WHITE):
	doll.getHoverText().addSmallText(_text, _color)

func processHoverText(_dt:float):
	var finalText:String = ""
	
	var hoverAm:int = hoverTexts.size()
	for _i in range(hoverAm):
		var _ii:int = (hoverAm - _i - 1)
		hoverTexts[_ii][1] -= _dt
		if(hoverTexts[_ii][1] <= 0.0):
			hoverTexts.remove_at(_ii)
	
	for theEntry in hoverTexts:
		finalText += theEntry[0] + "\n"
	
	if(typingStatus == GI.TYPING_ACTION):
		finalText += "( Emoting )" + "\n"
	elif(typingStatus == GI.TYPING_CHAT):
		finalText += "( Typing )" + "\n"
	
	var thePawn := getPawn()
	if(thePawn && thePawn.ai && !isControlledByAnyPlayer()):
		if(PawnAI.DEBUG_AI):
			var theAIText := thePawn.ai.getDebugText()
			if(!theAIText.is_empty()):
				finalText += theAIText+"\n"
		if(PawnAI.DEBUG_RELATIONSHIPS):
			var theLines := GM.main.relationshipSystem.getDebugTextLinesFor(thePawn)
			var theCharacter := thePawn.getCharacter()
			var theMemoryHolder := theCharacter.memoryHolder
			
			theLines.append_array(theMemoryHolder.getDebugLines())
			
			if(!theLines.is_empty()):
				finalText += Util.join(theLines, "\n")+"\n"
	
	
	var hover_text := doll.getHoverText()
	hover_text.setHoverText(finalText)
	
	#hover_text.setProgressInfos(["Doing something", "asd"], [0.3, 0.5])
	if(thePawn):
		hover_text.setProgressInfos(thePawn.progressBarsTextsCached, thePawn.progressBarsValuesCached)
	else:
		hover_text.setProgressInfos([], [])

func pushTypingStatus(_status:int):
	typingStatus = _status
	typing_status_reset_timer.start()

func resetTypingStatus():
	typingStatus = GI.TYPING_NONE
	typing_status_reset_timer.stop()

func _on_doll_on_gesture_play(gestureID: String, playFullBody: bool, playPartial: bool) -> void:
	onGesturePlay.emit(gestureID, playFullBody, playPartial)

func playGesture(gestureID: String):
	GM.dollHolder.askPlayGesture(self, gestureID)
	
func lookAt(_node:Node3D):
	getDoll().lookAt(_node)

func lookAtDoll(_doll:DollController):
	if(!_doll):
		lookAt(null)
	else:
		lookAt(_doll.getDoll().getEyesNode())

func applyHitRandom(_strength:float):
	doll.applyHitRandom(_strength)

func doStruggleAnimFor(_time:float):
	doll.doStruggleAnimFor(_time)

func getBackupDollLeashPoint() -> DollLeashPoint:
	return backup_leash_point

func _on_typing_status_reset_timer_timeout() -> void:
	typingStatus = GI.TYPING_NONE

func doCoupleAnimLocal(_animation:String):
	var theDoll := getDoll()
	if(_animation.is_empty()):
		theDoll.animation_tree.stopLayer(theDoll.animation_tree.LAYER_COUPLE)
		return
	theDoll.animation_tree.playLayer(theDoll.animation_tree.LAYER_COUPLE, _animation, 1.0, true)

func doCombatAnimLocal(_animation:String, _speedMult:float = 1.0, _forceAnim:bool = true):
	if(_animation.is_empty()):
		return
	var theDoll := getDoll()
	#theDoll.animation_tree.stopLayer(theDoll.animation_tree.LAYER_COMBAT, true)
	#await get_tree().process_frame
	theDoll.animation_tree.playLayer(theDoll.animation_tree.LAYER_COMBAT, _animation, _speedMult, _forceAnim)

func doDodgeAnimLocal(_dir:Vector2, _animation:String = "dodge", _speedMult:float = 1.0, _forceAnim:bool = true):
	if(_animation.is_empty()):
		return
	var theDoll := getDoll()
	#theDoll.animation_tree.stopLayer(theDoll.animation_tree.LAYER_COMBAT, true)
	#await get_tree().process_frame
	theDoll.animation_tree.playLayer(theDoll.animation_tree.LAYER_COMBAT, _animation, _speedMult, _forceAnim)
	theDoll.animation_tree.setBlend2DPos(theDoll.animation_tree.LAYER_COMBAT, _animation, _dir)
	
func stopCombatAnimLocal():
	var theDoll := getDoll()
	theDoll.animation_tree.stopLayer(theDoll.animation_tree.LAYER_COMBAT)

func getBodyGlobalRotation() -> Vector3:
	return model_root.global_rotation
	
func getBodyRotationGlobalBasis() -> Basis:
	return model_root.global_basis

func getLocalVelocity() -> Vector3:
	var rot_basis := model_root.global_basis.orthonormalized()
	return rot_basis.inverse()*velocity

func getYRotation() -> float:
	return model_root.global_rotation.y
