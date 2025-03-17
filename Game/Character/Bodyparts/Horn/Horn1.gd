extends BodypartHornBase

func _init():
	id = "Horn1"

func getName() -> String:
	return "Horn 1"

func getScenePath(_slot:String) -> String:
	if(_slot == BodypartSlot.LeftHorn):
		return "res://Mesh/Parts/Horn/Horn1/horn_1l.tscn"
	else:
		return "res://Mesh/Parts/Horn/Horn1/horn_1r.tscn"
