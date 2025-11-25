extends BodypartHornBase

func _init():
	super._init()
	id = "HornChaos"

func getName() -> String:
	return "Horn of Chaos"

func getScenePath(_slot:int) -> String:
	if(_slot == BodypartSlot.LeftHorn):
		return "res://Mesh/Parts/Horn/HornChaos/horn_chaos_l.tscn"
	else:
		return "res://Mesh/Parts/Horn/HornChaos/horn_chaos_r.tscn"
