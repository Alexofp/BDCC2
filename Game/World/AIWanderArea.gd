@tool
extends Node3D
class_name AIWanderArea

@export var radius:float = 10.0

func getRandomSpot() -> Vector3:
	return global_position + Vector3(RNG.randfRange(-radius, radius), 0.0, RNG.randfRange(-radius, radius))

func _enter_tree() -> void:
	if(Engine.is_editor_hint()):
		return
	World.addPOI(self)

# Surface area
func calcWeight() -> float:
	return PI * radius * radius

@export_tool_button("SNAP TO FLOOR", "Callable") var doSnapToFloor_action = doSnapToFloor
func doSnapToFloor():
	var aRayInfo:Dictionary = Util.castRaySlow(self, to_global(Vector3(0.0, 0.3, 0.0)), to_global(Vector3(0.0, -3.0, 0.0)))
	if(aRayInfo.is_empty()):
		return
	var thePos:Vector3 = aRayInfo["position"]
	
	global_position = thePos + Vector3(0.0, 0.2, 0.0)
