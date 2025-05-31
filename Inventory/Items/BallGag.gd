extends ItemBase

var ballColor:Color = Color("bf0000")

func _init():
	id = "BallGag"

func getName() -> String:
	return "Ball gag"

func getSlot() -> int:
	return InventorySlot.Mouth

func getOptions() -> Dictionary:
	return {
		"ballColor": {
			name = "Ball Color",
			type = "color",
			editors = [EDITOR_INTERACT],
		},
	}
