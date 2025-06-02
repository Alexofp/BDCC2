extends ItemBase

var color1:Color = Color("262626")
var color2:Color = Color("521e00")
var color3:Color = Color("ff6600")
var pulledUp:bool = false

func _init():
	id = "InmateTop"

func getName() -> String:
	return "Inmate top"

func getSlot() -> int:
	return InventorySlot.Top

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
		"pulledUp": {
			name = "Pulled up",
			type = "bool",
			editors = [EDITOR_INTERACT],
		},
	}

func getSexHideTags() -> Dictionary:
	return {
		SexHideTag.CoversBreasts: !pulledUp,
	}
