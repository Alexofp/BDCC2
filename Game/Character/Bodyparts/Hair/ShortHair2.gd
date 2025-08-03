extends BodypartHairBase

func _init():
	super._init()
	id = "ShortHair2"

func getName() -> String:
	return "Short hair 2"

func getOptions() -> Dictionary:
	return super.getOptions()

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/ShortHair2/short_hair_2.tscn"
