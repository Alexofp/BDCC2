extends BodypartHairBase

var bowColor:Color = Color("ff65ff")
var bowHide:bool = false

func _init():
	super._init()
	id = "LongHairBow"

func getName() -> String:
	return "Long hair (Bow)"

func getOptions() -> Dictionary:
	var theOptions := super.getOptions()
	theOptions["bowColor"] = {
		name = "Bow color",
		type = "color",
		editors = [EDITOR_PART],
	}
	theOptions["bowHide"] = {
		name = "Hide bow",
		type = "bool",
		editors = [EDITOR_PART],
	}
	return theOptions

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/LongHairBow/long_hair_bow.tscn"
