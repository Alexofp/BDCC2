extends Node3D

var player:BaseCharacter = BaseCharacter.new()
@onready var doll_controller: CharacterBody3D = $DollController

#func _init():
#	GlobalRegistry.doInit()

func _ready() -> void:
	doll_controller.getDoll().setCharacter(player)
	$WorldEnvironment.environment.sdfgi_enabled = false
