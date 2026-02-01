extends Node3D
class_name AIWanderArea

@export var radius:float = 10.0

func getRandomSpot() -> Vector3:
	return global_position + Vector3(RNG.randfRange(-radius, radius), 0.0, RNG.randfRange(-radius, radius))

func _enter_tree() -> void:
	World.addPOI(self)
