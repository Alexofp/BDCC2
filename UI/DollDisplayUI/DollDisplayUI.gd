extends SubViewportContainer

@onready var sub_viewport: SubViewport = %SubViewport
@onready var directional_light_3d: DirectionalLight3D = %DirectionalLight3D
@onready var doll: Doll = %Doll
@onready var character_creator_camera_setup: CharacterCreatorCameraSetup = %CharacterCreatorCameraSetup

@export var cameraSetup:bool = true

var currentChar:BaseCharacter
var controllingCamera:bool = false

func _ready() -> void:
	if(!cameraSetup):
		character_creator_camera_setup.queue_free()
		character_creator_camera_setup = null

func setCharacter(_char:BaseCharacter):
	currentChar = _char
	doll.setCharacter(_char)

func clearCharacter():
	currentChar = null
	doll.setCharacter(null)

func _physics_process(_delta: float) -> void:
	if(currentChar):
		doll.currentIdleAnim = currentChar.idleAnim
		doll.currentWalkAnim = currentChar.walkAnim
	doll.animStand()

func loadFromPreset(_preset:CharacterPreset):
	if(!_preset):
		clearCharacter()
		return
	var _newChar:BaseCharacter = BaseCharacter.new()
	_newChar.inventory.clear()
	_preset.applyToCharacter(_newChar)
	setCharacter(_newChar)

func _on_gui_input(_event: InputEvent) -> void:
	if(!character_creator_camera_setup):
		return
	if(_event is InputEventMouseButton):
		if(_event.button_index in [MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MIDDLE]):
			if(_event.pressed):
				UIHandler.releaseUIFocus()
				controllingCamera = true
			else:
				controllingCamera = false
	character_creator_camera_setup.passInputEvent(_event, controllingCamera)

#func _input(event: InputEvent) -> void:
#	character_creator_camera_setup.passInputEvent(event, controllingCamera)

func getDoll() -> Doll:
	return doll

func getCameraSetup() -> CharacterCreatorCameraSetup:
	return character_creator_camera_setup
