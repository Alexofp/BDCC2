extends BodypartHairBase

func _init():
	super._init()
	id = "LongSideHair"

func getName() -> String:
	return "Long side hair"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/LongSideHair/long_side_hair.tscn"
