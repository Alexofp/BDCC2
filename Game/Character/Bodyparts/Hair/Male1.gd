extends BodypartHairBase

func _init():
	super._init()
	id = "Male1"
	mascWeight = 1.0
	femWeight = 0.02
	androWeight = 1.0

func getName() -> String:
	return "Male hair 1"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/Male1/Male1.tscn"
