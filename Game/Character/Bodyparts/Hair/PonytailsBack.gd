extends BodypartHairBase

var bandColor:Color = Color("171717")

func _init():
	super._init()
	id = "PonytailsBack"

func getName() -> String:
	return "Twin ponytails"

func getOptions() -> Dictionary:
	var theOptions := super.getOptions()
	theOptions["bandColor"] = {
		name = "Band color",
		type = "color",
		editors = [EDITOR_PART],
	}
	return theOptions

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/PonytailsBack/ponytails_back.tscn"
