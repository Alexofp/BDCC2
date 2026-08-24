extends BodypartHairBase

var bandColor:Color = Color("171717")

func _init():
	super._init()
	id = "Ponytail4"
	mascWeight = 0.02
	femWeight = 1.0
	androWeight = 1.0

func generateFor(_gen:CharacterGenerator):
	super.generateFor(_gen)
	bandColor = _gen.colors.hairBand

func getName() -> String:
	return "Ponytail 4"

func getOptions() -> Dictionary:
	var theOptions := super.getOptions()
	theOptions["bandColor"] = {
		name = "Band color",
		type = "color",
		editors = [EDITOR_PART],
	}
	return theOptions

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/Ponytail4/ponytail_4.tscn"
