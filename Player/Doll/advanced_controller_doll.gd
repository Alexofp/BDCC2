extends CharacterBody3D
# https://github.com/Jamsers/Godot-Human-For-Scale

const LOOK_SENSITIVITY = 0.0025
const LOOK_LIMIT_UPPER = 1.15
const LOOK_LIMIT_LOWER = -1.15
const ANIM_MOVE_SPEED = 3
const ANIM_RUN_SPEED = 5.5
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
var noclip_on = false
var mousecapture_on = false
var rigidbody_collisions = []
var input_velocity = Vector3.ZERO
var anim_player

var mouse_movement = Vector2.ZERO
var forward_isdown = false
var backward_isdown = false
var left_isdown = false
var right_isdown = false
var sprint_isdown = false
var jump_isdown = false
var noclip_isdown = false
var mousecapture_isdown = false

func getDoll() -> Doll:
	return $ModelRoot/Doll.getDoll()

func _ready():
	basis = Basis.IDENTITY
	#anim_player = $"ModelRoot/mannequiny-0_3_0/AnimationPlayer"
	#anim_player.playback_default_blend_time = 0.75

func process_input_human():
	forward_isdown = Input.is_action_pressed("move_forward")
	backward_isdown = Input.is_action_pressed("move_back")
	left_isdown = Input.is_action_pressed("move_left")
	right_isdown = Input.is_action_pressed("move_right")
	jump_isdown = Input.is_action_pressed("move_jump")
	sprint_isdown = Input.is_action_pressed("move_sprint")
	
	noclip_isdown = Input.is_action_just_pressed("debug_noclip")
	mousecapture_isdown = Input.is_action_just_pressed("debug_mousecapture")

func _process(delta):
	process_input_human()
	process_mousecapture(delta)
	process_camera()
	process_movement()
	process_animation(delta)
	process_noclip(delta)
	
	var move_speed = ANIM_MOVE_SPEED * MOVE_MULT
	if sprint_isdown:
		move_speed = ANIM_RUN_SPEED * RUN_MULT
	
	if noclip_on:
		velocity = move_direction * (move_speed * NOCLIP_MULT)
	else:
		velocity.x = move_direction_no_y.x * move_speed 
		velocity.z = move_direction_no_y.z * move_speed
		if not is_on_floor():
			velocity.y -= GRAVITY_FORCE * delta
		if jump_isdown and is_on_floor():
			velocity.y = JUMP_FORCE
	
	input_velocity = velocity
	
	move_and_slide()
	
	rigidbody_collisions = []
	
	for index in get_slide_collision_count():
		var collision = get_slide_collision(index)
		if collision.get_collider() is RigidBody3D:
			rigidbody_collisions.append(collision)

func _physics_process(delta):
	var central_multiplier = input_velocity.length() * COLLIDE_FORCE
	var directional_multiplier = input_velocity.length() * (COLLIDE_FORCE/DIRECTIONAL_FORCE_DIV)
	
	for collision in rigidbody_collisions:
		var direction = -collision.get_normal()
		var location = collision.get_position()
		collision.get_collider().apply_central_impulse(direction * central_multiplier)
		collision.get_collider().apply_impulse(direction * directional_multiplier, location)

func process_mousecapture(delta):
	if(mousecapture_isdown):
		mousecapture_on = !mousecapture_on
	
	if mousecapture_on:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func process_camera():
	var camera_rotation_euler = camera_rotation.get_euler()
	
	if mousecapture_on:
		camera_rotation_euler += Vector3(mouse_movement.y, mouse_movement.x, 0) * LOOK_SENSITIVITY
		camera_rotation_euler.x = clamp(camera_rotation_euler.x, LOOK_LIMIT_LOWER, LOOK_LIMIT_UPPER)
	
	camera_rotation = Quaternion.from_euler(camera_rotation_euler)
	$CameraPivot.basis = Basis(camera_rotation)
	camera_rotation_no_y = Basis($CameraPivot.basis.x, Vector3.UP, $CameraPivot.basis.z).get_rotation_quaternion()
	
	mouse_movement = Vector2.ZERO

func process_movement():
	var input_direction = Vector3.ZERO
	
	if forward_isdown:
		input_direction.z -= 1.0
	if backward_isdown:
		input_direction.z += 1.0
	if left_isdown:
		input_direction.x -= 1.0
	if right_isdown:
		input_direction.x += 1.0
	
	move_direction = camera_rotation * input_direction
	move_direction_no_y = camera_rotation_no_y * input_direction
	move_direction = move_direction.normalized()
	move_direction_no_y = move_direction_no_y.normalized()

func process_animation(delta):
	if(anim_player != null):
		if !is_on_floor():
			anim_player.play("Fall")
		elif move_direction != Vector3.ZERO:
			if sprint_isdown:
				anim_player.play("Run", -1, RUN_MULT)
			else:
				anim_player.play("Jog", -1, MOVE_MULT)
		else:
			anim_player.play("Idle")
	
	if move_direction != Vector3.ZERO:
		$ModelRoot.basis = basis_rotate_toward($ModelRoot.basis, Basis.looking_at(-move_direction_no_y), ROTATE_SPEED * delta)

func process_noclip(delta):
	if(noclip_isdown):
		noclip_on = !noclip_on
		$CollisionShape.disabled = !$CollisionShape.disabled

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouse_movement -= event.relative

static func rotate_toward(from: Quaternion, to: Quaternion, delta: float) -> Quaternion:
	return from.slerp(to, clamp(delta / from.angle_to(to), 0.0, 1.0)).normalized()

static func basis_rotate_toward(from: Basis, to: Basis, delta: float) -> Basis:
	return Basis(rotate_toward(from.get_rotation_quaternion(), to.get_rotation_quaternion(), delta)).orthonormalized()
