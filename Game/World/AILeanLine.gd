@tool
extends Node3D
class_name AILeanLine

@export var width:float = 2.0

func getRandomSpot() -> Vector3:
	return to_global(Vector3(RNG.randfRange(-width, width), 0.0, 0.0))

func _enter_tree() -> void:
	if(Engine.is_editor_hint()):
		return
	World.addPOI(self)

@export_tool_button("SNAP TO FLOOR", "Callable") var doSnapToFloor_action = doSnapToFloor
func doSnapToFloor():
	var aRayInfo:Dictionary = Util.castRaySlow(self, to_global(Vector3(0.0, 0.3, 0.0)), to_global(Vector3(0.0, -3.0, 0.0)))
	if(aRayInfo.is_empty()):
		return
	var thePos:Vector3 = aRayInfo["position"]
	
	global_position = thePos
	
	var aWallRay:Dictionary = Util.castRaySlow(self, to_global(Vector3(0.0, 0.3, 0.1)), to_global(Vector3(0.0, 0.3, -2.0)))
	if(aWallRay.is_empty()):
		return
	var theWallPos:Vector3 = aWallRay["position"]
	global_position = theWallPos + Vector3(0.0, -0.3, 0.0)
	
@export_tool_button("ROTATE 45 CCW", "Callable") var rotateCCW_action = doRotate45ccw
func doRotate45ccw():
	global_rotation_degrees.y += 45.0
@export_tool_button("ROTATE 45 CW", "Callable") var rotateCW_action = doRotate45cw
func doRotate45cw():
	global_rotation_degrees.y -= 45.0
