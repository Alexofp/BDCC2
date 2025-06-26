extends Node3D
class_name Control3D

func _process(_delta: float) -> void:
	processPos.call_deferred()
	
func processPos():
	var theCam := get_viewport().get_camera_3d()
	if(!theCam):
		visible = false
		return
	if(theCam.is_position_behind(global_position)):
		visible = false
		return
	visible = true
	var thePos := theCam.unproject_position(global_position)
	for theChild in get_children():
		if(theChild is Control):
			var theFinalPos := thePos
			theFinalPos.x -= theChild.size.x/2.0
			theChild.position = theFinalPos
