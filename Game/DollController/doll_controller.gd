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

var move_direction = Vector3.ZERO
var move_direction_no_y = Vector3.ZERO
var camera_rotation = Quaternion.IDENTITY
var camera_rotation_no_y = Quaternion.IDENTITY
@export var noclip_on:bool = false
var mousecapture_on = true
var rigidbody_collisions = []
var input_velocity = Vector3.ZERO
var anim_player

@export var syncPosition:Vector3 = Vector3.ZERO
@export var syncRotation:Vector3 = Vector3.ZERO

@onready var doll_controls: DollControls = %DollControls
#var mouse_movement = Vector2.ZERO
#@export var sprint_isdown:bool = false
#var jump_isdown = false
#var noclip_isdown = false
#var mousecapture_isdown = false
#@export var input_dir:Vector2 = Vector2.ZERO
#@export var camera_dir:Vector2 = Vector2.ZERO

@onready var SpringArm = %SpringArm
@onready var CameraPivot = %CameraPivot
@onready var doll: Doll = %Doll
@onready var model_root: Node3D = %ModelRoot
@onready var interactor: Interactor = %Interactor
@onready var camera: PriorityCamera = %Camera

const STATE_NORMAL = "normal"
const STATE_SITTING = "sitting"

@export var state:String = STATE_NORMAL
@export var characterID:String: set = setCharacterID
var uniqueID:int = -1
#@onready var sit_node: SynchronizedTargetNode = %SitNode

@export var expressionState:int = DollExpressionState.Normal

func getNetworkPlayerID() -> int:
	for playerID in Network.players:
		var info:NetworkPlayerInfo = Network.players[playerID]
		if(info.charID == characterID):
			return playerID
	return -1

func setCharacterID(newID:String):
	characterID = newID
	Log.Print("setCharacterID "+str(newID))
	#getDoll().setCharacter(GM.characterRegistry.getCharacter(newID))

func processCharacterID():
	if(!GM.characterRegistry):
		return
	var theChar := GM.characterRegistry.getCharacter(characterID)
	if(!theChar):
		return
	if(theChar != getDoll().getChar()):
		getDoll().setCharacter(theChar)

func canSit() -> bool:
	return getState() == STATE_NORMAL


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

func processPoseSpot():
	var thePoseSpot:PoseSpot = getPoseSpot()
	if(!thePoseSpot):
		return
	global_position = thePoseSpot.global_position
	model_root.global_rotation = thePoseSpot.global_rotation

#func getBodySkeleton():
#	return getDoll().getBodySkeleton()
func setState(newState:String):
	state = newState
	
	if(state == STATE_SITTING):
		velocity = Vector3(0.0, 0.0, 0.0)

func getState() -> String:
	return state

func getDoll() -> Doll:
	return doll
	
func playDollAnim(_dollAnim:String, _howFast:float = 1.0):
	#getDoll().playAnim(dollAnim, howFast)
	pass

func _enter_tree() -> void:
	UIHandler.addMouseCapturer(self)

func _exit_tree() -> void:
	UIHandler.removeMouseCapturer(self)

func _ready():
	basis = Basis.IDENTITY
	SpringArm.add_excluded_object(self.get_rid())
	#anim_player = $"ModelRoot/mannequiny-0_3_0/AnimationPlayer"
	#anim_player.playback_default_blend_time = 0.75

	#if(Network.isMultiplayer()):
		#doll_controls.set_multiplayer_authority(networkPlayerID)
		#doll_controls.set_multiplayer_authority(networkPlayerID)
		#Log.Print("doll_controls.set_multiplayer_authority "+str(networkPlayerID))

	updateControlsMultiplayerAuthority()
	if(getPawn()):
		updatePoseSpot()

func reset_input():
	doll_controls.resetInput()
	
	#jump_isdown = false
	#noclip_isdown = false
	#mousecapture_isdown = false
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
	#mousecapture_isdown = Input.is_action_just_pressed("debug_mousecapture")

func syncVec3(ourVec3:Vector3, remoteVec3:Vector3, howSmooth:float = 0.9, autoSnapDist:float=0.02, tooBigSnapDist:float=3.0) -> Vector3:
	var result: Vector3 = ourVec3*howSmooth + remoteVec3*(1.0 - howSmooth)

	var globalDiff:float = ourVec3.distance_squared_to(remoteVec3)
	if(globalDiff < autoSnapDist*autoSnapDist || globalDiff > tooBigSnapDist*tooBigSnapDist):
		result = remoteVec3
	
	#var xdiff:float = abs(ourVec3.x - remoteVec3.x)
	#if(xdiff < autoSnapDist || xdiff > tooBigSnapDist):
		#result.x = remoteVec3.x
	#var ydiff:float = abs(ourVec3.y - remoteVec3.y)
	#if(ydiff < autoSnapDist || ydiff > tooBigSnapDist):
		#result.y = remoteVec3.y
	#var zdiff:float = abs(ourVec3.z - remoteVec3.z)
	#if(zdiff < autoSnapDist || zdiff > tooBigSnapDist):
		#result.z = remoteVec3.z
	
	return result
	
func syncRot3(ourVec3:Vector3, remoteVec3:Vector3, howSmooth:float = 0.8, autoSnapDist:float=0.02) -> Vector3:
	#print(ourVec3)
	#var result: Vector3 = ourVec3.lerp(remoteVec3, 1.0-howSmooth)
	var result: Vector3 = Vector3.ZERO
	result.x = lerp_angle(ourVec3.x, remoteVec3.x, 1.0 - howSmooth)
	result.y = lerp_angle(ourVec3.y, remoteVec3.y, 1.0 - howSmooth)
	result.z = lerp_angle(ourVec3.z, remoteVec3.z, 1.0 - howSmooth)

	var globalDiff:float = ourVec3.distance_squared_to(remoteVec3)
	if(globalDiff < autoSnapDist*autoSnapDist):
		result = remoteVec3
	
	#var xdiff:float = abs(ourVec3.x - remoteVec3.x)
	#if(xdiff < autoSnapDist || xdiff > tooBigSnapDist):
		#result.x = remoteVec3.x
	#var ydiff:float = abs(ourVec3.y - remoteVec3.y)
	#if(ydiff < autoSnapDist || ydiff > tooBigSnapDist):
		#result.y = remoteVec3.y
	#var zdiff:float = abs(ourVec3.z - remoteVec3.z)
	#if(zdiff < autoSnapDist || zdiff > tooBigSnapDist):
		#result.z = remoteVec3.z
	
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
	doll.setWalkAnim(theChar.getWalkAnim())
	doll.updatePose() # Could technically be removed, this is called in updateFromCharacter
	#doll.setIdleAnim(theChar.getIdleAnim())

func _process(delta:float):
	processFocus()
	processChar(delta)
	
	var hasAuthority:bool = !isRemote()
	var theIsControlledByUs:bool = isControlledByUs()#isControlledByPlayer()
	#camera.current = theIsControlledByUs
	#print(camera.current)
	
	if(hasAuthority):
		reset_input()
	if(theIsControlledByUs):
		doll_controls.processInput()
	
	processCharacterID()

	if(theIsControlledByUs):
		process_mousecapture(delta)
	if(theIsControlledByUs):
		process_camera_pivot()
	process_movement()
	if(hasAuthority):
		if(doll_controls.noclip_isdown):
			noclip_on = !noclip_on
	if(getState() == STATE_NORMAL):
		process_animation(delta)
	process_noclip(delta)
	
	if(!hasAuthority):
		position = syncVec3(position, syncPosition)
		model_root.rotation = syncRot3(model_root.rotation, syncRotation)
	
	if(getState() == STATE_NORMAL):
		processMove(delta)
	
	processPoseSpot()
	#if(getState() == STATE_SITTING): # SIT HACK. IMPLEMENT PROPER SIT SYNC
	#	playSitAnim()
	
	if(hasAuthority):
		syncPosition = position
		syncRotation = model_root.rotation
		
		processExpressionState(delta)
	doll.setExpressionState(expressionState)

func processExpressionState(_delta:float):
	var currentSex:SexEngine = GM.sexManager.getSexEngineOfCharID(characterID)
	if(currentSex):
		setExpressionState(currentSex.getExpressionState(characterID))
	else:
		setExpressionState(DollExpressionState.Normal)

func processMove(delta:float):
	if(!isRemote()):
		var move_speed: = ANIM_MOVE_SPEED * MOVE_MULT * getWalkSpeedMult()
		if doll_controls.sprint_isdown && canSprint():
			move_speed = ANIM_RUN_SPEED * RUN_MULT
			if(noclip_on):
				move_speed *= NOCLIP_MULT
		
		if noclip_on:
			velocity = move_direction * move_speed
		else:
			#var isOnFloor = is_on_floor()
			
			velocity.x = move_direction_no_y.x * move_speed 
			velocity.z = move_direction_no_y.z * move_speed
			
			# Uncomment for root motion
			#if(isOnFloor):
				#var current_dir_no_y = model_root.basis * Vector3.BACK
				#
				#var rootPos = getBodySkeleton().getRootPos()
				#velocity.x = current_dir_no_y.x * rootPos.z / delta * 2.0
				#velocity.z = current_dir_no_y.z * rootPos.z / delta * 2.0
			#else:
				## In air
				#velocity.x = move_direction_no_y.x * move_speed 
				#velocity.z = move_direction_no_y.z * move_speed
			if doll_controls.jump_isdown && is_on_floor() && !noclip_on:
				velocity.y = JUMP_FORCE * getJumpHeight()
	
	if !noclip_on:
		if not is_on_floor():
			velocity.y -= GRAVITY_FORCE * delta
		


func _physics_process(_delta:float):
	if(isControlledByUs()):
		process_camera()
	
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



func canScrollUp() -> bool:
	if(!GM.game || !GM.game.interact_ui):
		return true
	var interact_ui := GM.game.interact_ui
	if(!interact_ui.canScrollUp() || interact_ui.didScrollThisFrame()):
		return false
	return true

func canScrollDown() -> bool:
	if(!GM.game || !GM.game.interact_ui):
		return true
	var interact_ui := GM.game.interact_ui
	if(!interact_ui.canScrollDown() || interact_ui.didScrollThisFrame()):
		return false
	return true

func process_mousecapture(_delta:float):
	if(doll_controls.mousecapture_isdown):
		mousecapture_on = !mousecapture_on
	
	#if mousecapture_on && !UIHandler.hasAnyUIVisible():
	#	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#else:
	#	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func shouldCaptureMouse() -> bool:
	if mousecapture_on && !UIHandler.hasAnyUIVisible():
		return true
	return false

func process_camera_pivot():
	if(!camera.isActive()):
		return
	var camera_rotation_euler = camera_rotation.get_euler()
	
	camera_rotation_euler += Vector3(doll_controls.camera_dir.y, doll_controls.camera_dir.x, 0.0) * LOOK_SENSITIVITY_TOUCH * (-1.0 if getDoll().isFirstPerson() else 1.0)
	if mousecapture_on:
		camera_rotation_euler += Vector3(doll_controls.mouse_movement.y, doll_controls.mouse_movement.x, 0) * LOOK_SENSITIVITY
	camera_rotation_euler.x = clamp(camera_rotation_euler.x, LOOK_LIMIT_LOWER, LOOK_LIMIT_UPPER)
	
	camera_rotation = Quaternion.from_euler(camera_rotation_euler)
	CameraPivot.basis = Basis(camera_rotation)
	camera_rotation_no_y = Basis(CameraPivot.basis.x, Vector3.UP, CameraPivot.basis.z).get_rotation_quaternion()
	
	doll_controls.mouse_movement = Vector2.ZERO
	
	if(!UIHandler.hasAnyUIVisible()):
		if(Input.is_action_just_pressed("camera_zoomin") && canScrollDown()):
			SpringArm.spring_length -= 0.1
		if(Input.is_action_just_pressed("camera_zoomout") && canScrollUp()):
			SpringArm.spring_length += 0.1
	

	if(!processDollPoseCamera()):
		if(SpringArm.spring_length <= 0.0):
			SpringArm.spring_length = 0.0
			SpringArm.position.x = 0.0
		elif(SpringArm.spring_length <= 1.0):
			SpringArm.position.x = 0.1
			CameraPivot.position.y = 1.525
		else:
			SpringArm.position.x = 0.3
			CameraPivot.position.y = 1.125
	
	#if(getDoll().isFirstPerson()):
	#	CameraPivot.position = model_root.basis * Vector3(0.0, 1.625, 0.1)
	#var theSpot := getPoseSpot()
	if(getState() == STATE_NORMAL):
		CameraPivot.position.x = 0
		CameraPivot.position.z = 0
	else:
		SpringArm.position.x = 0.0
		#SpringArm.position.z = 0.0
		CameraPivot.global_position = getBodySkeleton().getChestBoneAttachment().global_position + Vector3(0.0, 0.3, 0.0)


func process_camera():
	if(!camera.isActive()):
		return

func processDollPoseCamera() -> bool:
	# Maybe all of this should happen inside the base character
	var theChar:BaseCharacter = getCharacter()
	if(!theChar || theChar.getIdlePose() == ""):
		return false
	var theDollPose:DollPoseBase = GlobalRegistry.getDollPose(theChar.getIdlePose())
	if(!theDollPose || !theDollPose.hasCustomCamera()):
		return false
	var theCameraOffset:Vector2 = theDollPose.processCamera(SpringArm.spring_length)
	SpringArm.position.x = theCameraOffset.x
	CameraPivot.position.y = theCameraOffset.y
	return true

func getGlobalChestBonePosition() -> Vector3:
	return getBodySkeleton().getChestBoneAttachment().global_position

func process_movement():
	#var input_direction = Vector3.ZERO
	#
	#input_direction.z = doll_controls.input_dir.y
	#input_direction.x = doll_controls.input_dir.x
	#
	#move_direction = camera_rotation * input_direction
	#move_direction_no_y = camera_rotation_no_y * input_direction
	#move_direction = move_direction.normalized()
	#move_direction_no_y = move_direction_no_y.normalized()
	move_direction = doll_controls.move_direction
	move_direction_no_y = doll_controls.move_direction_no_y


var recordedVelocity:Vector3
func process_animation(delta):
	if(getDoll() != null):
		#var bodySkeleton = getBodySkeleton()
		#bodySkeleton.rollOnLand = (recordedVelocity.y < -10.0)
		recordedVelocity = velocity
		if !is_on_floor():
			getDoll().animFall()
			##playDollAnim(DollAnim.Fall)
			##bodySkeleton.jump()
		elif move_direction != Vector3.ZERO:
			if doll_controls.sprint_isdown && canSprint():
				##playDollAnim(DollAnim.Run)
				##bodySkeleton.run()
				getDoll().animRun()
			else:
				##playDollAnim(DollAnim.Walk)
				##bodySkeleton.walk()
				getDoll().animWalk()
		else:
			##playDollAnim(DollAnim.Idle)
			##bodySkeleton.stand()
			getDoll().animStand()
	
	if move_direction != Vector3.ZERO && !isRemote():
		model_root.basis = basis_rotate_toward(model_root.basis, Basis.looking_at(-move_direction_no_y), ROTATE_SPEED * delta)

func isRemote() -> bool:
	return Network.isMultiplayer() && !is_multiplayer_authority()

func process_noclip(_delta):
	$CollisionShape.disabled = noclip_on || (state == STATE_SITTING)

func _unhandled_input(_event):
	if(UIHandler.hasAnyUIVisible()):
		return
	#
	#if _event is InputEventMouseMotion:
		#mouse_movement -= _event.relative

func rotate_toward(from: Quaternion, to: Quaternion, delta: float) -> Quaternion:
	return from.slerp(to, clamp(delta / from.angle_to(to), 0.0, 1.0)).normalized()

func basis_rotate_toward(from: Basis, to: Basis, delta: float) -> Basis:
	return from.slerp(to, delta)
	#return Basis(rotate_toward(from.get_rotation_quaternion(), to.get_rotation_quaternion(), delta)).orthonormalized()

func isControlledByPlayer() -> bool:
	return GM.pcDoll == self

func grabControl():
	#GM.setCurrentDoll(self)
	pass

func onGainControl():
	#camera.current = true
	#interact_ui.visible = true
	#updateControlsMultiplayerAuthority()
	pass

func onLoseControl():
	#camera.current = false
	#interact_ui.visible = false
	#updateControlsMultiplayerAuthority()
	pass

func getInteractor() -> Interactor:
	return interactor

func updatePoseSpot():
	var theSpot := getPoseSpot()
	
	if(!theSpot):
		doll.setAnimPlayerEnabled(true)
		#if(getState() != STATE_NORMAL):
		getBodySkeleton().resetBones()
		getDoll().alignPenisToVagina(null)
		setState(STATE_NORMAL)
		
		# Bad code?
		var theChar:BaseCharacter = getCharacter()
		if(theChar):
			theChar.triggerUpdatePartFilter()
	else:
		doll.setAnimPlayerEnabled(false)
		#if(getState() != STATE_SITTING):
		setState(STATE_SITTING)
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
	return getNetworkPlayerID() == Network.getMultiplayerID()

func saveNetworkData() -> Dictionary:
	return {
		charID = characterID,
		UID = uniqueID,
	}

func loadNetworkData(_data:Dictionary):
	characterID = SAVE.loadVar(_data, "charID", characterID)
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
		Log.Print("doll_controls.set_multiplayer_authority "+str(NID))

var cachedNID:int = -1
func processFocus():
	var NID:int = getNetworkPlayerID()
	var myNID:int = Network.getMultiplayerID()
	
	#if(Network.isServer()):
	#	Log.Print(str(NID))
	
	if(cachedNID != NID):
		if(NID == myNID):
			onGainControl()
			GM.dollHolder.notifyCurrentDollSwitch(self)
		elif(cachedNID == myNID):
			onLoseControl()
		updateControlsMultiplayerAuthority()
	
	cachedNID = NID

func getPawn() -> CharacterPawn:
	return GM.pawnRegistry.getPawn(characterID)

func getCharacter() -> BaseCharacter:
	return GM.characterRegistry.getCharacter(characterID)

func onSeatChange(_newSpot:PoseSpot):
	updatePoseSpot()

func setExpressionState(newExpr:int):
	if(newExpr == DollExpressionState.IgnoreChange):
		return
	expressionState = newExpr
