extends ItemBase

var color:Color = Color.WHITE
var shifted:bool = false

func _init():
	id = "PlainPanties"

func getName() -> String:
	return "Plain panties"

func getSlot() -> int:
	return InventorySlot.UnderwearBottom

func getOptions() -> Dictionary:
	return {
		"color": {
			name = "Color",
			type = "color",
			editors = [EDITOR_INTERACT],
		},
		"shifted": {
			name = "Shifted to the side",
			type = "bool",
			editors = [EDITOR_INTERACT],
		},
	}

func getSexHideTags() -> Dictionary:
	return {
		SexHideTag.CoversPenis: !shifted,
		SexHideTag.CoversVagina: !shifted,
		SexHideTag.CoversAnus: !shifted,
	}
