extends Node3D
@onready var leash_point1: LeashPoint = $TestPhysicsCube/LeashPoint
@onready var leash_point2: LeashPoint = $TestPhysicsCube2/LeashPoint

func _ready() -> void:
	GM.leashSystem.connectLeash(
		LeashPointConnection.createLeashpoint(leash_point1),
		LeashPointConnection.createLeashpoint(leash_point2),
		LeashSettings.createSimple()
	)
