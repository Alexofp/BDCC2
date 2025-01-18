extends Node3D
class_name DollAttachPoint

@export var pointName:String = ""
@export var skeleton:Skeleton3D

func getSkeleton() -> Skeleton3D:
	return skeleton

func getDoll() -> Doll:
	var result:Node = get_parent()
	
	while(result != null):
		if(result is Doll):
			return result
		result = result.get_parent()
	return null

func _enter_tree() -> void:
	var doll := getDoll()
	
	if(doll == null):
		Log.error("Attach point couldn't find a doll during creation")
		return
	doll.setupAttachPoint(self)

func _exit_tree() -> void:
	var doll := getDoll()
	
	if(doll == null):
		Log.error("Attach point couldn't find a doll during deletion")
		return
	doll.removeAttachPoint(self)
