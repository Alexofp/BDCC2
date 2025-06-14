extends Node
class_name DollControls
@onready var doll_controller: DollController = $".."

var mouse_movement = Vector2.ZERO
@export var sprint_isdown:bool = false
@export var jump_isdown = false
@export var noclip_isdown = false
var mousecapture_isdown = false
@export var input_dir:Vector2 = Vector2.ZERO
@export var camera_dir:Vector2 = Vector2.ZERO

@export var move_direction:Vector3 = Vector3.ZERO
@export var move_direction_no_y:Vector3 = Vector3.ZERO

@export var pid:int = 1: set = setPID

func setPID(newPid:int):
	pid = newPid
	set_multiplayer_authority(newPid)

func resetInput():
	if(Network.isMultiplayer() && !is_multiplayer_authority()):
		return
	jump_isdown = false
	noclip_isdown = false
	mousecapture_isdown = false
	sprint_isdown = false
	input_dir = Vector2.ZERO
	camera_dir = Vector2.ZERO
	move_direction = Vector3.ZERO
	move_direction_no_y = Vector3.ZERO


func processInput():
	if(Network.isMultiplayer() && !is_multiplayer_authority()):
		#Log.Print("Meow")
		return
	if(!doll_controller.isControlledByUs()):
		return
	#Log.Print("Meow "+str(get_path()))
	input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_forward", "move_back")
	camera_dir = Vector2.ZERO
	camera_dir.x = Input.get_axis("camera_left", "camera_right")
	camera_dir.y = Input.get_axis("camera_up", "camera_down")
	jump_isdown = Input.is_action_pressed("move_jump")
	sprint_isdown = Input.is_action_pressed("move_sprint")
	
	noclip_isdown = Input.is_action_just_pressed("debug_noclip")
	mousecapture_isdown = Input.is_action_just_pressed("debug_mousecapture")
	#print(input_dir)

	var input_direction: = Vector3.ZERO
	input_direction.z = input_dir.y
	input_direction.x = input_dir.x
	move_direction = doll_controller.camera_rotation * input_direction
	move_direction_no_y = doll_controller.camera_rotation_no_y * input_direction
	move_direction = move_direction.normalized()
	move_direction_no_y = move_direction_no_y.normalized()
	
	if(Input.is_action_just_pressed("move_jump")):
		GameInteractor.sendPingToServer()

func _unhandled_input(event):
	if(Network.isMultiplayer() && !is_multiplayer_authority()):
		return
	if(UIHandler.hasAnyUIVisible()):
		return
	if(!doll_controller.isControlledByUs()):
		return
	
	if event is InputEventMouseMotion:
		mouse_movement -= event.relative
