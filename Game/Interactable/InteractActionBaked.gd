extends RefCounted
class_name InteractActionBaked

@export var name:String = "New action"
@export var uniqueID:int = 0
@export var disabled:bool = false

func getName() -> String:
	return name
