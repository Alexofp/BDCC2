extends BodypartHairBase

func _init():
	super._init()
	id = "ShortHair"

func getName() -> String:
	return "Short hair"

func getOptions() -> Dictionary:
	return super.getOptions()

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/ShortHair/short_hair.tscn"
