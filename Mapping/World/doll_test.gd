extends Node3D

var player:BaseCharacter = BaseCharacter.new()
@onready var doll: Doll = $Doll

func _ready() -> void:
	doll.setCharacter(player)
	
