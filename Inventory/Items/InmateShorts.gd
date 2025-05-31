extends ItemBase

var color1:Color = Color("262626")
var color2:Color = Color("521e00")
var color3:Color = Color("ff6600")
var pulledDown:bool = false

func _init():
	id = "InmateShorts"

func getName() -> String:
	return "Inmate shorts"

func getSlot() -> int:
	return InventorySlot.Bottom

func getOptions() -> Dictionary:
	return {
		"color1": {
			name = "Color 1",
			type = "color",
			editors = [EDITOR_INTERACT],
		},
		"color2": {
			name = "Color 2",
			type = "color",
			editors = [EDITOR_INTERACT],
		},
		"color3": {
			name = "Color 3",
			type = "color",
			editors = [EDITOR_INTERACT],
		},
		"pulledDown": {
			name = "Pulled down",
			type = "bool",
			editors = [EDITOR_INTERACT],
		},
	}
