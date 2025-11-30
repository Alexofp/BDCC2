extends BodypartHairBase

func _init():
	super._init()
	id = "LongChaosHair"

func getName() -> String:
	return "Long chaotic hair"

func getOptions() -> Dictionary:
	return super.getOptions()

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/LongChaosHair/long_chaos_hair.tscn"
