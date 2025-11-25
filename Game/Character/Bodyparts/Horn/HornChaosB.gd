extends BodypartHornBase

func _init():
	super._init()
	id = "HornChaosB"

func getName() -> String:
	return "Horn of Chaos (broken)"

func getScenePath(_slot:int) -> String:
	if(_slot == BodypartSlot.LeftHorn):
		return "res://Mesh/Parts/Horn/HornChaos/horn_chaos_lb.tscn"
	else:
		return "res://Mesh/Parts/Horn/HornChaos/horn_chaos_rb.tscn"
