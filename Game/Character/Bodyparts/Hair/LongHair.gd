extends BodypartHairBase

func _init():
	super._init()
	id = "LongHair"

func getName() -> String:
	return "Long hair"

func getOptions() -> Dictionary:
	return super.getOptions()

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/LongHair/long_hair.tscn"
