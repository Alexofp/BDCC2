extends BodypartHairBase

func _init():
	super._init()
	id = "Male4"
	mascWeight = 1.0
	femWeight = 0.02
	androWeight = 1.0

func getName() -> String:
	return "Male hair 4"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/Male4/Male4.tscn"
