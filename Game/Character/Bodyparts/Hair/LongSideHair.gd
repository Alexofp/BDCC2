extends BodypartHairBase

func _init():
	super._init()
	id = "LongSideHair"
	mascWeight = 0.1
	femWeight = 1.0
	androWeight = 1.0

func getName() -> String:
	return "Long side hair"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/LongSideHair/long_side_hair.tscn"
