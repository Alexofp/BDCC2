extends SexTaskBase

func _init() -> void:
	id = "Default"

func getActionScore(_actionArgs:Array, _taskID:String, _taskArgs:Array, _context:Dictionary) -> float:
	if(_actionArgs == _taskArgs):
		return 1.0
	return 0.0
