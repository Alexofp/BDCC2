extends BodypartHairBase

func _init():
	id = "SideHair"

func getName() -> String:
	return "Side hair"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/SideHair/side_hair.tscn"
