extends BodypartHairBase

func _init():
	super._init()
	id = "SideHair"
	mascWeight = 0.03
	femWeight = 1.0
	androWeight = 1.0

func getName() -> String:
	return "Side hair"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/SideHair/side_hair.tscn"
