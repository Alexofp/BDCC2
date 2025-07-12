extends BodypartHairBase

func _init():
	id = "LongCuteHair"

func getName() -> String:
	return "Long cute hair"

func getOptions() -> Dictionary:
	return super.getOptions()

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/LongCuteHair/long_cute_hair.tscn"
