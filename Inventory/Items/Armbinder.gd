extends ItemBase

func _init():
	id = "Armbinder"

func getName() -> String:
	return "Armbinder"

func getSlot() -> int:
	return InventorySlot.Wrists
