extends BodypartHairBase

var bandColor:Color = Color("171717")

func _init():
	id = "Ponytail3"

func getName() -> String:
	return "Ponytail 3"

func getOptions() -> Dictionary:
	var theOptions := super.getOptions()
	theOptions["bandColor"] = {
		name = "Band color",
		type = "color",
		editors = [EDITOR_PART],
	}
	return theOptions

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/Ponytail3/ponytail_3.tscn"
