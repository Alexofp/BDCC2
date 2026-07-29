extends BodypartHairBase

var bandColor:Color = Color("171717")

func _init():
	super._init()
	id = "Ponytail1"

func generateFor(_gen:CharacterGenerator):
	super.generateFor(_gen)
	bandColor = _gen.colors.hairBand

func getName() -> String:
	return "Ponytail 1"

func getOptions() -> Dictionary:
	var theOptions := super.getOptions()
	theOptions["bandColor"] = {
		name = "Band color",
		type = "color",
		editors = [EDITOR_PART],
	}
	return theOptions

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/Ponytail1/ponytail1.tscn"
