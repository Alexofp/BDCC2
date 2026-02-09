extends Node
class_name DollControls
@onready var doll_controller: DollController = $".."

var mouse_movement:Vector2 = Vector2.ZERO
@export var sprint_isdown:bool = false
@export var jump_isdown := false
@export var noclip_isdown := false
@export var input_dir:Vector2 = Vector2.ZERO
@export var camera_dir:Vector2 = Vector2.ZERO

@export var move_direction:Vector3 = Vector3.ZERO
@export var move_direction_no_y:Vector3 = Vector3.ZERO

@export var combatMode_isDown:bool = false
@export var attack_isDown:bool = false

@export var pid:int = 1: set = setPID

signal multiplayerAuthorityUpdate

#func _ready():
#	NetworkTime.before_tick_loop.connect(doInputGather)

#func doInputGather():
	#resetInput()
	#processInput()

func setPID(newPid:int):
	pid = newPid
	set_multiplayer_authority(newPid)
	multiplayerAuthorityUpdate.emit()

func resetInput():
	if(Network.isMultiplayer() && !is_multiplayer_authority()):
		return
	jump_isdown = false
	noclip_isdown = false
	sprint_isdown = false
	input_dir = Vector2.ZERO
	camera_dir = Vector2.ZERO
	move_direction = Vector3.ZERO
	move_direction_no_y = Vector3.ZERO
	combatMode_isDown = false
	attack_isDown = false


func processInput():
	if(Network.isMultiplayer() && !is_multiplayer_authority()):
		#Log.Print("Meow")
		return
	if(!doll_controller.isControlledByUs()):
		return
	if(UIHandler.isGameplayInputBlocked()):
		return
	if(!doll_controller.camera.isActive()):
		return
	#Log.Print("Meow "+str(get_path()))
	input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_forward", "move_back")
	camera_dir = Vector2.ZERO
	camera_dir.x = Input.get_axis("camera_left", "camera_right") * OPTIONS.controls.cameraSensitivityGamepad
	camera_dir.y = Input.get_axis("camera_up", "camera_down")  * OPTIONS.controls.cameraSensitivityGamepad * (-1.0 if OPTIONS.controls.invertYGamepad else 1.0)
	jump_isdown = Input.is_action_pressed("move_jump") || Input.is_action_just_pressed("move_jump")
	sprint_isdown = Input.is_action_pressed("move_sprint")
	
	noclip_isdown = Input.is_action_just_pressed("debug_noclip")
	combatMode_isDown = Input.is_action_just_pressed("game_combatmode")
	attack_isDown = Input.is_action_just_pressed("combat_attack")
	#print(input_dir)

	var input_direction: = Vector3.ZERO
	input_direction.z = input_dir.y
	input_direction.x = input_dir.x
	move_direction = doll_controller.camera_rotation * input_direction
	move_direction_no_y = doll_controller.camera_rotation_no_y * input_direction
	move_direction = move_direction.normalized()
	move_direction_no_y = move_direction_no_y.normalized()
	
	#if(Input.is_action_just_pressed("move_jump")):
	#	GI.sendPingToServer()
	#if(Input.is_action_just_pressed("move_jump")):
	#	Network.getMyPlayerInfo().changeCurrentCharID("")

func _unhandled_input(event):
	if(Network.isMultiplayer() && !is_multiplayer_authority()):
		return
	if(UIHandler.hasAnyUIVisible()):
		return
	if(!doll_controller.isControlledByUs()):
		return
	if(!doll_controller.camera.isActive()):
		return
	
	if event is InputEventMouseMotion:
		mouse_movement -= event.relative * OPTIONS.controls.cameraSensitivity * Vector2(1.0, -1.0 if OPTIONS.controls.invertY else 1.0)
