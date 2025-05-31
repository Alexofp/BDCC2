@tool
extends "res://addons/godot-polyliner/Line3D/LinePath3D.gd"

@export var nodeA:Node3D
@export var nodeB:Node3D

func _process(_delta: float) -> void:
	if(!nodeA || !nodeB):
		#visible = false
		return
	#visible = true
	var theCurve:Curve3D = curve
	theCurve.set_point_position(0, to_local(nodeA.global_position))
	theCurve.set_point_position(1, to_local(nodeB.global_position))
