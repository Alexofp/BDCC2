extends ItemBase

var color:Color = Color.WHITE
var pulledDown:bool = false

func _init():
	id = "PlainBra"

func getName() -> String:
	return "Plain bra"

func getSlot() -> int:
	return InventorySlot.UnderwearTop

func getOptions() -> Dictionary:
	return {
		"color": {
			name = "Color",
			type = "color",
			editors = [EDITOR_INTERACT],
		},
		"pulledDown": {
			name = "Pulled down",
			type = "bool",
			editors = [EDITOR_INTERACT],
		},
	}
