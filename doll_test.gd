extends Node3D

var player:BaseCharacter = BaseCharacter.new()
@onready var doll: Doll = $Doll
@onready var character_creator: Control = $CanvasLayer/CharacterCreator

@onready var animation_player: AnimationPlayer = %AnimationPlayer
var zoomProgress:float = 0.0

#func _init():
#	GlobalRegistry.doInit()

func _ready() -> void:
	doll.setCharacter(player)
	
	character_creator.setCharacter(player)
	
	animation_player.play("CameraZoom", 0.0, 0.0)

func _unhandled_input(event: InputEvent) -> void:
	if(event is InputEventMouseButton):
		if(event.button_index == MOUSE_BUTTON_WHEEL_UP):
			zoomProgress += 0.1
			zoomProgress = clamp(zoomProgress, 0.0, 1.0)
			animation_player.seek(zoomProgress, true)
		if(event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			zoomProgress -= 0.1
			zoomProgress = clamp(zoomProgress, 0.0, 1.0)
			animation_player.seek(zoomProgress, true)
		
