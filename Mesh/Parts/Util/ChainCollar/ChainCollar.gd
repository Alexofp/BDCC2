extends Node3D

@onready var doll_leash_point: DollLeashPoint = %DollLeashPoint

func _ready() -> void:
	_on_doll_leash_point_on_leash_change()

func _on_doll_leash_point_on_leash_change() -> void:
	if(doll_leash_point.isSomethingConnected()):
		visible = true
	else:
		visible = false
