extends BodypartHairBase

func _init():
	super._init()
	id = "LongCuteHair"
	mascWeight = 0.01
	femWeight = 1.0
	androWeight = 0.2

func getName() -> String:
	return "Long cute hair"

func getOptions() -> Dictionary:
	return super.getOptions()

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/LongCuteHair/long_cute_hair.tscn"
