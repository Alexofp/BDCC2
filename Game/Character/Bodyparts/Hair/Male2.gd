extends BodypartHairBase

func _init():
	super._init()
	id = "Male2"
	mascWeight = 1.0
	femWeight = 0.02
	androWeight = 1.0

func getName() -> String:
	return "Male hair 2"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/Male2/Male2.tscn"
