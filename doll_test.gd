extends Node3D

var player:BaseCharacter = BaseCharacter.new()
@onready var doll: Doll = $Doll
@onready var character_creator: Control = $CanvasLayer/CharacterCreator

func _init():
	GlobalRegistry.doInit()

func _ready() -> void:
	doll.setCharacter(player)
	
	character_creator.setCharacter(player)
