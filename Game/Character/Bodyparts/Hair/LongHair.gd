extends BodypartHairBase

func _init():
	super._init()
	id = "LongHair"
	mascWeight = 0.1
	femWeight = 1.0
	androWeight = 1.0

func getName() -> String:
	return "Long hair"

func getOptions() -> Dictionary:
	return super.getOptions()

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/LongHair/long_hair.tscn"
